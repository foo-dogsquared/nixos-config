variable "ssh_keys" {
  type        = list(number)
  description = "SSH keys for the associated server"
}

resource "hcloud_server" "plover" {
  name        = "plover"
  image       = "ubuntu-24.04"
  server_type = "cx22"
  datacenter  = "hel1-dc2"

  ssh_keys = concat(var.ssh_keys[*], [
    hcloud_ssh_key.plover.id
  ])

  delete_protection  = false
  rebuild_protection = false

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "hcloud_ssh_key" "plover" {
  name       = "plover.foodogsquared.one"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGo3tfNQjWZ5pxlqREfBgQJxdNzGHKJIy5hDS9Z+Hpth plover.foodogsquared.one"
}

resource "local_file" "network_file" {
  content = jsonencode({
    interfaces = {
      wan = {
        ipv4 = hcloud_server.plover.ipv4_address
        ipv6 = hcloud_server.plover.ipv6_address
      }
    }
  })
  filename = "${path.module}/network.json"
}
