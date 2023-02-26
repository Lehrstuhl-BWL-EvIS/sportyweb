#!/bin/bash

# The collaborative development of complex software like
# Sportyweb will be much easier if each developer starts
# on the same basis.
#
# This script takes care of setting up a new and clean
# development environment each time it's run. It is meant
# to be run on a regular basis. E.g. after each DB change.
#
# The script has to be executable. On Mac & Linux run:
# chmod +x setup-dev-env.sh
#
# To run/execute the script:
# ./setup-dev-env.sh

set -o errexit
set -o nounset
set -o pipefail

echo "- Setup Development Environment: Start"

echo "- Install and update dependencies"
mix deps.get

echo "- Drop databases (Dev & Test)"
MIX_ENV=dev  mix ecto.drop
MIX_ENV=test mix ecto.drop

echo "- Create databases (Dev & Test)"
MIX_ENV=dev  mix ecto.create
MIX_ENV=test mix ecto.create

echo "- Run database migrations (Dev & Test)"
MIX_ENV=dev  mix ecto.migrate
MIX_ENV=test mix ecto.migrate

echo "- Generate a dump of the SQL structure"
MIX_ENV=dev mix ecto.dump

echo "- Run seed file"
mix run priv/repo/seeds.exs

echo "- Generate the ExDoc project documentation"
mix docs

echo "- Generate an ERD (Entity Relationship Diagram)"
if command -v mmdc &> /dev/null
then
    # https://hexdocs.pm/ecto_erd/Mix.Tasks.Ecto.Gen.Erd.html#module-mermaid
    mix ecto.gen.erd --output-path=ecto_erd.mmd && mmdc -i ecto_erd.mmd -o documentation/erd.pdf
    rm ecto_erd.mmd # Remove the mermaid file
else
    echo "  WARNING: Can't generate an ERD!"
    echo "           Please install mermaid-cli (https://github.com/mermaid-js/mermaid-cli)"
fi

echo "- Setup Development Environment: Done"
