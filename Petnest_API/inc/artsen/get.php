<?php
// RESTfulAPI/api/inc/artsen/get.php
// --- "Get" alle dierenartsen

$sql = "SELECT
            id,
            voornaam,
            achternaam,
            email,
            telefoon,
            praktijknaam,
            gemeente_id,
            firebase_uid
        FROM dierenartsen";

$result = $conn->query($sql);

if (!$result) {
    $response['code']   = 7;
    $response['status'] = $api_response_code[$response['code']]['HTTP Response'];
    $response['data']   = $conn->error;
    deliver_response($response);
}

// Resultset omvormen
$response['data'] = getJsonObjFromResult($result);
$result->free();
$conn->close();

// JSON terugsturen
deliver_JSONresponse($response);
exit;
