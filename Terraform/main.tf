provider aws{
    region = "us-east-2"
}

resource "aws_s3_bucket" "webapps3mybucket12"{
    bucket = "webapps3mybucket12"
}

# Define the IAM role resource
resource "aws_iam_role" "ec2_role" {
  name               = "my-ec2-role"  # Replace with your desired role name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach the AmazonSSMManagedInstanceCore policy to the IAM role
resource "aws_iam_policy_attachment" "ssmpolicy_attachment" {
  name       = "ssm_policy_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach the AmazonS3ReadOnlyAccess policy to the IAM role
resource "aws_iam_policy_attachment" "s3_policy_attachment" {
  name       = "s3_policy_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

// vpc creation
# Define the VPC resource
resource "aws_vpc" "webapp_vpc" {
  cidr_block = "10.0.0.0/16"  # Specify the CIDR block for the VPC (replace with your desired CIDR block)
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "mywebapp-vpc"  # Replace with your desired VPC name
  }
}

resource "aws_subnet" "subnet_az1"{
    count = 3
    vpc_id = aws_vpc.webapp_vpc.id
    cidr_block = cidrsubnet(aws_vpc.webapp_vpc.cidr_block, 8,count.index)
    availability_zone = "us-east-2b"
    tags={
        Name = count.index == 0 ? "public-web-subnet-az2" : count.index == 1 ? "private-app-subnet-az2" : "private-db-subnet-az2" 
    }
}

resource "aws_subnet" "subnet_az2"{
    count = 3
    vpc_id = aws_vpc.webapp_vpc.id
    cidr_block = cidrsubnet(aws_vpc.webapp_vpc.cidr_block, 8,count.index+3)
    availability_zone = "us-east-2c"
    tags={
        Name = count.index == 0 ? "public-web-subnet-az2" : count.index == 1 ? "private-app-subnet-az2" : "private-db-subnet-az2" 
    }
}