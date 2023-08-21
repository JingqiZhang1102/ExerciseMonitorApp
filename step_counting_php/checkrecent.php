<?php
    session_start();
    
    /* This file is the login page for employees. */
 
    // Include config file (connecter to mysql)
    require_once "config.php";

    
    // Define variables and initialize with empty values
    //$id = $_SESSION["id"];
    
    $response = array();
    $recent_results = array();
 
// Processing form data when form is submitted
if($_SERVER["REQUEST_METHOD"] == "POST"){
    if (empty($_POST["id"])){
        $response['error'] = true;
        $response['message'] = "no id passed in?";
    } else {
        $id = $_POST["id"];
        
        $sql = "select date, step from step_records where id = ?";
        $stmt = mysqli_prepare($link, $sql);
        if(empty($stmt)){
            $response['error'] = true;
            $response['message'] = "stmt is empty!!?!";
            $response['recent_results'] = $recent_results;
        }
        else {
            mysqli_stmt_bind_param($stmt, "s", $param_id);
            $param_id = $id;
            
            // execute the sql statement
            if(mysqli_stmt_execute($stmt)){
                mysqli_stmt_store_result($stmt);
                mysqli_stmt_bind_result($stmt, $date_var, $step_var);

                while (mysqli_stmt_fetch($stmt)) {
                    $recent_results[$date_var] = $step_var;
                }
                $recent_length = count($recent_results);
                
                // keep at most 7 recent records
                if ($recent_length >= 8) {
                    $recent_results = array_slice($recent_results, -7, 7);
                    /*$cut_results = array_slice($recent_results, -1, 7);
                    $response['error'] = false;
                    $response['message'] = "sql statement executed";
                    $response['recent_results'] = $cut_results;*/
                }
                else {
                    /*$response['error'] = false;
                    $response['message'] = "sql statement executed";
                    $response['recent_results'] = $recent_results;*/
                }
                
                $response['error'] = false;
                $response['message'] = "sql statement executed";
                $response['recent_results'] = $recent_results;
            }
            // cannot execute
            else {
                $response['error'] = true;
                $response['message'] = "cannot execute?!";
                $response['recent_results'] = $recent_results;
            }
        }
    }
    
    
    
    
} else {
    $response['error'] = true;
    $response['message'] = "Request not allowed";
    $response['recent_results'] = $recent_results;
}
    
    $_SESSION["response"] = $response;
    
    echo json_encode($response);
?>
