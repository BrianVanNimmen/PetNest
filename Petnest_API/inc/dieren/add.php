<?php
// --- "add" een dier

// Zijn de nodige parameters meegegeven in de request?
// verplicht: naam, klant_id, soort
check_required_fields(["naam", "klant_id", "soort"]);

// optionele velden (kunnen NULL zijn)
$geboortedatum = isset($postvars['geboortedatum']) ? $postvars['geboortedatum'] : null;

$dierenarts_id = isset($postvars['dierenarts_id']) && $postvars['dierenarts_id'] !== ''
    ? (int)$postvars['dierenarts_id']
    : null;

// ----------------------------------------------------
// NIEUW: foto upload + foto_url genereren
// ----------------------------------------------------
$foto_url = null;

// Alleen uitvoeren als er effectief een foto is meegestuurd
if (isset($_FILES['foto']) && $_FILES['foto']['error'] === UPLOAD_ERR_OK) {

    // pad naar uploads-map: /api/uploads/
    // add.php zit in: /api/inc/dieren/add.php → daarom ../../uploads/
    $uploadDir = __DIR__ . '/../../uploads/';

    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $tmpName  = $_FILES['foto']['tmp_name'];
    $origName = basename($_FILES['foto']['name']);
    $ext      = strtolower(pathinfo($origName, PATHINFO_EXTENSION));

    // veilige extensies
    if (!in_array($ext, ['jpg','jpeg','png','gif','webp'])) {
        die('{"error":"Invalid image type","status":"fail"}');
    }

    // unieke bestandsnaam
    $newName  = uniqid('dier_', true) . '.' . $ext;
    $destPath = $uploadDir . $newName;

    if (move_uploaded_file($tmpName, $destPath)) {
        $foto_url = 'uploads/' . $newName;
    }
}

if ($foto_url === null) {
    $foto_url = 'uploads/default-dier.png';
}

// ----------------------------------------------------
//  EINDE NIEUWE CODE — rest blijft bijna identiek
// ----------------------------------------------------

// create prepared statement
if(!$stmt = $conn->prepare("
    INSERT INTO dieren (naam, klant_id, dierenarts_id, soort, geboortedatum, foto_url)
    VALUES (?,?,?,?,?,?)
")){
    die('{"error":"Prepared Statement failed on prepare","errNo":' . json_encode($conn -> errno) .',"mysqlError":' . json_encode($conn -> error) .',"status":"fail"}');
}

// bind parameters
if(!$stmt -> bind_param(
    "siisss",
    $postvars['naam'],
    $postvars['klant_id'],
    $dierenarts_id,
    $postvars['soort'],
    $geboortedatum,
    $foto_url
)){
    die('{"error":"Prepared Statement bind failed on bind","errNo":' . json_encode($conn -> errno) .',"mysqlError":' . json_encode($conn -> error) .',"status":"fail"}');
}

$stmt -> execute();

if($conn->affected_rows == 0) {
    $stmt -> close();
    die('{"error":"Prepared Statement failed on execute : no rows affected","errNo":' . json_encode($conn -> errno) .',"mysqlError":' . json_encode($conn -> error) .',"status":"fail"}');
}

$stmt -> close();

$PR_ID = $conn -> insert_id;

// --- AUTOMATISCH LEGE MEDISCH DOSSIER AANMAKEN ---

$medischStmt = $conn->prepare("
    INSERT INTO medisch_dossier (dier_id, gebit_status, botten_status, spieren_status)
    VALUES (?, 'onbekend', 'onbekend', 'onbekend')
");

if (!$medischStmt) {
    die(json_encode([
        "error" => "Failed to prepare medisch_dossier insert",
        "mysqlError" => $conn->error,
        "status" => "fail"
    ]));
}

if (!$medischStmt->bind_param("i", $PR_ID)) {
    die(json_encode([
        "error" => "Failed to bind medisch_dossier insert",
        "mysqlError" => $conn->error,
        "status" => "fail"
    ]));
}

$medischStmt->execute();
$medischStmt->close();


die('{"data":"ok","message":"Record added successfully","status":200, "PR_ID": ' . $PR_ID . '}');
?>
