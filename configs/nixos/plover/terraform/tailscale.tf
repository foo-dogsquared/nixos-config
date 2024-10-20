data "tailscale_device" "plover" {
  hostname = "plover"
}

resource "tailscale_device_authorization" "plover_authorization" {
  device_id = data.tailscale_device.plover.id
  authorized = true
  depends_on = [ hcloud_server.plover ]
}

resource "tailscale_tailnet_key" "plover" {
  reusable = false
  ephemeral = false
  preauthorized = true
  recreate_if_invalid = "always"
  description = "Plover"
}

resource "tailscale_device_tags" "hcloud_plover" {
  device_id = data.tailscale_device.plover.id
  tags = [ "tag:server" ]
}

resource "local_file" "tailscale_auth_key" {
  content = tailscale_tailnet_key.plover.key
  filename = "${path.module}/plover-tailscale-auth-key"
}
