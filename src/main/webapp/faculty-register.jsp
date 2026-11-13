<%@ page import="java.sql.*" %>
<%@ page import="jspExample2.Db" %>

<%
String message = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {

    String facultyId =
        request.getParameter("faculty_id");

    String name =
        request.getParameter("name");

    String email =
        request.getParameter("email");

    String mobile =
        request.getParameter("mobile");

    String department =
        request.getParameter("department");

    String designation =
        request.getParameter("designation");

    String gender =
        request.getParameter("gender");

    String about =
        request.getParameter("about");


    if (facultyId != null) {

        facultyId =
            facultyId.trim().toUpperCase();
    }


    boolean validId =
        facultyId != null &&
        facultyId.matches("^T10([1-9]|10)$");


    if (!validId) {

        message =
            "Invalid Faculty ID. Use T101 to T110.";

    } else if (name == null ||
               name.trim().isEmpty()) {

        message =
            "Faculty name is required.";

    } else {

        Connection con = null;
        PreparedStatement ps = null;

        try {

            con = Db.getConnection();

            String sql =
                "INSERT INTO users " +
                "(username,password,role,name,email,mobile,department,designation,about,gender) " +
                "VALUES (?,?,?,?,?,?,?,?,?,?)";

            ps = con.prepareStatement(sql);

            ps.setString(1, facultyId);

            ps.setString(2, "lbrce123");

            ps.setString(3, "faculty");

            ps.setString(4, name);

            ps.setString(5, email);

            ps.setString(6, mobile);

            ps.setString(7, department);

            ps.setString(8, designation);

            ps.setString(9, about);

            ps.setString(10, gender);

            ps.executeUpdate();

            message =
                "Faculty registration successful. Password: lbrce123";

        } catch (Exception e) {

            message =
                "Registration Error: " +
                e.getMessage();

        } finally {

            try {
                if (ps != null) ps.close();
            } catch (Exception e) {}

            try {
                if (con != null) con.close();
            } catch (Exception e) {}
        }
    }
}
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">

<title>Faculty Registration</title>

<style>

body {
    margin: 0;
    font-family: Arial;
    background: #eef3f8;
}

.container {
    width: 650px;
    margin: 40px auto;
    background: white;
    padding: 30px;
    border-radius: 12px;
    box-shadow: 0 3px 15px rgba(0,0,0,.15);
}

h2 {
    text-align: center;
    color: #0b5ed7;
}

.form-group {
    margin-bottom: 15px;
}

label {
    display: block;
    margin-bottom: 6px;
    font-weight: bold;
}

input,
select,
textarea {
    width: 100%;
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 6px;
}

textarea {
    height: 80px;
}

.radio-group {
    display: flex;
    gap: 20px;
}

.radio-group input {
    width: auto;
}

button {
    padding: 12px 20px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
}

.submit {
    background: #0b5ed7;
    color: white;
}

.reset {
    background: #6c757d;
    color: white;
}

.message {
    padding: 12px;
    background: #e7f3ff;
    margin-bottom: 15px;
    border-radius: 6px;
}

</style>

</head>

<body>

<div class="container">

<h2>Faculty Registration</h2>

<% if (!message.isEmpty()) { %>

<div class="message">
<%= message %>
</div>

<% } %>


<form method="post">

<div class="form-group">

<label>Faculty ID</label>

<input type="text"
       name="faculty_id"
       placeholder="T101"
       required>

</div>


<div class="form-group">

<label>Faculty Name</label>

<input type="text"
       name="name"
       required>

</div>


<div class="form-group">

<label>Email</label>

<input type="email"
       name="email">

</div>


<div class="form-group">

<label>Mobile</label>

<input type="text"
       name="mobile">

</div>


<div class="form-group">

<label>Department</label>

<select name="department">

<option value="CSE">
Computer Science and Engineering
</option>

</select>

</div>


<div class="form-group">

<label>Designation</label>

<select name="designation">

<option>Assistant Professor</option>
<option>Associate Professor</option>
<option>Professor</option>

</select>

</div>


<div class="form-group">

<label>Gender</label>

<div class="radio-group">

<label>
<input type="radio"
       name="gender"
       value="Male">
Male
</label>

<label>
<input type="radio"
       name="gender"
       value="Female">
Female
</label>

</div>

</div>


<div class="form-group">

<label>About Faculty</label>

<textarea name="about"></textarea>

</div>


<div class="form-group">

<label>
<input type="checkbox"
       required>
I confirm the information is correct.
</label>

</div>


<button class="submit"
        type="submit">
Register Faculty
</button>

<button class="reset"
        type="reset">
Reset
</button>

</form>

</div>

</body>

</html>