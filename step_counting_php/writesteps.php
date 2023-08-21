<?php
    session_start();
    
    /* This file is the login page for employees. */
 
    // Include config file (connecter to mysql)
    require_once "config.php";

    
    // Define variables and initialize with empty values
    $id = $_SESSION["id"];
    $stepcount = $distance = "";
    
    $response = array();
    
    $stepgoal = 0;
    $passgoal = 0;
    
    $yesterday_total = 0;
 
// Processing form data when form is submitted
if($_SERVER["REQUEST_METHOD"] == "POST"){
    
    if (empty($_POST["stepcount"]) || empty($_POST["distance"])) {
        $response['error'] = true;
        $response['message'] = 'No stepcount or distance passed in';
    } else {
        $stepcount = $_POST["stepcount"];
        $distance = $_POST["distance"];
        
        // write into step_records
        $sql = "REPLACE INTO `step_records`(`id`, `date`, `step`, `distance`,`yearmonth`) VALUES (?,?,?,?,?)";
        
        $stmt = mysqli_prepare($link, $sql);
        if(empty($stmt)){
            ;
        }
        else{
            mysqli_stmt_bind_param($stmt, "ssids", $param_id, $param_date, $param_step, $param_dist, $param_yearmonth);
            $param_id = $id;
            
            date_default_timezone_set('America/Los_Angeles');
            $date = date("Y-m-d");
            $_SESSION["date"] = $date;
            $param_date = $date;
            
            $_SESSION["step"] = $stepcount;
            $param_step = $stepcount;
            $_SESSION["distance"] = $distance;
            $param_dist = $distance;
            
            $param_yearmonth = substr($param_date, 0, 7);
            
            // Attempt to execute the prepared statement
            if(mysqli_stmt_execute($stmt)){
                mysqli_stmt_store_result($stmt);
                $response['error'] = false;
                $response['message'] = "step record: Write into mysql";
            } else{
                $response['error'] = true;
                $response['message'] = "step record: Not executed";
            }
            // Close statement
            mysqli_stmt_close($stmt);
        }
        
        
        // get current user's goal
        $sql = "SELECT stepgoal FROM user WHERE id = ?";
        
        $stmt = mysqli_prepare($link, $sql);
        if(empty($stmt)){
            $response['error'] = true;
            $response['message'] = "stepgoal stmt empty";
        }
        else{
            mysqli_stmt_bind_param($stmt, "s", $param_id);
            $param_id = $id;
            
            /*$response['error'] = false;
            $response['message'] = "get goal";*/
            
            // Attempt to execute the prepared statement
            if(mysqli_stmt_execute($stmt)){
                mysqli_stmt_store_result($stmt);
                mysqli_stmt_bind_result($stmt, $stepgoal_var);
                if(mysqli_stmt_fetch($stmt)) {
                    $stepgoal = $stepgoal_var;
                    $_SESSION["stepgoal"] = $stepgoal;
                } else{
                    $response['error'] = true;
                    $response['message'] = "fetch stepgoal failed";
                }
            } else{
                $response['error'] = true;
                $response['message'] = "get goal: Not executed";
            }
            // Close statement
            mysqli_stmt_close($stmt);
        }
        
        // compare goal with current step
        if ($stepcount >= $stepgoal) {
            // pass the goal, Good!
            // get the total points yesterday
            /*$sql = "SELECT total_point FROM user_points WHERE id = ? AND date = ?";*/
            
            // 0817: get the total points not today
            $sql = "SELECT total_point FROM user_points WHERE id = ? AND date != ?";
            
            $stmt = mysqli_prepare($link, $sql);
            if(empty($stmt)){
                $response['error'] = true;
                $response['message'] = "get yesterday stmt empty";
            }
            else{
                mysqli_stmt_bind_param($stmt, "ss", $param_id, $param_date);
                $param_id = $id;
                date_default_timezone_set('America/Los_Angeles');
                $date = date("Y-m-d");
                /*$param_date = date( "Y-m-d", strtotime( $date . "-1 day"));*/
                $param_date = $date;
                
                /*$response['error'] = false;
                $response['message'] = "get yesterday's total point";*/
                
                if(mysqli_stmt_execute($stmt)){
                    mysqli_stmt_store_result($stmt);
                    
                    // Check if there is a record for yesterday
                    if(mysqli_stmt_num_rows($stmt) == 1){
                        // there is record for yesterday
                        mysqli_stmt_bind_result($stmt, $total_var);
                        if(mysqli_stmt_fetch($stmt)){
                            $yesterday_total = $total_var;
                        }
                    } else {
                        // no record yesterday :(
                        ;
                    }
                } else {
                    $response['error'] = true;
                    $response['message'] = "yesterday not execute";
                }
                // Close statement
                mysqli_stmt_close($stmt);
            }
            // update today's record in user_points
            $sql = "REPLACE INTO `user_points`(`id`, `date`, `point`, `total_point`, `level`) VALUES (?,?,?,?,?)";
            
            $stmt = mysqli_prepare($link, $sql);
            if(empty($stmt)){
                $response['error'] = true;
                $response['message'] = "update today userpoint stmt empty";
            }
            else{
                mysqli_stmt_bind_param($stmt, "ssiii", $param_id, $param_date, $param_point, $param_total, $param_level);
                $param_id = $id;
                date_default_timezone_set('America/Los_Angeles');
                $date = date("Y-m-d");
                $param_date = $date;
                $param_point = 1;
                $param_total = $yesterday_total + $param_point;
                $param_level = 1 + floor($param_total / 5);
                
                /*$response['error'] = false;
                $response['message'] = "update today userpoints";*/
                
                if(mysqli_stmt_execute($stmt)){
                    mysqli_stmt_store_result($stmt);
                } else {
                    $response['error'] = true;
                    $response['message'] = "today update not execute";
                }
                mysqli_stmt_close($stmt);
            }
            
        }
        else{
            // not yet, fighting~
            $sql = "SELECT total_point FROM user_points WHERE id = ? AND date = ?";
            $stmt = mysqli_prepare($link, $sql);
            if(empty($stmt)){
                $response['error'] = true;
                $response['message'] = "get yesterday stmt empty";
            }
            else{
                mysqli_stmt_bind_param($stmt, "ss", $param_id, $param_date);
                $param_id = $id;
                date_default_timezone_set('America/Los_Angeles');
                $date = date("Y-m-d");
                $param_date = date( "Y-m-d", strtotime( $date . "-1 day"));
                /*$response['error'] = false;
                $response['message'] = "get yesterday's total point";*/
                if(mysqli_stmt_execute($stmt)){
                    mysqli_stmt_store_result($stmt);
                    // Check if there is a record for yesterday
                    if(mysqli_stmt_num_rows($stmt) == 1){
                        // there is record for yesterday
                        mysqli_stmt_bind_result($stmt, $total_var);
                        if(mysqli_stmt_fetch($stmt)){
                            $yesterday_total = $total_var;
                        }
                    } else {
                        // no record yesterday :(
                        $yesterday_total = 0;
                    }
                } else {
                    $response['error'] = true;
                    $response['message'] = "yesterday not execute";
                }
                // Close statement
                mysqli_stmt_close($stmt);
            }
            // update today's record in user_points
            $sql = "REPLACE INTO `user_points`(`id`, `date`, `point`, `total_point`, `level`) VALUES (?,?,?,?,?)";
            
            $stmt = mysqli_prepare($link, $sql);
            if(empty($stmt)){
                $response['error'] = true;
                $response['message'] = "update today userpoint stmt empty";
            }
            else{
                mysqli_stmt_bind_param($stmt, "ssiii", $param_id, $param_date, $param_point, $param_total, $param_level);
                $param_id = $id;
                date_default_timezone_set('America/Los_Angeles');
                $date = date("Y-m-d");
                $param_date = $date;
                $param_point = 0;
                $param_total = $yesterday_total + $param_point;
                $param_level = 1 + floor($param_total / 5);
                /*$response['error'] = false;
                $response['message'] = "update today userpoints";*/
                if(mysqli_stmt_execute($stmt)){
                    mysqli_stmt_store_result($stmt);
                } else {
                    $response['error'] = true;
                    $response['message'] = "today update not execute";
                }
                mysqli_stmt_close($stmt);
            }
            
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
