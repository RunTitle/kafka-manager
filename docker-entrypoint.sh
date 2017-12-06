#!/bin/bash

if [ "$1" = 'web' ]; then
    exec kafka-manager-1.3.3.15/bin/kafka-manager
else
    exec "$@"
fi
