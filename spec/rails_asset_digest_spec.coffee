grunt = require("grunt")
cp    = require("child_process")
read  = grunt.file.read
write = grunt.file.write

runGruntTask = (task, config, done) ->
  cp.spawn("grunt",
    [
      task,
      "--config", JSON.stringify(config),
      "--tasks", "../tasks"
      "--gruntfile", "spec/Gruntfile.coffee"
    ],
    {stdio: 'inherit'}
  ).on("exit", -> done())

createWorkspace = (workspacePath) ->
  cp.exec "mkdir -p #{workspacePath}"

cleanWorkspace = (workspaceRoot) ->
  cp.exec "rm -rf #{workspaceRoot}"

beforeEach -> createWorkspace(@workspacePath = "spec/tmp/public/assets")
afterEach  -> cleanWorkspace("spec/tmp/")

describe "rails_asset_digest", ->

  describe "appends entries to an existing rails manifest", ->
    Given ->
      @existingManifest =
        """
        ---
        some/assetpipeline/generated-tree.js: some/assetpipeline/generated-tree-536a9e5ddkfjc9v9e9r939494949491.js
        another/tree-we-didnt-touch.js: another/entry-we-didnt-touch-536a9e5d711e0593e43360ad330ccc31.js
        """

      @expectedManifest =
        """
        ---
        some/assetpipeline/generated-tree.js: some/assetpipeline/generated-tree-536a9e5ddkfjc9v9e9r939494949491.js
        another/tree-we-didnt-touch.js: another/entry-we-didnt-touch-536a9e5d711e0593e43360ad330ccc31.js
        rootfile.js: rootfile-54267464ea71790d3ec68e243f64b98e.js
        sourcemapping.js.map: sourcemapping-742adbb9b78615a3c204b83965bb62f7.js.map
        othersubdirectory/generated-tree.js: othersubdirectory/generated-tree-e4ce151e4824a9cbadf1096551b070d8.js
        subdirectory/with/alibrary.js: subdirectory/with/alibrary-313b3b4b01cec6e4e82bdeeb258503c5.js
        style.css: style-7527fba956549aa7f85756bdce7183cf.css
        """

    Given ->
      @config =
        rails_asset_digest:
          sut:
            options:
              assetPath: "tmp/public/assets/"
            files:
              "tmp/public/assets/rootfile.js"                         : "../test/common_rails_project/public/assets/javascripts/rootfile.js"
              "tmp/public/assets/sourcemapping.js.map"                : "../test/common_rails_project/public/assets/javascripts/sourcemapping.js.map"
              "tmp/public/assets/othersubdirectory/generated-tree.js" : "../test/common_rails_project/public/assets/javascripts/othersubdirectory/generated-tree.js"
              "tmp/public/assets/subdirectory/with/alibrary.js"       : "../test/common_rails_project/public/assets/javascripts/subdirectory/with/alibrary.js"
              "tmp/public/assets/style.css"                           : "../test/common_rails_project/public/assets/stylesheets/style.css"

    Given -> write("#{@workspacePath}/manifest.yml", @existingManifest)
    Given (done) -> runGruntTask("rails_asset_digest", @config, done)
    When  -> @writtenManifest = read("#{@workspacePath}/manifest.yml")
    Then  -> @writtenManifest == @expectedManifest