<?php
// --- "delete" een afspraak (bezoek)

// Zijn de nodige parameters meegegeven in de request?
check_required_fields(["id"]);

if(!$stmt = $conn->prepare("DELETE FROM bezoeken WHERE id = ?")){
	die('{"error":"Prepared Statement failed on prepare","errNo":' . json_encode($conn->errno) .',"mysqlError":' . json_encode($conn->error) .',"status":"fail"}');
}

// bind parameters ( s = string | i = integer | d = double | b = blob )
if(!$stmt->bind_param("i", $postvars["id"])){
	die('{"error":"Prepared Statement bind failed on bind","errNo":' . json_encode($conn->errno) .',"mysqlError":' . json_encode($conn->error) .',"status":"fail"}');
}

$stmt->execute();

if($conn->affected_rows == 0) {
	// delete failed
	$stmt->close();
	die('{"error":"Prepared Statement failed on execute : no rows affected","errNo":' . json_encode($conn->errno) .',"mysqlError":' . json_encode($conn->error) .',"status":"fail"}');
}

// deleted
$stmt->close();
die('{"data":"ok","message":"Record deleted successfully","status":200}');
?>
