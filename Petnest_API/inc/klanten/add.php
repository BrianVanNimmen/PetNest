<?php
// RESTfulAPI/api/inc/klanten/add.php
// --- Klant toevoegen op basis van reeds aangemaakte Firebase-user (firebase_uid)

check_required_fields([
    "voornaam",
    "achternaam",
    "email",
    "firebase_uid"
]);

if (empty($postvars['firebase_uid'])) {
    die(json_encode(["error" => "firebase_uid is leeg of niet meegegeven", "status" => "fail"]));
}

$firebase_uid  = $postvars['firebase_uid'];
$geboortedatum = !empty($postvars['geboortedatum']) ? $postvars['geboortedatum'] : null;
$gemeente_id   = !empty($postvars['gemeente_id'])   ? (int)$postvars['gemeente_id'] : null;

if (!$stmt = $conn->prepare("
    INSERT INTO klanten (voornaam, achternaam, geboortedatum, gemeente_id, email, firebase_uid)
    VALUES (?,?,?,?,?,?)

")) {
    die(json_encode(["error" => "Prepare failed", "errNo" => $conn->errno, "mysqlError" => $conn->error, "status" => "fail"]));
}

if (!$stmt->bind_param(
    "sssiss",
    $postvars['voornaam'],
    $postvars['achternaam'],
    $geboortedatum,
    $gemeente_id,
    $postvars['email'],
    $firebase_uid
)) {
    die(json_encode(["error" => "Bind failed", "errNo" => $conn->errno, "mysqlError" => $conn->error, "status" => "fail"]));
}

$stmt->execute();

if ($conn->affected_rows == 0) {
    $stmt->close();
    die(json_encode(["error" => "No rows inserted", "errNo" => $conn->errno, "mysqlError" => $conn->error, "status" => "fail"]));
}

$stmt->close();
$PR_ID = $conn->insert_id;

die(json_encode([
    "data"         => "ok",
    "message"      => "Klant succesvol toegevoegd",
    "status"       => 200,
    "PR_ID"        => $PR_ID,
    "firebase_uid" => $firebase_uid
]));
