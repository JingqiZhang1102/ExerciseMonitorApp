<?php
    session_start();
    
    /* This file is the signu- page for app users. */
    require_once "config.php";

    
    // Define variables and initialize with empty values
    $id = $check_date = "";
    $response = array();

// Processing form data when form is submitted
if($_SERVER["REQUEST_METHOD"] == "POST"){
    if (empty($_POST['id']) || empty($_POST['check_date'])) {
        $response['error'] = true;
        $response['message'] = 'calendar: id or date missing';
    } else {
        $id = $_POST['id'];
        $check_date = $_POST['check_date'];
        
        // get current user password
        $sql = "SELECT step FROM step_records WHERE id = ? and date = ?";
        $stmt = mysqli_prepare($link, $sql);
        if(empty($stmt)){
            $response['error'] = true;
            $response['message'] = "calendar: empty stmt :(";
        }
        else{
            mysqli_stmt_bind_param($stmt, "ss", $param_id, $param_date);
            $param_id = $id;
            $param_date = $check_date;
            // Attempt to execute the prepared statement
            if(mysqli_stmt_execute($stmt)){
                mysqli_stmt_store_result($stmt);
                if(mysqli_stmt_num_rows($stmt) == 1) {
                    mysqli_stmt_bind_result($stmt, $date_step);
                    if(mysqli_stmt_fetch($stmt)){
                        $response['error'] = false;
                        $response['message'] = "calendar: executed, get date_step";
                        $response['date_step'] = $date_step;
                    } else {
                        $response['error'] = true;
                        $response['message'] = "calendar: cannot fetch stmt?";
                    }
                } else {
                    $response['date_step'] = 0;
                    $response['error'] = false;
                    $response['message'] = "calendar: executed, get date_step; no record for this date, so 0";
                }
            } else{
                $response['error'] = true;
                $response['message'] = "calendar: sql not executed";
            }
            // Close statement
            mysqli_stmt_close($stmt);
        }
        
    }
    // Close connection
    mysqli_close($link);
} else {
    $response['error'] = true;
    $response['message'] = "calandar: Request not allowed";
}
    
    $_SESSION["response"] = $response;
    
    echo json_encode($response);
?>
