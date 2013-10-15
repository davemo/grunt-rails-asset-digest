'use strict';

var grunt = require('grunt');
var fs    = require('fs');
var path  = require('path');

exports.asset_digest = {
  setUp: function(done) {
    done();
  },
  normalizes_asset_path_to_add_trailing_slash: function(test) {

    test.expect(1);

    var actual   = grunt.file.read('tmp/public/assets/manifest.yml');
    var expected = grunt.file.read('test/expected/manifest-with-no-entries.yml');
    test.equal(actual, expected, 'manifest entries do not contain leading slashes.');

    test.done();
  }
};
