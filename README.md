![Logo-OCS](http://cdn.ocsinventory-ng.org/common/banners/banner300px.png)

## Some Links
  - [ASK question](https://ask.ocsinventory-ng.org)
  - [Website](https://www.ocsinventory-ng.org/?utm_source=github-ocs)
  - [Github](https://github.com/OCSInventory-NG)
  - [OCS Professional](https://www.ocsinventory-ng.org/en/#ocs-pro-en)



OCS (Open Computers and Software Inventory Next Generation) is an assets management and deployment solution.
Since 2001, OCS Inventory NG has been looking for making software and hardware more powerful.
OCS Inventory NG asks its agents to know the software and hardware composition of every computer or server.

----------


## Assets management

Since 2001, OCS Inventory NG has been looking for making software and hardware more powerful. OCS Inventory NG asks its agents to know the software and hardware composition of every computer or server. OCS Inventory also ask to discover network’s elements which can’t receive an agent. Since the version 2.0, OCS Inventory NG take in charge the SNMP scans functionality.
This functionality’s main goal is to complete the data retrieved from the IP Discover scan. These SNMP scans will allow you to add a lot more informations from your network devices : printers, scanner, routers, computer without agents, …

----------

## Deployment

OCS Inventory NG includes the packet deployment functionality to be sure that all of the softwares environments which are on the network are the same. From the central management server, you can send the packets which will be downloaded with HTTP/HTTPS and launched by the agent on client’s computer. The OCS deployment is configured to make the packets less impactable on the network. OCS is used as a deployment tool on IT stock of more 100 000 devices.

----------


## Installation
#### Start your OCSInventory container

Starting a **OCSInventory container** is simple:
Clone this repository :

> sudo git clone https://github.com/OCSInventory-NG/OCSInventory-Docker-Image.git
> cd OCSInventory-Docker-Image


*The following command uses the **default values**.*

> sudo docker run \
> -p 80:80 \
> --name myocsinventory \
> -e OCS_DBNAME=ocsweb \
> -e OCS_DBSERVER_READ=localhost \
> -e OCS_DBSERVER_WRITE=localhost \
> -e OCS_DBUSER=ocs \
> -e OCS_DBPASS=ocs \
> -itd \
> ocsinventory/ocsinventory-docker-image:latest \
> bash

----------
### Use setup.sh to start you OCSInventory container

Enter the directory you just clone, and run the setup.sh script

> cd OCSInventory-Docker-Image
> sudo bash setup.sh

Follow the steps, the script will do the work for you

### Environmental variables options

Use the following environmental variables to connect your MySQL Server.

> OCS_DBNAME= *(Name of your database)*
> OCS_DBSERVER_READ= *(Database Server)*
> OCS_DBSERVER_WRITE=*(Database Server)*
> OCS_DBUSER= *(User database)*
> OCS_DBPASS= *(User password)*

----------

### Using Docker container

If you want to run your OCSInventory within a MYSQL docker container, simply start your database server before starting your OCSInventory container. More information here for MYSQL container or use our **[Stack OCSInventory](https://github.com/OCSInventory-NG/OCSInventory-Docker-Stack.git)**.

----------

### Container shell access and viewing container logs

The docker exec command allows you to run commands inside a Docker container. The following command line will give you a bash shell inside your OCSInventory container:

> sudo docker exec -it yourcontainerOCSInventory bash

You can access to the container logs through the following Docker command:

> sudo docker logs yourcontainerOCSInventory

----------

### Create a volume back up from the docker's host

The Docker documentation is a good starting point for understanding the different storage options and give advice in this area. We will simply show the basic procedure here:

Create a data directory on your host system:

> mkdir /my/own/datadir

Start your OCSInventory container like this:

> sudo docker run \
> -p 80:80 \
> --name myocsinventory \
> -v /my/own/datadir:/data/save/ocsinventory \
> -e OCS_DBNAME=ocsweb \
> -e OCS_DBSERVER_READ=localhost \
> -e OCS_DBSERVER_WRITE=localhost \
> -e OCS_DBUSER=ocs \
> -e OCS_DBPASS=ocs \
> -itd \
> ocsinventory/ocsinventory-docker-image:latest \
> bash

The  option -v /my/own/datadir:/data/save/ocsinventory mounts the /my/own/datadir directory from the host system as /data/save/ocsinventory inside the container.

----------

### Mount a volume as a data volume

Create a volume:

> docker volume create ocsdata

Run your container:

> sudo docker run \
> -p 80:80 \
> --name name-container \
> -v ocsdata:/usr/share/ocsinventory-reports/ \
> -v ocsdata:/etc/ocsinventory-reports/ \
> -v ocsdata:/var/lib/ocsinventory-reports/ \
> -e OCS_DBNAME=ocsweb \
> -e OCS_DBSERVER_READ=localhost \
> -e OCS_DBSERVER_WRITE=localhost \
> -e OCS_DBUSER=ocs \
> -e OCS_DBPASS=ocs \
> -itd \
> ocsinventory/ocsinventory-docker-image:latest \
> bash

It is advisable to keep the directories mentioned in the example:

> /var/lib/ocsinventory-reports/ <br>
> /etc/ocsinventory-reports/ <br>
> /usr/share/ocsinventory-reports/ocsreports/ <br>

They contain the necessary information for a proper server and web interface functioning

## Contributing

1. Fork it!
2. Create your feature branch: git checkout -b my-new-feature
3. Add your changes: git add folder/file1.php
4. Commit your changes: git commit -m 'Add some feature'
5. Push to the branch: git push origin my-new-feature
6. Submit a pull request !


## License

OCS Inventory Docker Image is GPLv3 licensed
