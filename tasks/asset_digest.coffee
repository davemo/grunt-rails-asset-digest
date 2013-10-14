#
# * grunt-asset-digest
# * https://github.com/davemo/grunt-asset-digest
# *
# * Copyright (c) 2013 David Mosher
# * Licensed under the MIT license.
#

fs     = require "fs"
path   = require "path"
crypto = require "crypto"

DEFAULT_ASSET_PATH    = "public/assets/"
DEFAULT_ALGORITHM     = "md5"
DEFAULT_MANIFEST_NAME = "manifest.yml"

"use strict"

module.exports = (grunt) ->

  _ = grunt.util._

  # Please see the Grunt documentation for more information regarding task
  # creation: http://gruntjs.com/creating-tasks
  grunt.registerMultiTask "asset_digest", "Generates asset fingerprints and appends to a rails manifest", ->

    assetPath      = @options(assetPath: DEFAULT_ASSET_PATH).assetPath
    manifestPath   = @options(manifestPath: "#{assetPath}#{DEFAULT_MANIFEST_NAME}").manifestPath
    assetPathRegex = @options(assetPathRegex: ///^#{assetPath}///).assetPathRegex
    separator      = @options(separators: ", ").separator
    algorithm      = @options(algorithm: DEFAULT_ALGORITHM).algorithm

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
      extension = path.extname dest

      if extension is ".map"
        extension = "#{path.extname(path.basename(dest, extension))}#{extension}"

      content = src
      filename = "#{path.dirname(dest)}/#{path.basename(dest, extension)}-#{algorithmHash.update(content).digest("hex")}#{extension}"
      filesToHashed[stripAssetPath dest] = stripAssetPath filename

      grunt.file.write filename, content
      grunt.log.writeln "File #{filename} created."

    manifestData = grunt.file.read(manifestPath)
    manifestDataLines = manifestData.split "\n"
    replaceCount = 0
    filesMatched = {} # to prevent duplicate files

    manifestDataLines = _(manifestDataLines).map (line) ->
      _(line).tap (l) ->
        match = l.match /^(\S+?):/
        file = match?[1]
        if match and filesToHashed[file]
          if filesMatched[file]
            l = null
          else
            l = "#{file}: #{filesToHashed[file]}"
            filesMatched[file] = true
            replaceCount++

    for file of filesMatched
      delete filesToHashed[file]

    for file, hash of filesToHashed
      manifestDataLines.push "#{file}: #{hash}"

    manifestData = _(manifestDataLines).compact().join("\n")

    fs.writeFileSync manifestPath, manifestData
    grunt.log.writeln "Replaced #{replaceCount} lines and appended #{_(filesToHashed).size()} lines to #{manifestPath}"
