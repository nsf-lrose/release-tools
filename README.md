# release-tools #

## What ##

Tools to help creating release assets: homebrew formulas, docker images, debian packages,...

## Structure ##

* homebrew-scripts

   Scripts to help generate formulas and their corresponding tar files for each release component. (So far, lroze-blaze, samurai, fractl)
   
* lrose-docker-scripts

   Scripts to generate docker images, and one level below under the **debian** folder, scripts and files to generate binary debian packages.
