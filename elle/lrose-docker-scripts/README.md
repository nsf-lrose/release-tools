# docker_scripts
Various scripts and files to build a lrose-elle image

  * build.md
  		Show how to build the image
  * Dockerfile
      Used by the build.sh script
  * docker-container.md
  		Explain how to use the image
  * build.sh
      create a VERSION file with today's date
      build lrose-elle from the top of NCAR/lrose-core
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

--------

05/19/2020

Then for elle,
I made ...

Dockerfile_latest_18.10
     "           _16.x

build_latest.sh

How to build ...

./build_latest.sh -u 18.10

06/09/2020

building on ubuntu doesn't work, when building lrose-core/libs,
error in finding 

In file included from Hdf5/Hdf5xx.cc:36:0:

./include/Ncxx/Hdf5xx.hh:44:10: fatal error: H5public.h: No such file or directory

 #include <H5public.h>

          ^~~~~~~~~~~~

compilation terminated.

the include file is in 
/usr/... /serial/


---- 

so moved to centos:7 as the base container.

NOTE: chrpath is NOT found when running the centos:7 base image.
