{ pkgs, lib, self }:

{
  # Similar to `lib.fetchers.proxyImpureEnvVars` but for Git.
  #
  # !!! I don't know which is important among them (except for a handful of
  # envvars) so I'm taking most of them.
  gitImpureEnvVars = [
    "GIT_PROXY"
    "GIT_HTTP_PROXY_AUTHMETHOD"
    "GIT_SSL_VERSION"
    "GIT_PROXY_COMMAND"
    "GIT_SSH_COMMAND"
    "GIT_CREDENTIALS"
    "GIT_SSL_CERT"
    "GIT_SSL_KEY"
    "GIT_SSL_CERT_TYPE"
    "GIT_PROXY_SSL_CERT"
    "GIT_PROXY_SSL_KEY"
    "GIT_HTTP_USER_AGENT"
  ];

  /**
    A convenient wrapper for fetching contents from the Internet Archive.

    # Arguments

    It's a sole attribute set with the extra following attributes:

    id
    : The identifier of the item typically found in the URL of the object.

    formats
    : An array of formats to be downloaded. Mutually exclusive with `file`
    attribute.

    file
    : The specific file to be downloaded. Mutually exclusive with `formats`
    attribute.

    It can also accept other arguments as an extra attributes for its fetcher
    function (e.g., `hash` for fixed-output derivations).

    # Type

    ```
    fetchInternetArchive :: Attr -> Derivation
    ```

    # Examples

    ```nix
    fetchInternetArchive {
      id = "md_music_sonic_the_hedgehog";
      formats = [ "TEXT" "PNG" ];
      hash = "sha256-xbhasJ/wEgcY+EcBAJp5UoYB4N4It3QV/iIeGGdCET8=";
    }

    fetchInternetArchive {
      id = "md_music_sonic_the_hedgehog";
      file = "01 - Title Theme - Masato Nakamura.flac";
      hash = "sha256-kGjsVjtjXK9imqyi4GF6qkFVmobiTAe/ZAeEwiouqS4=";
    }
    ```
  */
  fetchInternetArchive = pkgs.callPackage ./fetch-internet-archive { };

  /**
    An convenient wrapper for downloading Ugee drivers.

    # Arguments

    It's a sole attribute set with the following attributes:

    fileId
    : The file identifier containing the driver.

    pid
    : The identifier of the model.

    ext
    : The file extension expected for the file.

    # Type

    ```
    fetchUgeeDriver :: Attr -> Derivation
    ```

    # Examples

    ```nix
    # Ugee M908.
    fetchUgeeDriver {
      fileId = "943";
      pid = "505";
      hash = "sha256-50Dbyaaa1B8nQu3+tTGvh/yjQqwaARB2MWtKSOUYsKg=";
      ext = "tar.gz";
    }
    ```
  */
  fetchUgeeDriver = pkgs.callPackage ./fetch-ugee-driver { };

  /**
    A builder for extracting the website icon into an output.

    # Arguments

    It is a sole attribute set with the following required attributes:

    url
    : The URL of the webpage to have its icon extracted.

    # Type

    ```
    extractWebsiteIcon :: Attr -> Derivation
    ```

    # Example

    ```nix
    extractWebsiteIcon {
      url = "https://google.com";
    }
    ```
  */
  fetchWebsiteIcon = pkgs.callPackage ./fetch-website-icon { };

  /**
    Fetch images from Pexels.

    # Arguments

    It is a sole attribute set with the following attributes:

    ids
    : A list of image IDs (string) to be downloaded.

    # Type

    ```
    fetchPexelImages :: Attr -> Derivation
    ```

    # Examples

    ```nix
    fetchPexelImages {
      ids = [ "31735589" ];
      hash = "";
    }
    ```
  */
  fetchPexelsImages = pkgs.callPackage ./fetch-pexels-asset/images.nix { };

  /**
    Fetch videos from Pexels.

    # Arguments

    Same as `fetchPexelImages`.

    # Type

    ```
    fetchPexelsVideos :: Attr -> Derivation
    ```

    # Examples

    ```nix
    fetchPexelVideos {
      ids = [ "31735589" ];
      hash = "";
    }
    ```
  */
  fetchPexelsVideos = pkgs.callPackage ./fetch-pexels-asset/videos.nix { };

  /**
    Fetch images from Unsplash.

    # Arguments

    Same as `fetchPexelsImages`

    # Type

    ```
    fetchUnsplashImages :: Attr -> Derivation
    ```

    # Examples

    ```nix
    fetchUnsplashImages {
      ids = [ "" ];
      hash = "";
    }
    ```
  */
  fetchUnsplashImages = pkgs.callPackage ./fetch-unsplash-asset/images.nix { };
}
