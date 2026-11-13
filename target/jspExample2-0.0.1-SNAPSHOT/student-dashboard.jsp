<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="jspExample2.Db" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
    // =========================
    // STUDENT SESSION CHECK
    // =========================

    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    String regNo = (String) session.getAttribute("reg_no");

    if (username == null || !"STUDENT".equalsIgnoreCase(role)) {
        response.sendRedirect("index.html");
        return;
    }

    if (regNo == null || regNo.trim().equals("")) {
        regNo = username;
    }

    // =========================
    // STUDENT DETAILS
    // =========================

    String studentName = username;
    String section = "-";
    String department = "-";
    String email = "-";
    String mobile = "-";
    String year = "-";

    // Default semester
    String selectedSemester = request.getParameter("semester");

    if (selectedSemester == null || selectedSemester.trim().equals("")) {
        selectedSemester = "1";
    }

    int semester = 1;

    try {
        semester = Integer.parseInt(selectedSemester);
        if (semester < 1 || semester > 8) {
            semester = 1;
        }
    } catch (Exception e) {
        semester = 1;
    }

    // =========================
    // VARIABLES FOR CHART
    // =========================

    ArrayList<String> subjectNames = new ArrayList<String>();
    ArrayList<Integer> subjectPresent = new ArrayList<Integer>();
    ArrayList<Integer> subjectAbsent = new ArrayList<Integer>();
    ArrayList<Double> subjectPercentage = new ArrayList<Double>();

    int semesterPresent = 0;
    int semesterAbsent = 0;
    int semesterTotal = 0;

    double semesterPercentage = 0;

    // =========================
    // DATABASE
    // =========================

    try {

        Connection con = Db.getConnection();

        // -------------------------
        // GET STUDENT DETAILS
        // -------------------------

        String studentSql =
            "SELECT reg_no, name, email, mobile, department, year, section " +
            "FROM students WHERE reg_no=?";

        PreparedStatement studentPs = con.prepareStatement(studentSql);
        studentPs.setString(1, regNo);

        ResultSet studentRs = studentPs.executeQuery();

        if (studentRs.next()) {

            studentName = studentRs.getString("name");

            if (studentRs.getString("section") != null) {
                section = studentRs.getString("section");
            }

            if (studentRs.getString("department") != null) {
                department = studentRs.getString("department");
            }

            if (studentRs.getString("email") != null) {
                email = studentRs.getString("email");
            }

            if (studentRs.getString("mobile") != null) {
                mobile = studentRs.getString("mobile");
            }

            if (studentRs.getString("year") != null) {
                year = studentRs.getString("year");
            }
        }

        studentRs.close();
        studentPs.close();

        // -------------------------
        // SUBJECT-WISE ATTENDANCE
        // -------------------------

        String subjectSql =
            "SELECT subject, " +
            "COUNT(*) AS total_classes, " +
            "SUM(CASE WHEN status='Present' THEN 1 ELSE 0 END) AS present_classes, " +
            "SUM(CASE WHEN status='Absent' THEN 1 ELSE 0 END) AS absent_classes " +
            "FROM attendance " +
            "WHERE reg_no=? AND semester=? " +
            "GROUP BY subject " +
            "ORDER BY subject";

        PreparedStatement subjectPs = con.prepareStatement(subjectSql);

        subjectPs.setString(1, regNo);
        subjectPs.setInt(2, semester);

        ResultSet subjectRs = subjectPs.executeQuery();

        while (subjectRs.next()) {

            String subject = subjectRs.getString("subject");

            int total = subjectRs.getInt("total_classes");
            int present = subjectRs.getInt("present_classes");
            int absent = subjectRs.getInt("absent_classes");

            double percentage = 0;

            if (total > 0) {
                percentage = (present * 100.0) / total;
            }

            subjectNames.add(subject);
            subjectPresent.add(present);
            subjectAbsent.add(absent);
            subjectPercentage.add(percentage);
        }

        subjectRs.close();
        subjectPs.close();

        // -------------------------
        // SEMESTER-WISE ATTENDANCE
        // -------------------------

        String semesterSql =
            "SELECT " +
            "COUNT(*) AS total_classes, " +
            "SUM(CASE WHEN status='Present' THEN 1 ELSE 0 END) AS present_classes, " +
            "SUM(CASE WHEN status='Absent' THEN 1 ELSE 0 END) AS absent_classes " +
            "FROM attendance " +
            "WHERE reg_no=? AND semester=?";

        PreparedStatement semesterPs = con.prepareStatement(semesterSql);

        semesterPs.setString(1, regNo);
        semesterPs.setInt(2, semester);

        ResultSet semesterRs = semesterPs.executeQuery();

        if (semesterRs.next()) {

            semesterTotal = semesterRs.getInt("total_classes");
            semesterPresent = semesterRs.getInt("present_classes");
            semesterAbsent = semesterRs.getInt("absent_classes");

            if (semesterTotal > 0) {
                semesterPercentage =
                    (semesterPresent * 100.0) / semesterTotal;
            }
        }

        semesterRs.close();
        semesterPs.close();

        con.close();

    } catch (Exception e) {

        out.println(
            "<div style='background:#ffe6e6;color:#b00020;padding:12px;margin:20px;border-radius:8px;'>" +
            "Database Error: " + e.getMessage() +
            "</div>"
        );
    }

    // =========================
    // OVERALL ATTENDANCE
    // =========================

    int overallPresent = 0;
    int overallAbsent = 0;
    int overallTotal = 0;
    double overallPercentage = 0;

    try {

        Connection con2 = Db.getConnection();

        String overallSql =
            "SELECT " +
            "COUNT(*) AS total_classes, " +
            "SUM(CASE WHEN status='Present' THEN 1 ELSE 0 END) AS present_classes, " +
            "SUM(CASE WHEN status='Absent' THEN 1 ELSE 0 END) AS absent_classes " +
            "FROM attendance WHERE reg_no=?";

        PreparedStatement overallPs = con2.prepareStatement(overallSql);

        overallPs.setString(1, regNo);

        ResultSet overallRs = overallPs.executeQuery();

        if (overallRs.next()) {

            overallTotal = overallRs.getInt("total_classes");
            overallPresent = overallRs.getInt("present_classes");
            overallAbsent = overallRs.getInt("absent_classes");

            if (overallTotal > 0) {
                overallPercentage =
                    (overallPresent * 100.0) / overallTotal;
            }
        }

        overallRs.close();
        overallPs.close();
        con2.close();

    } catch (Exception e) {
        // Keep dashboard running
    }
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">

