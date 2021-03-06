# How to build an LROSE-Elle image

## Prerequisites

All you need a `Dockerfile` and the `build.sh`.
In buid.sh, replace the **ORGANIZATION** and possibly **IMAGE** variables with your own.

## Build the image

./build.sh

If successful, you should have the image on your
system. Double check with

`docker images`

## Export the image

`docker export <image_ID> --output lrose-elle.tgz`

## Copy it to another machine and import it

`docker import lrose-elle.tgz`

## Building a custom image

The image generated with the given Dockerfile is a generic image with just enough run-time libraries to support running lrose binaries.

If you wanted to add more packages, create additional users... you can either add instructions to the Dockerfile, or follow these steps

  * `docker run -it --name my_container /bin/bash`
  * Unless you specified a user (-u, --user) you should be root.
  * Add user(s), packages, ...
  * exit
  * `docker ps -a` to get your modified container ID
  * `docker commit <container_ID> mycustomimage`
  
`docker images` should now list your *mycustomimage*



