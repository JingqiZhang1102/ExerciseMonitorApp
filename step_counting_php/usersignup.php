<?php
    session_start();
    
    /* This file is the signu- page for app users. */
    require_once "config.php";

    
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
        
        // write into user
        $sql = "INSERT INTO `user`(`id`, `password`, `stepgoal`) VALUES (?,?,?)";
        
        $stmt = mysqli_prepare($link, $sql);
        if(empty($stmt)){
            $response['error'] = true;
            $response['message'] = "empty stmt";
        }
        else{
            mysqli_stmt_bind_param($stmt, "ssi", $param_id, $param_password, $param_stepgoal);
            $param_id = $id;
            $param_password = $password;
            $param_stepgoal = 3000;
            
            // Attempt to execute the prepared statement
            if(mysqli_stmt_execute($stmt)){
                mysqli_stmt_store_result($stmt);
                
                $response['error'] = false;
                $response['user'] = $id;
            } else{
                $response['error'] = true;
                $response['message'] = "stmt not executed";
            }
            // Close statement
            mysqli_stmt_close($stmt);
        }
        
        // write into user_points
        $sql = "INSERT INTO `user_points`(`id`,`date`,`point`,`total_point`, `level`) VALUES (?,?,?,?)";
        
        $stmt = mysqli_prepare($link, $sql);
        if(empty($stmt)){
            $response['error'] = true;
            $response['message'] = "user_point empty stmt";
        }
        else{
            mysqli_stmt_bind_param($stmt, "ssiii", $param_id,$param_date, $param_point,$param_total_point, $param_level);
            $param_id = $id;
            
            date_default_timezone_set('America/Los_Angeles');
            $date = date("Y-m-d");
            $_SESSION["date"] = $date;
            $param_date = $date;
            
            $param_point = 0;
            $param_total_point = 0;
            $param_level = 0;
            
            // Attempt to execute the prepared statement
            if(mysqli_stmt_execute($stmt)){
                mysqli_stmt_store_result($stmt);
                
                $response['error'] = false;
                $response['user'] = $id;
            } else{
                $response['error'] = true;
                $response['message'] = "user_point not executed";
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
