#!/bin/bash
sudo docker build -t pjw_postgresql .

echo run it like this:
echo sudo docker run --rm -P --name pg_test pjw_postgresql
echo .
echo link data like this:
echo sudo docker run --rm -t -i --link pg_test:pg pjw_postgresql bash
echo .
echo to connect:
echo $ sudo docker ps
echo psql -h localhost -p 49153 -d docker -U docker --password
echo .
echo to save changes:
echo docker commit pjw_postgresql