<title>Student Dashboard | LBRCE Attendance </title>

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<!-- CHART.JS -->

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: Arial, Helvetica, sans-serif;
    background: #f3f6fa;
    color: #263238;
}

/* =========================
   SIDEBAR
========================= */

.sidebar {
    position: fixed;
    left: 0;
    top: 0;
    width: 245px;
    height: 100vh;
    background: #174c79;
    color: white;
    padding-top: 20px;
}

.logo {
    text-align: center;
    font-size: 22px;
    font-weight: bold;
    padding: 15px;
    border-bottom: 1px solid rgba(255,255,255,0.2);
}

.menu {
    margin-top: 20px;
}

.menu a {
    display: block;
    color: white;
    text-decoration: none;
    padding: 14px 25px;
    font-size: 15px;
}

.menu a:hover {
    background: #216797;
}

.menu a.active {
    background: #20a8df;
}

/* =========================
   MAIN
========================= */

.main {
    margin-left: 245px;
    padding: 25px;
}

/* =========================
   TOP BAR
========================= */

.topbar {
    background: white;
    padding: 18px 22px;
    border-radius: 10px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 25px;
}

.topbar h1 {
    margin: 0;
    color: #174c79;
    font-size: 25px;
}

.logout {
    background: #e53935;
    color: white;
    text-decoration: none;
    padding: 10px 18px;
    border-radius: 6px;
}

/* =========================
   STUDENT CARD
========================= */

.student-card {
    background: linear-gradient(135deg, #174c79, #20a8df);
    color: white;
    border-radius: 12px;
    padding: 25px;
    margin-bottom: 25px;
    box-shadow: 0 5px 15px rgba(0,0,0,0.12);
}

.student-card h2 {
    margin-top: 0;
}

.student-info {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 15px;
}

.info-box {
    background: rgba(255,255,255,0.15);
    padding: 12px;
    border-radius: 8px;
}

.info-box small {
    display: block;
    opacity: 0.8;
    margin-bottom: 5px;
}

/* =========================
   STAT CARDS
========================= */

.stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 18px;
    margin-bottom: 25px;
}

