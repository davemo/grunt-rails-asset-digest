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

  removeKeysThatStartWith = (unDigestedFilePath, ext, obj) ->
    keys = _.keys(obj)
    actualKeysToRemove = _(keys).filter (key) -> _s.startsWith(key, unDigestedFilePath)
    _(actualKeysToRemove).each (key) -> delete obj[key]
    obj

  grunt.registerMultiTask "rails_asset_digest", "Generates asset fingerprints and appends to a rails manifest", ->

    assetPath      = @options(assetPath: "public/assets/").assetPath
    algorithm      = @options(algorithm: "md5").algorithm

    manifestName   = "manifest.json"
    assetPathRegex = ///^#{normalizeAssetPath(assetPath)}///
    manifestPath   = "#{normalizeAssetPath(assetPath)}#{manifestName}"

    stripAssetPath = (path) ->
      path.replace assetPathRegex, ''

    if !grunt.file.exists manifestPath
      grunt.log.warn "#{manifestPath} did not exist"
      false

    addedManifestEntries = {}
    existingManifestData = JSON.parse(grunt.file.read(manifestPath))?.files

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
      undigestedFilename = "#{path.dirname(dest)}/#{path.basename(dest, extension)}"
      digestedFilename = "#{path.dirname(dest)}/#{path.basename(dest, extension)}-#{digest}#{extension}"

      addedManifestEntries[stripAssetPath digestedFilename] = {
        mtime: new Date(stats.mtime).toISOString()
        digest: digest
        size: stats.size
        logical_path: stripAssetPath dest
      }

      if existingManifestData
        existingManifestData = removeKeysThatStartWith(stripAssetPath(undigestedFilename), extension, existingManifestData)

      grunt.file.write digestedFilename, content
      grunt.log.writeln "File #{digestedFilename} created."

    addedCount   = _.keys(addedManifestEntries).length
    fs.writeFileSync manifestPath, JSON.stringify(_.extend({files: _.extend(addedManifestEntries, existingManifestData)}))

    grunt.log.writeln "Added #{addedCount} lines to #{manifestPath}, total entries #{_.keys(addedManifestEntries).length}"
