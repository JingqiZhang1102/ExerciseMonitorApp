<?php
    session_start();
    
    /* This file is the signu- page for app users. */
    require_once "config.php";

    
    // Define variables and initialize with empty values
    $id = "";
    $response = array();
    $level = 0;
     
// Processing form data when form is submitted
if($_SERVER["REQUEST_METHOD"] == "POST"){
    if (empty($_POST['id'])) {
        $response['error'] = true;
        $response['message'] = 'checklevel: id missing';
    } else {
        $id = $_POST['id'];
        // save to session array
        $_SESSION["id"] = $id;
        
        // get current user password
        $sql = "SELECT level FROM user_points WHERE id = ?";
        $stmt = mysqli_prepare($link, $sql);
        if(empty($stmt)){
            $response['error'] = true;
            $response['message'] = "checklevel: empty stmt";
        }
        else{
            mysqli_stmt_bind_param($stmt, "s", $param_id);
            $param_id = $id;
            // Attempt to execute the prepared statement
            if(mysqli_stmt_execute($stmt)){
                mysqli_stmt_store_result($stmt);
                mysqli_stmt_bind_result($stmt, $level_var);
                if(mysqli_stmt_fetch($stmt)){
                    $level = $level_var;
                }
                $response['error'] = false;
                $response['message'] = "checklevel: executed, get level_var";
                $response['level'] = $level;
            } else{
                $response['error'] = true;
                $response['message'] = "checklevel: sql not executed";
            }
            // Close statement
            mysqli_stmt_close($stmt);
        }
        
    }
    // Close connection
    mysqli_close($link);
} else {
    $response['error'] = true;
    $response['message'] = "checklevel: Request not allowed";
}
    
    $_SESSION["response"] = $response;
    
    echo json_encode($response);
?>
