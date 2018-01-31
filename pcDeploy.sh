#!/bin/bash

appCount=$2
echo $1

if [ -z "$1" ] && [ -z "$2" ]
   then
     clear
     echo "The script is expecting two parameters"
     echo "in this format pcDeploy.sh {ACTION} {AppCount}"
     echo "Action can be: "
     echo "  clean to populate the dbdata with the default data and build the app from source"
     echo "   build to buld the app from source and use existing dbdata"
     echo "   start to start the environment with the latest code and dbdata"
     exit
fi
   if [ -z "$2" ]
     then
       clear
       echo "the number of app services is missing"
       exit
  fi

if [ "$1" == "clean" ]
    then
    # Running a stand alone mysql DB with a mounted volumes for future use
      docker rm  -f mysql
      rm -rf dbdata
      mkdir dbdata
      docker pull mysql
      # runnning a mysql container to push all the data in the volume
          docker run -d  -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=root -p 3306:3306 -v "$(pwd)"/dbdata:/var/lib/mysql -v "$(pwd)"/src/main/resources/db/mysql:/docker-entrypoint-initdb.d --name mysql mysql
        sleep 10
        echo " mysql was populated Succesfully "
    docker stop mysql
     mvn package -Dmaven.test.skip=true
    docker-compose up --build --scale app=${appCount} -d

elif [ "$1" == "build" ]
    then
    mvn package -Dmaven.test.skip=true
    docker-compose up --build --scale app=${appCount}

 elif [ "$1" == "start" ]
  then
   docker-compose up --scale app=${appCount}
 else
   echo "The command state is invalid"
   exit
 fi




echo "Make sure to add '127.0.0.1 petclinic.local' ro /etc/hosts"
