grunt  = require("grunt")
spawn  = require("child_process").spawn
read   = grunt.file.read
write  = grunt.file.write
mkdir  = grunt.file.mkdir
clear  = grunt.file.delete
expand = grunt.file.expand

runGruntTask = (scenario, done) ->
  spawn("grunt",
    [
      "rails_asset_digest",
      "--gruntfile", "spec/Gruntfile.#{scenario}.coffee"
    ],
    {stdio: 'inherit'}
  ).on("exit", -> done())

beforeEach -> mkdir @workspacePath = "spec/tmp/public/assets"
afterEach  -> clear "spec/tmp/"

keysShouldBeEqualIn = (written, expected) ->
  expect(Object.keys(JSON.parse(written).files).sort()).toEqual(Object.keys(expected.files).sort())
  expect(Object.keys(JSON.parse(written).assets).sort()).toEqual(Object.keys(expected.assets).sort())

describe "rails_asset_digest", ->

  Given ->
    @railsManifestEntries = -> {
      "assets": {
        "entry-we-didnt-touch.js" : "entry-we-didnt-touch-536a9e5d711e0593e43360ad330ccc31.js"
        "thing-that-existed.js" : "thing-that-existed-536a9e5ddkfjc9v9e9r939494949491.js"
        "style/style-should-stay.css" : "style-should-stay-OLDSHA.css"
      }
      "files": {
        "thing-that-existed-536a9e5ddkfjc9v9e9r939494949491.js" : {
          "mtime": "2014-02-05T00:52:02.649Z",
          "digest": "536a9e5ddkfjc9v9e9r939494949491"
          "size": 32
          "logical_path": "thing-that-existed.js"
        }
        "entry-we-didnt-touch-536a9e5d711e0593e43360ad330ccc31.js": {
          "mtime": "2014-02-05T00:52:02.649Z",
          "digest": "536a9e5d711e0593e43360ad330ccc31",
          "size": 32,
          "logical_path": "entry-we-didnt-touch.js"
        }
        "style/style-should-stay-OLDSHA.css" : {
          "mtime": "2014-02-04T18:14:52.000Z"
          "digest": "OLDSHA"
          "size": 32
          "logical_path": "style/style-should-stay.css"
        }
      }
    }

    @taskManifestEntries = -> {
      "assets": {
        "rootfile.js" : "rootfile-54267464ea71790d3ec68e243f64b98e.js"
        "sourcemapping.js.map" : "sourcemapping-742adbb9b78615a3c204b83965bb62f7.js.map"
        "othersubdirectory/generated-tree.js" : "othersubdirectory/generated-tree-e4ce151e4824a9cbadf1096551b070d8.js"
        "subdirectory/with/alibrary.js" : "subdirectory/with/alibrary-313b3b4b01cec6e4e82bdeeb258503c5.js"
        "style.css" : "style-7527fba956549aa7f85756bdce7183cf.css"
      }
      "files": {
        "rootfile-54267464ea71790d3ec68e243f64b98e.js": {
          "mtime": "2014-02-04T18:14:52.000Z",
          "digest": "54267464ea71790d3ec68e243f64b98e",
          "size": 29,
          "logical_path": "rootfile.js"
        },
        "sourcemapping-742adbb9b78615a3c204b83965bb62f7.js.map": {
          "mtime": "2014-02-04T18:14:52.000Z",
          "digest": "742adbb9b78615a3c204b83965bb62f7",
          "size": 108,
          "logical_path": "sourcemapping.js.map"
        },
        "othersubdirectory/generated-tree-e4ce151e4824a9cbadf1096551b070d8.js": {
          "mtime": "2014-02-04T18:14:52.000Z",
          "digest": "e4ce151e4824a9cbadf1096551b070d8",
          "size": 39,
          "logical_path": "othersubdirectory/generated-tree.js"
        },
        "subdirectory/with/alibrary-313b3b4b01cec6e4e82bdeeb258503c5.js": {
          "mtime": "2014-02-04T18:14:52.000Z",
          "digest": "313b3b4b01cec6e4e82bdeeb258503c5",
          "size": 29,
          "logical_path": "subdirectory/with/alibrary.js"
        },
        "style-7527fba956549aa7f85756bdce7183cf.css": {
          "mtime": "2014-02-04T18:14:52.000Z",
          "digest": "7527fba956549aa7f85756bdce7183cf",
          "size": 41,
          "logical_path": "style.css"
        }
      }
    }

    @staleManifestEntries = -> {
      "assets": {
        "rootfile.js" : "rootfile-OLDSHA.js"
        "sourcemapping.js.map" : "sourcemapping-OLDSHA.js.map"
        "othersubdirectory/generated-tree.js" : "othersubdirectory/generated-tree-OLDSHA.js"
        "subdirectory/with/alibrary.js" : "subdirectory/with/alibrary-313b3b4b01cec6e4e82bdeeb258503c5.js"
        "style.css" : "style-OLDSHA.css"
        "style/style-should-stay.css" : "style-should-stay-OLDSHA.css"
      }
      "files": {
        "rootfile-OLDSHA.js" : {
          "mtime": "2014-02-04T18:14:52.000Z"
          "digest": "OLDSHA"
          "size": 32
          "logical_path": "rootfile.js"
        }
        "sourcemapping-OLDSHA.js.map" : {
          "mtime": "2014-02-04T18:14:52.000Z"
          "digest": "OLDSHA"
          "size": 32
          "logical_path": "sourcemapping.js.map"
        }
        "othersubdirectory/generated-tree-OLDSHA.js" : {
          "mtime": "2014-02-04T18:14:52.000Z"
          "digest": "OLDSHA"
          "size": 32
          "logical_path": "othersubdirectory/generated-tree.js"
        }
        "subdirectory/with/alibrary-OLDSHA.js" : {
          "mtime": "2014-02-04T18:14:52.000Z"
          "digest": "OLDSHA"
          "size": 32
          "logical_path": "subdirectory/with/alibrary.js"
        }
        "style-OLDSHA.css" : {
          "mtime": "2014-02-04T18:14:52.000Z"
          "digest": "OLDSHA"
          "size": 32
          "logical_path": "style.css"
        }
        "style/style-should-stay-OLDSHA.css" : {
          "mtime": "2014-02-04T18:14:52.000Z"
          "digest": "OLDSHA"
          "size": 32
          "logical_path": "style/style-should-stay.css"
        }
      }
    }

  context "a manifest with rails asset pipeline generated entries", ->

    Given ->
      @existingManifest = @railsManifestEntries()

      @expectedManifest = {
        assets: Object.assign(@taskManifestEntries().assets, @railsManifestEntries().assets)
        files: Object.assign(@taskManifestEntries().files, @railsManifestEntries().files)
      }

    describe "appends new manifest entries, does not touch existing rails entries", ->

      Given -> write("#{@workspacePath}/manifest.json", JSON.stringify(@existingManifest))
      Given (done) -> runGruntTask("basic", done)
      When  -> @writtenManifest = read("#{@workspacePath}/manifest.json")
      Then  -> keysShouldBeEqualIn(@writtenManifest, @expectedManifest)

  context "a manifest with stale entries from a previous run of the grunt task", ->

    Given ->
      @existingManifest = {
        assets: Object.assign(@railsManifestEntries().assets, @staleManifestEntries().assets)
        files: Object.assign(@railsManifestEntries().files, @staleManifestEntries().files)
      }
      @expectedManifest = {
        assets: Object.assign(@railsManifestEntries().assets, @taskManifestEntries().assets)
        files: Object.assign(@railsManifestEntries().files, @taskManifestEntries().files)
      }

    describe "replaces stale entries", ->

      Given -> write("#{@workspacePath}/manifest.json", JSON.stringify(@existingManifest))
      Given (done) -> runGruntTask("basic", done)
      When  -> @writtenManifest = read("#{@workspacePath}/manifest.json")
      Then  -> keysShouldBeEqualIn(@writtenManifest, @expectedManifest)

  context "an empty manifest", ->

    Given ->
      @existingManifest = {}
      @expectedManifest = @taskManifestEntries()

    describe "appends new entries", ->

      Given -> write("#{@workspacePath}/manifest.json", JSON.stringify(@existingManifest))
      Given (done) -> runGruntTask("basic", done)
      When  -> @writtenManifest = read("#{@workspacePath}/manifest.json")
      Then  -> keysShouldBeEqualIn(@writtenManifest, @expectedManifest)

    describe "normalizes the asset path by adding a trailing slash", ->

      Given -> write("#{@workspacePath}/manifest.json", JSON.stringify(@existingManifest))
      Given (done) -> runGruntTask("assetPath", done)
      When  -> @writtenManifest = read("#{@workspacePath}/manifest.json")

  describe "writes contents of fingerprinted files properly", ->

    Given -> @existingManifest = {}
    Given -> write("#{@workspacePath}/manifest.json", JSON.stringify(@existingManifest))
    Given (done) -> runGruntTask("basic", done)
    Then  -> read("#{expand('spec/tmp/public/assets/rootfile-*.js')[0]}") == read("spec/common_rails_project/public/assets/javascripts/rootfile.js")
    And   -> read("#{expand('spec/tmp/public/assets/sourcemapping-*.js.map')[0]}") == read("spec/common_rails_project/public/assets/javascripts/sourcemapping.js.map")
    And   -> read("#{expand('spec/tmp/public/assets/style-*.css')[0]}") == read("spec/common_rails_project/public/assets/stylesheets/style.css")
    And   -> read("#{expand('spec/tmp/public/assets/othersubdirectory/generated-tree-*.js')[0]}") == read("spec/common_rails_project/public/assets/javascripts/othersubdirectory/generated-tree.js")
    And   -> read("#{expand('spec/tmp/public/assets/subdirectory/with/alibrary-*.js')[0]}") == read("spec/common_rails_project/public/assets/javascripts/subdirectory/with/alibrary.js")
