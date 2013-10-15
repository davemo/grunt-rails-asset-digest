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

"use strict"

module.exports = (grunt) ->

  _ = grunt.util._

  normalizeAssetPath = (path) ->
    unless _.str.endsWith(path, "/")
      path += "/"
    path

  grunt.registerMultiTask "rails_asset_digest", "Generates asset fingerprints and appends to a rails manifest", ->

    assetPath      = @options(assetPath: "public/assets/").assetPath
    algorithm      = @options(algorithm: "md5").algorithm

    manifestName   = "manifest.yml"
    assetPathRegex = ///^#{normalizeAssetPath(assetPath)}///
    manifestPath   = "#{normalizeAssetPath(assetPath)}#{manifestName}"

    stripAssetPath = (path) ->
      path.replace assetPathRegex, ''

    if !grunt.file.exists manifestPath
      grunt.log.warn "#{manifestPath} did not exist"
      false

    filesToHashed = {}

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
      filename = "#{path.dirname(dest)}/#{path.basename(dest, extension)}-#{algorithmHash.update(content).digest("hex")}#{extension}"
      filesToHashed[stripAssetPath dest] = stripAssetPath filename

      grunt.file.write filename, content
      grunt.log.writeln "File #{filename} created."

    manifestDataLines = grunt.file.read(manifestPath).split "\n"
    replaceCount      = 0
    filesMatched      = {} # to prevent duplicate files

    manifestDataLines = _(manifestDataLines).map (line) ->
      match = line.match /^(\S+?):/
      file  = match?[1]
      if match and filesToHashed[file]
        if filesMatched[file]
          # Already seen this file in the manifest
          return null
        else
          line = "#{file}: #{filesToHashed[file]}"
          filesMatched[file] = true
          replaceCount++
      return line

    _(filesMatched).each (__, file) ->
      delete filesToHashed[file]

    _(filesToHashed).each (hashed, file) ->
      manifestDataLines.push "#{file}: #{hashed}"

    manifestData = _(manifestDataLines).compact().join("\n")

    fs.writeFileSync manifestPath, manifestData
    grunt.log.writeln "Replaced #{replaceCount} lines and appended #{_(filesToHashed).size()} lines to #{manifestPath}"
