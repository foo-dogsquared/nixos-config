variable "zone_id" {
  description = "Hetzner DNS zone ID to be configured with."
}

resource "hetznerdns_record" "plover_ipv4" {
  zone_id = var.zone_id
  name    = "plover"
  type    = "A"
  value   = hcloud_server.plover.ipv4_address
}

resource "hetznerdns_record" "plover_ipv6" {
  zone_id = var.zone_id
  name    = "plover"
  type    = "AAAA"
  value   = hcloud_server.plover.ipv6_address
}

variable "services" {
  type    = list(string)
  default = ["auth", "pass", "code"]
}

resource "hetznerdns_record" "plover_services" {
  for_each = toset(var.services)
  zone_id  = var.zone_id
  name     = each.key
  type     = "CNAME"
  value    = "plover"
}
