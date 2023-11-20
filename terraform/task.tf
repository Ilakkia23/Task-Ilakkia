provider "aws" {
  region = "ap-south-1"

}


resource "aws_instance" "terraform-1" {
  ami           = "ami-0287a05f0ef0e9d9a"
  instance_type = "t2.micro"
  key_name = "Devopskeypair"
  tags = {
    Name = "example-instance"
  }
}
