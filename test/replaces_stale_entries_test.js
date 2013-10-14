'use strict';

var grunt = require('grunt');
var fs    = require('fs');
var path  = require('path');

exports.asset_digest = {
  setUp: function(done) {
    done();
  },
  replaces_stale_entries: function(test) {

    test.expect(1);

    var actual   = grunt.file.read('tmp/public/assets/manifest.yml');
    var expected = grunt.file.read('test/expected/manifest-with-stale-entries.yml');
    test.equal(actual, expected, 'stale entries in manifest are replaced');

    test.done();
  }
};
