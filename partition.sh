#!/bin/bash



STR=$'g\nn\n1\n\n+512M\nt\n1\nn\n\n\n\nw'
echo "$STR" | fdisk /dev/sda
