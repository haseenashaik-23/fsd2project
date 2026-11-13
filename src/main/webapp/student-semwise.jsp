<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jspExample2.Db" %>

<%
if (session.getAttribute("role") == null ||
    !"STUDENT".equals(session.getAttribute("role"))) {

    response.sendRedirect("index.html");
    return;
}

String regNo =
    (String)session.getAttribute("reg_no");

String semester =
    request.getParameter("semester");

if (semester == null) {
    semester = "1";
}

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">

<title>Semwise Attendance</title>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #eef4f8;
}

.container {
    width: 95%;
    max-width: 1100px;
    margin: 25px auto;
    background: white;
    padding: 25px;
    border-radius: 10px;
    box-shadow: 0 4px 15px rgba(0,0,0,.15);
}

h1 {
    color: #174c79;
    text-align: center;
}

select {
    padding: 10px;
    min-width: 180px;
}

.filter {
    text-align: center;
    margin: 20px;
}

.chart-box {
    position: relative;
    width: 100%;
    height: 500px;
}

button {
    padding: 10px 20px;
    background: #174c79;
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
}

</style>

</head>

<body>

<div class="container">

<h1>Semester-wise Attendance</h1>

<div class="filter">

<form method="get">

<select name="semester"
        onchange="this.form.submit()">

<%
for(int i=1;i<=8;i++) {
%>

<option value="<%=i%>"
<%=semester.equals(String.valueOf(i))
    ? "selected" : ""%>>
Semester <%=i%>
</option>

<%
}
%>

</select>

</form>

</div>

<div class="chart-box">

<canvas id="attendanceChart"></canvas>

</div>

<br>

<div style="text-align:center;">

<button
onclick="location.href='student-dashboard.jsp'">
Back to Dashboard
</button>

</div>

</div>

<script>

const subjectNames = [];
const percentages = [];

<%

try {

    con = Db.getConnection();

    ps = con.prepareStatement(
        "SELECT subject, " +
        "COUNT(*) AS total_classes, " +
        "SUM(CASE WHEN status='Present' THEN 1 ELSE 0 END) AS present_classes " +
        "FROM attendance " +
        "WHERE reg_no=? " +
        "AND semester=? " +
        "GROUP BY subject " +
        "ORDER BY subject"
    );

    ps.setString(1,regNo);
    ps.setInt(2,Integer.parseInt(semester));

    rs = ps.executeQuery();

    while(rs.next()) {

        String sub =
            rs.getString("subject");

        int total =
            rs.getInt("total_classes");

        int present =
            rs.getInt("present_classes");

        double percentage =
            total > 0
            ? present * 100.0 / total
            : 0;

        String safeSub =
            sub.replace("\\","\\\\")
               .replace("'","\\'");

%>

subjectNames.push('<%=safeSub%>');
percentages.push(<%=percentage%>);

<%

    }

} catch(Exception e) {

} finally {

    try {
        if(rs != null) rs.close();
    } catch(Exception e) {}

    try {
        if(ps != null) ps.close();
    } catch(Exception e) {}

    try {
        if(con != null) con.close();
    } catch(Exception e) {}

}

%>


new Chart(
    document.getElementById("attendanceChart"),
    {
        type: "bar",

        data: {

            labels: subjectNames,

            datasets: [

                {
                    label: "Attendance Percentage",

                    data: percentages,

                    borderWidth: 1
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
                        text: "Attendance %"
                    }

                },

                x: {

                    title: {
                        display: true,
                        text: "Subjects"
                    }

                }

            }

        }

    }
);

</script>

</body>

</html>