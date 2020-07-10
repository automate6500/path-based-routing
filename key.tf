resource "aws_key_pair" "key" {
  key_name   = "${terraform.workspace}-${var.key.name}"
  public_key = file("${var.key.public_key}")
}
