<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jspExample2.Db" %>

<%
if (session.getAttribute("role") == null ||
    !"FACULTY".equals(session.getAttribute("role"))) {

    response.sendRedirect("index.html");
    return;
}

String semester =
    request.getParameter("semester");

String section =
    request.getParameter("section");

String subject =
    request.getParameter("subject");

if (semester == null) semester = "1";
if (section == null) section = "A";
if (subject == null) subject = "";

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">

<title>Faculty Semwise Attendance</title>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #eef4f8;
}

.container {
    width: 95%;
    max-width: 1200px;
    margin: 25px auto;
    background: white;
    padding: 25px;
    border-radius: 10px;
    box-shadow: 0 4px 15px rgba(0,0,0,.15);
}

h1 {
    text-align: center;
    color: #174c79;
}

.filters {
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    gap: 10px;
    margin: 20px;
}

select {
    padding: 10px;
    min-width: 170px;
}

button {
    padding: 10px 18px;
    border: none;
    border-radius: 5px;
    background: #174c79;
    color: white;
    cursor: pointer;
}

.chart-box {
    width: 100%;
    height: 550px;
}

</style>

<script>

function loadSubjects() {

    const semester =
        document.getElementById("semester").value;

    const subject =
        document.getElementById("subject");

    subject.innerHTML =
        '<option value="">All Subjects</option>';

    if (semester === "") return;

    fetch("get-subjects.jsp?semester=" + semester)
        .then(response => response.json())
        .then(data => {

            data.forEach(function(item) {

                const option =
                    document.createElement("option");

                option.value = item;
                option.textContent = item;

                subject.appendChild(option);

            });

        });

}

</script>

</head>

<body>

<div class="container">

<h1>Faculty Semwise Attendance</h1>

<form method="get">

<div class="filters">

<select
    name="semester"
    id="semester"
    onchange="loadSubjects()">

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


<select name="section">

<option value="A"
<%="A".equals(section) ? "selected" : ""%>>
Section A
</option>

<option value="B"
<%="B".equals(section) ? "selected" : ""%>>
Section B
</option>

</select>


<select
    name="subject"
    id="subject">

<option value="">
All Subjects
</option>

<%
if(!semester.isEmpty()) {

    try {

        con = Db.getConnection();

        ps = con.prepareStatement(
            "SELECT subject_name " +
            "FROM subjects " +
            "WHERE semester=? " +
            "ORDER BY id"
        );

        ps.setInt(
            1,
            Integer.parseInt(semester)
        );

        rs = ps.executeQuery();

        while(rs.next()) {

            String sub =
                rs.getString("subject_name");
%>

<option value="<%=sub%>"
<%=sub.equals(subject)
    ? "selected" : ""%>>
<%=sub%>
</option>

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
}
%>

</select>


<button type="submit">
View Chart
</button>

</div>

</form>


<div class="chart-box">

<canvas id="facultyChart"></canvas>

</div>


<br>

<div style="text-align:center;">

<button
onclick="location.href='faculty-dashboard.jsp'">
Back to Dashboard
</button>

</div>

</div>


<script>

const studentNames = [];
const percentages = [];

<%

try {

    con = Db.getConnection();

    String sql =
        "SELECT " +
        "s.reg_no, " +
        "s.name, " +
        "COUNT(a.id) AS total_classes, " +
        "SUM(CASE WHEN a.status='Present' THEN 1 ELSE 0 END) AS present_classes " +
        "FROM students s " +
        "LEFT JOIN attendance a " +
        "ON s.reg_no=a.reg_no " +
        "AND a.semester=? " +
        "AND a.section=? ";

    if(!subject.isEmpty()) {
        sql += "AND a.subject=? ";
    }

    sql +=
        "WHERE s.section=? " +
        "GROUP BY s.reg_no,s.name " +
        "ORDER BY s.reg_no";

    ps = con.prepareStatement(sql);

    int index = 1;

    ps.setInt(
        index++,
        Integer.parseInt(semester)
    );

    ps.setString(
        index++,
        section
    );

    if(!subject.isEmpty()) {

        ps.setString(
            index++,
            subject
        );
    }

    ps.setString(
        index++,
        section
    );

    rs = ps.executeQuery();

    while(rs.next()) {

        String name =
            rs.getString("reg_no")
            + " - "
            + rs.getString("name");

        int total =
            rs.getInt("total_classes");

        int present =
            rs.getInt("present_classes");

        double percentage =
            total > 0
            ? present * 100.0 / total
            : 0;

        String safeName =
            name.replace("\\","\\\\")
                .replace("'","\\'");

%>

studentNames.push('<%=safeName%>');
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
    document.getElementById("facultyChart"),
    {

        type: "bar",

        data: {

            labels: studentNames,

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
                        text: "Attendance Percentage"
                    }

                },

                x: {

                    title: {
                        display: true,
                        text: "Students"
                    }

                }

            }

        }

    }
);

</script>

</body>

</html>