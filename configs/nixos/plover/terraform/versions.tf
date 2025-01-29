terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.48.1"
    }

    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = "2.2.0"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.17.2"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }
}
