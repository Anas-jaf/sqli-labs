#!/bin/bash

RUN ["/bin/bash", "-c", "sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list"]

/bin/bash -c "sudo sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list"