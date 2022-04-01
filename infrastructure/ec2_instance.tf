


resource "aws_instance" "web_server" {
    ami = data.aws_ami.bionic.id
    instance_type = "t2.micro"
    security_groups = [aws_security_group.web_server_sec.id]
    subnet_id = aws_subnet.public.id
    associate_public_ip_address = true
    availability_zone = "us-west-1a"
    key_name          = aws_key_pair.key_pair.key_name
  provisioner "file" {
    source      = "./${aws_key_pair.key_pair.key_name}.pem"
    destination = "/home/ubuntu/${aws_key_pair.key_pair.key_name}.pem"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./${aws_key_pair.key_pair.key_name}.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 ~/${aws_key_pair.key_pair.key_name}.pem"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${aws_key_pair.key_pair.key_name}.pem")
      host        = self.public_ip
    }
  }

}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "local_file" "private_key" {

  filename          = "ssh-key.pem"
  sensitive_content = tls_private_key.key.private_key_pem
  file_permission   = "0400"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "ssh-key"
  public_key = tls_private_key.key.public_key_openssh
}