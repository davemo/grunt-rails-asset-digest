#
# * grunt-rails-asset-digest
# * https://github.com/davemo/grunt-rails-asset-digest
# *
# * Copyright (c) 2013 David Mosher
# * Licensed under the MIT license.
#

fs     = require "fs"
path   = require "path"
crypto = require "crypto"
_      = require "underscore"
_s     = require "underscore.string"

"use strict"

module.exports = (grunt) ->

  normalizeAssetPath = (path) ->
    unless _s.endsWith(path, "/")
      path += "/"
    path

  removeOldKeys = (filepath, obj) ->
    keys = _.keys(obj)
    actualKeysToRemove = _(keys).filter (key) -> obj[key].logical_path == filepath
    _(actualKeysToRemove).each (key) -> delete obj[key]
    obj

  grunt.registerMultiTask "rails_asset_digest", "Generates asset fingerprints and appends to a rails manifest", ->

    assetPath      = @options(assetPath: "public/assets/").assetPath
    algorithm      = @options(algorithm: "md5").algorithm
    manifestName   = @options(manifestName: "manifest.json").manifestName

    assetPathRegex = ///^#{normalizeAssetPath(assetPath)}///
    manifestPath   = "#{normalizeAssetPath(assetPath)}#{manifestName}"

    stripAssetPath = (path) ->
      path.replace assetPathRegex, ''

    if !grunt.file.exists manifestPath
      grunt.log.warn "#{manifestPath} did not exist"
      false

    addedManifestFileEntries = {}
    addedManifestAssetEntries = {}
    existingManifestFilesData  = JSON.parse(grunt.file.read(manifestPath))?.files
    existingManifestAssetsData = JSON.parse(grunt.file.read(manifestPath))?.assets

    _(@files).each (files) ->

      src = files.src[0]
      dest = files.dest
      unless grunt.file.exists(src)
        grunt.log.warn "Source file \"" + src + "\" not found."
        return false

      algorithmHash = crypto.createHash algorithm
      extension     = path.extname dest

      if extension is ".map"
        extension = "#{path.extname(path.basename(dest, extension))}#{extension}"

      content  = grunt.file.read(src)
      digest = algorithmHash.update(content).digest("hex")
      stats = fs.statSync(src)
      undigestedFilename = "#{path.dirname(dest)}/#{path.basename(dest, extension)}#{extension}"
      digestedFilename = "#{path.dirname(dest)}/#{path.basename(dest, extension)}-#{digest}#{extension}"

      addedManifestFileEntries[stripAssetPath digestedFilename] = {
        mtime: new Date(stats.mtime).toISOString()
        digest: digest
        size: stats.size
        logical_path: stripAssetPath dest
      }

      addedManifestAssetEntries[stripAssetPath undigestedFilename] = stripAssetPath digestedFilename

      if existingManifestFilesData
        existingManifestFilesData = removeOldKeys(stripAssetPath(undigestedFilename), existingManifestFilesData)

      if existingManifestAssetsData
        existingManifestAssetsData = removeOldKeys(stripAssetPath(undigestedFilename), existingManifestAssetsData)

      grunt.file.write digestedFilename, content
      grunt.log.writeln "File #{digestedFilename} created."

    addedCount   = _.keys(addedManifestFileEntries).length
    fs.writeFileSync manifestPath, JSON.stringify(_.extend({
      files: _.extend(addedManifestFileEntries, existingManifestFilesData)
      assets: _.extend(addedManifestAssetEntries, existingManifestAssetsData)
    }))

    grunt.log.writeln "Added #{addedCount} keys to #{manifestPath} (in .files and .assets), total #{_.keys(addedManifestFileEntries).length}"
