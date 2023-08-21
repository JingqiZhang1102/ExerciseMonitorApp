<?php
    session_start();
    require_once "config.php";
    
    $response = array();
    $recent_results = array();
    $stepgoal = "";
 
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
                //$recent_length = count($recent_results);
                
                $response['error'] = false;
                $response['message'] = "sql statement executed";
                $response['recent_results'] = $recent_results;
            }
            // cannot execute
            else {
                $response['error'] = true;
                $response['message'] = "cannot execute?!";
            }
        }
        
        $sql = "select stepgoal from user where id = ?";
        $stmt = mysqli_prepare($link, $sql);
        if(empty($stmt)){
            $response['error'] = true;
            $response['message'] = "2 stmt is empty!!?!";
        }
        else {
            mysqli_stmt_bind_param($stmt, "s", $param_id);
            $param_id = $id;
            
            // execute the sql statement
            if(mysqli_stmt_execute($stmt)){
                mysqli_stmt_store_result($stmt);
                mysqli_stmt_bind_result($stmt, $goal_var);

                while (mysqli_stmt_fetch($stmt)) {
                    $stepgoal = $goal_var;
                }
                //$recent_length = count($recent_results);
                
                $response['error'] = false;
                $response['message'] = "2 sql statement executed";
                $response['stepgoal'] = $stepgoal;
            }
            // cannot execute
            else {
                $response['error'] = true;
                $response['message'] = "2 cannot execute?!";
            }
        }
    }
    
} else {
    $response['error'] = true;
    $response['message'] = "Request not allowed";
}
    
    $_SESSION["response"] = $response;
    
    echo json_encode($response);
?>
