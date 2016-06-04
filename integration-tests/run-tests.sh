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
#---------------------------------------------------------------------------------------------------
set -e
set -o pipefail

rails_versions=(4.1.15 4.2.6) 
echo ${rails_versions[0]}
echo ${rails_versions[1]}
