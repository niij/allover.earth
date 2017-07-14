const mozjpeg = require('imagemin-mozjpeg');

module.exports = function(grunt) {
  // Load all Grunt tasks that are listed in package.json automagically
  require('load-grunt-tasks')(grunt);

  grunt.initConfig({
      // shell commands for use in Grunt tasks
      shell: {
          jekyllBuild: {
              command: 'jekyll build'
          },
          jekyllServe: {
              command: 'jekyll serve'
          }
      },
    
      imagemin: {
          static: {
              options: {
                  optimizationLevel: 3,
                  svgoPlugins: [{removeViewBox: false}],
                  use: [mozjpeg()] // Example plugin usage
              },
              files: {
              }
          },
          dynamic: {
              files: [{
                  expand: true,
                  cwd: 'img/',
                  src: ['**/*.{png,jpg,gif}'],
                  dest: '_site/img/'
              }]
          }
      }
  });
  
  grunt.loadNpmTasks('grunt-contrib-imagemin');


  // Register the grunt serve task
  grunt.registerTask('serve', [
      'imagemin',
      'shell:jekyllServe'
  ]);

  // Register the grunt build task
  grunt.registerTask('build', [
      'imagemin',
      'shell:jekyllBuild'
  ]);

  // Register build as the default task fallback
  grunt.registerTask('default', ['build']);

};
