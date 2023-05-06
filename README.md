# **AWS-Terraform-Module!**

![Capture](https://user-images.githubusercontent.com/104639044/235067873-e71bfba4-d5a5-469d-836d-47fe9763ff3e.PNG)

## Pre-requisites:

1. AWS account
2. AMI user
3. AWS services - basic knowledge of VPC, EC2, ALB, Auto scaling, RDS
4. Code editor (I used VS code)
5. Terraform installed on Linux server
6. Terraform basics

In this tutorial, I am going to use most of the Terraform essential features such as

1. Variables -----> Useful to make our code dynamic
2. Modules -----> Useful to make terraform code DRY and provisioning of 'n' number of resources with a single module
3. outputs -----> Useful in provisioning other resources as inputs
4. Data source -----> Useful in provisioning resources as it dynamically provides the required data using APIs (enables us to use already existing resources)
5. Lifecycle block -----> Its a check on the infra's health before destroying any resources

The idea is to provision a 2-tier model in custom vpc with 2 public subnets and 2 private subnets. All 4 of them will be in 2 different zones using Terraform. I will also provision 2 application servers/EC2 instances in those public subnets and 2 RDS mysql servers in private subnets along with the Application load balancer and autoscaling feature.

# Modules

A Terraform module is nothing more than a directory of Terraform scripts. Modules are most useful as a reuse structure that allows the instantiation of a single deployment pattern across multiple environments and applications. Modules are useful in reducing the time to write the terraform files to provision resources, in other words with modules we can create several resources such as 'n' number of VPC, ec2 etc with a single code base

## 1. VPC Module

VPC creates an isolated network/data center to provision servers for our application. In the code base, I have created a folder 'vpc' where I have created 3 files main.tf, variables.tf and outputs.tf. In main.tf i have written terraform code to create

a. VPC

b. Internet gateway

c. One public route table, One private route table

d. 2 public subnets and 2 private subnets

e. Public and private Route table association for both public and private subnets

f. Security group for VPC

## 2. EC2 Module

EC2 is an Iaas service that AWS provides that enables us to run the application over the cloud. Under the ec2 module, i have a main.tf file where I have used the "aws_ami" data source to get the latest Ubuntu image and used that to create 2 instances in 2 public subnets that I created in the VPC module. Please refer to the code base that I provided at the end.

## 3. ALB Module

The load balancer is the one who balances the load of the application with the target groups. Under alb folder, i have a file main.tf in which I have created

a. Target Group settings with Health check settings. In target group settings I have set up a health check of the target group that is attached to the ALB.

b. Application load balancer with subnets attached to it (used the subnets that I have created in vpc module).

c. Attached the instances that are created in EC2 module to the target group

d. Security group (created in vpc module)

## 4. Auto-Scaling

The name itself specifies that AWS auto-scaling will scale the application's capacity based on the load. When CPU utilization increases it will automatically spin up the instances for us and also scale-in the application when there is less CPU utilization. This autoscale will rely on the health check of the ALB that was created in the previous step.

## 5. RDS - Mysql
