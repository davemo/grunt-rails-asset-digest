#
# * grunt-rails-asset-digest
# * https://github.com/davemo/grunt-rails-asset-digest
# *
# * Copyright (c) 2013 David Mosher
# * Licensed under the MIT license.
#
"use strict"
module.exports = (grunt) ->

  TEST_MANIFEST_PATH = "tmp/public/assets/manifest.yml"

  TEST_FILES =
    "tmp/public/assets/rootfile.js"          : "test/common_rails_project/public/assets/javascripts/rootfile.js"
    "tmp/public/assets/sourcemapping.js.map" : "test/common_rails_project/public/assets/javascripts/sourcemapping.js.map"
    "tmp/public/assets/othersubdirectory/generated-tree.js" : "test/common_rails_project/public/assets/javascripts/othersubdirectory/generated-tree.js"
    "tmp/public/assets/subdirectory/with/alibrary.js" : "test/common_rails_project/public/assets/javascripts/subdirectory/with/alibrary.js"
    "tmp/public/assets/style.css" : "test/common_rails_project/public/assets/stylesheets/style.css"

  grunt.initConfig
    shell:
      create_empty_manifest:
        command: [
          "mkdir -p tmp/public/assets"
          "touch #{TEST_MANIFEST_PATH}"
        ].join("&&")

      add_preexisting_manifest_entries:
        command: "cat test/fixtures/manifest-with-existing-entries.yml >> #{TEST_MANIFEST_PATH}"

      add_manifest_header:
        command: "cat test/fixtures/manifest-with-no-entries.yml >> #{TEST_MANIFEST_PATH}"

      add_stale_manifest_entries:
        command: "cat test/fixtures/manifest-with-stale-entries.yml >> #{TEST_MANIFEST_PATH}"

    clean:
      tests: ["tmp"]

    rails_asset_digest:
      options:
        assetPath: "tmp/public/assets/"

      appends_to_manifest_with_existing_entries:
        files: TEST_FILES

      appends_to_manifest_with_no_entries:
        files: TEST_FILES

      replaces_stale_entries:
        files: TEST_FILES

    nodeunit:
      appends_to_manifest_with_existing_entries:
        ["test/appends_entries_to_existing_manifest_test.js"]

      appends_to_manifest_with_no_entries:
        ["test/appends_entries_to_manifest_with_no_entries_test.js"]

      replaces_stale_entries:
        ["test/replaces_stale_entries_test.js"]

  grunt.loadTasks "tasks"

  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-nodeunit"
  grunt.loadNpmTasks "grunt-shell"

  grunt.registerTask "test-appending-to-manifest-with-existing-entries", [
    "clean"
    "shell:create_empty_manifest"
    "shell:add_preexisting_manifest_entries"
    "rails_asset_digest:appends_to_manifest_with_existing_entries"
    "nodeunit:appends_to_manifest_with_existing_entries"
  ]

  grunt.registerTask "test-appending-to-manifest-with-no-entries", [
    "clean"
    "shell:create_empty_manifest"
    "shell:add_manifest_header"
    "rails_asset_digest:appends_to_manifest_with_no_entries"
    "nodeunit:appends_to_manifest_with_no_entries"
  ]

  grunt.registerTask "test-replaces-stale-entries", [
    "clean"
    "shell:create_empty_manifest"
    "shell:add_stale_manifest_entries"
    "rails_asset_digest:replaces_stale_entries"
    "nodeunit:replaces_stale_entries"
  ]

  grunt.registerTask "test", [
    "test-appending-to-manifest-with-existing-entries"
    "test-appending-to-manifest-with-no-entries"
    "test-replaces-stale-entries"
  ]

  grunt.registerTask "default", ["test"]
