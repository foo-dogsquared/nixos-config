terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.48.1"
    }

    hetznerdns = {
      source = "timohirt/hetznerdns"
      version = "2.2.0"
    }
  }
}
