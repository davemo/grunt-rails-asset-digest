module.exports = (grunt) ->

  grunt.loadTasks "../tasks"

  grunt.initConfig
    rails_asset_digest:
      with_trailing_slash_scenario:
        options:
          assetPath: "tmp/public/assets"
        files:
          "tmp/public/assets/rootfile.js"                         : "common_rails_project/public/assets/javascripts/rootfile.js"
          "tmp/public/assets/sourcemapping.js.map"                : "common_rails_project/public/assets/javascripts/sourcemapping.js.map"
          "tmp/public/assets/othersubdirectory/generated-tree.js" : "common_rails_project/public/assets/javascripts/othersubdirectory/generated-tree.js"
          "tmp/public/assets/subdirectory/with/alibrary.js"       : "common_rails_project/public/assets/javascripts/subdirectory/with/alibrary.js"
          "tmp/public/assets/style.css"                           : "common_rails_project/public/assets/stylesheets/style.css"