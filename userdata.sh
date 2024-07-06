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

# Retrieve RDS endpoint from Terraform output
DBName="deham14"
DBUser="admin"
DBPassword="PassWord%123"
RDS_ENDPOINT="localhost"

# Create MySQL user and grant permissions
mysql -u root -p"$DBRootPassword" -e "CREATE DATABASE IF NOT EXISTS $DBName;"
mysql -u root -p"$DBRootPassword" -e "CREATE USER IF NOT EXISTS '$DBUser'@'%' IDENTIFIED BY '$DBPassword';"
mysql -u root -p"$DBRootPassword" -e "GRANT ALL PRIVILEGES ON $DBName.* TO '$DBUser'@'%';"
mysql -u root -p"$DBRootPassword" -e "FLUSH PRIVILEGES;"

# Create a temporary file to store the database value
sudo touch db.txt
sudo chmod 777 db.txt
sudo echo "DATABASE $DBName;" >> db.txt
sudo echo "USER $DBUser;" >> db.txt
sudo echo "PASSWORD $DBPassword;" >> db.txt
sudo echo "HOST $RDS_ENDPOINT;" >> db.txt


sudo yum install -y wget
sudo wget http://wordpress.org/latest.tar.gz -P /var/www/html/

cd /var/www/html
sudo tar -zxvf latest.tar.gz
sudo cp -rvf wordpress/* .

sudo rm -R wordpress
sudo rm latest.tar.gz

echo "Terraform output:"

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