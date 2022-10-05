data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = "true"

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  owners = ["099720109477"]
}

resource "aws_vpc" "todoapp_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "todoapp_vpc"
  }
}

resource "aws_internet_gateway" "todoapp_igw" {
  vpc_id = aws_vpc.todoapp_vpc.id

  tags = {
    Name = "todoapp_igw"
  }
}

resource "aws_subnet" "todoapp_public_subnet" {
  count             = var.subnet_count.public
  vpc_id            = aws_vpc.todoapp_vpc.id
  
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "todoapp_public_subnet_${count.index}"
  }
}

resource "aws_subnet" "todoapp_private_subnet" {
  count             = var.subnet_count.private
  
  vpc_id            = aws_vpc.todoapp_vpc.id
  
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  
  availability_zone = data.aws_availability_zones.available.names[count.index]


  tags = {
    Name = "todoapp_private_subnet_${count.index}"
  }
}

resource "aws_route_table" "todoapp_public_rt" {
  vpc_id = aws_vpc.todoapp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.todoapp_igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = var.subnet_count.public
  route_table_id = aws_route_table.todoapp_public_rt.id
  subnet_id      = 	aws_subnet.todoapp_public_subnet[count.index].id
}

resource "aws_route_table" "todoapp_private_rt" {
  vpc_id = aws_vpc.todoapp_vpc.id
}

resource "aws_route_table_association" "private" {
  count          = var.subnet_count.private
  route_table_id = aws_route_table.todoapp_private_rt.id
  
  subnet_id      = aws_subnet.todoapp_private_subnet[count.index].id
}

resource "aws_security_group" "todoapp_web_sg" {
  name        = "todoapp_web_sg"
  description = "Security group for todoapp web servers"
  vpc_id      = aws_vpc.todoapp_vpc.id

  ingress {
    description = "Allow all traffic through HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"] //TODO: only add allow single ip
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "todoapp_web_sg"
  }
}

// Security group for RDS instance
resource "aws_security_group" "todoapp_db_sg" {

  name        = "todoapp_db_sg"
  description = "Security group for todoapp database"
  vpc_id      = aws_vpc.todoapp_vpc.id


  ingress {
    description     = "Allow traffic from only the EC2 instance"
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "tcp"
    security_groups = [aws_security_group.todoapp_web_sg.id]
  }

  tags = {
    Name = "todoapp_db_sg"
  }
}

resource "aws_db_subnet_group" "todoapp_db_subnet_group" {

  name        = "todoapp_db_subnet_group"
  description = "DB subnet group for todoapp"
  
  // Since the db subnet group requires 2 or more subnets, we are going to
  // loop through our private subnets in "todoapp_private_subnet" and
  // add them to this db subnet group

  subnet_ids  = [for subnet in aws_subnet.todoapp_private_subnet : subnet.id]
}

resource "aws_db_instance" "todoapp_database" {
  allocated_storage      = var.settings.database.allocated_storage
  engine                 = var.settings.database.engine
  engine_version         = var.settings.database.engine_version
  instance_class         = var.settings.database.instance_class
  
  // DB credentials
  db_name                = var.settings.database.db_name
  username               = var.db_username
  password               = var.db_password
  
  // DB subnet group
  db_subnet_group_name   = aws_db_subnet_group.todoapp_db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.todoapp_db_sg.id]
  skip_final_snapshot    = var.settings.database.skip_final_snapshot
}

// Key pairs
resource "aws_key_pair" "todoapp_kp" {
  key_name   = "todoapp_kp"
  public_key = file("todoapp_kp.pub")
}

// Create the EC2 instace
resource "aws_instance" "todoapp_web" {
  count                  = var.settings.web_app.count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.settings.web_app.instance_type
  
  // [count.index] grab the first subnet in "todoapp_public_subnet
  subnet_id              = aws_subnet.todoapp_public_subnet[count.index].id
  key_name               = aws_key_pair.todoapp_kp.key_name
  

  vpc_security_group_ids = [aws_security_group.todoapp_web_sg.id]
  tags = {
    Name = "todoapp_web_${count.index}"
  }
}

// Elastic IP
resource "aws_eip" "todoapp_web_eip" {
  count    = var.settings.web_app.count
  instance = aws_instance.todoapp_web[count.index].id
  vpc      = true

  tags = {
    Name = "todoapp_web_eip_${count.index}"
  }
}

