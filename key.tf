resource "aws_key_pair" "key" {
  key_name   = var.key.name
  public_key = file("${var.key.public_key}")
}
