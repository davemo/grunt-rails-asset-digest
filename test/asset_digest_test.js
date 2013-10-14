'use strict';

var grunt = require('grunt');
var fs    = require('fs');
var path  = require('path');

/*
  ======== A Handy Little Nodeunit Reference ========
  https://github.com/caolan/nodeunit

  Test methods:
    test.expect(numAssertions)
    test.done()
  Test assertions:
    test.ok(value, [message])
    test.equal(actual, expected, [message])
    test.notEqual(actual, expected, [message])
    test.deepEqual(actual, expected, [message])
    test.notDeepEqual(actual, expected, [message])
    test.strictEqual(actual, expected, [message])
    test.notStrictEqual(actual, expected, [message])
    test.throws(block, [error], [message])
    test.doesNotThrow(block, [error], [message])
    test.ifError(value)
*/

exports.asset_digest = {
  setUp: function(done) {
    // setup happens in grunt shell:testsetup
    done();
  },
  sample_project: function(test) {

    test.expect(1);

    var actual   = grunt.file.read('tmp/public/assets/manifest.yml');
    debugger;
    var expected = grunt.file.read('test/expected/manifest.yml');
    test.equal(actual, expected, 'manifest should be written properly.');

    test.done();
  }
};
