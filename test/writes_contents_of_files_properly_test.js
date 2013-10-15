'use strict';

var grunt = require('grunt');
var fs    = require('fs');
var path  = require('path');

exports.asset_digest = {
  setUp: function(done) {
    done();
  },
  writes_contents_of_javascript_file_in_root: function(test) {

    test.expect(1);
    // so we dont need to know the md5 hashes
    var actual_path = grunt.file.expand('tmp/public/assets/rootfile-*.js')[0];
    var actual      = grunt.file.read(actual_path);
    var expected    = grunt.file.read('test/common_rails_project/public/assets/javascripts/rootfile.js');

    test.equal(actual, expected, 'rootfile.js has the proper output');
    test.done();
  },

  writes_contents_of_sourcemap_file_in_root: function (test) {
    test.expect(1);

    var actual_path = grunt.file.expand('tmp/public/assets/sourcemapping-*.js.map')[0];
    var actual      = grunt.file.read(actual_path);
    var expected    = grunt.file.read('test/common_rails_project/public/assets/javascripts/sourcemapping.js.map');

    test.equal(actual, expected, 'sourcemapping.js.map has the proper output');
    test.done();
  },

  writes_contents_of_css_file_in_stylesheets: function (test) {
    test.expect(1);

    var actual_path = grunt.file.expand('tmp/public/assets/style-*.css')[0];
    var actual = grunt.file.read(actual_path);
    var expected = grunt.file.read('test/common_rails_project/public/assets/stylesheets/style.css');

    test.equal(actual, expected, 'style.css has the proper output');
    test.done();
  },

  writes_contents_of_javascript_file_one_level_deep: function (test) {
    test.expect(1);

    var actual_path = grunt.file.expand('tmp/public/assets/othersubdirectory/generated-tree-*.js')[0];
    var actual = grunt.file.read(actual_path);
    var expected = grunt.file.read('test/common_rails_project/public/assets/javascripts/othersubdirectory/generated-tree.js');

    test.equal(actual, expected, 'generated-tree.js has the proper output');
    test.done();
  },

  writes_contents_of_javascript_more_than_one_level_deep: function (test) {
    test.expect(1);

    var actual_path = grunt.file.expand('tmp/public/assets/subdirectory/with/alibrary-*.js')[0];
    var actual = grunt.file.read(actual_path);
    var expected = grunt.file.read('test/common_rails_project/public/assets/javascripts/subdirectory/with/alibrary.js');

    test.equal(actual, expected, 'alibrary.js has the proper output');
    test.done();
  }
};
