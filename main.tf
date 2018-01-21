provider "aws" {
  version = "~> 1.7"
}

data "aws_subnet" "selected" {
  id = "${element(var.subnet_ids, 0)}"
}

data "aws_vpc" "selected" {
  id = "${data.aws_subnet.selected.vpc_id}"
}

resource "aws_instance" "mongo_server_primary" {
  count = "${var.shards_count}"

  ami           = "${var.ami}"
  instance_type = "${var.mongo_instance_type}"
  key_name      = "${var.key_pair}"
  subnet_id     = "${element(var.subnet_ids, 0)}"

  vpc_security_group_ids = ["${aws_security_group.mongo_server.id}"]

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags = "${merge(var.tags, var.instance_tags,
                  map("Module", var.module),
                  map("Name", format("%s-mongo-%s-1", var.name, count.index + 1)),
                  map("Role", "mongo-server-primary"),
                  map("MongoName", var.name),
                  map("MongoShard", count.index + 1))}"
}

resource "aws_instance" "mongo_server_replica_set" {
  count = "${var.shards_count * var.replica_set_count}"

  ami           = "${var.ami}"
  instance_type = "${var.mongo_instance_type}"
  key_name      = "${var.key_pair}"
  subnet_id     = "${element(var.subnet_ids, (count.index % var.shards_count + 1) % length(var.subnet_ids))}"

  vpc_security_group_ids = ["${aws_security_group.mongo_server.id}"]

  lifecycle {
    ignore_changes = ["ami"]
  }

  tags = "${merge(var.tags, var.instance_tags,
                  map("Module", var.module),
                  map("Name", format("%s-mongo-%s-1", var.name, count.index / var.shards_count + 1, count.index % var.shards_count + 2)),
                  map("Role", "mongo-server-replica"),
                  map("MongoName", var.name),
                  map("MongoShard", count.index / var.shards_count + 1))}"
}

resource "aws_security_group" "mongo_server" {
  name        = "${var.name}-mongo-server"
  description = "${var.name} Mongo server"
  vpc_id      = "${data.aws_vpc.selected.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
    from_port   = 27017
    to_port     = 27019
    protocol    = "tcp"
    self        = true
  }

  ingress = {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = "${var.admin_sg_ids}"
    cidr_blocks     = "${var.admin_cidrs}"
  }

  tags = "${merge(var.tags, map("Module", var.module))}"
}
