# All-encompassing environment for cloud platform management. I'm using only
# one so far but apparently these providers have some tool to enable easy
# access and usage for their platform.
#
# The reason why we have these with a light sandbox is for more sophiscated
# tools like in Google Cloud SDK.
{ buildFHSUserEnv }:

(buildFHSUserEnv {
  name = "cloud-admin-env";
  targetPkgs = pkgs: (with pkgs; [
    awscli2 # For Amazon Web Services.
    azure-cli # For Microsoft Azure.

    # For Google Cloud Platform.
    (google-cloud-sdk.withExtraComponents
      (with google-cloud-sdk.components; [
        gke-gcloud-auth-plugin
        gcloud-man-pages
        cloud-run-proxy
      ])
    )

    kubectl # For managing Kubernetes cluster if it is on one.
    hcloud # For Hetzner Cloud.
    linode-cli # For Linode.
    vultr-cli # For Vultr.

    # It's here since Google Cloud SDK needs it.
    python3
  ]);
}).env
