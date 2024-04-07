# ------------------------------
# IAM Role
# ------------------------------
# EC2 Common
data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# App Server
resource "aws_iam_instance_profile" "app_server_profile" {
  name = aws_iam_role.app_server_iam_role.name
  role = aws_iam_role.app_server_iam_role.name

}

resource "aws_iam_role" "app_server_iam_role" {
  name               = "${var.project}-${var.environment}-app-server-iam-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "app_server_iam_role_ec2_readonly" {
  role       = aws_iam_role.app_server_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "app_server_iam_role_ssm_managed" {
  role       = aws_iam_role.app_server_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "app_server_iam_role_ssm_readonly" {
  role       = aws_iam_role.app_server_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "app_server_iam_role_s3_readonly" {
  role       = aws_iam_role.app_server_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Step Server
resource "aws_iam_instance_profile" "step_server_profile" {
  name = aws_iam_role.step_server_iam_role.name
  role = aws_iam_role.step_server_iam_role.name
}

resource "aws_iam_role" "step_server_iam_role" {
  name               = "${var.project}-${var.environment}-step-server-iam-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "step_server_iam_role_ec2_readonly" {
  role       = aws_iam_role.step_server_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "step_server_iam_role_ssm_managed" {
  role       = aws_iam_role.step_server_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
