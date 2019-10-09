# release-tools #

## What ##

LROSE Release Process.  Tools and steps to create release assets: homebrew formulas, docker images, debian packages,...

## Structure ##

Each major release of LROSE has build scripts that pull unique versions of the LROSE tools.  The build scripts include:

* homebrew-scripts

   Scripts to help generate formulas and their corresponding tar files for each release component. (So far, lroze-blaze, samurai, fractl)
   
* lrose-docker-scripts

   Scripts to generate docker images, and one level below under the **debian** folder, scripts and files to generate binary debian packages.
   
## Release Process ##

1. Continuous Integration Scripts
(CircleCI .yml file)

2.  Update Release Notes: 
a. What applications/tools are included and which versions
b. What bug fixes, etc. 

3. Build lrose-core using --lrose-cyclone flag

4. Build brew formula

5. Build Docker ubuntu images & push to DockerHub

6. Sanity Test
