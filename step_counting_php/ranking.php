<?php
    session_start();
    
    /* This file is the login page for employees. */
 
    // Include config file (connecter to mysql)
    require_once "config.php";

    
    // Define variables and initialize with empty values
    //$id = $_SESSION["id"];
    $date = $_SESSION["date"];
    $response = array();
    $id_step = array();
    
    //$id_step[$id] = $_SESSION["step"];
    $response['id_step'] = $id_step;
 
// Processing form data when form is submitted
if($_SERVER["REQUEST_METHOD"] == "POST"){
    if (empty($_POST["id"])){
        $response['error'] = true;
        $response['message'] = "no id passed in?";
    } else {
        $id = $_POST["id"];
        $id_step[$id] = $_SESSION["step"];
        // get the id and step pair
        $sql = "SELECT step_records.id,step_records.step FROM `step_records`,`friend` WHERE friend.id_1 = ? and friend.id_2 = step_records.id and step_records.date = ?";
        
        $stmt = mysqli_prepare($link, $sql);
        if(empty($stmt)){
            $response['error'] = true;
            $response['message'] = "empty stmt";
        }
        else{
            mysqli_stmt_bind_param($stmt, "ss", $param_id, $param_date);
            $param_id = $id;
            $param_date = $date;
            
            $response['error'] = false;
            $response['message'] = "Executed the sql";
            
            // Attempt to execute the prepared statement
            if(mysqli_stmt_execute($stmt)){
                mysqli_stmt_store_result($stmt);
                mysqli_stmt_bind_result($stmt, $id_var, $step_var);
                // store the pairs into the id_step array
                while (mysqli_stmt_fetch($stmt)) {
                    $id_step[$id_var] = $step_var;
                }
                $response['error'] = false;
                $response['message'] = "sql statement executed";
                $response['id_step'] = $id_step;
            } else{
                $response['error'] = true;
                $response['message'] = "not execute";
            }
            // Close statement
            mysqli_stmt_close($stmt);
        }
    }
    
    // Close connection
    mysqli_close($link);
} else {
    $response['error'] = true;
    $response['message'] = "Request not allowed";
}
    
    $_SESSION["response"] = $response;
    
    echo json_encode($response);
?>
