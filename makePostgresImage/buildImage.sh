#!/bin/bash
sudo docker build -t weirp/pg1 .

echo run it like this:
echo sudo docker run --rm -P --name pg1 pg1
echo .
echo link data like this:
echo sudo docker run --rm -t -i --link pg_test:pg pg1 bash
echo .
echo to connect:
echo $ sudo docker ps
echo psql -h localhost -p 49153 -d docker -U docker --password
echo .
echo to save changes:
echo docker commit pg1
echo .
echo to push to the repository:
echo docker push weirp/pg1


