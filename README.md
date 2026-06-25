# AWS Scalable Web Infrastructure with Terraform and GitLab CI/CD

## Project Overview

This project shows how I built and deployed scalable AWS infrastructure using Terraform and GitLab CI/CD.

The main goal was to practice real-world Infrastructure as Code skills. I used Terraform to create AWS networking, servers, a database, storage, security, DNS, HTTPS, and CI/CD automation.

The infrastructure was deployed successfully through a GitLab CI/CD pipeline. I also tested Auto Scaling by using `stress-ng` to increase CPU usage on an EC2 instance. This showed that the environment could add more EC2 instances when demand increased and remove them when demand went back down.

---

## Table of Contents

- [Architecture](#architecture)
- [Current Infrastructure Design](#current-infrastructure-design)
- [AWS Services Used](#aws-services-used)
- [Tools and Technologies](#tools-and-technologies)
- [GitLab CI/CD Pipeline](#gitlab-cicd-pipeline)
- [Auto Scaling Test](#auto-scaling-test)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Skills Demonstrated](#skills-demonstrated)
  
---

## Architecture

The Application Load Balancer and EC2 instances are deployed in public subnets. The RDS database is deployed in private subnets for better security.

```mermaid
flowchart LR
    User[User] --> Route53[Route53 DNS]
    Route53 --> ALB[Application Load Balancer]
    ACM[ACM SSL/TLS Certificate] --> ALB

    ALB --> ASG[Auto Scaling Group]

    subgraph AWS[AWS Cloud]
        subgraph VPC[Custom VPC]
            subgraph Public[Public Subnets]
                ALB
                ASG
                EC2A[EC2 Instance]
                EC2B[EC2 Instance]
            end

            subgraph Private[Private Subnets]
                RDS[(RDS Database)]
            end
        end

        S3[S3 Bucket]
        IAM[IAM Role / Instance Profile]
    end

    ASG --> EC2A
    ASG --> EC2B

    EC2A --> RDS
    EC2B --> RDS

    EC2A --> S3
    EC2B --> S3

    IAM --> EC2A
    IAM --> EC2B
```

---

## Current Infrastructure Design

This project uses the following setup:

* The Application Load Balancer is placed in public subnets.
* EC2 instances run in public subnets inside an Auto Scaling Group.
* The RDS database runs in private subnets.
* Security groups control traffic between the load balancer, EC2 instances, and RDS.
* Route53 points the domain name to the Application Load Balancer.
* ACM provides the SSL/TLS certificate for HTTPS.
* The Auto Scaling Group adds or removes EC2 instances based on demand.
* Terraform state is stored remotely in an S3 backend.
* An S3 bucket is also created as part of the infrastructure.

---

## AWS Services Used

This project creates the following AWS resources:

* VPC
* Public subnets
* Private subnets
* Internet Gateway
* NAT Gateway
* Route tables
* Security groups
* Application Load Balancer
* Target Group
* HTTP listener
* HTTPS listener
* ACM SSL/TLS certificate
* Route53 DNS record
* Launch Template
* Auto Scaling Group
* EC2 instances
* IAM role
* IAM instance profile
* S3 bucket
* RDS database
* Remote Terraform state using an S3 backend

---

## Tools and Technologies

* Terraform
* AWS
* GitLab CI/CD
* Linux
* Bash
* Apache
* stress-ng

---

## Project Goals

The main goals of this project were to:

* Build AWS infrastructure using Terraform.
* Create reusable Terraform modules.
* Keep the environments separate from reusable modules.
* Deploy infrastructure automatically with GitLab CI/CD.
* Store Terraform state remotely.
* Build a load-balanced web environment.
* Set up an Auto Scaling Group.
* Test Auto Scaling using CPU stress testing.

---

## Repository Structure

```text
.
├── .gitignore
├── .gitlab-ci.yml
├── README.md
├── docs
│   └── screenshots
└── terraform
    ├── environment
    │   └── dev
    │       ├── backend.tf
    │       ├── main.tf
    │       ├── outputs.tf
    │       ├── terraform.tf
    │       ├── variables.tf
    │       └── versions.tf
    ├── modules
    │   ├── IAM
    │   ├── acm
    │   ├── auto_scaling
    │   ├── key_pair
    │   ├── launch_template
    │   ├── lb
    │   ├── network
    │   ├── rds
    │   ├── route53
    │   └── s3
    └── scripts
        └── apache2.sh
```

---

## Terraform Module Overview

The infrastructure is built with reusable Terraform modules. Each module is responsible for one part of the setup.

### Network Module

The network module creates the main AWS networking resources.

Resources created:

* VPC
* Public subnets
* Private subnets
* Internet Gateway
* NAT Gateway
* Public route table
* Private route tables
* Route table associations

### Security Groups Module

The security groups module creates separate security groups for each infrastructure resource.

Security groups created:

* Load balancer security group
* EC2 security group
* RDS security group

### Load Balancer Module

The load balancer module creates the public entry point for the web application.

Resources created:

* Application Load Balancer
* Target Group
* HTTP listener
* HTTPS listener
* HTTP to HTTPS redirect

### Launch Template Module

The launch template module defines how EC2 instances are created.

The configuration includes:

* Ubuntu AMI
* Instance type
* SSH key pair
* IAM instance profile
* Security group
* User data script
* Instance metadata settings

### Auto Scaling Module

The Auto Scaling module creates the EC2 Auto Scaling Group.

Resources created:

* Auto Scaling Group
* Target tracking scaling policy
* Load balancer target group attachment

I tested the Auto Scaling Group with `stress-ng` to increase CPU usage and trigger scaling events.

### RDS Module

The RDS module creates the database layer.

Resources created:

* RDS database instance
* DB subnet group

The RDS database is placed in private subnets.

### S3 Module

The S3 module creates an S3 bucket used by the infrastructure or application.

### ACM Module

The ACM module creates and validates an SSL/TLS certificate using AWS Certificate Manager.

### Route53 Module

The Route53 module creates a DNS alias record that points to the Application Load Balancer.

### IAM Module

The IAM module creates an IAM role and instance profile for the EC2 instances.

---

## GitLab CI/CD Pipeline

This project uses GitLab CI/CD to automate the Terraform deployment.

The pipeline has these stages:

```text
validate
plan
apply
destroy
```

### Pipeline Workflow

1. Code is pushed to the repository.
2. GitLab CI/CD starts the Terraform pipeline.
3. Terraform initializes the backend and providers.
4. Terraform checks that the configuration is valid.
5. Terraform creates an execution plan.
6. Terraform applies the changes and creates the infrastructure.
7. Terraform destroy can be run when the infrastructure is no longer needed.

---

## GitLab CI/CD Variables

Sensitive values are stored in GitLab CI/CD variables. They are not committed to the repository.

Example variables used by the pipeline:

```text
MY_AWS_ACCESS_KEY_ID
MY_AWS_SECRET_ACCESS_KEY
db_username
db_password
PUB_KEY
```

AWS credentials, database passwords, and other secrets should always be stored securely in GitLab CI/CD variables.

---

## Deployment Evidence

The infrastructure was successfully created using the GitLab CI/CD pipeline.

Screenshots were taken to show the deployment process and the AWS resources created by Terraform.

Evidence captured includes:

* Successful GitLab pipeline stages
* Terraform validate stage
* Terraform plan stage
* Terraform apply stage
* AWS VPC resources
* Public subnets
* Private subnets
* Application Load Balancer
* Target Group
* Auto Scaling Group
* EC2 instances
* RDS database
* S3 bucket
* Route53 DNS record
* ACM certificate
* Auto Scaling scale-out behavior
* Auto Scaling scale-in behavior

Screenshots are stored in:

```text
docs/screenshots/
```

---

## Screenshots

### GitLab Pipeline Success

![GitLab Pipeline Success](docs/screenshots/branch_pipeline.png)

### Terraform Validate Stage

![Terraform Validate Stage](docs/screenshots/tf_validate.png)

### Terraform Plan Stage

![Terraform Plan Stage](docs/screenshots/tf_plan.png)

### Terraform Apply Stage

![Terraform Apply Stage](docs/screenshots/tf_apply.png)

### Terraform Destroy Stage

![Terraform Destroy Stage](docs/screenshots/tf_destroy.png)

### AWS VPC Resources

![AWS VPC Resources](docs/screenshots/vpc.png)

### Public and Private Subnets

![AWS Subnets](docs/screenshots/subnets.png)

### Application Load Balancer

![Application Load Balancer](docs/screenshots/lb.png)

### Launch Template

![Launch template](docs/screenshots/launch_template.png)

### Auto Scaling Group

![Auto Scaling Group](docs/screenshots/autoscaling.png)

### EC2 Instances

![EC2 Instances](docs/screenshots/ec2.png)

### RDS Database

![RDS Database](docs/screenshots/db.png)

### S3 Bucket

![S3 Bucket](docs/screenshots/s3.png)

### Route53 Record

![Route53 Record](docs/screenshots/route53.png)

### ACM Certificate

![ACM Certificate](docs/screenshots/acm.png)

### Auto Scaling Scale-Out Event

![Auto Scaling Scale Out](docs/screenshots/autoscaling-scale-out.png)

### Auto Scaling Scale-In Event

![Auto Scaling Scale In](docs/screenshots/autoscaling-scale-in.png)

---

## Auto Scaling Test

To test Auto Scaling, I used `stress-ng` on an EC2 instance to increase CPU usage.

Example command:

```bash
stress-ng --cpu 2 --cpu-load 90 --timeout 10m --metrics-brief
```

![stress-ng](docs/screenshots/stress_cpu_testing.png)

The CPU usage increased, which caused the Auto Scaling Group to launch more EC2 instances.

![ec2](docs/screenshots/cpu_utilization.png)

After the CPU usage dropped, the Auto Scaling Group reduced the number of running EC2 instances based on the scaling policy.

![cpu increased](docs/screenshots/ec2_terminated.png)

This test showed that the infrastructure can respond automatically when demand changes.

---

## Remote Terraform State

This project uses a remote Terraform backend.

Instead of storing Terraform state locally, the state file is stored in an S3 bucket.

Using remote state helps with:

* Better state management
* Team collaboration
* Keeping state available after local files are removed
* Safer infrastructure management

---

## Security Considerations

This project includes several security-focused choices:

* Infrastructure is managed with Terraform.
* Terraform state is stored remotely.
* Security groups are separated by resource type.
* RDS is deployed in private subnets.
* HTTPS is enabled with AWS Certificate Manager.
* IAM roles are used for EC2 permissions.
* Sensitive values are passed through GitLab CI/CD variables.
* Database credentials are not committed to the repository.

---

## Troubleshooting

One big problem I had while working on this project was that my IaC kept terminating EC2 instances and launching new ones over and over. 
At first, I thought the Auto Scaling Group was scaling because the CPU usage was too high, so I checked the CloudWatch metrics. The CPU usage was only around 40%, so it was not the issue.

![instances_issues](docs/screenshots/instances_issues.png)

![cpu](docs/screenshots/cpu.png)

Next, I checked the AutoScaling Group activity history. I saw that the instances were being replaced because they failed an ELB health check. 
After checking the ALB target group, I found out that the EC2 instances were marked as unhealthy.
The issue was that the target group health check was using HTTP on port 80, but I hadn't deployed the application yet. Since nothing was running on port 80, the health checks failed.

![history](docs/screenshots/history.png)

![tg](docs/screenshots/tg.png)

Because the instances failed the ALB health checks, the Auto Scaling Group treated them as unhealthy and kept replacing them. 
To fix this during deployment, I increased the AutoScaling Group `health_check_grace_period` from 300 seconds to 600 seconds. 
This gave me enough time to deploy the app and start the service before AutoScaling responded to the failed health checks.

## Skills Demonstrated

This project shows hands-on experience with:

* Infrastructure as Code
* Terraform module design
* AWS networking
* VPC architecture
* Public and private subnet design
* Route tables
* NAT Gateway setup
* Application Load Balancing
* Auto Scaling
* EC2 provisioning
* RDS provisioning
* S3 setup
* IAM roles and instance profiles
* Route53 DNS setup
* ACM certificate setup
* GitLab CI/CD
* Remote Terraform state
* Linux administration
* Bash scripting
* Cloud infrastructure troubleshooting
* Scalability testing

---

## Author

Created by Oj Mendes
