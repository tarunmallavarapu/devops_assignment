locals {
    common_tags = {
        Environment = var.vpc_environment
    }
}

resource "aws_vpc" "vpc" {
    cidr_block = var.app_cidr

    tags = merge(
        local.common_tags,
        {
            "Name" = "${var.vpc_environment}-${var.vpc_name}"
        },
        {
            "Service" = "vpc"
        }
    )
}

resource "aws_internet_gateway" "gateway" {
    vpc_id  = aws_vpc.vpc.id

    tags = merge(
    local.common_tags,
    {
      "Service" = "internet-gateway"
    },
    {
      "Name" = "${var.vpc_environment}-${var.vpc_name}"
    },
  )
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.vpc_public_subnets)
  availability_zone = element(keys(var.vpc_public_subnets), count.index)
  cidr_block        = var.vpc_public_subnets[element(keys(var.vpc_public_subnets), count.index)]

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.vpc_environment}-${var.vpc_name}-public-${element(keys(var.vpc_public_subnets), count.index)}"
    },
    {
      "Service" = "subnet"
    },
    {
      "Tier" = "public"
    },
  )
}

resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.vpc_app_subnets)
  availability_zone = element(keys(var.vpc_app_subnets), count.index)
  cidr_block        = var.vpc_app_subnets[element(keys(var.vpc_app_subnets), count.index)]

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.vpc_environment}-${var.vpc_name} app - ${element(keys(var.vpc_app_subnets), count.index)}"
    },
    {
      "Service" = "subnet"
    },
    {
      "Tier" = "app"
    },
  )
}

resource "aws_eip" "nat-eip" {
  vpc   = true
}

data "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id
  filter {
    name = "tag:Name"
    values = ["assignment-assignment_vpc-public-ap-northeast-2a"]
  }
  depends_on = [
    aws_subnet.public
  ]
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = data.aws_subnet.public.id
  depends_on    = [aws_internet_gateway.gateway]

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.vpc_environment}-${var.vpc_name} public nat-gateway"
    },
    {
      "Service" = "nat-gateway"
    },
  )
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.vpc_environment}-${var.vpc_name} public"
    },
    {
      "Service" = "route-table"
    },
    {
      "Tier" = "public"
    },
  )
}


resource "aws_route_table" "app" {
  vpc_id = aws_vpc.vpc.id
  count  = length(var.vpc_public_subnets)

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.vpc_environment}-${var.vpc_name} app main table ${count.index}"
    },
    {
      "Service" = "route-table"
    },
    {
      "Tier" = "app"
    },
  )
}

resource "aws_route" "public-to-external" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_route" "app-to-external" {
  count                  = length(var.vpc_public_subnets)
  route_table_id         = element(aws_route_table.app.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat-gw.*.id, count.index)
}

resource "aws_route_table_association" "public" {
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  count          = length(var.vpc_public_subnets)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

resource "aws_route_table_association" "app" {
  subnet_id      = element(aws_subnet.app.*.id, count.index)
  count          = length(var.vpc_app_subnets)
  route_table_id = element(aws_route_table.app.*.id, count.index)
}