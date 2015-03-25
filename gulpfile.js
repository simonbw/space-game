var gulp = require('gulp');
var browserify = require('browserify');
var watchify = require('watchify');
var source = require('vinyl-source-stream');

function publish(b) {
  var success = true
  b.bundle()
    .on('error', function(e) {
      console.log(e)
      success = false
    })
    .pipe(source('main.js'))
    .pipe(gulp.dest('./bin'))
  if (success) {
    console.log('success')
  }
  return b
}

gulp.task('default', function() {
  publish(browserify({
    debug: true,
    entries: ['./src/main.coffee'],
    extensions: ['.coffee']
  }).transform('coffeeify'));
});

gulp.task('watch', function() {
  var b = browserify({
    cache: {},
    packageCache: {},
    fullPaths: true,
    debug: true,

    entries: ['./src/main.coffee'],
    extensions: ['.coffee']
  }).transform('coffeeify');
  b = watchify(b);
  b.on('update', function() {
    publish(b);
  });
  publish(b);
});