return {
  tls_servers = {
    pem_private_key = "@CERT_DIR@/key.pem",
    pem_cert = "@CERT_DIR@/cert.pem",
    pem_ca = "@CERT_DIR@/fullchain.pem",
  }
}
