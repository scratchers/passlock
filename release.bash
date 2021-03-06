#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "version required"
    exit 1
fi

# move to working directory
cd $( dirname "${BASH_SOURCE[0]}" )

# add version to script
sed -r -i "s/const VERSION = '.+\+dev'/const VERSION = '$1'/" src/DatabaseManagementSystem.php

php -r '
    require "vendor/autoload.php";

    use Composer\Semver\Semver;
    use gpgl\core\DatabaseManagementSystem as DB;

    if (!Semver::satisfies(DB::VERSION, DB::VERSION_CONSTRAINT)) {
        throw new Exception("version does not satisfy version constraint");
    }
'

git commit -am "release version $1"
git tag -s "$1"

sed -i "s/const VERSION = '$1'/const VERSION = '$1+dev'/" src/DatabaseManagementSystem.php
git commit -am "bump version $1+dev"
