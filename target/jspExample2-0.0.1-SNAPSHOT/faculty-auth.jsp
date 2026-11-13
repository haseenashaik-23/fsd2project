<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String username =
        (String) session.getAttribute("username");

    String role =
        (String) session.getAttribute("role");

    if (username == null ||
        !"FACULTY".equalsIgnoreCase(role)) {

        response.sendRedirect("index.html");
        return;
    }

    String message =
        request.getParameter("message");
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">

<title>Faculty Authentication</title>

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

    padding: 25px 20px;
}

.header h1 {
    margin: 0;
    font-size: 25px;
}

.header p {
    margin: 8px 0 0;
    font-size: 15px;
}

.body {
    padding: 30px;
}

.welcome {
    text-align: center;
    margin-bottom: 25px;
}

.welcome h2 {
    margin: 0;
    color: #174c79;
}

.welcome p {
    color: #666;
    margin-top: 8px;
}

.option {
    margin-bottom: 18px;
}

.option button {
    width: 100%;

    padding: 14px;

    border: none;

    border-radius: 7px;

    font-size: 17px;

    font-weight: bold;

    cursor: pointer;

    color: white;
}

.password-btn {
    background: #1688bd;
}

.password-btn:hover {
    background: #0d6f9d;
}

.otp-btn {
    background: #28a745;
}

.otp-btn:hover {
    background: #218838;
}

.logout {
    text-align: center;
    margin-top: 20px;
}

.logout a {
    color: #d00000;

    text-decoration: none;

    font-weight: bold;
}

.logout a:hover {
    text-decoration: underline;
}

.message {
    background: #e8f5e9;

    color: #1b5e20;

    padding: 12px;

    border-radius: 6px;

    margin-bottom: 20px;

    text-align: center;
}

.footer {
    background: #f4f4f4;

    text-align: center;

    padding: 12px;

    color: #174c79;

    font-weight: bold;
}

.info {
    background: #eef6fb;

    border-left: 4px solid #1688bd;

    padding: 12px;

    margin-bottom: 20px;

    color: #555;

    font-size: 14px;

    line-height: 1.5;
}

</style>

</head>

<body>

<div class="container">

    <div class="header">

        <h1>
            Faculty Authentication
        </h1>

        <p>
            LBRCE Smart Attendance Portal
        </p>

    </div>


    <div class="body">

        <div class="welcome">

            <h2>
                Welcome, <%= username %>
            </h2>

            <p>
                Select an authentication method
            </p>

        </div>


        <% if (message != null &&
               !message.trim().equals("")) { %>

            <div class="message">
                <%= message %>
            </div>

        <% } %>


        <div class="info">

            <b>Password Login:</b>

            Open the faculty dashboard directly.

            <br><br>

            <b>OTP Login:</b>

            Generate a 6-digit OTP
            and verify it on screen.

        </div>


        <!-- PASSWORD LOGIN -->

        <div class="option">

            <form
                action="faculty-dashboard.jsp"
                method="post"
            >

                <button
                    type="submit"
                    class="password-btn"
                >

                    🔐 Password Login

                </button>

            </form>

        </div>


        <!-- OTP LOGIN -->

        <div class="option">

            <form
                action="faculty-otp.jsp"
                method="get"
            >

                <button
                    type="submit"
                    class="otp-btn"
                >

                    🔢 Generate OTP Login

                </button>

            </form>

        </div>


        <div class="logout">

            <a href="logout.jsp">
                Logout
            </a>

        </div>

    </div>


    <div class="footer">

        2026 © LBRCE - CSE-C
        @Team14 (2024-28)

    </div>

</div>

</body>

</html>