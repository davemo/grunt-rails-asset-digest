#
# * grunt-asset-digest
# * https://github.com/davemo/grunt-asset-digest
# *
# * Copyright (c) 2013 David Mosher
# * Licensed under the MIT license.
#
"use strict"
module.exports = (grunt) ->

  initialManifestPath = "tmp/public/assets/manifest.yml"

  grunt.initConfig
    shell:
      testsetup:
        command: [
          "mkdir -p tmp/public/assets"
          "touch #{initialManifestPath}"
          "echo --- >> #{initialManifestPath}"
          "echo some\/assetpipeline\/generated-tree.js: some\/assetpipeline\/generated-tree-536a9e5ddkfjc9v9e9r939494949491.js >> #{initialManifestPath}"
          "echo another\/tree-we-didnt-touch.js: another\/entry-we-didnt-touch-536a9e5d711e0593e43360ad330ccc31.js >> #{initialManifestPath}"
        ].join("&&")

    clean:
      tests: ["tmp"]

    asset_digest:
      default_options:
        options:
          assetPath: "tmp/public/assets/"

        files:
          "tmp/public/assets/rootfile.js"          : "test/sample_project/public/assets/javascripts/rootfile.js"
          "tmp/public/assets/sourcemapping.js.map" : "test/sample_project/public/assets/javascripts/sourcemapping.js.map"
          "tmp/public/assets/othersubdirectory/generated-tree.js" : "test/sample_project/public/assets/javascripts/othersubdirectory/generated-tree.js"
          "tmp/public/assets/subdirectory/with/alibrary.js" : "test/sample_project/public/assets/javascripts/subdirectory/with/alibrary.js"
          "tmp/public/assets/style.css" : "test/sample_project/public/assets/stylesheets/style.css"

    nodeunit:
      tests: ["test/*_test.js"]


  grunt.loadTasks "tasks"

  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-nodeunit"
  grunt.loadNpmTasks "grunt-shell"

  grunt.registerTask "test", ["clean", "shell:testsetup", "asset_digest", "nodeunit"]
  grunt.registerTask "default", ["test"]
