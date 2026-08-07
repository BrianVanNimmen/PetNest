<?php
if (!defined('INDEX')) {
   header("HTTP/1.1 404 Not Found");
    die('<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL /wm/api/inc/dbcon.php was not found on this server.</p>
</body></html>');
}

// // localhost
// $servername = "localhost";
// $username = "root";
// $password = "jouw_wachtwoord";
// $dbname = "petnest@home";


// Docker
$servername = "petnest_db"; // container naam ipv localhost
$username = "root";
$password = "jouw_wachtwoord"; // zie docker-compose.yml
$dbname = "petnest_home";

// // combell
// $servername = "jouw_server.db.webhosting.be";
// $username = "jouw_gebruikersnaam";
// $password = "jouw_wachtwoord";
// $dbname = "jouw_databasenaam";

$conn = mysqli_connect($servername, $username, $password, $dbname) or die(mysqli_connect_error());
mysqli_set_charset($conn, 'utf8mb4'); // mysqli extension
// de 2e parameter is de collation voor de connectie : op welke 

?>