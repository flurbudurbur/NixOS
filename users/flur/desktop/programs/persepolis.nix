{ pkgs, ... }:
{
  home.packages = with pkgs; [
    persepolis
  ];

  # Persepolis uses aria2 as its backend
  programs.aria2 = {
    enable = true;
    settings = {
      # Maximum number of connections per download
      max-connection-per-server = 16;
      # Minimum split size for multi-connection downloads
      min-split-size = "1M";
      # Continue downloading partially downloaded files
      continue = true;
      # File allocation method (falloc is faster on modern filesystems)
      file-allocation = "falloc";
    };
  };
}
