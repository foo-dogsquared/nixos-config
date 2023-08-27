return {
	tls_servers = {
		pem_private_key = os.getenv("CREDENTIALS_DIRECTORY") .. "/key.pem",
		pem_cert = os.getenv("CREDENTIALS_DIRECTORY") .. "/cert.pem",
		pem_ca = os.getenv("CREDENTIALS_DIRECTORY") .. "/fullchain.pem",
		bind_address = "@host_address@:@port@",
	},
}
