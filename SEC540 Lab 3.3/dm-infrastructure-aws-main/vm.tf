resource "aws_key_pair" "devsecops" {
  key_name   = "devsecops"
  public_key = file(var.bastion_ssh_public_key)
}

data "template_file" "bastion_user_data" {
  template = file("${path.root}/assets/bastion/bootstrap.tpl")

  vars = {
    region            = var.region
    bastion_log_group = aws_cloudwatch_log_group.dm_bastion.name
  }
}

data "aws_ssm_parameter" "amazon_linux_2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "bastion" {
  ami                         = var.bastion_image_id == "" ? data.aws_ssm_parameter.amazon_linux_2_ami.value : var.bastion_image_id
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  subnet_id                   = aws_subnet.management_a.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.devsecops.key_name

  user_data = data.template_file.bastion_user_data.rendered

  vpc_security_group_ids = [
    aws_security_group.management_bastion.id
  ]

  root_block_device {
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge(local.tags, {
    Name    = "dm-mgmt-bastion"
    Product = "Operations"
  })
}
