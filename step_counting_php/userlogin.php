<?php
    session_start();
    
    /* This file is the login page for employees. */
 
    // Include config file (connecter to mysql)
    require_once "config.php";
    
    $ip = $_SERVER['REMOTE_ADDR'];

    
    // Define variables and initialize with empty values
    $id = $password = "";
    
    $response = array();
    
 
// Processing form data when form is submitted
if($_SERVER["REQUEST_METHOD"] == "POST"){
    
    if (empty($_POST['username']) || empty($_POST['password'])) {
        $response['error'] = true;
        $response['message'] = 'Username or password missing';
    } else {
        $id = $_POST['username'];
        // save to session array
        $_SESSION["id"] = $id;
        $password = $_POST['password'];
        
        $sql = "SELECT id, password FROM user WHERE id = ?";
        
        $stmt = mysqli_prepare($link, $sql);
        if(empty($stmt)){
            ;
        }
        else{
            mysqli_stmt_bind_param($stmt, "s", $param_id);
            $param_id = $id;
            
            // Attempt to execute the prepared statement
            if(mysqli_stmt_execute($stmt)){
                mysqli_stmt_store_result($stmt);
                
                // Check if the ID exists, if yes then verify password
                if(mysqli_stmt_num_rows($stmt) == 1){
                    mysqli_stmt_bind_result($stmt, $id, $hashed_password);
                    if(mysqli_stmt_fetch($stmt)){
                        if($hashed_password == $password){
                            $_SESSION["loggedin"] = true;
                            $_SESSION["id"] = $id;
                            $response['error'] = false;
                            $response['user'] = $id;

                        } else{
                            $response['error'] = true;
                            $response['message'] = 'Invalid password';
                        }
                    }
                } else{
                    $response['error'] = true;
                    $response['message'] = 'Invalid username';
                }
            } else{
                $response['error'] = true;
                $response['message'] = "Request not allowed";
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
