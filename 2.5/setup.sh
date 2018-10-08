#!/bin/bash

echo "Welcome to OCSInventory Docker image setup"


echo "Please specify container name"
read containerName
while ! [[ $containerName =~ ^[[:lower:]_]+$ ]]; do
	echo "Please choose another name without uppercase and number, only letters."
	read containerName
done
echo "Your container name: $containerName"


echo "Please specify your database parameters in next steps:"

echo "Database name"
read databaseName
while ! [[ $databaseName =~ ^[a-zA-Z_0-9]+$ ]]; do
        echo "Please choose valid database name"
        read databaseName
done

echo "Database server READ"
read databaseServerRead
while ! [[ $databaseServerRead =~ ^[a-zA-Z_0-9.]+$ ]]; do
        echo "Please choose valid database server"
        read databaseServerRead
done


echo "Database server WRITE"
read databaseServerWrite
while ! [[ $databaseServerWrite =~ ^[a-zA-Z_0-9.]+$ ]]; do
        echo "Please choose valid database server"
        read databaseServerWrite
done


echo "Database user"
read databaseUser
while ! [[ $databaseUser =~ ^[a-zA-Z_0-9]+$ ]]; do
        echo "Please choose valid database user"
        read databaseUser
done

echo "Database password"
read databasePassword
while [[ -z $databasePassword ]]; do
        echo "Please choose valid database password"
        read databasePassword
done

echo "Do you want to attach existing data volume ? (yes / no)"
read dataVolume

VOLUME_ARGS=""
if [ $dataVolume = "yes" ]
then
    echo "Name of data volume:"
    read dataVolumeName
    VOLUME_ARGS="-v ${dataVolumeName}:/usr/share/ocsinventory-reports/ocsreports/ -v ${dataVolumeName}:/etc/ocsinventory-reports/ -v ${dataVolumeName}:/var/lib/ocsinventory-reports/"
fi


BASEPATH=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
#MODIFY APACHE CONFIGURATION
#sed -i -e "s/PerlSetEnv OCS_DB_HOST localhost/PerlSetEnv OCS_DB_HOST ${databaseServerWrite}/g" $BASEPATH/conf/z-ocsinventory-server.conf
#sed -i -e "s/PerlSetEnv OCS_DB_NAME ocsweb/PerlSetEnv OCS_DB_NAME ${databaseName}/g" $BASEPATH/conf/z-ocsinventory-server.conf
#sed -i -e "s/PerlSetEnv OCS_DB_LOCAL ocsweb/PerlSetEnv OCS_DB_LOCAL ${databaseName}/g" $BASEPATH/conf/z-ocsinventory-server.conf
#sed -i -e "s/PerlSetEnv OCS_DB_USER ocs/PerlSetEnv OCS_DB_USER ${databaseUser}/g" $BASEPATH/conf/z-ocsinventory-server.conf
#sed -i -e "s/PerlSetVar OCS_DB_PWD ocs/PerlSetVar OCS_DB_PWD ${databasePassword}/g" $BASEPATH/conf/z-ocsinventory-server.conf



COMMAND="docker run -p 80:80 --name ${containerName} -e OCS_DBNAME=${databaseName} \
-e OCS_DBSERVER_READ=${databaseServerRead} -e OCS_DBSERVER_WRITE=${databaseServerWrite} \
-e OCS_DBUSER=${databaseUser} -e OCS_DBPASS=${databasePassword} ${VOLUME_ARGS} -itd ocsinventory/ocsinventory-docker-image:master"

echo "========================================="
echo ""
echo "The command to launch your container is:"
echo ""
echo ${COMMAND}
echo ""
echo "=========================================="

echo ""
echo "Do you want to run container now ? (yes / no)"
read launchNow

if [ $launchNow = "yes" ]
then
    $(${COMMAND})
fi






