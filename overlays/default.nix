self: super:

{
# https://github.com/mozilla/nixpkgs-mozilla
latest = {
    rustChannels = (import ./rust-overlay.nix self super).latest.rustChannels or "";
  };
}
