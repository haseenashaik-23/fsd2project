
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="jspExample2.Db" %>

<%
String facultyUser = (String) session.getAttribute("username");
String facultyRole = (String) session.getAttribute("role");

if (facultyUser == null || !"FACULTY".equalsIgnoreCase(facultyRole)) {
    response.sendRedirect("index.html");
    return;
}

String message = request.getParameter("message");
String errorMessage = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String action = request.getParameter("action");

    try (Connection con = Db.getConnection()) {

        if ("add".equals(action)) {
            String subjectName = request.getParameter("subject_name");

            if (subjectName == null || subjectName.trim().isEmpty()) {
                throw new Exception("Enter a subject name.");
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO subjects(subject_name) VALUES(?)")) {
                ps.setString(1, subjectName.trim());
                ps.executeUpdate();
            }

            response.sendRedirect("subject-management.jsp?message=Subject+added");
            return;
        }

        else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String subjectName = request.getParameter("subject_name");

            if (subjectName == null || subjectName.trim().isEmpty()) {
                throw new Exception("Subject name cannot be empty.");
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE subjects SET subject_name=? WHERE id=?")) {
                ps.setString(1, subjectName.trim());
                ps.setInt(2, id);

                if (ps.executeUpdate() == 0) {
                    throw new Exception("Subject not found.");
                }
            }

            response.sendRedirect("subject-management.jsp?message=Subject+updated");
            return;
        }

        else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));

            try (PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM subjects WHERE id=?")) {
                ps.setInt(1, id);

                if (ps.executeUpdate() == 0) {
                    throw new Exception("Subject not found.");
                }
            }

            response.sendRedirect("subject-management.jsp?message=Subject+deleted");
            return;
        }

        else {
            throw new Exception("Invalid action.");
        }

    } catch (SQLIntegrityConstraintViolationException e) {
        errorMessage = "This subject already exists. Choose a different name.";
    } catch (Exception e) {
        errorMessage = e.getMessage();
    }
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Subject Management</title>
<style>
*{box-sizing:border-box}
body{margin:0;font-family:Arial,sans-serif;background:#f3f6fb;color:#243247}
header{background:#174c79;color:white;padding:18px 25px;display:flex;justify-content:space-between;align-items:center}
header h1{margin:0;font-size:23px}
header a{color:white;text-decoration:none}
.container{max-width:1050px;margin:30px auto;padding:0 18px}
.panel{background:white;padding:25px;border-radius:10px;box-shadow:0 2px 10px #00000012;margin-bottom:22px}
h2{color:#174c79;margin-top:0}
input{padding:10px;border:1px solid #ccd5df;border-radius:5px;font-size:15px}
button{padding:10px 15px;border:0;border-radius:5px;background:#1688bd;color:white;cursor:pointer;font-weight:bold}
button:hover{opacity:.9}
.danger{background:#c0392b}
.success{background:#e2f6e8;color:#17652c;padding:12px;border-radius:5px;margin-bottom:15px}
.error{background:#ffe4e4;color:#a00000;padding:12px;border-radius:5px;margin-bottom:15px}
table{width:100%;border-collapse:collapse}
th,td{padding:12px;border-bottom:1px solid #e4e8ee;text-align:left}
th{background:#eaf1f8;color:#174c79}
.subject-input{width:100%;min-width:180px}
.actions{display:flex;gap:8px;align-items:center}
.add-row{display:flex;gap:10px;flex-wrap:wrap}
.add-row input{flex:1;min-width:200px}
@media(max-width:650px){.table-wrap{overflow-x:auto}table{min-width:550px}}
</style>
</head>
<body>

<header>
<h1>Subject Management</h1>
<div>
<%= facultyUser %> &nbsp; | &nbsp;
<a href="faculty-dashboard.jsp">Dashboard</a>
&nbsp; | &nbsp;
<a href="logout.jsp">Logout</a>
</div>
</header>

<div class="container">

<% if (message != null) { %>
<div class="success"><%= message %></div>
<% } %>

<% if (!errorMessage.isEmpty()) { %>
<div class="error"><%= errorMessage %></div>
<% } %>

<div class="panel">
<h2>Add New Subject</h2>
<form method="post" action="subject-management.jsp">
<input type="hidden" name="action" value="add">
<div class="add-row">
<input type="text" name="subject_name" placeholder="Enter subject name" required maxlength="150">
<button type="submit">Add Subject</button>
</div>
</form>
</div>

<div class="panel">
<h2>Existing Subjects</h2>
<div class="table-wrap">
<table>
<thead>
<tr><th>ID</th><th>Subject Name</th><th>Actions</th></tr>
</thead>
<tbody>
<%
try (Connection con = Db.getConnection();
     PreparedStatement ps = con.prepareStatement(
         "SELECT id,subject_name FROM subjects ORDER BY id");
     ResultSet rs = ps.executeQuery()) {

    while (rs.next()) {
        int subjectId = rs.getInt("id");
        String subjectName = rs.getString("subject_name");
%>
<tr>
<td>
<form id="subject<%= subjectId %>" method="post" action="subject-management.jsp"></form>
<%= subjectId %>
</td>
<td>
<input form="subject<%= subjectId %>"
       type="text" name="subject_name"
       class="subject-input"
       value="<%= subjectName %>"
       maxlength="150" required>
<input form="subject<%= subjectId %>" type="hidden" name="id" value="<%= subjectId %>">
</td>
<td>
<div class="actions">
<button form="subject<%= subjectId %>" type="submit" name="action" value="update">Save / Update</button>
<form method="post" action="subject-management.jsp"
      onsubmit="return confirm('Delete this subject? Existing attendance history will remain in the attendance table.')">
<input type="hidden" name="action" value="delete">
<input type="hidden" name="id" value="<%= subjectId %>">
<button type="submit" class="danger">Delete</button>
</form>
</div>
</td>
</tr>
<%
    }
} catch (Exception e) {
%>
<tr><td colspan="3">Database error: <%= e.getMessage() %></td></tr>
<%
}
%>
</tbody>
</table>
</div>
</div>

</div>
</body>
</html>