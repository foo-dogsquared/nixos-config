variable "hcloud_token" {
  sensitive = true
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_server" "plover" {
  name        = "plover"
  image       = "debian-12"
  server_type = "cx21"
  location    = "hel1"
  datacenter  = "hel1-dc2"

  ssh_keys = [hcloud_ssh_key.foodogsquared.id]

  delete_protection  = true
  rebuild_protection = true

  user_data = file("${path.module}/files/hcloud/hcloud-user-data.yml")

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.plover.id
    ip         = "172.27.0.1"
    alias_ips = [
      "172.27.0.2",
      "172.27.0.3"
    ]
  }

  depends_on = [
    hcloud_network_subnet.plover-subnet
  ]
}

resource "hcloud_ssh_key" "foodogsquared" {
  name       = "foodogsquared@foodogsquared.one"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILPR52KfVODfKsgdvYSoQinV3kyOTZ4mtKa0fah5Wkfr foodogsquared@foodogsquared.one"
}

resource "hcloud_network" "plover" {
  name     = "plover"
  ip_range = "172.16.0.0/12"
}

resource "hcloud_network_subnet" "plover-subnet" {
  network_id   = hcloud_network.plover.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "172.27.0.0/16"
}
