data "tailscale_devices" "foodogsquared" {
  name_prefix = "foodogsquared-"
}

resource "tailscale_contacts" "default" {
  account {
    email = "foodogsquared@foodogsquared.one"
  }

  support {
    email = "foodogsquared@foodogsquared.one"
  }

  security {
    email = "welp@foodogsquared.one"
  }
}

resource "tailscale_acl" "basic" {
  acl = jsonencode({
    tagOwners : {
      "tag:dev" : ["group:dev"],
      "tag:server" : ["group:admin"],
      "tag:family" : [
        "foodogsquared@foodogsquared.one"
      ],
    }
    groups : {
      "group:admin" : ["foodogsquared@foodogsquared.one"],
      "group:dev" : ["foodogsquared@foodogsquared.one"],
    }
    ssh : [
      {
        action : "accept"
        src : ["autogroup:members"]
        dst : ["autogroup:self"]
        users : ["autogroup:nonroot"]
      },

      {
        action : "accept"
        src : ["group:dev"]
        dst : ["tag:dev"]
        users : ["admin"]
      }
    ]
  })
  depends_on = [module.hetzner_vps_plover]
}
