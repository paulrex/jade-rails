#!/bin/bash
#
# This script runs "integration tests" for the jade-rails gem.
# For each Rails version we'd like to confirm compatibility with, the script will:
#   1. Instantiate a new Rails app.
#   2. Add the jade-rails gem to the app.
#   3. Set up a basic controller and view.
#   4. Add a simple Jade template, and set up the view to render it.
#   5. Assert that the Jade template is correctly compiled. Specifically:
#       5.1. In development, assert that the Jade template correctly compiles to a JS file.
#       5.2. In production, assert that:
#             - the application.js file compiles
#             - the application.js file contains the Jade template JS
#
# ASSUMPTIONS:
#   - This script is running on OS X. (The sed syntax is specific to OS X.)
#   - The bundler gem is globally available.
#   - rbenv is being used to manage Ruby versions.
#---------------------------------------------------------------------------------------------------
set -e
set -o pipefail

# To simplify all the other references to files and paths, force this script to only run from inside
# the integration-tests directory itself.
current_directory=$(pwd)
if [[ $current_directory != *"integration-tests" ]]
then
  echo
  echo "ERROR"
  echo "This script must be run from inside the integration-tests directory."
  echo
  exit 1
fi

# Test against the currently-supported Rails versions.
# See: http://guides.rubyonrails.org/maintenance_policy.html
# rails_versions=(4.1.15 4.2.6)
rails_versions=(4.1.15)
dev_server_port=30000
for rails_version in ${rails_versions[@]}; do
  echo
  echo "Beginning integration test for Rails v${rails_version}..."
  echo

  # Set up the version of Rails we're testing against.
  sed -i '' "5 s/.*/gem 'rails', '${rails_version}'/" ./Gemfile
  bundle install
  rbenv rehash
  installed_rails_version=$(rails -v)
  if [[ $installed_rails_version != "Rails ${rails_version}" ]]
  then
    echo
    echo "ERROR"
    echo "Failed to correctly install Rails version ${rails_version}."
    echo
    exit 1
  fi

  # Instantiate a new Rails app using that version.
  app_name="test-${rails_version}"
  rails new ${app_name}

  # TODO: Add test code here.

  # Clean out the instantiated Rails app.
  rm -r ${app_name}

  echo
  echo "Successfully completed integration test for Rails v${rails_version}."
  echo
done
