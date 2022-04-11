#!/bin/bash

name="Peter Szathmary"
email="peter.szathmary@t-systems.com"
hostname=$(hostname)
cpu=$(lscpu | grep 'Model name' | cut -f 2 -d ":" | awk '{$1=$1}1')
total_memory="Total: $(awk '/^Mem/ {print $2}' <(free -h))"
used_memory="Used: $(awk '/^Mem/ {print $3}' <(free -h))"
free_memory="Free: $(awk '/^Mem/ {print $4}' <(free -h))"
available_memory="Available: $(awk '/^Mem/ {print $7}' <(free -h))"
memory="${used_memory} ${free_memory}"
os_release="$(cat /etc/os-release | grep PRETTY | tr -d '"' | sed 's/PRETTY_NAME=//g')"
kernel="$(uname -rs)"

cat > index.html << EOF
<html>
        <head>
                <title>$hostname</title>
        </head>
        <body style="background-color: powderblue;">
                <h1>Welcome to $hostname Info Page</h1>
                <hr>
                <b>This VM is administrated by:</b><br> $name
                <p><b>You can contact the admin via:</b> $email</p>
                <br>

                <p><i>Server info:</i></p>
                <table border="1">
                        <tr>
                                <td><b>CPU</b></td>
                                <td><b>Memory</b></td>
                                <td><b>OSRelease</b></td>
                                <td><b>Kernel</b></td>
                        </tr>
                        <tr>
                                <td>$cpu</td>
                                <td>$memory</td>
                                <td>$os_release</td>
                                <td>$kernel</td>
                        </tr>
                </table>
        </body>
</html>
EOF