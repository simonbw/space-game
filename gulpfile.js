const gulp = require('gulp');
const source = require('vinyl-source-stream');
const buffer = require('vinyl-buffer');
const browserify = require('browserify');
const watchify = require('watchify');
const babelify = require('babelify');

function compile(watch) {
  var bundler = browserify('./src/main.js', {debug: true, cache: {}, packageCache: {}});
  if (watch) {
    bundler = watchify(bundler);
  }
  bundler = bundler.transform(babelify, {presets: ['es2015']});

  function rebundle() {
    return bundler.bundle()
      .on('error', function (err) {
        console.error(err);
        this.emit('end');
      })
      .pipe(source('main.js'))
      .pipe(buffer())
      .pipe(gulp.dest('./bin'));
  }

  if (watch) {
    bundler.on('update', function () {
      process.stdout.write('-> bundling...');
      rebundle().on('end', function () {
        console.log('done');
      });
    });
  }

  return rebundle();
}

function watch() {
  return compile(true);
}

gulp.task('build', function () {
  return compile();
});

gulp.task('watch', function () {
  return watch();
});

gulp.task('default', ['build']);