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

resource "gitea_repository" "nixos-config" {
  username = gitea_user.foodogsquared.username
  name = "nixos-config"
  mirror = true
  migration_clone_address = "https://github.com/foo-dogsquared/nixos-config.git"
  migration_service = "github"
  migration_service_auth_token = var.github_clone_token
  migration_mirror_interval = "4h"
  website = "https://foo-dogsquared.github.io/nixos-config"
  private = false
}

resource "gitea_repository" "website" {
  username = gitea_user.foodogsquared.username
  name = "website"
  mirror = true
  migration_clone_address = "https://github.com/foo-dogsquared/website.git"
  migration_service = "github"
  migration_service_auth_token = var.github_clone_token
  migration_mirror_interval = "4h"
  website = "https://foodogsquared.one"
  private = false
}

resource "gitea_repository" "asciidoctor-foodogsquared-extensions" {
  username = gitea_user.foodogsquared.username
  name = "asciidoctor-foodogsquared-extensions"
  mirror = true
  migration_clone_address = "https://github.com/foo-dogsquared/asciidoctor-foodogsquared-extensions.git"
  migration_service = "github"
  migration_service_auth_token = var.github_clone_token
  migration_mirror_interval = "4h"
  private = false
}

resource "gitea_repository" "wiki" {
  username = gitea_user.foodogsquared.username
  name = "wiki"
  mirror = true
  migration_clone_address = "https://github.com/foo-dogsquared/wiki.git"
  migration_service = "github"
  migration_service_auth_token = var.github_clone_token
  migration_mirror_interval = "4h"
  website = "https://wiki.foodogsquared.one"
  private = false
}

resource "gitea_repository" "dotfiles" {
  username = gitea_user.foodogsquared.username
  name = "dotfiles"
  mirror = true
  migration_clone_address = "https://github.com/foo-dogsquared/dotfiles.git"
  migration_service = "github"
  migration_service_auth_token = var.github_clone_token
  migration_mirror_interval = "4h"
  website = "https://wiki.foodogsquared.one"
  private = false
}
