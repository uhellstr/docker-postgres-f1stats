#!/bin/bash
SCRIPTDIR=`pwd`
cd $SCRIPTDIR/Postgresimage
docker build -t postgres-db . 
