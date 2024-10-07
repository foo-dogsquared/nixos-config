variable "hcloud_token" {
  sensitive = true
}

variable "hcloud_dns_token" {
  sensitive = true
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "hetznerdns" {
  apitoken = var.hcloud_dns_token
}

resource "hetznerdns_zone" "main" {
  name = "foodogsquared.one"
  ttl = 3600
}

resource "hetznerdns_primary_server" "main" {
  address = hcloud_server.plover.ipv4_address
  port = 53
  zone_id = hetznerdns_zone.main.id
}

resource "hetznerdns_primary_server" "main_ipv6" {
  address = hcloud_server.plover.ipv6_address
  port = 53
  zone_id = hetznerdns_zone.main.id
}

resource "hcloud_server" "plover" {
  name        = "plover"
  image       = "ubuntu-24.04"
  server_type = "cx22"
  datacenter  = "hel1-dc2"

  ssh_keys = [
    hcloud_ssh_key.foodogsquared.id,
    hcloud_ssh_key.plover.id
  ]

  delete_protection  = false
  rebuild_protection = false

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.plover.id
    ip         = "10.0.0.2"
  }

  depends_on = [
    hcloud_network_subnet.plover-subnet
  ]
}

resource "hcloud_ssh_key" "foodogsquared" {
  name       = "foodogsquared@foodogsquared.one"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILPR52KfVODfKsgdvYSoQinV3kyOTZ4mtKa0fah5Wkfr foodogsquared@foodogsquared.one"
}

resource "hcloud_ssh_key" "plover" {
  name = "plover.foodogsquared.one"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGo3tfNQjWZ5pxlqREfBgQJxdNzGHKJIy5hDS9Z+Hpth plover.foodogsquared.one"
}

resource "hcloud_network" "plover" {
  name     = "personal"
  ip_range = "10.0.0.0/8"
  delete_protection = false
}

resource "hcloud_network_subnet" "plover-subnet" {
  network_id   = hcloud_network.plover.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/12"
}
