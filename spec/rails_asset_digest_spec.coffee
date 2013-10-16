grunt  = require("grunt")
spawn  = require("child_process").spawn
read   = grunt.file.read
write  = grunt.file.write
mkdir  = grunt.file.mkdir
clear  = grunt.file.delete
expand = grunt.file.expand

runGruntTask = (task, config, done) ->
  spawn("grunt",
    [
      task,
      "--config", JSON.stringify(config),
      "--tasks", "../tasks"
      "--gruntfile", "spec/Gruntfile.coffee"
    ],
    {stdio: 'inherit'}
  ).on("exit", -> done())

beforeEach -> mkdir @workspacePath = "spec/tmp/public/assets"
afterEach  -> clear "spec/tmp/"

describe "rails_asset_digest", ->

  Given ->
    @railsManifestEntries =
      """
      some/assetpipeline/generated-tree.js: some/assetpipeline/generated-tree-536a9e5ddkfjc9v9e9r939494949491.js
      another/tree-we-didnt-touch.js: another/entry-we-didnt-touch-536a9e5d711e0593e43360ad330ccc31.js
      """
    @taskManifestEntries =
      """
      rootfile.js: rootfile-54267464ea71790d3ec68e243f64b98e.js
      sourcemapping.js.map: sourcemapping-742adbb9b78615a3c204b83965bb62f7.js.map
      othersubdirectory/generated-tree.js: othersubdirectory/generated-tree-e4ce151e4824a9cbadf1096551b070d8.js
      subdirectory/with/alibrary.js: subdirectory/with/alibrary-313b3b4b01cec6e4e82bdeeb258503c5.js
      style.css: style-7527fba956549aa7f85756bdce7183cf.css
      """
    @staleManifestEntries =
      """
      rootfile.js: rootfile-OLDSHA.js
      sourcemapping.js.map: sourcemapping-OLDSHA.js.map
      othersubdirectory/generated-tree.js: othersubdirectory/generated-tree-OLDSHA.js
      subdirectory/with/alibrary.js: subdirectory/with/alibrary-OLDSHA.js
      style.css: style-OLDSHA.css
      """
    @config =
      rails_asset_digest:
        sut:
          options:
            assetPath: "tmp/public/assets/"
          files:
            "tmp/public/assets/rootfile.js"                         : "common_rails_project/public/assets/javascripts/rootfile.js"
            "tmp/public/assets/sourcemapping.js.map"                : "common_rails_project/public/assets/javascripts/sourcemapping.js.map"
            "tmp/public/assets/othersubdirectory/generated-tree.js" : "common_rails_project/public/assets/javascripts/othersubdirectory/generated-tree.js"
            "tmp/public/assets/subdirectory/with/alibrary.js"       : "common_rails_project/public/assets/javascripts/subdirectory/with/alibrary.js"
            "tmp/public/assets/style.css"                           : "common_rails_project/public/assets/stylesheets/style.css"

  context "a manifest with rails asset pipeline generated entries", ->
    Given ->
      @existingManifest =
        """
        ---
        #{@railsManifestEntries}
        """

      @expectedManifest =
        """
        ---
        #{@railsManifestEntries}
        #{@taskManifestEntries}
        """

    describe "appends new manifest entries, does not touch existing rails entries", ->
      Given -> write("#{@workspacePath}/manifest.yml", @existingManifest)
      Given (done) -> runGruntTask("rails_asset_digest", @config, done)
      When  -> @writtenManifest = read("#{@workspacePath}/manifest.yml")
      Then  -> @writtenManifest == @expectedManifest

  context "a manifest with stale entries from a previous task", ->
    Given ->
      @existingManifest =
        """
        ---
        #{@railsManifestEntries}
        #{@staleManifestEntries}
        """

      @expectedManifest =
        """
        ---
        #{@railsManifestEntries}
        #{@taskManifestEntries}
        """

    describe "replaces stale entries", ->
      Given -> write("#{@workspacePath}/manifest.yml", @existingManifest)
      Given (done) -> runGruntTask("rails_asset_digest", @config, done)
      When  -> @writtenManifest = read("#{@workspacePath}/manifest.yml")
      Then  -> @writtenManifest == @expectedManifest

  context "an empty manifest", ->
    Given ->
      @existingManifest =
        """
        ---
        """

      @expectedManifest =
        """
        ---
        #{@taskManifestEntries}
        """

    describe "appends new entries", ->
      Given -> write("#{@workspacePath}/manifest.yml", @existingManifest)
      Given (done) -> runGruntTask("rails_asset_digest", @config, done)
      When  -> @writtenManifest = read("#{@workspacePath}/manifest.yml")
      Then  -> @writtenManifest == @expectedManifest

    describe "normalizes the asset path by adding a trailing slash", ->
      Given -> @config.rails_asset_digest.sut.options.assetPath = "tmp/public/assets"
      Given -> write("#{@workspacePath}/manifest.yml", @existingManifest)
      Given (done) -> runGruntTask("rails_asset_digest", @config, done)
      When  -> @writtenManifest = read("#{@workspacePath}/manifest.yml")
      Then  -> @writtenManifest == @expectedManifest

  describe "writes contents of fingerprinted files properly", ->
    Given -> @existingManifest = "---"
    Given -> write("#{@workspacePath}/manifest.yml", @existingManifest)
    Given (done) -> runGruntTask("rails_asset_digest", @config, done)
    Then  -> read("#{expand('spec/tmp/public/assets/rootfile-*.js')[0]}") == read("spec/common_rails_project/public/assets/javascripts/rootfile.js")
    And   -> read("#{expand('spec/tmp/public/assets/sourcemapping-*.js.map')[0]}") == read("spec/common_rails_project/public/assets/javascripts/sourcemapping.js.map")
    And   -> read("#{expand('spec/tmp/public/assets/style-*.css')[0]}") == read("spec/common_rails_project/public/assets/stylesheets/style.css")
    And   -> read("#{expand('spec/tmp/public/assets/othersubdirectory/generated-tree-*.js')[0]}") == read("spec/common_rails_project/public/assets/javascripts/othersubdirectory/generated-tree.js")
    And   -> read("#{expand('spec/tmp/public/assets/subdirectory/with/alibrary-*.js')[0]}") == read("spec/common_rails_project/public/assets/javascripts/subdirectory/with/alibrary.js")
