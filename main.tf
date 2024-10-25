// Provider block
provider "aws" {
  region = var.aws_region
}

// Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = var.aws_vpc
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, { Name = "main-vpc" })
}

// Create a public subnet with public IPs assigned
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet

  map_public_ip_on_launch = true // Enable public IP assignment

  tags = merge(var.tags, { Name = "public-subnet" })
}

// Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet

  tags = merge(var.tags, { Name = "private-subnet" })
}

// Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "main-gateway" })
}

// Create a public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(var.tags, { Name = "public-route-table" })
}

// Associate the public subnet with the public route table
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

// Create a private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "private-route-table" })
}

// Associate the private subnet with the private route table
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

// Create a Security Group for HTTP and SSH access
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH traffic"

  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // Add this ingress rule to your security group
   ingress {
     from_port   = 8080  // Change to the port your application uses
     to_port     = 8080
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "web-sg" })
}

// Create an EC2 instance with user data to set up a Java web server
// Create an EC2 instance with user data to set up a Java web server
resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type         = var.instance_type
  key_name               = var.key_name
  subnet_id             = aws_subnet.public_subnet.id  // Use public subnet ID
  vpc_security_group_ids = [aws_security_group.web_sg.id]  // Use security group ID

  // Associate public IP address
  associate_public_ip_address = true // Enable public IP assignment

  # User data to install Java, Git, Maven, clone the repository, and run the app
user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y apache2 openjdk-11-jdk maven git

              # Install Jenkins
              # Add the Jenkins repository and key
              wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key  | sudo apt-key add -
              echo "deb http://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
              sudo apt update -y
              sudo apt install -y jenkins

              # Start and enable Apache and Jenkins
              sudo systemctl start apache2
              sudo systemctl enable apache2
              sudo systemctl start jenkins
              sudo systemctl enable jenkins

              # Clone the GitHub repository
              cd /home/ubuntu
              git clone https://github.com/DevOps-AWS-123/todo-app.git

              # Build the application with Maven
              cd todo-app
              mvn clean package

              # Move the built JAR to a safe directory
              sudo cp target/todoapp-0.0.1-SNAPSHOT.jar /usr/local/bin/todoapp.jar

              # Start the application using nohup
              nohup java -jar /usr/local/bin/todoapp.jar > /var/log/todo-app.log 2>&1 &

              # Confirm successful deployment by updating the index.html
              echo "<h1>Your Java Application is Deployed!</h1>" | sudo tee /var/www/html/index.html
              EOF


  tags = merge(var.tags, { Name = "web-server" })
}



// Output the public IP of the web server
output "web_server_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "The public IP address of the web server instance."
}
       