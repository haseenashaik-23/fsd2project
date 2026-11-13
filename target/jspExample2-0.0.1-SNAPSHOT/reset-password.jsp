<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jspExample2.Db" %>

<%

String message = "";

if("POST".equalsIgnoreCase(request.getMethod())){

    String username =
        request.getParameter("username");

    String newPassword =
        request.getParameter("new_password");

    String confirmPassword =
        request.getParameter("confirm_password");


    if(!newPassword.equals(confirmPassword)){

        message =
            "Passwords do not match.";

    }
    else{

        try{

            Connection c =
                Db.getConnection();

            PreparedStatement ps =
                c.prepareStatement(
                    "UPDATE users SET password=? " +
                    "WHERE username=?"
                );

            ps.setString(1,newPassword);

            ps.setString(2,username);

            int count =
                ps.executeUpdate();

            ps.close();

            c.close();


            if(count > 0){

                message =
                    "Password reset successfully.";

            }
            else{

                message =
                    "Username not found.";

            }

        }
        catch(Exception e){

            message =
                "Error: " + e.getMessage();

        }

    }

}

%>

<!DOCTYPE html>

<html>

<head>

<meta charset="UTF-8">

<title>Reset Password</title>

<style>

body{

    margin:0;

    font-family:Arial;

    background:#e6eef4;

}

.box{

    width:450px;

    margin:100px auto;

    background:white;

    padding:35px;

    box-shadow:0 5px 20px rgba(0,0,0,.2);

}

input{

    width:100%;

    padding:12px;

    margin:8px 0 18px;

}

button{

    width:100%;

    padding:13px;

    border:0;

    background:#159fd5;

    color:white;

}

.message{

    padding:12px;

    background:#e1f5e9;

    margin-bottom:15px;

}

</style>

</head>

<body>

<div class="box">

<h2>RESET PASSWORD</h2>

<% if(!message.equals("")){ %>

<div class="message">

<%= message %>

</div>

<% } %>

<form method="post">

<label>Username / Student ID</label>

<input
    name="username"
    required>

<label>New Password</label>

<input
    type="password"
    name="new_password"
    required>

<label>Confirm Password</label>

<input
    type="password"
    name="confirm_password"
    required>

<button type="submit">

Reset Password

</button>

</form>

<br>

<a href="index.html">

Back to Login

</a>

</div>

</body>

</html>