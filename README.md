# Connect to a private EC2 instance using session manager from a Custom VPC built with terraform.

We will be using Terraform to build the custom VPC, private and public subnets, nat gateways, route tables and private instances we will connect to.


## Steps

Log into AWS Console, create an IAM role and attach the AmazonSSMManagedInstanceCore permission policy, it enables AWS Systems Manager service core functionality.

Clone the repo

Update the iam_instance_profile = "iam_role_created"

It will use aws default profile configured on your system to run terraform

run terraform init

run terraform apply --auto-approve

Connect to instance using the Systems manager, install yum install httpd to test it out

Clean up resources by running terraform destroy --auto-approve

