#
# * grunt-rails-asset-digest
# * https://github.com/davemo/grunt-rails-asset-digest
# *
# * Copyright (c) 2013 David Mosher
# * Licensed under the MIT license.
#
"use strict"
module.exports = (grunt) ->

  grunt.loadNpmTasks "grunt-jasmine-bundle"

  grunt.initConfig
    spec:
      e2e:
        minijasminenode:
          showColors: true