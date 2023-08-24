#!/bin/zsh

# Alias PHP version to Brew versions
function p() {
  zparseopts -D -E -a opts -verbose::=verbose v::=version -version::=version
  VERSION='0.0.2'
  brew_prefix=$(brew --prefix)

  function log() {
    if [[ $verbose ]]; then
      echo $1
    fi
  }

  function get_php_bin_path() {
    ls -d $brew_prefix/Cellar/php*/$1*/bin
  }

  function get_php_versions() {
    ls -d $brew_prefix/Cellar/php*/* | grep -E -o '/[0-9]+.[0-9]+' | sed -E 's#/##'
  }

  function set_php_version() {
    _current_php_version=$(p current)
    _current_path=$(get_php_bin_path "$_current_php_version")
    _old_path=$(php -r "echo str_replace('$_current_path:', '', '$PATH');")

    if [[ -z $1 ]]; then
      export PATH="$_old_path"
      return
    fi

    PHP_VERSIONS="$(get_php_versions)"

    _version_exists="$(php -r "echo preg_match('/^$1$/m', '$PHP_VERSIONS');")"

    if [[ $_version_exists == "0" ]]; then
      echo "Could not find PHP version $1, is it installed?";
      return
    fi

    _new_path=$(get_php_bin_path $1)
    _old_path=$(php -r "echo str_replace('$_new_path:', '', '$_old_path');")
    export PATH="$_new_path:$_old_path"
  }

  log "p@$VERSION"

  if [[ $1 == 'current' ]]; then
    local PHP_VERSION=$(php -v | grep -Eo 'PHP [0-9]+.[0-9]+')
    echo ${PHP_VERSION/PHP /};
    return;
  fi

  if [[ $1 == 'use' ]]; then
    if [[ $2 == 'system' ]]; then
      log 'use system'
      set_php_version
    elif [[ -n $2 ]]; then
      log "use $2"
      set_php_version $2
    else
      composerjson_path=$(_find_up composer.json | tr -d '[:space:]')
      if [[ -a $composerjson_path/composer.json ]]; then
        p_version=$(cat $composerjson_path/composer.json | jq '.require.php' | grep -Eo '[0-9](.[0-9])?' | head -n 1)
        log "use v$p_version from composer.json"
        if [[ -n $p_version ]]; then
          set_php_version $p_version
          return
        fi
      fi
    fi
    return
  fi

  if [[ $1 == 'list' || $1 == 'ls' ]]; then
    get_php_versions
    return
  fi

  if [[ $version == '--version' || $version == '-v' ]]; then
    echo $VERSION
    return
  fi;

  echo "p $VERSION
  A fast and simple PHP manager

  USAGE:
  p <SUBCOMMAND>

  FLAGS:
  -h, --help
  Prints help information

  -v, --version
  Prints version information

  SUBCOMMANDS:
  current       Print the current PHP version
  use [version] Change PHP version
  list          List all available PHP versions [alias: ls]
  "
}
