# Terraform-EC2-Instances

This repo is used to deploy EC2 instances on your AWS account using Terraform. It creates a custom VPC, Security Group, Private and Public Subnet (you will need to specify), Internet Gateway, NAT Gateway, Route Tables fetches latest AMI-ID using aws_ssm_parametar data block and deploys EC2 instances using these parametars. 

This code will work regardless of the region and the number of instances.

Variables: 

           - aws_region - for selecting Region

           - instance_count - for selecting the number of Instances created

           - instance_type - for selecting the Instance Type

           - rules -  for defining the rules of the Secutiy Group
           
           - availability_zone_index - for selecting the Availability Zone
           

To run this code on your machine and target your AWS account you need to:

1. Install the Terraform CLI on your machine: https://developer.hashicorp.com/terraform/downloads

2. Configure your AWS credentials: Before you can interact with your AWS account through Terraform, you need to configure your AWS access and secret access keys. You can do this by creating an AWS IAM user with the necessary permissions and configuring the access keys on your machine using the AWS CLI or manually configuring them in the ~/.aws/credentials file.

3. Initialise the working directory: Navigate to where the Terraform EC2 Modules directory is located and run terraform init to initialise the working directory. This will download the necessary providers and modules.

4. Confugre AWS SSO: if you haven't configured your AWS SSO credentials yet run: aws configure sso to configure the SSO parametars. Next, run aws sso login --profile {your profile} to login with your SSO credentials. And finally, run: export AWS_PROFILE={your profile} to set it as a default profile when logging in with terraform.  

5. Preview the changes: Run terraform plan to preview the changes that Terraform will make to your AWS account based on the configuration in your .tf files.

6. Apply the changes: If you are satisfied with the changes that Terraform will make, run terraform apply to apply the changes to your AWS account.

