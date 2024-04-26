provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "app_vpc"
  }
}

resource "aws_internet_gateway" "app_gw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "app_gw"
  }
}

resource "aws_subnet" "app_subnet" {
  vpc_id = aws_vpc.app_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "app_subnet"
  }
}

resource "aws_route_table" "app_rt" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_gw.id
  }
  tags = {
    Name = "app_rt"
  }
}

resource "aws_route_table_association" "app_rta" {
  subnet_id = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.app_rt.id
}

resource "aws_security_group" "app_sg" {
  name = "app_sg"
  description = "Allow web and db traffic" 
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  } 

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app_sg"
  }
}

resource "aws_elastic_beanstalk_application" "app_eba" {
  name        = "app_eba"
  description = "Tic Tac Toe app"
}

resource "aws_elastic_beanstalk_environment" "app_ebe" {
  name                = "appebeenv"
  application         = aws_elastic_beanstalk_application.app_eba.name
  solution_stack_name = "64bit Amazon Linux 2 v3.3.0 running ECS"
  version_label = aws_elastic_beanstalk_application_version.app_v.name
  cname_prefix = "mplacek22"
   setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "LabInstanceProfile"
    resource  = ""
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.app_vpc.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = aws_subnet.app_subnet.id
  }

  setting { # public ip address allows to connect
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "true"
  }
  setting { # single EC2 instance to save costs for tests, load balanced when application ready for production
    namespace = "aws:elasticbeanstalk:environment"
    name = "EnvironmentType"
    value = "SingleInstance"
  }
  setting { # AWS service role
    namespace = "aws:elasticbeanstalk:environment"
    name = "ServiceRole"
    value = "arn:aws:iam::851725643#716:role/LabRole" #accountID
  }

  setting { # supported architectures
    namespace = "aws:ec2:instances"
    name = "SupportedArchitectures"
    value = "x86_64"
  }

  setting { # EC2 instance type
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t2.small"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "SecurityGroups"
    value = aws_security_group.app_sg.id
  }
}

resource "aws_elastic_beanstalk_application_version" "app_v" {
  name        = "app_v1"
  application = aws_elastic_beanstalk_application.app_eba.name
  description = "application version created by Terraform"
  bucket      = aws_s3_bucket.app_bucket.bucket  # Corrected from aws_s3_bucket.cket.bucket
  key         = aws_s3_object.app_s3o.key
}


resource "aws_s3_bucket" "app_bucket" { # name must be unique and must contain only allowed characters (not _)
  bucket = "appbuckettictactoe"
}
resource "aws_s3_object" "app_s3o" {
   bucket = aws_s3_bucket.app_bucket.bucket
   key = "deploy.zip"
   source = "deploy.zip"
}


output "elastic_beanstalk_app_url" {
  value = "http://${aws_elastic_beanstalk_environment.app_ebe.cname}:3000"
}