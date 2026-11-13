<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jspExample2.Db" %>

<%
String role =
    (String)session.getAttribute("role");

String regNo =
    (String)session.getAttribute("reg_no");

if(regNo == null ||
   !"STUDENT".equalsIgnoreCase(role)){

    response.sendRedirect("index.html");
    return;
}
%>

<!DOCTYPE html>

<html>

<head>

<meta charset="UTF-8">

<title>Student Report</title>

<style>

body{
    margin:0;
    font-family:Arial;
    background:#f1f5f9;
}

.header{
    background:#174e78;
    color:white;
    padding:18px 25px;
}

.container{
    width:90%;
    margin:25px auto;
}

.panel{
    background:white;
    padding:25px;
    border-radius:8px;
}

table{
    width:100%;
    border-collapse:collapse;
}

th,td{
    padding:12px;
    border:1px solid #ddd;
}

th{
    background:#e7f2f9;
    color:#174e78;
}

</style>

</head>

<body>

<div class="header">
Student → Attendance Report
</div>

<div class="container">

<a href="student-dashboard.jsp">
← Dashboard
</a>

<div class="panel">

<h2>
Subject-wise Attendance
</h2>

<table>

<tr>

<th>Subject</th>
<th>Total Classes</th>
<th>Present</th>
<th>Absent</th>
<th>Percentage</th>

</tr>

<%

try(

Connection con =
    Db.getConnection();

PreparedStatement ps =
    con.prepareStatement(

        "SELECT subject," +

        "COUNT(*) AS total," +

        "SUM(CASE WHEN status='Present' " +
        "THEN 1 ELSE 0 END) AS present," +

        "SUM(CASE WHEN status='Absent' " +
        "THEN 1 ELSE 0 END) AS absent " +

        "FROM attendance " +

        "WHERE reg_no=? " +

        "GROUP BY subject"

    )

){

ps.setString(1,regNo);

ResultSet rs =
    ps.executeQuery();

while(rs.next()){

int total =
    rs.getInt("total");

int present =
    rs.getInt("present");

double percent =
    total == 0
    ? 0
    : present * 100.0 / total;

%>

<tr>

<td>
<%=rs.getString("subject")%>
</td>

<td>
<%=total%>
</td>

<td>
<%=present%>
</td>

<td>
<%=rs.getInt("absent")%>
</td>

<td>
<%=String.format("%.2f",percent)%>%
</td>

</tr>

<%
}

}catch(Exception e){
%>

<tr>
<td colspan="5">
<%=e.getMessage()%>
</td>
</tr>

<%
}
%>

</table>

</div>

</div>

</body>

</html>