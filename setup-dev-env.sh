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

echo "- Run seed file"
MIX_ENV=dev mix run priv/repo/seeds.exs
MIX_ENV=test mix run priv/repo/seeds.exs

echo "- Generate the ExDoc project documentation"
mix docs

echo "- Generate an ERD (Entity Relationship Diagram)"
if command -v dot &> /dev/null
then
    # https://hexdocs.pm/ecto_erd/Mix.Tasks.Ecto.Gen.Erd.html
    mix ecto.gen.erd && dot -Tpdf ecto_erd.dot -o documentation/erd.pdf
    rm ecto_erd.dot # Remove the .dot file
else
    echo "  WARNING: Can't generate an ERD!"
    echo "           Please install Graphviz (https://graphviz.org/)"
fi

echo "- Setup Development Environment: Done"
