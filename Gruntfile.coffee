module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON 'guess-who.json'
    banner:'/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
        '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
        '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
        '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
        ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n'

    clean:
      src: [
        'dist'
        'src/js/'
        'src/templates/js'
        'src/templates/html'
      ]
      spec: ['spec/js']

    imageEmbed:
      dist:
        src: [ "src/css/guess.css" ]
        dest: "dist/<%= pkg.name %>.css"
        options:
          deleteAfterEncoding : false
          maxImageSize: 0

    concat:
      options:
        banner:'<%= banner %>'
        stripBanners:true
      all:
        files:
          'dist/<%= pkg.name %>.js': [
            'libs/jquery.min.js',
            'libs/underscore-min.js',
            'libs/backbone.js',
            'libs/handlebars.js',
            'src/js/guess.js',
            'src/templates/js/**/*.js'
          ]
        nonull: true

    uglify:
      options:
        banner: '<%= banner %>'
      dist:
        src: 'dist/<%= pkg.name %>.js'
        dest: 'dist/<%= pkg.name %>.min.js'


    coffee:
      options:
        bare: true
      glob_to_multiple:
        expand: true,
        cwd: 'src/coffee'
        src: ['**/*.coffee']
        dest: 'src/js'
        ext: '.js'

    coffeelint:
      dist: ['src/coffee/**/*.coffee']
      options :
        'max_line_length':
          level: 'ignore'
          value: 120
        'no_trailing_whitespace':
          level: 'ignore'


    jade:
      #options:
        #debug: true
        #compileDebug: false
      files:
        expand: true
        cwd: "src/templates/jade"
        src: ["**/*.jade"]
        dest: 'src/templates/html'
        ext: '.html'

    handlebars:
        options:
            processName: (filePath) ->
                fileParts = filePath.split('/')
                fileNameParts = fileParts[fileParts.length - 1].split('.')
                fileNameParts[0].charAt(0).toUpperCase() + fileNameParts[0].substr(1);
    files:
        expand: true
        cwd: "src/templates/html"
        src: ["**/*.html"]
        dest: 'src/templates/js'
        ext: '.js'

    watch:
      coffee:
        files: ['<%= coffee.glob_to_multiple.cwd %>/**/*.coffee']
        tasks: ['coffeelint', 'coffee']
      jade:
        files: ["<%= jade.files.cwd %>/**/*.jade"]
        tasks: ['jade']
      handlebars:
        files: ["<%= handlebars.files.cwd %>/**/*.html"]
        tasks: ['handlebars', 'concat']
      concat:
        files: [
          "src/js/**/*.js"
          "src/css/**/*.css"
        ]
        tasks: ['concat', 'imageEmbed']

    play:
      error:
        file: 'doc/error.mp3'

  # Load the plugins.
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks "grunt-image-embed"
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-handlebars'
  grunt.loadNpmTasks 'grunt-play'

  # Default tasks.
  grunt.registerTask 'full', ['clean', 'coffeelint:dist', 'coffee:glob_to_multiple', 'jade', 'handlebars', 'concat:all', 'imageEmbed']

  grunt.registerTask 'quick', ['clean', 'coffeelint:dist', 'coffee:glob_to_multiple', 'jade', 'handlebars', 'concat:all', 'imageEmbed']

  grunt.registerTask 'default', ['quick', 'watch']
