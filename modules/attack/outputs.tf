output "ip" {
    value="${aws_instance.windows.*.public_ip}"
    description = "Windows server public IP address"
    depends_on = [
      aws_instance.windows,
    ]
}

output "private_ip" {
  value = "${aws_instance.windows.*.private_ip}"
  description = "Windows server private IP address"
  depends_on = [
      aws_instance.windows,
    ]
}

output "my_ip_addr" {
  value = local.ifconfig_co_json.ip
}