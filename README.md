# capstone_deham14
## My capstone project
### using terraform to create a wordpress website in a highly available and scalable environment in AWS

The infrastructure includes:

- 1 VPC - Virtual Private Cloud
- 2 Public Subnets
- 2 Private Subnets
- 1 NAT Gateway with Elastic IP in Public Subnet 2
- 3 Security Groups
  - ELB-SG - allowing only http traffic from everywhere
  - webserver-SG - allowing http from ELB-SG only and ssh from local IP only
  - RDS-SG - allowing mysql from webserver-SG only
- 1 ELB - Elastic Load Balancer in public subnets
- 1 Auto-Scaling Group for EC2 instances (min 2, desired 2, max 4) in private subnets
- UserData - a shell script that runs on EC2 startup
  - installing WordPress
  - fetching Website data from external S3
- 2 RDS - Relational Database Service
  - one backup RDS in an other Availability Zone

[To the presentation](https://github.com/xsam951/capstone_deham14/raw/presentation/capstone_presentation_samuel_tadrissi.pdf)
