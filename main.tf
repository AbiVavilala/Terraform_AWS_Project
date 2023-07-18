# Create AWS VPC
resource "aws_vpc" "Terraform_project" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Development_environment"
  }

}

#Create a public subnet
resource "aws_subnet" "Terraform_project_subnet" {
  vpc_id                  = aws_vpc.Terraform_project.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-2a"

  tags = {
    Name = "Terraform_Project_public"
  }
}

#create AWS internet Gateway 
resource "aws_internet_gateway" "Terraform_project_IG" {
  vpc_id = aws_vpc.Terraform_project.id

  tags = {
    Name = "Terraform_project_IG"
  }
}

#Create AWS route table

resource "aws_route_table" "Terraform_project_routetable" {
  vpc_id = aws_vpc.Terraform_project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Terraform_project_IG.id
  }

  tags = {
    Name = "Terraform_Project_public_routetable"
  }
}


resource "aws_route_table_association" "Terraform_project_RTassociate" {
  subnet_id      = aws_subnet.Terraform_project_subnet.id
  route_table_id = aws_route_table.Terraform_project_routetable.id
}

# Create Security groups

resource "aws_security_group" "Terraform_project_Securitygroup" {
  name        = "Terraform_project_Securitygroup"
  description = "Project security group"
  vpc_id      = aws_vpc.Terraform_project.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform_project_SG"
  }
}

resource "aws_instance" "dev_node" {
  instance_type = "t2.micro"
  ami = data.aws_ami.Terraform_project_webserver.id
  key_name = "Terraform"
  vpc_security_group_ids = [aws_security_group.Terraform_project_Securitygroup.id]
  subnet_id = aws_subnet.Terraform_project_subnet.id
  availability_zone = "ap-southeast-2a"
  user_data = file("userdata.tpl")
  tags = {
    Name = "dev_node"
  }
   
   
}