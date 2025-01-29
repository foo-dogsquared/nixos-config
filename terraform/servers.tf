variable "hcloud_token" {
  sensitive = true
}

provider "hcloud" {
  token = var.hcloud_token
}

module "hetzner_vps_plover" {
  source  = "../configs/nixos/plover/terraform"
  zone_id = data.hetznerdns_zone.main.id
  ssh_keys = [
    hcloud_ssh_key.foodogsquared.id
  ]
}
