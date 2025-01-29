variable "hcloud_dns_token" {
  sensitive = true
}

provider "hetznerdns" {
  apitoken = var.hcloud_dns_token
}

data "hetznerdns_zone" "main" {
  name = "foodogsquared.one"
}

resource "hetznerdns_record" "personal_site" {
  zone_id = data.hetznerdns_zone.main.id
  name    = "@"
  ttl     = 3600
  type    = "A"
  value   = "75.2.60.5"
}

resource "hetznerdns_record" "personal_site_cname" {
  zone_id = data.hetznerdns_zone.main.id
  name    = "www"
  ttl     = 3600
  type    = "CNAME"
  value   = "foodogsquared.netlify.app."
}

resource "hetznerdns_record" "personal_wiki" {
  zone_id = data.hetznerdns_zone.main.id
  name    = "wiki"
  ttl     = 3600
  type    = "CNAME"
  value   = "foodogsquared-wiki.netlify.app."
}

# Mail resources.
resource "hetznerdns_record" "mail_mx" {
  for_each = toset(["10 heracles.mxrouting.net.", "20 heracles-relay.mxrouting.net."])
  zone_id  = data.hetznerdns_zone.main.id
  name     = "@"
  type     = "MX"
  value    = each.value
}

resource "hetznerdns_record" "mail_dmarc" {
  zone_id = data.hetznerdns_zone.main.id
  name    = "_dmarc"
  ttl     = 3600
  type    = "TXT"
  value   = "v=DMARC1;p=none;rua=mailto:postmaster@foodogsquared.one;ruf=mailto:admin@foodogsquared.one"
}

resource "hetznerdns_record" "mail_dkim" {
  zone_id = data.hetznerdns_zone.main.id
  name    = "x._domainkey"
  ttl     = 3600
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyLlrgdsO4jLncMoGAowlE14oB9R2ESxNLRBtkzc24LOPJ1CwEIE+5AHZd+ZRMwiD7fdXcyCH7/E1BRXWT+TtLnKnBgf5I0z6EbPqiPPb6nmpDWrbZzA2mdKetAKz0kFJC8oYK7lQF7Bdh57y/HWksoH6yjl1E88m8tEQ/thlyABGjqzV+txgmc1BryFu23KasqI2c4We/KgvsoSSAaUHkjpAMCuJck/P0G9mJWyTHrnZN2gCotyenLBZew0BIbiA2XYp6dQW4sU+MawfZ0E1KA0lem0SRYCB+sGD248uj4xVo9sIiCVyO9EQXy/YCZTeuTQHf1+QeFzI82vIrlv63QIDAQAB"
}

resource "hetznerdns_record" "mail_spf" {
  zone_id = data.hetznerdns_zone.main.id
  name    = "@"
  type    = "TXT"
  value   = "v=spf1 include:mxlogin.com -all"
}

resource "hetznerdns_record" "mail_webmail" {
  for_each = toset(["mail", "webmail"])
  zone_id  = data.hetznerdns_zone.main.id
  name     = each.value
  type     = "CNAME"
  value    = "heracles.mxrouting.net."
}
