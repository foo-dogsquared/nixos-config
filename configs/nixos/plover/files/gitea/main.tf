variable "github_clone_token" {
  sensitive = true
}

variable "gitea_foodogsquared_password" {
  sensitive = true
}

provider "gitea" {
  # We're using envvars GITEA_BASE_URL instead of `base_url` and also
  # GITEA_TOKEN instead of `token`.
  insecure = false
}

resource "gitea_user" "foodogsquared" {
  username = "foodogsquared"
  login_name = "foodogsquared"
  password = var.gitea_foodogsquared_password
  email = "foodogsquared@foodogsquared.one"
  admin = true
  active = true
  full_name = "Gabriel Arazas"
  location = "Inside of your house"
}

resource "gitea_public_key" "foodogsquared" {
  title = "main public key"
  username = gitea_user.foodogsquared.username
  key = file("../../../../home-manager/foo-dogsquared/files/ssh-key.pub")
}

resource "gitea_repository" "personal_projects_from_github" {
  for_each = tomap({
    hugo-theme-more-contentful = {
      website = "https://foo-dogsquared.github.io/hugo-theme-more-contentful"
      interval = null
    }
    hugo-theme-contentful = {
      website = "https://foo-dogsquared.github.io/hugo-theme-contentful"
      interval = null
    }
    ansible-playbooks = {
      website = null
      interval = null
    }
    dotfiles = {
      website = null
      interval = null
    }
    wiki = {
      website = "https://wiki.foodogsquared.one"
      interval = "1h"
    }
    asciidoctor-foodogsquared-extensions = {
      website = null
      interval = null
    }
    website = {
      website = "https://foodogsquared.one"
      interval = "1h"
    }
    nixos-config = {
      website = "https://foo-dogsquared.github.io/nixos-config"
      interval = null
    }
  })
  name = each.key
  username = gitea_user.foodogsquared.username
  mirror = true
  migration_clone_address = "https://github.com/foo-dogsquared/${each.key}.git"
  migration_service = "github"
  migration_service_auth_token = var.github_clone_token
  migration_mirror_interval = each.value.interval != null ? each.value.interval : "4h"
  website = each.value.website
  private = false
}
