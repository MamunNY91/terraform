variable vpc_cidr_block{
    default = "10.10.0.0/16"
}
variable subnet_cidr_block{
    default = "10.10.1.0/24"
}
variable avail_zone{
    default = "us-east-1a"
}
variable env_prefix{
    default = "dev"
}
variable instance_type{
    default = "t2.micro"
}
