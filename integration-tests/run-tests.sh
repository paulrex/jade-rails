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

# This is a utility function to fail-fast if an assertion fails.
# It takes 1 argument which is the text of the error itself.
raise () {
  echo
  echo "ERROR"
  echo $1
  echo
  exit 1
}

# To simplify all the other references to files and paths, force this script to only run from inside
# the integration-tests directory itself.
current_directory=$(pwd)
if [[ $current_directory != *"integration-tests" ]]; then
  raise "This script must be run from inside the integration-tests directory."
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
  installed_rails_version=$(bundle exec rails -v)
  if [[ $installed_rails_version != "Rails ${rails_version}" ]]; then
    raise "Failed to correctly install Rails version ${rails_version}."
  fi

  # Instantiate a new Rails app using that version.
  app_name="test-${rails_version}"
  bundle exec rails new ${app_name}

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

  # Now set up a simple Jade template, along with the controller, view, and route to render it.
  # These files look exactly the same regardless of Rails version or app name.
  cp ../fixtures/amazing_template.jst.jade ./app/assets/javascripts/
  cp ../fixtures/test_controller.rb ./app/controllers/
  mkdir ./app/views/test
  cp ../fixtures/index.html.erb ./app/views/test/
  cp ../fixtures/routes.rb ./config/routes.rb

  # Now that we have a barebones Rails app set up with the gem and a Jade
  # template, we test to ensure the template compiles and renders properly, in
  # both dev and production. We also want to test the ability to set the
  # config.jade flags in the app code. So, specifically, the test plan is:
  #
  # 1. Test production assets.
  #     - Compile assets for production.
  #     - Confirm that the compiled application.js contains a Jade template ready to use.
  #     - Confirm that the compiled application.js does not have Jade code
  #       compiled with compileDebug (because this should be disabled by the
  #       default configuration for this gem). See lib/jade/rails/engine.rb.
  # 2. Test development assets.
  #     - Start a Rails dev server and request the application.js compiled on the fly for dev.
  #     - Confirm that the application.js served in development has the Jade template ready to use.
  #     - Confirm that the template was compiled with compileDebug turned on.
  # 3. Test app-level configuration.
  #     - Set config.jade.compile_debug to true in config/environments/production.rb.
  #     - Recompile assets for production.
  #     - Confirm that the compiled application.js has debugging code inside the Jade template.
  #
  # (Note that, by default, our test code also requires all commands to execute
  # successfully, because of the settings at the top of this script.)

  # These are the strings we'll check for to indicate whether or not
  # compileDebug was used when compiling the Jade template.
  compile_debug_off_string="this.JST.amazing_template=function(){var e=[];return e.push('<h1>Jade: A Template Engine</h1>"
  compile_debug_on_string="jade_debug.shift()"

  # 1. Test production assets.
  RAILS_ENV=production bundle exec rake assets:precompile
  production_compiled_js=$(cat public/assets/application-*.js)
  if [[ $production_compiled_js != *"$compile_debug_off_string"* ]]; then
    raise "Precompiled application.js did not have expected production-ready Jade template code."
  fi
  if [[ $production_compiled_js == *"$compile_debug_on_string"* ]]; then
    raise "Precompiled application.js contained debugging code inside Jade template."
  fi

  # 2. Test development assets.
  # Start up a server, request the compiled asset for the Jade template, and check its contents.
  # bundle exec rails s -p ${dev_server_port} > /dev/null 2>&1 &
  bundle exec rails s -p ${dev_server_port} &
  sleep 5 # Give the dev server time to boot.
  dev_compiled_js=$(curl localhost:${dev_server_port}/assets/application.js)
  if [[ $dev_compiled_js != *"$compile_debug_on_string"* ]]; then
    raise "Development application.js did not contain debugging code inside Jade template."
  fi
  # Clean up the backgrounded dev server.
  kill %%

  # 3. Test app-level configuration.
  # TODO

  # Clean out the instantiated Rails app.
  cd ..
  rm -r ${app_name}

  echo
  echo "Successfully completed integration test for Rails v${rails_version}."
  echo
done
