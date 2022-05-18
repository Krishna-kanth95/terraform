provider "aws" {
    region = "us-east-1"
}

variable "cidr_blocks" {
    description = "cidr blocks for vpc and subnets"
	type = list(object({
        cidr_block = string
        name = string
    }))
}

variable "az" {
    description = "availability zone for resources"
	type =  string
}

resource "aws_vpc" "dev-vpc" {
    cidr_block = var.cidr_blocks[0].cidr_block
    tags = {
        Name: var.cidr_blocks[0].name
    }
}

resource "aws_subnet" "subnet-vpc-1" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block =var.cidr_blocks[1].cidr_block
    availability_zone = var.az
    tags = {
        Name: var.cidr_blocks[1].name
    } 
}
