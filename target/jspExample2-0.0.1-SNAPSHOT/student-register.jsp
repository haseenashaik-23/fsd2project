<%@ page import="java.sql.*" %>
<%@ page import="jspExample2.Db" %>

<%
String message = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {

    String regNo = request.getParameter("reg_no");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String mobile = request.getParameter("mobile");
    String department = request.getParameter("department");
    String year = request.getParameter("year");
    String section = request.getParameter("section");
    String address = request.getParameter("address");
    String gender = request.getParameter("gender");

    if (regNo != null) {
        regNo = regNo.trim().toUpperCase();
    }

    boolean validId = false;

    if (regNo != null &&
        regNo.matches("^24761A05[D-H][0-9]$")) {

        String letter = regNo.substring(8, 9);

        int number =
            Integer.parseInt(regNo.substring(9, 10));

        if ("D".equals(letter)) {

            validId = number >= 2 && number <= 9;

        } else {

            validId = number >= 0 && number <= 9;
        }
    }

    if (!validId) {

        message = "Invalid Student ID.";

    } else if (name == null || name.trim().isEmpty()) {

        message = "Student name is required.";

    } else {

        Connection con = null;

        PreparedStatement studentPs = null;
        PreparedStatement userPs = null;

        try {

            con = Db.getConnection();

            con.setAutoCommit(false);


            String studentSql =
                "INSERT INTO students " +
                "(reg_no,name,email,mobile,department,year,section,address,gender) " +
                "VALUES (?,?,?,?,?,?,?,?,?)";

            studentPs =
                con.prepareStatement(studentSql);

            studentPs.setString(1, regNo);
            studentPs.setString(2, name);
            studentPs.setString(3, email);
            studentPs.setString(4, mobile);
            studentPs.setString(5, department);
            studentPs.setString(6, year);
            studentPs.setString(7, section);
            studentPs.setString(8, address);
            studentPs.setString(9, gender);

            studentPs.executeUpdate();


            String userSql =
                "INSERT INTO users " +
                "(username,password,role,name,reg_no,email,mobile,department,about,gender) " +
                "VALUES (?,?,? ,?,?,?,?,?,?,?)";

            userPs =
                con.prepareStatement(userSql);

            userPs.setString(1, regNo);

            /* Password = Student ID */
            userPs.setString(2, regNo);

            userPs.setString(3, "student");

            userPs.setString(4, name);

            userPs.setString(5, regNo);

            userPs.setString(6, email);

            userPs.setString(7, mobile);

            userPs.setString(8, department);

            userPs.setString(9, address);

            userPs.setString(10, gender);

            userPs.executeUpdate();


            con.commit();

            message =
                "Student registered successfully. Password is the Student ID.";

        } catch (Exception e) {

            try {
                if (con != null)
                    con.rollback();
            } catch (Exception ex) {}

            message =
                "Registration Error: " + e.getMessage();

        } finally {

            try {
                if (studentPs != null)
                    studentPs.close();
            } catch (Exception e) {}

            try {
                if (userPs != null)
                    userPs.close();
            } catch (Exception e) {}

            try {
                if (con != null)
                    con.close();
            } catch (Exception e) {}
        }
    }
}
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">

<title>Student Registration</title>

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

.radio-group,
.checkbox-group {
    display: flex;
    gap: 15px;
}

.radio-group input,
.checkbox-group input {
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
    background: #e7f3ff;
    padding: 12px;
    margin-bottom: 15px;
    border-radius: 6px;
}

</style>

</head>

<body>

<div class="container">

<h2>Student Registration</h2>

<% if (!message.isEmpty()) { %>

<div class="message">
<%= message %>
</div>

<% } %>

<form method="post">

<div class="form-group">

<label>Student ID</label>

<input type="text"
       name="reg_no"
       placeholder="24761A05D2"
       required>

</div>


<div class="form-group">

<label>Student Name</label>

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

<label>Year</label>

<select name="year">

<option>1st Year</option>
<option>2nd Year</option>
<option>3rd Year</option>
<option>4th Year</option>

</select>

</div>


<div class="form-group">

<label>Section</label>

<select name="section">

<option value="A">Section A</option>
<option value="B">Section B</option>

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

<label>Address</label>

<textarea name="address"></textarea>

</div>


<div class="form-group">

<label>Upload Photo</label>

<input type="file"
       name="photo">

</div>


<div class="form-group checkbox-group">

<label>

<input type="checkbox"
       name="agree"
       required>

I confirm that the information is correct.

</label>

</div>


<button type="submit" class="submit">
Register
</button>

<button type="reset" class="reset">
Reset
</button>

</form>

</div>

</body>

</html>