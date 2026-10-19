# This process only needs to be run on some hosted VM location that will serve the dotfile installer
#
# start with installing puppet
#    apt-get update && apt-get install -y puppet
# Get cloudflare origin certs and place them in ~/dotfiles/ssl.<key|cert>
#    You can find them here https://dash.cloudflare.com/0e0927350e78eca441f33e02cbf0046c/opennetadmin.com/ssl-tls/origin
# you can run it with the following
#    puppet apply ~/dotfiles/installer-hosting.pp
# If on an oracle vm, ensure you have added the iptables rules. Add them after dport 22
#    vi /etc/iptables/rules.v4
#        -A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
#    netfilter-persistent reload
# Also setup on oracle console
#  instance->networking->subnet->security
#  select default security list->security rules and then add 443

# Installs nginx and serves ~/dotfiles/dot.sh directly (no copy) over HTTPS
# at /install.sh and /, for whatever hostname or IP reaches the box.
# Plain HTTP redirects to HTTPS. The TLS cert and key live in ~/dotfiles.
#
# Usage:
#   sudo puppet apply ~/dotfiles/installer-hosting.pp
#
# Then:
#   curl -fsSL https://<any-name-pointing-here>
# or
#   curl -fsSL https://<any-name-pointing-here>/install.sh

# The directory this manifest lives in, as an absolute path with symlinks
# resolved. `puppet apply <file>` sets the environment's manifest to that
# file, and the ERB template reads it.
$dotfiles_dir = inline_template('<%= File.dirname(File.realpath(scope.compiler.environment.manifest)) %>')
$parent_dir   = inline_template('<%= File.dirname(@dotfiles_dir) %>')

$script       = "${dotfiles_dir}/dot.sh"

# TLS files inside your dotfiles. Adjust names to match yours.
# Use the full chain (server cert + intermediates) for ssl_cert.
$ssl_cert     = "${dotfiles_dir}/ssl.cert"
$ssl_key      = "${dotfiles_dir}/ssl.key"

$site_name    = 'dotfiles'

package { ['nginx', 'acl']:
  ensure => installed,
}

# Ubuntu home dirs are 750, so nginx workers (www-data) can't reach dot.sh.
# Grant www-data traverse-only (x) on the two directories in the path.
# The cert and key don't need this: nginx's master process reads them as root.
exec { 'www-data-traverse-dotfiles':
  command  => "setfacl -m u:www-data:x ${parent_dir} ${dotfiles_dir}",
  unless   => "getfacl -cp ${parent_dir} | grep -q '^user:www-data:..x' && getfacl -cp ${dotfiles_dir} | grep -q '^user:www-data:..x'",
  provider => shell,
  path     => ['/usr/bin', '/bin'],
  require  => Package['acl', 'nginx'],
}

file { "/etc/nginx/sites-available/${site_name}":
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => @("CONF"/$),
    # HTTP: redirect everything to HTTPS on whatever host was requested
    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;

        return 301 https://\$host\$request_uri;
    }

    # HTTPS: default_server + "_" = answer for any hostname or bare IP
    server {
        listen 443 ssl default_server;
        listen [::]:443 ssl default_server;
        http2 on;
        server_name _;
        server_tokens off;

        ssl_certificate     ${ssl_cert};
        ssl_certificate_key ${ssl_key};
        ssl_protocols       TLSv1.2 TLSv1.3;
        ssl_session_cache   shared:SSL:10m;
        ssl_session_timeout 1d;

        add_header Strict-Transport-Security "max-age=31536000" always;

        # Serve the script as plain text so curl | sh works and browsers show it
        default_type text/plain;
        charset utf-8;
        add_header Cache-Control "no-cache";

        # Read straight from your dotfiles; edits are live immediately
        location = /install.sh {
            alias ${script};
        }

        # "/" ends in a slash, so nginx would treat it as a directory and
        # look for an index file. Internally hand it to /install.sh instead.
        location = / {
            rewrite ^ /install.sh last;
        }

        location / {
            return 404;
        }
    }
    | CONF
  require => Package['nginx'],
  notify  => Service['nginx'],
}

file { "/etc/nginx/sites-enabled/${site_name}":
  ensure  => link,
  target  => "/etc/nginx/sites-available/${site_name}",
  require => File["/etc/nginx/sites-available/${site_name}"],
  notify  => Service['nginx'],
}

# Remove the stock Ubuntu welcome site
file { '/etc/nginx/sites-enabled/default':
  ensure  => absent,
  require => Package['nginx'],
  notify  => Service['nginx'],
}

exec { 'nginx-config-test':
  command     => '/usr/sbin/nginx -t',
  refreshonly => true,
  subscribe   => [
    File["/etc/nginx/sites-available/${site_name}"],
    File["/etc/nginx/sites-enabled/${site_name}"],
    File['/etc/nginx/sites-enabled/default'],
  ],
  before      => Service['nginx'],
}

service { 'nginx':
  ensure  => running,
  enable  => true,
  require => [Package['nginx'], Exec['www-data-traverse-dotfiles']],
}
