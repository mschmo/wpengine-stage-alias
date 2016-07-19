#!/bin/bash

# Make sure homebrew is installed
command -v brew >/dev/null 2>&1 || {
  echo "Homebrew not found. Installing..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

# Install nginx-full with subs filter module
brew tap homebrew/nginx
sudo brew install nginx-full --with-subs-filter-module

# Configure hosts file and nginx servers
declare -a sites=("$@")
for site in "${sites[@]}"
do
  if ! grep -Fxq "127.0.0.1  staging.$site.com" /etc/hosts
  then
    sudo -- sh -c -e "echo '127.0.0.1  staging.$site.com' >> /etc/hosts";
  fi
  sed -e "s/\${site}/$site/g" staging.conf > /usr/local/etc/nginx/servers/${site}.conf
done

# Start nginx service
sudo nginx
echo "Staging servers started. Access at:"
for site in "${sites[@]}"
do
  echo "staging.$site.com"
done
