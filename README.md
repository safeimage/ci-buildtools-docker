Build an Docker image containing all the build tools
====================================================

# Prerequisites

* [Chef Development Kit](https://downloads.chef.io/chef-dk/) v0.3.5 or up.
* [Docker](https://www.docker.com/) v1.4.0 or up
* Internet access
* A Unix shell (Cygwin might work but is not tested)

# Building the image

Just run `./build.sh`. After execution, you should have a Docker image as the output:

```
$ docker images | grep buildtools
releasequeue/ci-buildtools      latest               305c55fe5b1c        34 minutes ago      592.1 MB
```

That's all folks!