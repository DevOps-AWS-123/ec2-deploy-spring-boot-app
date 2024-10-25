aws_vpc        = "10.1.0.0/16"
public_subnet  = "10.1.1.0/24"
private_subnet = "10.1.2.0/24"
aws_region     = "us-east-1"
tags = {
  Environment = "prod"
  Project     = "VPC-Dynamic"
}
ami_id          = "ami-0866a3c8686eaeeba"  # Example for Ubuntu 20.04 in us-west-2
instance_type   = "t2.micro"
key_name        = "terraform-key"
public_subnet_id = "subnet-0123456789abcdef0"