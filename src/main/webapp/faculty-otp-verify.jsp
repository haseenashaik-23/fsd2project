<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String username =
        (String) session.getAttribute("username");

    String role =
        (String) session.getAttribute("role");


    // Faculty session check

    if (username == null ||
        !"FACULTY".equalsIgnoreCase(role)) {

        response.sendRedirect("index.html");
        return;
    }


    // Get entered OTP

    String enteredOTP =
        request.getParameter("otp");

    if (enteredOTP == null) {
        enteredOTP = "";
    }

    enteredOTP =
        enteredOTP.trim();


    // Get saved OTP

    String savedOTP =
        (String) session.getAttribute(
            "facultyOTP"
        );


    // Get OTP creation time

    Object otpTimeObject =
        session.getAttribute(
            "facultyOTPTime"
        );


    boolean valid = false;


    String errorMessage =
        "Invalid OTP.";


    // Check OTP exists

    if (savedOTP != null &&
        otpTimeObject != null) {


        long otpTime =
            ((Long) otpTimeObject).longValue();


        long currentTime =
            System.currentTimeMillis();


        long difference =
            currentTime - otpTime;


        // 5 minutes

        long fiveMinutes =
            5L * 60L * 1000L;


        // Check expiry

        if (difference >= 0 &&
            difference <= fiveMinutes) {


            // Check OTP

            if (enteredOTP.equals(savedOTP)) {

                valid = true;

            } else {

                errorMessage =
                    "Incorrect OTP.";

            }

        } else {

            errorMessage =
                "OTP expired. Please generate a new OTP.";

        }

    } else {

        errorMessage =
            "OTP not found. Please generate a new OTP.";

    }


    // =================================
    // OTP CORRECT
    // =================================

    if (valid) {


        session.setAttribute(
            "otpVerified",
            Boolean.TRUE
        );


        // Remove OTP after successful login

        session.removeAttribute(
            "facultyOTP"
        );


        session.removeAttribute(
            "facultyOTPTime"
        );


        // Open dashboard

        response.sendRedirect(
            "faculty-dashboard.jsp"
        );

        return;
    }
%>


<!DOCTYPE html>

<html>

<head>

<meta charset="UTF-8">

<title>OTP Verification Failed</title>


<style>

body {

    margin: 0;

    font-family: Arial, sans-serif;

    background: #eef4f8;

    display: flex;

    justify-content: center;

    align-items: center;

    min-height: 100vh;
}


.box {

    width: 430px;

    max-width: 90%;

    background: white;

    padding: 35px;

    text-align: center;

    border-radius: 12px;

    box-shadow:
        0 5px 20px
        rgba(0,0,0,0.2);
}


h1 {

    color: #c00000;

    font-size: 25px;
}


.error {

    background: #ffe5e5;

    color: #b00000;

    padding: 15px;

    border-radius: 6px;

    margin: 20px 0;
}


a {

    display: inline-block;

    background: #174c79;

    color: white;

    padding: 12px 22px;

    border-radius: 6px;

    text-decoration: none;

    font-weight: bold;
}


a:hover {

    background: #0d3c61;
}

</style>

</head>


<body>


<div class="box">


    <h1>
        ❌ OTP Verification Failed
    </h1>


    <div class="error">

        <%= errorMessage %>

    </div>


    <a href="faculty-otp.jsp">

        Generate New OTP

    </a>


</div>


</body>

</html>