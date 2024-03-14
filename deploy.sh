#!/usr/bin/env bash
set -xeuo pipefail
# if you don't have this yet, copy and modify deploy_config_template.sh
. deploy_config.sh

# push to itch
butler push --if-changed html5/ $itch_project:html5

# get itch version
export itch_version=$(butler status $itch_project:html5 | grep html5 | cut -d '|' -f 5 | tr -d ' ')

# if we don't already have it, set local git tag
export itch_local_tag=itch-html5-$itch_version
git tag -l | grep $itch_local_tag | git tag $itch_local_tag
