resource "aws_acm_certificate" "dm" {
  private_key       = file(var.acm_private_key)
  certificate_body  = file(var.acm_certificate_body)
  certificate_chain = file(var.acm_certificate_chain)
}
