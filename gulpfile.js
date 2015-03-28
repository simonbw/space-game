var gulp = require('gulp');
var browserify = require('browserify');
var watchify = require('watchify');
var source = require('vinyl-source-stream');

/**
 * Returns a browserify object.
 */
function getBundler() {
  return browserify({
    cache: {},        // needed for watchify
    packageCache: {}, // needed for watchify
    fullPaths: true,  // needed for watchify

    debug: true,
    entries: ['./src/main.coffee'],
    extensions: ['.coffee'],
    paths: ['./src', './node_modules']
  }).transform('coffeeify');
}

/**
 * Puts the output of browserify into bin/
 */
function publish(b) {
  var success = true
  var start = Date.now();
  b.bundle()
    .on('error', function(e) {
      console.log(e);
      success = false;
    })
    .pipe(source('main.js'))
    .pipe(gulp.dest('./bin'));
  if (success) {
    console.log("Updated in", Date.now() - start, "ms");
  }
  return b;
}

/**
 * Compiles everything once.
 */
gulp.task('default', function() {
  publish(getBundler());
});

/**
 * Watches for changes and recompiles.
 */
gulp.task('watch', function() {
  var b = watchify(getBundler());
  b.on('update', function() {
    publish(b);
  });
  publish(b);
});