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
rails_versions=(4.1.15 4.2.6)
# rails_versions=(4.1.15)
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

  # Inside this Rails app, set up the jade-rails gem.
  # (1) Add it to the Gemfile.
  sed -i '' "$ a\\
    gem 'jade-rails', :path => '../../'
    " ./${app_name}/Gemfile
  # (2) Run `bundle install` for the Rails app.
  cd ${app_name}
  bundle install
  # (3) Add the jade-runtime to the application.js.
  sed -i '' "/require_tree/ i\\
    //= require jade/runtime
    " ./app/assets/javascripts/application.js
  # (4) Add gem configuration into the Rails app config.
  sed -i '' "/class Application/ a\\
    config.jade.pretty = true
    " ./config/application.rb
  sed -i '' "/pretty/ a\\
    config.jade.compile_debug = true
    " ./config/application.rb

  # Now set up a simple Jade template, along with the controller, view, and route to render it.
  # These files look exactly the same regardless of Rails version or app name.
  cp ../amazing_template.jst.jade ./app/assets/javascripts/
  cp ../test_controller.rb ./app/controllers/
  mkdir ./app/views/test
  cp ../index.html.erb ./app/views/test/
  cp ../routes.rb ./config/routes.rb

  # Production Environment Test
  # Simply ensure that asset precompilation succeeds.
  RAILS_ENV=production bundle exec rake assets:precompile
  # TODO: Also assert on the contents of the compiled application.js.

  # Development Environment Test
  # Start up a server, request the compiled asset for the Jade template, and check its contents.
  bundle exec rails s -p ${dev_server_port} > /dev/null 2>&1 &
  sleep 5 # give the dev server time to boot
  compiled_template=$(curl localhost:${dev_server_port}/assets/amazing_template.js)
  echo
  echo $compiled_template
  echo
  if [[ $compiled_template != *"jade_debug.shift()"* ]]
  then
    echo
    echo "ERROR"
    echo "Compiled Jade template did not contain expected string 'jade_debug.shift()'."
    echo
    exit 1
  fi
  # Clean up the backgrounded dev server.
  kill %%

  # Clean out the instantiated Rails app.
  cd ..
  rm -r ${app_name}

  echo
  echo "Successfully completed integration test for Rails v${rails_version}."
  echo
done
