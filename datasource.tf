data "aws_ami" "Terraform_project_webserver" {
   most_recent = true
   owners = ["137112412989"]
   filter {
     name = "name"
     values = ["al2023-ami-2023.1.20230705.0-kernel-6.1-x86_64"]
   }
}