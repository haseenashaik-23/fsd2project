<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jspExample2.Db" %>

<%
String username =
    (String) session.getAttribute("username");

String role =
    (String) session.getAttribute("role");

Boolean otpVerified =
    (Boolean) session.getAttribute("otpVerified");

if (username == null ||
    !"FACULTY".equalsIgnoreCase(role)) {

    response.sendRedirect("index.html");
    return;
}

/*
 * If your faculty login requires OTP,
 * uncomment this block.
 */

/*
if (otpVerified == null ||
    !otpVerified) {

    response.sendRedirect("faculty-auth.jsp");
    return;
}
*/

String facultyName = username;

try {

    Connection con = Db.getConnection();

    PreparedStatement ps =
        con.prepareStatement(
            "SELECT name FROM users WHERE username=?"
        );

    ps.setString(1, username);

    ResultSet rs =
        ps.executeQuery();

    if (rs.next() &&
        rs.getString("name") != null) {

        facultyName =
            rs.getString("name");
    }

    rs.close();
    ps.close();
    con.close();

} catch (Exception e) {
}
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">

<title>Faculty Dashboard</title>

<style>

* {
    box-sizing: border-box;
}

body {

    margin: 0;

    font-family: Arial, sans-serif;

    background: #f2f6fa;
}

.header {

    background: #174c79;

    color: white;

    padding: 18px 30px;

    display: flex;

    justify-content: space-between;

    align-items: center;
}

.header h1 {
    margin: 0;
}

.logout {

    background: #e53935;

    color: white;

    text-decoration: none;

    padding: 10px 18px;

    border-radius: 5px;
}

.container {

    width: 94%;

    max-width: 1300px;

    margin: 30px auto;
}

.welcome {

    background: white;

    padding: 25px;

    border-radius: 8px;

    box-shadow:
        0 3px 12px rgba(0,0,0,.12);

    margin-bottom: 25px;
}

.welcome h2 {

    margin-top: 0;

    color: #174c79;
}

.cards {

    display: grid;

    grid-template-columns:
        repeat(3, 1fr);

    gap: 20px;
}

.card {

    background: white;

    padding: 25px;

    border-radius: 8px;

    box-shadow:
        0 3px 12px rgba(0,0,0,.12);

    text-decoration: none;

    color: #263238;

    transition: .2s;
}

.card:hover {

    transform: translateY(-4px);

    box-shadow:
        0 7px 18px rgba(0,0,0,.18);
}

.card h3 {

    color: #174c79;

    margin-top: 0;
}

.card p {

    color: #666;

    line-height: 1.5;
}

.attendance {
    border-top: 5px solid #2e7d32;
}

.students {
    border-top: 5px solid #1976d2;
}

.subjects {
    border-top: 5px solid #8e44ad;
}

.reports {
    border-top: 5px solid #f57c00;
}

.semwise {
    border-top: 5px solid #00897b;
}

.daily {
    border-top: 5px solid #c62828;
}

@media(max-width:900px) {

    .cards {
        grid-template-columns: 1fr 1fr;
    }
}

@media(max-width:600px) {

    .cards {
        grid-template-columns: 1fr;
    }

    .header {
        flex-direction: column;
        gap: 12px;
    }
}

</style>

</head>

<body>

<div class="header">

    <h1>
        Faculty Dashboard
    </h1>

    <div>

        Welcome,
        <b><%= facultyName %></b>

        &nbsp;&nbsp;

        <a
            href="logout.jsp"
            class="logout">

            Logout

        </a>

    </div>

</div>


<div class="container">


<div class="welcome">

    <h2>
        Welcome to LBRCE  Attendance Management System
    </h2>

    <p>

        Faculty ID:
        <b><%= username %></b>

    </p>

    <p>

        Manage students, subjects,
        attendance and reports from
        the options below.

    </p>

</div>


<div class="cards">


<a
    href="faculty-attendance.jsp"
    class="card attendance">

    <h3>
        Mark Attendance
    </h3>

    <p>
        Insert, update and delete
        attendance for students.
    </p>

</a>


<a
    href="faculty-students.jsp"
    class="card students">

    <h3>
        Student Management
    </h3>

    <p>
        Add, update, view and delete
        student information.
    </p>

</a>


<a
    href="subject-management.jsp"
    class="card subjects">

    <h3>
        Subject Management
    </h3>

    <p>
        Add, update and delete
        semester subjects.
    </p>

</a>


<a
    href="faculty-report.jsp"
    class="card reports">

    <h3>
        Attendance Reports
    </h3>

    <p>
        View student and subject-wise
        attendance reports.
    </p>

</a>


<a
    href="semwise-attendance.jsp"
    class="card semwise">

    <h3>
        Semester-wise Attendance
    </h3>

    <p>
        View semester attendance
        and percentage charts.
    </p>

</a>


<a
    href="daily-attendance.jsp"
    class="card daily">

    <h3>
        Daily Attendance
    </h3>

    <p>
        View attendance records
        for individual dates.
    </p>

</a>

</div>

</div>

</body>

</html>