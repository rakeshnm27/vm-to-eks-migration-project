data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )

  public_subnets = {
    for index, az in local.availability_zones :
    az => cidrsubnet(var.vpc_cidr, 8, index + 1)
  }

  private_subnets = {
    for index, az in local.availability_zones :
    az => cidrsubnet(var.vpc_cidr, 8, index + 11)
  }
}
