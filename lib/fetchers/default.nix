{ pkgs, lib, self }:

{
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
}
