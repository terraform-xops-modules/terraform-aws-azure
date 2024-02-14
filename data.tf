data "aws_vpc" "main" {
  id = var.aws_vpc_id
}

data "aws_route_tables" "main" {
  vpc_id = var.aws_vpc_id
}
