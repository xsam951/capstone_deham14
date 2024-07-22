#! /bin/bash -eux

# # Install updates
sudo yum update -y

# Configure AWS CLI with IAM role credentials
aws configure set default.region us-west-2

# Install required packages
sudo amazon-linux-extras install epel -y

# Install stress-ng tool
sudo yum install -y stress-ng

#Install httpd
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# Install MySQL
# Download and install MySQL community release package
sudo wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
sudo yum localinstall -y mysql57-community-release-el7-11.noarch.rpm

# Import GPG key
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022

# Update repository metadata
sudo yum clean all
sudo yum makecache

# Install MySQL server
sudo yum install -y mysql-community-server

# Start and enable MySQL service
sudo systemctl start mysqld.service
sudo systemctl enable mysqld.service

# Install PHP
sudo amazon-linux-extras install -y php7.4

# Update all installed packages
sudo yum update -y

# Restart Apache
sudo systemctl restart httpd

# define variables
DBName=${rds_db_name}
DBUser=${rds_username}
DBPassword=${rds_password}
DBHost=${rds_endpoint}
WPDir="/var/www/html"

# Install WordPress
sudo wget http://wordpress.org/latest.tar.gz -P $WPDir

# Extract WordPress files
cd $WPDir
sudo tar -zxvf latest.tar.gz
sudo cp -rvf wordpress/* .

# Clean up
sudo rm -R wordpress
sudo rm latest.tar.gz

#Install PHP Extensions
#sudo amazon-linux-extras enable php7.4
sudo yum clean metadata
sudo yum install -y php-cli php-pdo php-fpm php-json php-mysqlnd

# Restart Apache
sudo systemctl restart httpd

# Create credentials and config files and set ownershipt and permissions
sudo mkdir /home/ec2-user/.aws
sudo touch /home/ec2-user/.aws/credentials /home/ec2-user/.aws/config
sudo chmod 600 /home/ec2-user/.aws/credentials /home/ec2-user/.aws/config
sudo chmod 755 /home/ec2-user/.aws
sudo chown ec2-user:ec2-user /home/ec2-user/.aws -R

# Configure AWS credentials
sudo echo "[default]" > /home/ec2-user/.aws/credentials
sudo echo "aws_access_key_id=${access_key}" >> /home/ec2-user/.aws/credentials
sudo echo "aws_secret_access_key=${secret_key}" >> /home/ec2-user/.aws/credentials
sudo echo "aws_session_token=${session_token}" >> /home/ec2-user/.aws/credentials

# Configure AWS config
sudo echo "[default]" > /home/ec2-user/.aws/config
sudo echo "output = json" >> /home/ec2-user/.aws/config
sudo echo "region = ${region}" >> /home/ec2-user/.aws/config

# change owner of wordpress directory
sudo chown -R ec2-user:ec2-user $WPDir

TempDir="/tmp/backup"

# create temporary directory
mkdir -p $TempDir
sudo chown -R ec2-user:ec2-user $TempDir

# get latest backup
LatestWPBackup=$(sudo -u ec2-user aws s3 ls s3://${bucket_name}/ | grep wp_backup | sort -r | head -n 1 | awk '{print $4}')   

# Download the latest backup file from S3
sudo -u ec2-user aws s3 cp s3://${bucket_name}/$LatestWPBackup $TempDir/$LatestWPBackup

# Decompress backup file
cd $TempDir
rm -rf $WPDir/*
sudo -u ec2-user tar -xzf $LatestWPBackup -C $WPDir
rm -rf $TempDir/$LatestWPBackup


# update the elb_dns in wp-config
sudo sed -i "s/define( 'DB_NAME', .*/define( 'DB_NAME', '$DBName' );/" "$WPDir/wp-config.php"
sed -i "s/define( 'DB_USER', .*/define( 'DB_USER', '$DBUser' );/" "$WPDir/wp-config.php"
sed -i "s/define( 'DB_PASSWORD', .*/define( 'DB_PASSWORD', '$DBPassword' );/" "$WPDir/wp-config.php"
sed -i "s/define( 'DB_HOST', .*/define( 'DB_HOST', '$DBHost' );/" "$WPDir/wp-config.php"

# Find the latest mysql backup file
LatestDBBackup=$(ls -t $WPDir/*_db_backup.sql | head -n 1)

# Restore the database from the latest backup
mysql -h $DBHost -P 3306 -u $DBUser -p"$DBPassword" $DBName < "$LatestDBBackup"

# Update the database with the new site URL
NewIP="${elb_dns}"

# Fetch the old URL from the database
OldURL=$(mysql -h $DBHost -P 3306 -u $DBUser -p$DBPassword $DBName -N -e "SELECT CONCAT('http://', SUBSTRING_INDEX(SUBSTRING_INDEX(option_value, '/', 3), '://', -1)) AS OldURL FROM wp_options WHERE option_name = 'siteurl' OR option_name = 'home' LIMIT 1;")

# Update WordPress database URLs
mysql -h $DBHost -P 3306 -u $DBUser -p"$DBPassword" $DBName <<EOF
UPDATE wp_options SET option_value = 'http://$NewIP' WHERE option_name = 'siteurl' OR option_name = 'home';
UPDATE wp_posts SET guid = REPLACE(guid, '$OldURL', 'http://$NewIP');
UPDATE wp_posts SET post_content = REPLACE(post_content, '$OldURL', 'http://$NewIP');
UPDATE wp_postmeta SET meta_value = REPLACE(meta_value, '$OldURL', 'http://$NewIP');
UPDATE wp_options SET option_value = REPLACE(option_value, '$OldURL', 'http://$NewIP') WHERE option_name IN ('home', 'siteurl');
EOF

sudo rm -rf $LatestDBBackup

# Clean up temporary files
rm -rf $TempDir

# Create an upload script
cat <<EOL > /home/ec2-user/upload.sh
#!/bin/bash
DBName='$DBName'
DBUser='$DBUser'
DBPassword='$DBPassword'
DBHost='$DBHost'
S3Bucket='${bucket_name}'
TempDir='/tmp/backup'
WPDir='$WPDir'
sudo chown -R ec2-user:ec2-user \$WPDir
sudo mysqldump -h \$DBHost -P 3306 -u \$DBUser -p"\$DBPassword" "\$DBName" > \$WPDir/\$(date -d "+2 hours" +\%F-\%H\%M)_db_backup.sql
BackupFilename="wp_backup_\$(date -d "+2 hours" +\%F-\%H\%M).tar.gz"
mkdir -p \$TempDir
tar -czf \$TempDir/\$BackupFilename -C \$WPDir .
sudo -u ec2-user aws s3 cp \$TempDir/\$BackupFilename s3://\$S3Bucket/
rm -rf \$TempDir
sudo chown -R apache:apache \$WPDir
EOL

sudo chmod 755 /home/ec2-user/upload.sh

# change owner of wordpress directory
sudo chown -R apache:apache $WPDir

# Restart Apache
sudo systemctl restart httpd