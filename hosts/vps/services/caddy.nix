# Caddy reverse proxy, migrated from the netcup box's ~/caddy_stuff.
#
# DNS-01 challenges: srx.flur.dev goes through BunnyDNS (BUNNY_API_KEY), the
# remaining zones still go through Cloudflare (CF_API_TOKEN) until they're
# migrated. Both plugins are baked in; both keys live in the same EnvironmentFile.
{
  config,
  lib,
  pkgs,
  secretsPath,
  ...
}:
let
  # Same fallback pattern as users/flur/programs/git.nix: build succeeds before the
  # secret exists in nix-secrets, and picks it up automatically once it's added.
  # The yaml needs a top-level `caddy-cloudflare-env:` key whose value is full
  # EnvironmentFile content:
  #   CF_API_TOKEN=<token>
  #   BUNNY_API_TOKEN=<bunny.net account API key>
  caddySecretsFile = "${secretsPath}/system/vps/caddy.yaml";
  haveCaddySecrets = builtins.pathExists caddySecretsFile;
in
{
  sops.secrets."caddy-cloudflare-env" = lib.mkIf haveCaddySecrets {
    sopsFile = caddySecretsFile;
  };

  services.caddy = {
    enable = true;

    # globalConfig below sets `admin off`, which removes the admin API that
    # `caddy reload` depends on to push new config - reload would always fail
    # with "connection refused" to :2019. Restart on config changes instead.
    enableReload = false;

    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/bunny@v1.2.0"
        "github.com/caddy-dns/cloudflare@v0.2.4"
        "github.com/caddyserver/transform-encoder@v0.0.0-20260423033309-ba4124974830"
      ];
      hash = "sha256-kRUs6cJLicDNANibXOLLwKq3nqyzxypbnKMkdBHNz+U=";
    };

    globalConfig = ''
      admin off

      servers {
        client_ip_headers X-Forwarded-For X-Real-IP
        trusted_proxies static private_ranges
        trusted_proxies_strict
      }
    '';

    # Snippets, imported by name from each vhost below (matches the original Caddyfile)
    extraConfig = ''
      (cloudflare_tls) {
        tls {
          dns cloudflare {$CF_API_TOKEN}
        }
      }

      (bunny_tls) {
        tls {
          dns bunny {$BUNNY_API_TOKEN}
        }
      }

      (logging) {
        log {
          output file /var/log/caddy/{args[0]}.log
          format transform "{common_log}"
        }
      }
    '';

    virtualHosts."srx.flur.dev".logFormat = null;
    virtualHosts."srx.flur.dev".extraConfig = ''
      import bunny_tls
      import logging srx.flur.dev

      encode zstd gzip

      @api {
        path /config
        path /healthz
        path /stats/errors
        path /stats/checker
      }

      @search {
        path /search
      }

      @imageproxy {
        path /image_proxy
      }

      @static {
        path /static/*
      }

      header {
        Content-Security-Policy "upgrade-insecure-requests; default-src 'none'; script-src 'self'; style-src 'self' 'unsafe-inline'; form-action 'self' https://github.com/searxng/searxng/issues/new; font-src 'self'; frame-ancestors 'self'; base-uri 'self'; connect-src 'self' https://overpass-api.de; img-src * data:; frame-src https://www.youtube-nocookie.com https://player.vimeo.com https://www.dailymotion.com https://www.deezer.com https://www.mixcloud.com https://w.soundcloud.com https://embed.spotify.com;"
        Permissions-Policy "accelerometer=(),camera=(),geolocation=(),gyroscope=(),magnetometer=(),microphone=(),payment=(),usb=()"
        Referrer-Policy "no-referrer"
        Strict-Transport-Security "max-age=31536000"
        X-Content-Type-Options "nosniff"
        X-Robots-Tag "noindex, noarchive, nofollow"
        -Server
      }

      header @api {
        Access-Control-Allow-Methods "GET, OPTIONS"
        Access-Control-Allow-Origin "*"
      }

      route {
        header Cache-Control "max-age=0, no-store"
        header @search Cache-Control "max-age=5, private"
        header @imageproxy Cache-Control "max-age=604800, public"
        header @static Cache-Control "max-age=31536000, public, immutable"
      }

      reverse_proxy localhost:8080 {
        header_up X-Forwarded-Port {http.request.port}
        header_up X-Real-IP {http.request.remote.host}
        header_up Connection "close"
      }
    '';

    virtualHosts."git.flur.dev".logFormat = null;
    virtualHosts."git.flur.dev".extraConfig = ''
      import bunny_tls
      import logging git.flur.dev

      encode zstd gzip

      header {
        Referrer-Policy "no-referrer"
        Strict-Transport-Security "max-age=31536000"
        X-Content-Type-Options "nosniff"
        -Server
      }

      # flurLab, reached over the WireGuard relay tunnel (modules/relay.nix / hosts/flurLab/services/wireguard.nix)
      reverse_proxy 10.100.0.2:3000 {
        header_up X-Forwarded-Port {http.request.port}
        header_up X-Real-IP {http.request.remote.host}
      }
    '';

    virtualHosts."flur34.com".logFormat = null;
    virtualHosts."flur34.com".extraConfig = ''
      import cloudflare_tls
      import logging flur34.com

      root * /srv
      encode zstd gzip
      try_files {path} /index.html
      file_server

      header {
        Permissions-Policy "accelerometer=(),camera=(),geolocation=(),gyroscope=(),magnetometer=(),microphone=(),payment=(),usb=()"
        Referrer-Policy "same-origin"
        X-Content-Type-Options "nosniff"
        X-Robots-Tag "noindex, nofollow, noarchive, nositelinkssearchbox, nosnippet, notranslate, noimageindex"
        -Server
      }

      @static {
        path_regexp static \.(js|css|woff2?|ttf|png|jpg|jpeg|svg|gif|ico|mp4|webm)$
      }
      header @static Cache-Control "public, max-age=31536000, immutable"

      reverse_proxy localhost:8181
    '';

    virtualHosts."beta.flur34.com".logFormat = null;
    virtualHosts."beta.flur34.com".extraConfig = ''
      import cloudflare_tls
      import logging beta.flur34.com

      root * /srv
      encode zstd gzip

      header {
        Permissions-Policy "accelerometer=(),camera=(),geolocation=(),gyroscope=(),magnetometer=(),microphone=(),payment=(),usb=()"
        Referrer-Policy "same-origin"
        X-Content-Type-Options "nosniff"
        -Server
      }

      @root {
        path /
      }
      header @root {
        X-Robots-Tag "nofollow, noarchive, nosnippet, noimageindex"
      }

      @other {
        not path /
      }
      header @other {
        X-Robots-Tag "noindex, nofollow, noarchive, nosnippet, noimageindex"
      }

      @static {
        path_regexp static \.(js|css|woff2?|ttf|png|jpg|jpeg|svg|gif|ico|mp4|webm)$
      }
      header @static Cache-Control "public, max-age=31536000, immutable"

      handle /update {
        rewrite * /v1/update
        reverse_proxy http://localhost:8384
      }

      try_files {path} /index.html
      file_server
      reverse_proxy http://localhost:8383
    '';

    virtualHosts."sync.shiori.gg".logFormat = null;
    virtualHosts."sync.shiori.gg".extraConfig = ''
      import cloudflare_tls
      import logging sync.shiori.gg

      reverse_proxy localhost:8282
    '';

    virtualHosts."dev.shiori.gg".logFormat = null;
    virtualHosts."dev.shiori.gg".extraConfig = ''
      import cloudflare_tls
      import logging dev.shiori.gg

      root * /var/www/shiori.gg/
      file_server
    '';
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile =
    if haveCaddySecrets then
      config.sops.secrets."caddy-cloudflare-env".path
    else
      # Populate manually until secrets/system/vps/caddy.yaml exists in nix-secrets
      "-/etc/caddy/cloudflare.env";

  # Bans bot probes for wp-admin/xmlrpc.php/etc across all Caddy sites (not WordPress-specific
  # despite the name - carried over verbatim from /etc/fail2ban/{jail.d,filter.d}/caddy-wordpress.conf)
  services.fail2ban.jails.caddy-wordpress = {
    filter = ''
      [Definition]
      failregex = ^<HOST> .* "(GET|POST|HEAD) .*/wp-(admin|content|includes|login\.php|config\.php|cron\.php|json|trackback)
                  ^<HOST> .* "(GET|POST|HEAD) .*/xmlrpc\.php
                  ^<HOST> .* "(GET|POST|HEAD) .*/wlwmanifest\.xml
      ignoreregex =
    '';
    settings = {
      enabled = true;
      port = "http,https";
      logpath = "/var/log/caddy/*.log";
      maxretry = 1;
      findtime = 86400;
      bantime = 604800;
      backend = "auto";
    };
  };
}
