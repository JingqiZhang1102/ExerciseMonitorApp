<?php
    session_start();
    
    /* This file is the login page for employees. */
 
    // Include config file (connecter to mysql)
    require_once "config.php";

    
    // Define variables and initialize with empty values
    $id = $_SESSION["id"];
    
    $response = array();
    
    $fidexist = 1;
 
// Processing form data when form is submitted
if($_SERVER["REQUEST_METHOD"] == "POST"){
    
    if (empty($_POST["fid"])) {
        $response['error'] = true;
        $response['message'] = "No friend id passed in";
    } else {
        $id2 = $_POST["fid"];
        
        // check if the id exists
        $sql = "SELECT * FROM user WHERE id = ?";
        $stmt = mysqli_prepare($link, $sql);
        if(empty($stmt)){
            $response['error'] = true;
            $response['message'] = "stmt empty";
        }
        else{
            mysqli_stmt_bind_param($stmt, "s", $param_id);
            $param_id = $id2;
            
            // Attempt to execute the prepared statement
            if(mysqli_stmt_execute($stmt)){
                mysqli_stmt_store_result($stmt);
                // check if the id exists
                if(mysqli_stmt_num_rows($stmt) == 1) {
                    ;
                } else {
                    $fidexist = 0;
                    goto idnotexist;
                }
            } else{
                $response['error'] = true;
                $response['message'] = "check NOT executed";
            }
            // Close statement
            mysqli_stmt_close($stmt);
        }
        
        // write the friend table
        $sql = "REPLACE INTO `friend`(`id_1`, `id_2`) VALUES (?,?)";
        
        $stmt = mysqli_prepare($link, $sql);
        if(empty($stmt)){
            $response['error'] = true;
            $response['message'] = "stmt empty";
        }
        else{
            mysqli_stmt_bind_param($stmt, "ss", $param_id1, $param_id2);
            $param_id1 = $id;
            $param_id2 = $id2;
            
            // Attempt to execute the prepared statement
            if(mysqli_stmt_execute($stmt)){
                mysqli_stmt_store_result($stmt);
                $response['error'] = false;
                $response['message'] = "Write into mysql";
            } else{
                $response['error'] = true;
                $response['message'] = "NOT executed";
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
    
idnotexist:
    if($fidexist == 0) {
        $response['error'] = true;
        $response['message'] = "fid not exists";
    }
    
    $_SESSION["response"] = $response;
    
    echo json_encode($response);
?>
