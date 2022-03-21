resource "random_string" "ssm_random_id" {
  length  = 3
  special = false
  upper   = false
}

resource "aws_iam_role" "ssm_instance_role" {
  name               = "ssm-instance-role-${random_string.ssm_random_id.id}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }
}
EOF
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm-instance-profile-${random_string.ssm_random_id.id}"
  role = aws_iam_role.ssm_instance_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_instance_role_policy_attachment" {
  role       = aws_iam_role.ssm_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
