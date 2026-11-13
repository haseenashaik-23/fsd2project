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


    // Generate 6 digit OTP

    java.security.SecureRandom random =
        new java.security.SecureRandom();

    int otpNumber =
        random.nextInt(1000000);

    String otp =
        String.format("%06d", otpNumber);


    // Save OTP in session

    session.setAttribute(
        "facultyOTP",
        otp
    );


    // Save OTP creation time

    session.setAttribute(
        "facultyOTPTime",
        System.currentTimeMillis()
    );


    // OTP is not verified yet

    session.setAttribute(
        "otpVerified",
        Boolean.FALSE
    );
%>


<!DOCTYPE html>

<html>

<head>

<meta charset="UTF-8">

<title>Faculty OTP Login</title>


<style>

* {
    box-sizing: border-box;
}

body {

    margin: 0;

    font-family:
        Arial,
        Helvetica,
        sans-serif;

    min-height: 100vh;

    background:
        linear-gradient(
            rgba(20,70,100,0.75),
            rgba(20,70,100,0.75)
        ),
        url("assets/college.jpg");

    background-size: cover;

    background-position: center;

    display: flex;

    justify-content: center;

    align-items: center;
}


.container {

    width: 450px;

    max-width: 95%;

    background: white;

    border-radius: 12px;

    box-shadow:
        0 10px 30px
        rgba(0,0,0,0.35);

    overflow: hidden;
}


.header {

    background: #174c79;

    color: white;

    text-align: center;

    padding: 25px;
}


.header h1 {

    margin: 0;

    font-size: 25px;
}


.header p {

    margin: 8px 0 0;

    font-size: 14px;
}


.content {

    padding: 30px;
}


.faculty {

    background: #eef6fb;

    border-left:
        4px solid #1688bd;

    padding: 14px;

    margin-bottom: 20px;

    color: #333;
}


.info {

    text-align: center;

    color: #555;

    line-height: 1.6;

    margin-bottom: 15px;
}


.otp {

    font-size: 42px;

    font-weight: bold;

    letter-spacing: 10px;

    text-align: center;

    color: #1688bd;

    background: #eef8fc;

    border: 2px dashed #1688bd;

    border-radius: 10px;

    padding: 20px 10px;

    margin: 20px 0;
}


input {

    width: 100%;

    padding: 14px;

    border:
        1px solid #ccc;

    border-radius: 6px;

    font-size: 20px;

    text-align: center;

    letter-spacing: 6px;

    outline: none;
}


input:focus {

    border-color: #1688bd;
}


.verify-btn {

    width: 100%;

    padding: 14px;

    margin-top: 15px;

    border: none;

    border-radius: 6px;

    background: #1688bd;

    color: white;

    font-size: 17px;

    font-weight: bold;

    cursor: pointer;
}


.verify-btn:hover {

    background: #0d6f9d;
}


.back {

    text-align: center;

    margin-top: 20px;
}


.back a {

    color: #174c79;

    text-decoration: none;

    font-weight: bold;
}


.back a:hover {

    text-decoration: underline;
}


.footer {

    background: #f4f4f4;

    text-align: center;

    padding: 12px;

    color: #174c79;

    font-weight: bold;
}

</style>

</head>


<body>


<div class="container">


    <div class="header">

        <h1>
            Faculty OTP Login
        </h1>

        <p>
            LBRCE Smart Attendance Portal
        </p>

    </div>


    <div class="content">


        <div class="faculty">

            Faculty ID:

            <b>
                <%= username %>
            </b>

        </div>


        <div class="info">

            Your 6-digit OTP is:

        </div>


        <!-- OTP DISPLAY -->

        <div class="otp">

            <%= otp %>

        </div>


        <div class="info">

            OTP is valid for
            <b>5 minutes</b>.

        </div>


        <!-- ENTER OTP -->

        <form
            action="faculty-otp-verify.jsp"
            method="post"
        >

            <input
                type="text"
                name="otp"
                maxlength="6"
                minlength="6"
                pattern="[0-9]{6}"
                inputmode="numeric"
                placeholder="Enter OTP"
                required
            >


            <button
                type="submit"
                class="verify-btn"
            >

                🔐 Verify OTP

            </button>

        </form>


        <div class="back">

            <a href="faculty-auth.jsp">

                ← Back to Authentication

            </a>

        </div>


    </div>


    <div class="footer">

        2026 © LBRCE - CSE-C

    </div>


</div>


</body>

</html>