.stat-card {
    background: white;
    padding: 22px;
    border-radius: 10px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.stat-card h3 {
    margin: 0 0 10px;
    color: #666;
    font-size: 14px;
}

.stat-number {
    font-size: 28px;
    font-weight: bold;
    color: #174c79;
}

.present {
    color: #159447;
}

.absent {
    color: #e53935;
}

/* =========================
   SEMESTER SELECT
========================= */

.semester-box {
    background: white;
    padding: 20px;
    border-radius: 10px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    margin-bottom: 25px;
}

.semester-box label {
    font-weight: bold;
    color: #174c79;
    margin-right: 15px;
}

.semester-box select {
    width: 250px;
    padding: 12px;
    border: 1px solid #ccc;
    border-radius: 6px;
    font-size: 15px;
}

/* =========================
   CONTENT GRID
========================= */

.chart-grid {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 20px;
    margin-bottom: 25px;
}

/* =========================
   CHART CARDS
========================= */

.chart-card {
    background: white;
    padding: 22px;
    border-radius: 10px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.chart-card h2 {
    margin-top: 0;
    color: #174c79;
    font-size: 19px;
}

.chart-container {
    position: relative;
    height: 360px;
}

.pie-container {
    position: relative;
    height: 360px;
}

/* =========================
   TABLE
========================= */

.attendance-table-card {
    background: white;
    padding: 22px;
    border-radius: 10px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    overflow-x: auto;
}

.attendance-table-card h2 {
    color: #174c79;
    margin-top: 0;
}

table {
    width: 100%;
    border-collapse: collapse;
}

th {
    background: #174c79;
    color: white;
    padding: 13px;
    text-align: left;
}

td {
    padding: 12px;
    border-bottom: 1px solid #ddd;
}

tr:hover {
    background: #f5f9fc;
}

.badge {
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: bold;
}

.badge-good {
    background: #d9f7e4;
    color: #16823b;
}

.badge-warning {
    background: #fff2cc;
    color: #9a7200;
}

.badge-danger {
    background: #ffdede;
    color: #c62828;
}

/* =========================
   MOBILE
========================= */

@media(max-width:900px) {

    .sidebar {
        position: relative;
        width: 100%;
        height: auto;
    }

    .main {
        margin-left: 0;
    }

    .student-info {
        grid-template-columns: repeat(2, 1fr);
    }

    .stats {
        grid-template-columns: repeat(2, 1fr);
    }

    .chart-grid {
        grid-template-columns: 1fr;
    }
}

@media(max-width:600px) {

    .student-info {
        grid-template-columns: 1fr;
    }

    .stats {
        grid-template-columns: 1fr;
    }

    .topbar {
        flex-direction: column;
        gap: 15px;
        align-items: flex-start;
    }

    .semester-box select {
        width: 100%;
        margin-top: 10px;
    }
}

</style>

</head>

<body>

<!-- =========================
     SIDEBAR
========================= -->

<div class="sidebar">

    <div class="logo">
        LBRCE Attendance
    </div>

    <div class="menu">

        <a href="student-dashboard.jsp"
           class="active">
            🏠 Dashboard
        </a>

        <a href="student-record.jsp">
            📋 Record
        </a>

        <a href="student-report.jsp">
            📊 Report
        </a>

        <a href="student-semwise.jsp">
            📈 Semwise Attendance
        </a>

        <a href="logout.jsp">
            🚪 Logout
        </a>

    </div>

</div>


<!-- =========================
     MAIN CONTENT
========================= -->

<div class="main">


    <!-- TOP BAR -->

    <div class="topbar">

        <h1>
            Student Dashboard
        </h1>

        <a href="logout.jsp"
           class="logout">
            Logout
        </a>

    </div>


    <!-- =========================
         STUDENT DETAILS
    ========================= -->

    <div class="student-card">

        <h2>
            Welcome, <%= studentName %>
        </h2>

        <div class="student-info">

            <div class="info-box">
                <small>Student ID</small>
                <strong><%= regNo %></strong>
            </div>

            <div class="info-box">
                <small>Name</small>
                <strong><%= studentName %></strong>
            </div>

            <div class="info-box">
                <small>Section</small>
                <strong><%= section %></strong>
            </div>

            <div class="info-box">
                <small>Department</small>
                <strong><%= department %></strong>
            </div>

            <div class="info-box">
                <small>Year</small>
                <strong><%= year %></strong>
            </div>

            <div class="info-box">
                <small>Email</small>
                <strong><%= email %></strong>
            </div>

            <div class="info-box">
                <small>Mobile</small>
                <strong><%= mobile %></strong>
            </div>

            <div class="info-box">
                <small>Selected Semester</small>
                <strong>Semester <%= semester %></strong>
            </div>

        </div>

    </div>


    <!-- =========================
         OVERALL STATISTICS
    ========================= -->

    <div class="stats">

        <div class="stat-card">

            <h3>
                Overall Attendance
            </h3>

            <div class="stat-number">
                <%= String.format("%.2f", overallPercentage) %>%
            </div>

        </div>


        <div class="stat-card">

            <h3>
                Total Classes
            </h3>

            <div class="stat-number">
                <%= overallTotal %>
            </div>

        </div>


        <div class="stat-card">

            <h3>
                Present
            </h3>

            <div class="stat-number present">
                <%= overallPresent %>
            </div>

        </div>


        <div class="stat-card">

            <h3>
                Absent
            </h3>

            <div class="stat-number absent">
                <%= overallAbsent %>
            </div>

        </div>

    </div>


    <!-- =========================
         SEMESTER SELECT
    ========================= -->

    <div class="semester-box">

        <form method="get"
              action="student-dashboard.jsp">

            <label>
                Select Semester
            </label>

            <select name="semester"
                    onchange="this.form.submit()">

                <option value="1"
                    <%= semester == 1 ? "selected" : "" %>>
                    Semester 1
                </option>

                <option value="2"
                    <%= semester == 2 ? "selected" : "" %>>
                    Semester 2
                </option>

                <option value="3"
                    <%= semester == 3 ? "selected" : "" %>>
                    Semester 3
                </option>

                <option value="4"
                    <%= semester == 4 ? "selected" : "" %>>
                    Semester 4
                </option>

                <option value="5"
                    <%= semester == 5 ? "selected" : "" %>>
                    Semester 5
                </option>

                <option value="6"
                    <%= semester == 6 ? "selected" : "" %>>
                    Semester 6
                </option>

                <option value="7"
                    <%= semester == 7 ? "selected" : "" %>>
                    Semester 7
                </option>

                <option value="8"
                    <%= semester == 8 ? "selected" : "" %>>
                    Semester 8
                </option>

            </select>

        </form>

    </div>


    <!-- =========================
         CHARTS
    ========================= -->

    <div class="chart-grid">


        <!-- SUBJECT BAR CHART -->

        <div class="chart-card">

            <h2>
                Subject-wise Attendance
                - Semester <%= semester %>
            </h2>

            <div class="chart-container">

                <canvas id="subjectBarChart"></canvas>

            </div>

        </div>


        <!-- SEMESTER PIE CHART -->

        <div class="chart-card">

            <h2>
                Semester <%= semester %>
                Attendance
            </h2>

            <div class="pie-container">

                <canvas id="semesterPieChart"></canvas>

            </div>

        </div>

    </div>


    <!-- =========================
         SUBJECT TABLE
    ========================= -->

    <div class="attendance-table-card">

        <h2>
            Subject-wise Attendance Details
        </h2>

        <table>

            <thead>

                <tr>

                    <th>
                        Subject
                    </th>

                    <th>
                        Total Classes
                    </th>

                    <th>
                        Present
                    </th>

                    <th>
                        Absent
                    </th>

                    <th>
                        Attendance %
                    </th>

                </tr>

            </thead>

            <tbody>

<%
    if (subjectNames.size() == 0) {
%>

                <tr>

                    <td colspan="5"
                        style="text-align:center;padding:25px;">

                        No attendance records found
                        for Semester <%= semester %>.

                    </td>

                </tr>

<%
    } else {

        for (int i = 0; i < subjectNames.size(); i++) {

            int total =
                subjectPresent.get(i)
                + subjectAbsent.get(i);

            double percentage =
                subjectPercentage.get(i);

            String badgeClass = "badge-good";

            if (percentage < 75) {
                badgeClass = "badge-danger";
            } else if (percentage < 85) {
                badgeClass = "badge-warning";
            }
%>

                <tr>

                    <td>
                        <%= subjectNames.get(i) %>
                    </td>

                    <td>
                        <%= total %>
                    </td>

                    <td class="present">
                        <%= subjectPresent.get(i) %>
                    </td>

                    <td class="absent">
                        <%= subjectAbsent.get(i) %>
                    </td>

                    <td>

                        <span class="badge <%= badgeClass %>">

                            <%= String.format(
                                "%.2f",
                                percentage
                            ) %>%

                        </span>

                    </td>

                </tr>

<%
        }
    }
%>

            </tbody>

        </table>

    </div>


    <!-- =========================
         SEMESTER SUMMARY
    ========================= -->

    <div class="attendance-table-card"
         style="margin-top:25px;">

        <h2>
            Semester <%= semester %> Summary
        </h2>

        <table>

            <tr>

                <th>
                    Total Classes
                </th>

                <th>
                    Present
                </th>

                <th>
                    Absent
                </th>

                <th>
                    Attendance
                </th>

            </tr>

            <tr>

                <td>
                    <%= semesterTotal %>
                </td>

                <td class="present">
                    <%= semesterPresent %>
                </td>

                <td class="absent">
                    <%= semesterAbsent %>
                </td>

                <td>

                    <strong>

                        <%= String.format(
                            "%.2f",
                            semesterPercentage
                        ) %>%

                    </strong>

                </td>

            </tr>

        </table>

    </div>

</div>


<!-- =========================
     CHART JAVASCRIPT
========================= -->

<script>

const subjectNames = [

<%
for (int i = 0; i < subjectNames.size(); i++) {

    if (i > 0) {
        out.print(",");
    }

    String safeName =
        subjectNames.get(i)
        .replace("\\", "\\\\")
        .replace("\"", "\\\"")
        .replace("\n", " ");
%>

"<%= safeName %>"

<%
}
%>

];


const subjectPercentages = [

<%
for (int i = 0; i < subjectPercentage.size(); i++) {

    if (i > 0) {
        out.print(",");
    }
%>

<%= String.format(
    Locale.US,
    "%.2f",
    subjectPercentage.get(i)
) %>

<%
}
%>

];


// =========================
// SUBJECT BAR CHART
// =========================

const barCanvas =
    document.getElementById("subjectBarChart");

if (barCanvas) {

    new Chart(
        barCanvas,
        {
            type: "bar",

            data: {

                labels: subjectNames,

                datasets: [

                    {
                        label:
                            "Attendance Percentage",

                        data:
                            subjectPercentages,

                        borderWidth: 1,

                        borderRadius: 6

                    }

                ]

            },

            options: {

                responsive: true,

                maintainAspectRatio: false,

                scales: {

                    y: {

                        beginAtZero: true,

                        max: 100,

                        title: {

                            display: true,

                            text:
                                "Attendance %"

                        }

                    },

                    x: {

                        title: {

                            display: true,

                            text:
                                "Subjects"

                        }

                    }

                },

                plugins: {

                    legend: {

                        display: true

                    },

                    tooltip: {

                        callbacks: {

                            label:
                                function(context) {

                                    return context.raw + "%";

                                }

                        }

                    }

                }

            }

        }
    );

}


// =========================
// SEMESTER PIE CHART
// =========================

const pieCanvas =
    document.getElementById("semesterPieChart");

if (pieCanvas) {

    new Chart(

        pieCanvas,

        {

            type: "pie",

            data: {

                labels: [

                    "Present",

                    "Absent"

                ],

                datasets: [

                    {

                        data: [

                            <%= semesterPresent %>,

                            <%= semesterAbsent %>

                        ],

                        borderWidth: 2

                    }

                ]

            },

            options: {

                responsive: true,

                maintainAspectRatio: false,

                plugins: {

                    legend: {

                        position: "bottom"

                    },

                    tooltip: {

                        callbacks: {

                            label:
                                function(context) {

                                    const total =
                                        <%= semesterTotal %>;

                                    const value =
                                        context.raw;

                                    let percentage = 0;

                                    if (total > 0) {

                                        percentage =
                                            (
                                                value /
                                                total
                                            ) * 100;

                                    }

                                    return context.label
                                        + ": "
                                        + value
                                        + " ("
                                        + percentage.toFixed(2)
                                        + "%)";

                                }

                        }

                    }

                }

            }

        }

    );

}

</script>

</body>

</html>