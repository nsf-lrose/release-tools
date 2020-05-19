

The NFS volume creation and mounting can be done in one command when starting the container, using the **--mount** option. 
I'm showing how to do it here, but I think it is cleaner to create it from the shell first and then map it with the **-v** option as shown in docker-container.md

If there is demand for this alternate way of mapping NFS volumes, we could add a **-mount** option to the **lrose** wrapper, and support it in the **~/.lroseargs** file.

Check how the NFS volume is mounted by running this from the shell:

`mount`

You'll probably see a line like the following:

server:/path/to/volume on /path/to/mount-point type nfs4 (rw,.... )

Lookup the server IP address and use it in the following command (TODO: Can we just use the server name?) 
```
docker run --mount 'type=volume,src=VOLUME_NAME,volume-driver=local,dst=/LOCAL-MNT,volume-opt=type=nfs,volume-opt=device=:NFS_SHARE,"volume-opt=o=addr=NFS_SERVER,vers=4,hard,timeo=600,rsize=1048576,wsize=1048576,retrans=2"' <image> <command>
```
Where

`VOLUME_NAME` is the name of the volume you want to create (it will be listed when running `docker volume ls`)

If the name is already used, this will fail.

`LOCAL_MNT` is the path to that volume from inside the container

`NFS-SHARE` is the path to the volume on the server

`NFS-SERVER` is the IP address of the server
