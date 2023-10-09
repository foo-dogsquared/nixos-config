return {
	tls_servers = {
		-- These are expected to be imported through systemd LoadCredentials
		-- directive.
		{
			pem_private_key = os.getenv("CREDENTIALS_DIRECTORY") .. "/key.pem",
			pem_cert = os.getenv("CREDENTIALS_DIRECTORY") .. "/cert.pem",
			pem_ca = os.getenv("CREDENTIALS_DIRECTORY") .. "/fullchain.pem",
			bind_address = "@listen_address@",
		},
	},
}
