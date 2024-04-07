# ------------------------------
# launch template
# ------------------------------
resource "aws_launch_template" "app_lt" {
  update_default_version = true

  name = "${var.project}-${var.environment}-app-lt"

  image_id = data.aws_ami.app.id

  key_name = aws_key_pair.keypair.key_name

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project}-${var.environment}-app-server"
      Project = var.project
      Env     = var.environment
      Type    = "app"
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app_sg.id]
    delete_on_termination       = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.app_server_profile.name
  }

  user_data = filebase64("./src/initialize.sh")
}

# ------------------------------
# auto scaling group
# ------------------------------
resource "aws_autoscaling_group" "app_asg" {
  name                 = "${var.project}-${var.environment}-app-asg"

  min_size             = 1
  max_size             = 1
  desired_capacity     = 1

  health_check_grace_period = 300
  health_check_type    = "ELB"

  vpc_zone_identifier  = [
    aws_subnet.private_subnet_1a.id,
    aws_subnet.private_subnet_1c.id
  ]

  target_group_arns    = [aws_lb_target_group.alb_target_group.arn]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.app_lt.id
        version            = "$Latest"
      }
      override {
        instance_type = "t2.micro"
      }
    }
  }
}