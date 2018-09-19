#!/usr/bin/env bash

download_and_install_erlang() {
  local otp_version="$1"
  local install_dir="$2"
  local cache_dir="$3"

  mkdir -p "$install_dir"
  mkdir -p "$cache_dir"

  local filename="otp_src_$otp_version.tar.gz"
  local url="http://erlang.org/download/$filename"
  local tarpath="$cache_dir/$filename"
  local build_dir="$cache_dir/build"
  export ERL_TOP="$build_dir"

  mkdir -p "$build_dir"

  if [ ! -f "$tarpath" ]; then
    rm -rf "$cache_dir/*"
    rm -rf "$install_dir/*"

    echo "Downloading OTP $otp_version"
    curl -# "$url" -o "$tarpath" || (echo "Unable to download erlang" && exit 1)

    tar xzf "$tarpath" -C "$build_dir" --strip-components=1

    echo "Compiling erlang, this could take a few minutes"

    cd $build_dir
    ./configure
    make
    make RELEASE_ROOT="$install_dir" release
    cd -

    $install_dir/Install -minimal "$install_dir"

    chmod +x "$install_dir/bin/*"
  else
    echo "Using cached OTP $otp_version"
  fi

  export PATH="$install_dir/bin:$PATH"
}

download_and_install_elixir() {
  local elixir_version="$1"
  local otp_version="$2"
  local install_dir="$3"
  local cache_dir="$4"

  mkdir -p "$install_dir"
  mkdir -p "$cache_dir"

  local filename="$elixir_version-otp-$otp_version.zip"
  local url="https://repo.hex.pm/builds/elixir/v$filename"
  local tarpath="$cache_dir/$filename"
  local build_dir="$cache_dir/build/"

  if [ ! -f "$tarpath" ]; then
    rm -rf "$cache_dir/*"
    rm -rf "$install_dir/*"

    echo "Downloading elixir $elixir_version"
    curl -# "$url" -o "$tarpath"

    if [ "$?" -ne "0" ]; then
      echo "Unable to download an elixir for OTP $otp_version, falling back to generic elixir version"
      local fallback_url="https://repo.hex.pm/builds/elixir/v$elixir_version.zip"
      curl -# "$fallback_url" -o "$tarpath" || (echo "Unable to download elixir" && exit 1)
    fi

    unzip -q "$tarpath" -d "$install_dir/"

    chmod +x "$install_dir/bin/*"
  else
    echo "Using cached elixir $elixir_version"
  fi

  export PATH="$install_dir/bin:$PATH"
}

download_and_install_node() {
  local node_version="$1"
  local npm_version="$2"
  local install_dir="$3"
  local cache_dir="$4"

  mkdir -p "$install_dir"
  mkdir -p "$cache_dir"

  local os="$(uname | tr A-Z a-z)"
  local filename="node-v$version-$os-x86.tar.gz"
  local url="http://s3pository.heroku.com/node/v$version/$filename"
  local tarpath="$cache_dir/$filename"

  if [ ! -f "$tarpath" ]; then
    echo "Downloading node"
    curl -# "$url" -o "$tarpath" || (echo "Unable to download node" && exit 1)

    tar xzf "$tarpath" -C "$install_dir" --strip-components=1

    chmod +x "$install_dir/bin/*"
  else
    echo "Using cached node $node_version"
  fi

  export PATH="$install_dir/bin:$PATH"

  if [[ `npm --version` != "$npm_version" ]]; then
    echo "Updating npm to $npm_version"
    npm install --unsafe-perm --quiet -g npm@$npm_version
  fi
}
