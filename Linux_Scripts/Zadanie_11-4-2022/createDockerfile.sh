#!/bin/bash

cat > Dockerfile << EOF
    FROM nginx:stable

    LABEL maintainer="peter.szathmary@t-systems.com"

    ADD ./index.html /usr/share/nginx/html/index.html

    EXPOSE 80

    CMD ["nginx", "-g", "daemon off;"]
EOF