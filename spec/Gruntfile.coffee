"use strict"
module.exports = (grunt) ->

  grunt.loadTasks "../tasks"

  TEST_FILES =
    "tmp/public/assets/rootfile.js"                         : "../test/common_rails_project/public/assets/javascripts/rootfile.js"
    "tmp/public/assets/sourcemapping.js.map"                : "../test/common_rails_project/public/assets/javascripts/sourcemapping.js.map"
    "tmp/public/assets/othersubdirectory/generated-tree.js" : "../test/common_rails_project/public/assets/javascripts/othersubdirectory/generated-tree.js"
    "tmp/public/assets/subdirectory/with/alibrary.js"       : "../test/common_rails_project/public/assets/javascripts/subdirectory/with/alibrary.js"
    "tmp/public/assets/style.css"                           : "../test/common_rails_project/public/assets/stylesheets/style.css"

  grunt.initConfig
    rails_asset_digest:
      options:
        assetPath: "tmp/public/assets/"

      appends_to_manifest_with_existing_entries:
        files: TEST_FILES

      # appends_to_manifest_with_no_entries:
      #   files: TEST_FILES

      # replaces_stale_entries:
      #   files: TEST_FILES

      # writes_contents_of_files_properly:
      #   files: TEST_FILES

      # normalizes_asset_path_to_add_trailing_slash:
      #   options:
      #     assetPath: "tmp/public/assets"
      #   files: TEST_FILES