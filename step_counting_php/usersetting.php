<?php
    session_start();
    
    /* This file is the signu- page for app users. */
    require_once "config.php";

    
    // Define variables and initialize with empty values
    $id = $newgoal = $password = "";
    $response = array();
     
// Processing form data when form is submitted
if($_SERVER["REQUEST_METHOD"] == "POST"){
    if (empty($_POST['id']) || empty($_POST['newgoal'])) {
        $response['error'] = true;
        $response['message'] = 'id or goal missing';
    } else {
        $id = $_POST['id'];
        $newgoal = $_POST['newgoal'];
        // save to session array
        $_SESSION["id"] = $id;
        $_SESSION["newgoal"] = $newgoal;
        
        // get current user password
        $sql = "SELECT password FROM user WHERE id = ?";
        $stmt = mysqli_prepare($link, $sql);
        if(empty($stmt)){
            $response['error'] = true;
            $response['message'] = "get pwd empty stmt";
        }
        else{
            mysqli_stmt_bind_param($stmt, "s", $param_id);
            $param_id = $id;
            // Attempt to execute the prepared statement
            if(mysqli_stmt_execute($stmt)){
                mysqli_stmt_store_result($stmt);
                mysqli_stmt_bind_result($stmt, $password_var);
                if(mysqli_stmt_fetch($stmt)){
                    $password = $password_var;
                }
                $response['error'] = false;
                $response['user'] = $id;
            } else{
                $response['error'] = true;
                $response['message'] = "get pwd not executed";
            }
            // Close statement
            mysqli_stmt_close($stmt);
        }
        
        // update the step goal
        $sql = "REPLACE INTO `user`(`id`, `password`, `stepgoal`) VALUES (?,?,?)";
        $stmt = mysqli_prepare($link, $sql);
        if(empty($stmt)){
            $response['error'] = true;
            $response['message'] = "update goal empty stmt";
        }
        else{
            mysqli_stmt_bind_param($stmt, "ssi", $param_id, $param_password, $param_goal);
            $param_id = $id;
            $param_password = $password;
            $param_goal = intval($newgoal);
            // Attempt to execute the prepared statement
            if(mysqli_stmt_execute($stmt)){
                mysqli_stmt_store_result($stmt);
                $response['error'] = false;
                $response['user'] = $id;
            } else{
                $response['error'] = true;
                $response['message'] = "update goal not executed";
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
