<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jspExample2.Db" %>

<%
if (session.getAttribute("role") == null ||
    !"FACULTY".equals(session.getAttribute("role"))) {

    response.sendRedirect("index.html");
    return;
}

String action =
    request.getParameter("action");

String deleteRegNo =
    request.getParameter("delete_reg_no");

String message = "";
String error = "";


/* =========================================================
   DELETE STUDENT
   ========================================================= */

if ("delete".equals(action) &&
    deleteRegNo != null &&
    !deleteRegNo.trim().equals("")) {

    Connection con = null;
    PreparedStatement ps = null;

    try {

        con = Db.getConnection();

        /*
         * Because attendance.reg_no has
         * ON DELETE CASCADE,
         * student's attendance will also be deleted.
         */

        ps = con.prepareStatement(
            "DELETE FROM students WHERE reg_no=?"
        );

        ps.setString(
            1,
            deleteRegNo.trim()
        );

        int result =
            ps.executeUpdate();

        if (result > 0) {

            message =
                "Student " +
                deleteRegNo +
                " deleted successfully.";

        } else {

            error =
                "Student not found: " +
                deleteRegNo;
        }

    } catch (Exception e) {

        error =
            "Delete Error: " +
            e.getMessage();

    } finally {

        try {
            if (ps != null)
                ps.close();
        } catch (Exception e) {}

        try {
            if (con != null)
                con.close();
        } catch (Exception e) {}
    }
}
%>


<!DOCTYPE html>

<html>

<head>

<meta charset="UTF-8">

<title>Student Management</title>

<style>

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #eef4f8;
}

.header {
    background: #174c79;
    color: white;
    padding: 18px 25px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.header h1 {
    margin: 0;
}

.header a {
    text-decoration: none;
    padding: 10px 15px;
    border-radius: 5px;
    margin-left: 8px;
}

.dashboard {
    background: white;
    color: #174c79;
}

.logout {
    background: #d32f2f;
    color: white;
}

.container {
    width: 96%;
    margin: 25px auto;
    background: white;
    padding: 25px;
    border-radius: 10px;
    box-shadow: 0 4px 15px rgba(0,0,0,.12);
}

h2 {
    text-align: center;
    color: #174c79;
}

.success {
    background: #d9f7df;
    color: #176b2c;
    padding: 12px;
    margin-bottom: 20px;
    border-radius: 5px;
    font-weight: bold;
}

.error {
    background: #ffdede;
    color: #a00000;
    padding: 12px;
    margin-bottom: 20px;
    border-radius: 5px;
    font-weight: bold;
}

table {
    width: 100%;
    border-collapse: collapse;
}

th {
    background: #174c79;
    color: white;
    padding: 12px;
}

td {
    border: 1px solid #ddd;
    padding: 10px;
    text-align: center;
}

tr:nth-child(even) {
    background: #f8fbfd;
}

.edit-btn {
    background: #1565c0;
    color: white;
    border: none;
    padding: 7px 12px;
    border-radius: 5px;
    cursor: pointer;
}

.delete-btn {
    background: #c62828;
    color: white;
    border: none;
    padding: 7px 12px;
    border-radius: 5px;
    cursor: pointer;
}

</style>


<script>

function deleteStudent(regNo) {

    const answer =
        confirm(
            "Are you sure you want to delete student " +
            regNo +
            "?\n\n" +
            "The student's attendance records will also be deleted."
        );

    if (!answer) {
        return;
    }

    document.getElementById(
        "deleteRegNo"
    ).value = regNo;

    document.getElementById(
        "deleteForm"
    ).submit();
}

</script>

</head>


<body>


<div class="header">

<h1>
    Student Management
</h1>

<div>

<a
    href="faculty-dashboard.jsp"
    class="dashboard">

    Dashboard

</a>

<a
    href="logout.jsp"
    class="logout">

    Logout

</a>

</div>

</div>


<div class="container">

<h2>
    Student Management
</h2>


<%
if (!message.equals("")) {
%>

<div class="success">
    <%=message%>
</div>

<%
}

if (!error.equals("")) {
%>

<div class="error">
    <%=error%>
</div>

<%
}
%>


<!--
=========================================================
HIDDEN DELETE FORM
=========================================================
-->

<form
    id="deleteForm"
    method="post">

<input
    type="hidden"
    name="action"
    value="delete">

<input
    type="hidden"
    name="delete_reg_no"
    id="deleteRegNo">

</form>


<table>

<thead>

<tr>

<th>
S.No
</th>

<th>
Student ID
</th>

<th>
Name
</th>

<th>
Email
</th>

<th>
Mobile
</th>

<th>
Department
</th>

<th>
Year
</th>

<th>
Section
</th>

<th>
Gender
</th>

<th>
Edit
</th>

<th>
Delete
</th>

</tr>

</thead>


<tbody>

<%

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {

    con = Db.getConnection();

    ps = con.prepareStatement(
        "SELECT " +
        "reg_no, " +
        "name, " +
        "email, " +
        "mobile, " +
        "department, " +
        "year, " +
        "section, " +
        "gender " +
        "FROM students " +
        "ORDER BY reg_no"
    );

    rs = ps.executeQuery();

    int sno = 1;

    while (rs.next()) {

        String regNo =
            rs.getString("reg_no");

%>

<tr>

<td>
    <%=sno++%>
</td>

<td>
    <b>
        <%=regNo%>
    </b>
</td>

<td>
    <%=rs.getString("name")%>
</td>

<td>
    <%=rs.getString("email")%>
</td>

<td>
    <%=rs.getString("mobile")%>
</td>

<td>
    <%=rs.getString("department")%>
</td>

<td>
    <%=rs.getString("year")%>
</td>

<td>
    <%=rs.getString("section")%>
</td>

<td>
    <%=rs.getString("gender")%>
</td>


<td>

<form
    method="get"
    action="faculty-student-edit.jsp">

<input
    type="hidden"
    name="reg_no"
    value="<%=regNo%>">

<button
    type="submit"
    class="edit-btn">

    Edit

</button>

</form>

</td>


<td>

<button
    type="button"
    class="delete-btn"
    onclick="deleteStudent('<%=regNo%>')">

    Delete

</button>

</td>

</tr>

<%
    }

} catch (Exception e) {
%>

<tr>

<td
    colspan="11">

    Database Error:
    <%=e.getMessage()%>

</td>

</tr>

<%
} finally {

    try {
        if (rs != null)
            rs.close();
    } catch (Exception e) {}

    try {
        if (ps != null)
            ps.close();
    } catch (Exception e) {}

    try {
        if (con != null)
            con.close();
    } catch (Exception e) {}
}

%>

</tbody>

</table>

</div>

</body>

</html>