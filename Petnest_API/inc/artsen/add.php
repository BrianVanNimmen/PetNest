<?php
// RESTfulAPI/api/inc/artsen/add.php
// --- Dierenarts toevoegen op basis van reeds aangemaakte Firebase-user (firebase_uid)

// Vanaf nu verwachten we multipart/form-data (FormData in frontend), geen JSON meer.

// Verplichte velden (via $_POST)
$required = ['voornaam', 'achternaam', 'email', 'firebase_uid'];
foreach ($required as $field) {
    if (!isset($_POST[$field]) || trim($_POST[$field]) === '') {
        die(json_encode([
            "status"  => "fail",
            "message" => "Verplicht veld ontbreekt: $field"
        ]));
    }
}

// Certificaat is verplicht
if (
    !isset($_FILES['certificaat']) ||
    $_FILES['certificaat']['error'] !== UPLOAD_ERR_OK
) {
    die(json_encode([
        "status"  => "fail",
        "message" => "Certificaat is verplicht."
    ]));
}

// Velden uit POST
$voornaam      = $_POST['voornaam'];
$achternaam    = $_POST['achternaam'];
$email         = $_POST['email'];
$firebase_uid  = $_POST['firebase_uid'];

$telefoon      = isset($_POST['telefoon'])      ? $_POST['telefoon']      : null;
$praktijknaam  = isset($_POST['praktijknaam'])  ? $_POST['praktijknaam']  : null;
$gemeente_id = isset($_POST['gemeente_id']) && $_POST['gemeente_id'] !== '' ? (int)$_POST['gemeente_id'] : null;

// Status standaard in afwachting
$status = 'in afwachting';

// Certificaat uploaden
$uploadDir = __DIR__ . '/../../uploads/certificaten/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0775, true);
}

$tmpName  = $_FILES['certificaat']['tmp_name'];
$origName = basename($_FILES['certificaat']['name']);
$ext      = strtolower(pathinfo($origName, PATHINFO_EXTENSION));

// Optioneel: eenvoudige extensie-check
$allowed = ['pdf', 'jpg', 'jpeg', 'png'];
if (!in_array($ext, $allowed)) {
    die(json_encode([
        "status"  => "fail",
        "message" => "Ongeldig bestandstype voor certificaat."
    ]));
}

$newName  = time() . '_' . preg_replace('/[^a-zA-Z0-9_\.-]/', '_', $origName);
$destPath = $uploadDir . $newName;

if (!move_uploaded_file($tmpName, $destPath)) {
    die(json_encode([
        "status"  => "fail",
        "message" => "Uploaden van certificaat mislukt."
    ]));
}

// Pad dat je in de DB bewaart (relatief t.o.v. API-root)
$certificaat_url = 'uploads/certificaten/' . $newName;

// Prepared statement opbouwen (status + certificaat_url toegevoegd)
if (!$stmt = $conn->prepare("
    INSERT INTO dierenartsen 
        (voornaam, achternaam, email, firebase_uid, telefoon, praktijknaam, gemeente_id, status, certificaat_url)
    VALUES (?,?,?,?,?,?,?,?,?)
")) {
    die(json_encode([
        "status"     => "fail",
        "error"      => "Prepared Statement failed on prepare",
        "errNo"      => $conn->errno,
        "mysqlError" => $conn->error
    ]));
}

// s = string, i = integer
if (!$stmt->bind_param(
    "ssssssiss",
    $voornaam,
    $achternaam,
    $email,
    $firebase_uid,
    $telefoon,
    $praktijknaam,
    $gemeente_id,
    $status,
    $certificaat_url
)) {
    die(json_encode([
        "status"     => "fail",
        "error"      => "Prepared Statement failed on bind_param",
        "errNo"      => $stmt->errno,
        "mysqlError" => $stmt->error
    ]));
}

if (!$stmt->execute()) {
    $stmt->close();
    die(json_encode([
        "status"     => "fail",
        "error"      => "Prepared Statement failed on execute",
        "errNo"      => $stmt->errno,
        "mysqlError" => $stmt->error
    ]));
}

if ($conn->affected_rows == 0) {
    $stmt->close();
    die(json_encode([
        "status"     => "fail",
        "error"      => "Geen rijen toegevoegd",
        "errNo"      => $conn->errno,
        "mysqlError" => $conn->error
    ]));
}

$stmt->close();

$ID = $conn->insert_id;

// succesvol antwoord
die(json_encode([
    "status"         => 200,
    "message"        => "Dierenarts succesvol toegevoegd",
    "id"             => $ID,
    "firebase_uid"   => $firebase_uid,
    "status_arts"    => $status,
    "certificaatUrl" => $certificaat_url
]));
