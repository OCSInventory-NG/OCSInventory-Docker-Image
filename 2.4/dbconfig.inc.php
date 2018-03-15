<?php
define("DB_NAME", getenv('OCS_DBNAME'));
define("SERVER_READ", getenv('OCS_DBSERVER_READ'));
define("SERVER_WRITE", getenv('OCS_DBSERVER_WRITE'));
define("COMPTE_BASE", getenv('OCS_DBUSER'));
define("PSWD_BASE", getenv('OCS_DBPASS'));
$_SESSION["PSWD_BASE"]=PSWD_BASE;
?>
