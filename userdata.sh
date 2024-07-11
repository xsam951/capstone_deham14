#! /bin/bash

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

# Retrieve the temporary root password
temp_password=$(sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

# Set the desired root password
DBRootPassword='root@258!Password'

# Change the root password using the temporary password
mysql -u root -p"$temp_password" --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DBRootPassword';"

# Install PHP
sudo amazon-linux-extras install -y php7.4

# Update all installed packages
sudo yum update -y

# Restart Apache
sudo systemctl restart httpd

# define variables
DBName="deham14"
DBUser="admin"
DBPassword="PassWord%123"
RDS_ENDPOINT="localhost"
WPDir="/var/www/html"


# Create MySQL user and grant permissions
mysql -u root -p"$DBRootPassword" -e "CREATE DATABASE IF NOT EXISTS $DBName;"
mysql -u root -p"$DBRootPassword" -e "CREATE USER IF NOT EXISTS '$DBUser'@'%' IDENTIFIED BY '$DBPassword';"
mysql -u root -p"$DBRootPassword" -e "GRANT ALL PRIVILEGES ON $DBName.* TO '$DBUser'@'%';"
mysql -u root -p"$DBRootPassword" -e "FLUSH PRIVILEGES;"

# Install WordPress
sudo wget http://wordpress.org/latest.tar.gz -P $WPDir

# Extract WordPress files
cd $WPDir
sudo tar -zxvf latest.tar.gz
sudo cp -rvf wordpress/* .

# Clean up
sudo rm -R wordpress
sudo rm latest.tar.gz

# Copy wp-config.php file to wordpress directory
sudo cp ./wp-config-sample.php ./wp-config.php
sudo sed -i "s/'database_name_here'/'$DBName'/g" wp-config.php
sudo sed -i "s/'username_here'/'$DBUser'/g" wp-config.php
sudo sed -i "s/'password_here'/'$DBPassword'/g" wp-config.php
sudo sed -i "s/'localhost'/'$RDS_ENDPOINT'/g" wp-config.php

sudo mysql -h "$RDS_ENDPOINT" -u "$DBUser" -p"$DBPassword" "$DBName" -e "SHOW DATABASES;"

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

# download wp-files from s3 bucket
sudo -u ec2-user aws s3 sync s3://${bucket_name}/ $WPDir

# Find the latest mysql backup file
LatestBackup=$(ls -t $WPDir/*_db_backup.sql | head -n 1)

# Restore the database from the latest backup
mysql -u root -p"$DBRootPassword" "$DBName" < "$LatestBackup"

# Update the database with the new site URL
IP_ADDRESS=$(curl -s http://checkip.amazonaws.com)
mysql -u root -p"$DBRootPassword" $DBName -e "UPDATE wp_options SET option_value = 'http://$IP_ADDRESS' WHERE option_name = 'siteurl' OR option_name = 'home';"

# Restart Apache
sudo systemctl restart httpd

# create an upload-script
echo "#!/bin/bash" > /home/ec2-user/upload.sh
echo "DBRootPassword='$DBRootPassword'" >> /home/ec2-user/upload.sh
echo "DBName='$DBName'" >> /home/ec2-user/upload.sh
echo 'sudo mysqldump -u root -p"$DBRootPassword" "$DBName" > /var/www/html/$(date -d "+2 hours" +\%F-\%H\%M)_db_backup.sql' >> /home/ec2-user/upload.sh
echo 'sudo -u ec2-user aws s3 sync /var/www/html/ s3://'${bucket_name}'/' >> /home/ec2-user/upload.sh

chmod 755 /home/ec2-user/upload.sh