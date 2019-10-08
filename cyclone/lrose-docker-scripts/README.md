# docker_scripts
Various scripts and files to build a lrose-cyclone image

  * build.md
  		Show how to build the image
  * Dockerfile
      Used by the build.sh script
  * docker-container.md
  		Explain how to use the image
  * build.sh
      create a VERSION file with today's date
      build lrose-cyclone from the top of NCAR/lrose-core
      -or- 
      build a version with a specific lrose-core tag
      ```
      ./build.sh -t 20190801
      ```
      or
      ```
      ./build.sh -u 18.10 -t 20190801
      ```

  * lrose
  		Wrapper script to simplify running commands in the container
  * release.sh
      Tag the image and push it so that it is available as 'latest' as well as 'mmddyyyy'
  * pull.rb
      Script to get the image pull count

