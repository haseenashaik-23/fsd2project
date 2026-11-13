<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jspExample2.Db" %>

<%
if (session.getAttribute("role") == null ||
    !"FACULTY".equals(session.getAttribute("role"))) {

    response.sendRedirect("index.html");
    return;
}

String semester = request.getParameter("semester");
String section = request.getParameter("section");
String subject = request.getParameter("subject");
String academicYear = request.getParameter("academic_year");

if (semester == null) semester = "";
if (section == null) section = "";
if (subject == null) subject = "";
if (academicYear == null) academicYear = "";

semester = semester.trim();
section = section.trim();
subject = subject.trim();
academicYear = academicYear.trim();

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">

<title>Student Attendance Report</title>

<style>

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #eef4f8;
}

.container {
    width: 95%;
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

.filters {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    background: #f4f7fa;
    padding: 18px;
    border-radius: 8px;
    margin-bottom: 20px;
}

select {
    padding: 10px;
    min-width: 160px;
    border: 1px solid #ccc;
    border-radius: 5px;
}

button {
    padding: 10px 18px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
}

.search {
    background: #174c79;
    color: white;
}

.pdf {
    background: #b3261e;
    color: white;
}

.back {
    background: #555;
    color: white;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 20px;
}

th {
    background: #174c79;
    color: white;
    padding: 12px;
}

td {
    padding: 10px;
    border: 1px solid #ddd;
    text-align: center;
}

.good {
    color: green;
    font-weight: bold;
}

.low {
    color: red;
    font-weight: bold;
}

.report-title {
    text-align: center;
    margin-top: 20px;
}

@media print {

    body {
        background: white;
    }

    .filters,
    .no-print {
        display: none !important;
    }

    .container {
        width: 100%;
        margin: 0;
        box-shadow: none;
    }

}

</style>

<script>

function loadSubjects() {

    const semester =
        document.getElementById("semester").value;

    const subject =
        document.getElementById("subject");

    subject.innerHTML =
        '<option value="">Select Subject</option>';

    if (semester === "") {
        return;
    }

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

        })
        .catch(error => {
            console.log(error);
        });
}

function downloadPDF() {

    window.print();

}

</script>

</head>

<body>

<div class="container">

<h1>Student Attendance Report</h1>

<form method="get">

<div class="filters">

<select
    name="semester"
    id="semester"
    onchange="loadSubjects()"
    required>

<option value="">Select Semester</option>

<%
for (int i = 1; i <= 8; i++) {
%>

<option value="<%=i%>"
<%= semester.equals(String.valueOf(i)) ? "selected" : "" %>>
Semester <%=i%>
</option>

<%
}
%>

</select>


<select name="section" required>

<option value="">Select Section</option>

<option value="A"
<%= "A".equals(section) ? "selected" : "" %>>
Section A
</option>

<option value="B"
<%= "B".equals(section) ? "selected" : "" %>>
Section B
</option>

</select>


<select name="academic_year" required>

<option value="">Select Academic Year</option>

<%
for (int y = 2024; y <= 2034; y++) {

    String ay = y + "-" + String.valueOf(y + 1).substring(2);
%>

<option value="<%=ay%>"
<%= ay.equals(academicYear) ? "selected" : "" %>>
<%=ay%>
</option>

<%
}
%>

</select>


<select name="subject" id="subject" required>

<option value="">Select Subject</option>

<%
if (!semester.isEmpty()) {

    try {

        con = Db.getConnection();

        ps = con.prepareStatement(
            "SELECT subject_name " +
            "FROM subjects " +
            "WHERE semester=? " +
            "ORDER BY id"
        );

        ps.setInt(1, Integer.parseInt(semester));

        rs = ps.executeQuery();

        while (rs.next()) {

            String sub =
                rs.getString("subject_name");
%>

<option value="<%=sub%>"
<%= sub.equals(subject) ? "selected" : "" %>>
<%=sub%>
</option>

<%
        }

    } catch (Exception e) {

    } finally {

        try {
            if (rs != null) rs.close();
        } catch (Exception e) {}

        try {
            if (ps != null) ps.close();
        } catch (Exception e) {}

        try {
            if (con != null) con.close();
        } catch (Exception e) {}
    }
}
%>

</select>


<button class="search" type="submit">
View Report
</button>

<button
    type="button"
    class="pdf"
    onclick="downloadPDF()">
Download as PDF
</button>

</div>

</form>


<%
if (!semester.isEmpty() &&
    !section.isEmpty() &&
    !subject.isEmpty() &&
    !academicYear.isEmpty()) {
%>

<div class="report-title">

<h2>
<%=subject%>
</h2>

<p>
Semester <%=semester%> |
Section <%=section%> |
Academic Year <%=academicYear%>
</p>

</div>

<table>

<tr>

<th>S.No</th>
<th>Student ID</th>
<th>Student Name</th>
<th>Total Classes</th>
<th>Present</th>
<th>Absent</th>
<th>Attendance %</th>

</tr>

<%

try {

    con = Db.getConnection();

    ps = con.prepareStatement(
        "SELECT " +
        "s.reg_no, " +
        "s.name, " +
        "COUNT(a.id) AS total_classes, " +
        "SUM(CASE WHEN a.status='Present' THEN 1 ELSE 0 END) AS present_count, " +
        "SUM(CASE WHEN a.status='Absent' THEN 1 ELSE 0 END) AS absent_count " +
        "FROM students s " +
        "LEFT JOIN attendance a " +
        "ON s.reg_no=a.reg_no " +
        "AND a.semester=? " +
        "AND a.section=? " +
        "AND a.subject=? " +
        "AND a.academic_year=? " +
        "WHERE s.section=? " +
        "GROUP BY s.reg_no,s.name " +
        "ORDER BY s.reg_no"
    );

    ps.setInt(1, Integer.parseInt(semester));
    ps.setString(2, section);
    ps.setString(3, subject);
    ps.setString(4, academicYear);
    ps.setString(5, section);

    rs = ps.executeQuery();

    int count = 1;

    while (rs.next()) {

        int total =
            rs.getInt("total_classes");

        int present =
            rs.getInt("present_count");

        int absent =
            rs.getInt("absent_count");

        double percentage =
            total > 0
            ? (present * 100.0 / total)
            : 0;

%>

<tr>

<td><%=count++%></td>

<td>
<%=rs.getString("reg_no")%>
</td>

<td>
<%=rs.getString("name")%>
</td>

<td>
<%=total%>
</td>

<td>
<%=present%>
</td>

<td>
<%=absent%>
</td>

<td class="<%=percentage >= 75 ? "good" : "low"%>">
<%=String.format("%.2f", percentage)%>%
</td>

</tr>

<%
    }

} catch (Exception e) {
%>

<tr>
<td colspan="7">
Database Error: <%=e.getMessage()%>
</td>
</tr>

<%
} finally {

    try {
        if (rs != null) rs.close();
    } catch (Exception e) {}

    try {
        if (ps != null) ps.close();
    } catch (Exception e) {}

    try {
        if (con != null) con.close();
    } catch (Exception e) {}
}

%>

</table>

<%
}
%>

<br>

<div class="no-print">

<button
    class="back"
    onclick="location.href='faculty-dashboard.jsp'">
Back to Dashboard
</button>

</div>

</div>

</body>
</html>