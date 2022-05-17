# nilrt-containers

Experimental scripts to build docker containers of NI Linux Real-Time.

# Prerequisites

You will need [opkg](https://git.yoctoproject.org/opkg).

# Usage

```
    ./build-container <x.y.z>
```

Version number must be a release version from the feed. As of this writing,
available versions are as follows.

    - 20.0.0
    - 20.1.0
    - 20.5.0
    - 20.6.0
    - 20.7.0
    - 21.0.0
    - 21.3.0
    - 21.5.0
    - 21.8.0

Grabs a system image from the dist feed and creates a container tagged as
`nilrt:<version>`.

```
    ./run-container <x.y.z> <cmd args...>
```

Convenience wrapper to run an nilrt container.
