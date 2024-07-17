# capstone_deham14
## My capstone project
### using terraform to create a wordpress website in a highly available and scalable environment in AWS

The infrastructure so far includes:

- 1 VPC - Virtual Private Cloud
- 2 Public Subnets
- 1 initail EC2 with a Security Group allowing http and ssh traffic
- 1 ELB - Elastic Load Balancer
- 1 Auto-Scaling Group with 1-4 EC2 instances
