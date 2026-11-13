<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jspExample2.Db" %>

<%
String message = "";
String messageType = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {

    String facultyId = request.getParameter("faculty_id");
    String facultyName = request.getParameter("faculty_name");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirm_password");
    String email = request.getParameter("email");
    String mobile = request.getParameter("mobile");
    String department = request.getParameter("department");
    String designation = request.getParameter("designation");
    String gender = request.getParameter("gender");
    String about = request.getParameter("about");

    if (facultyId == null) facultyId = "";
    if (facultyName == null) facultyName = "";
    if (password == null) password = "";
    if (confirmPassword == null) confirmPassword = "";
    if (email == null) email = "";
    if (mobile == null) mobile = "";
    if (department == null) department = "";
    if (designation == null) designation = "";
    if (gender == null) gender = "";
    if (about == null) about = "";

    facultyId = facultyId.trim();
    facultyName = facultyName.trim();
    email = email.trim();
    mobile = mobile.trim();
    department = department.trim();
    designation = designation.trim();
    gender = gender.trim();
    about = about.trim();

    if (facultyId.isEmpty() ||
        facultyName.isEmpty() ||
        password.isEmpty() ||
        confirmPassword.isEmpty() ||
        email.isEmpty() ||
        mobile.isEmpty() ||
        department.isEmpty() ||
        designation.isEmpty() ||
        gender.isEmpty()) {

        message = "Please fill all required fields.";
        messageType = "error";

    } else if (!password.equals(confirmPassword)) {

        message = "Password and Confirm Password do not match.";
        messageType = "error";

    } else if (!facultyId.matches("T[0-9]+")) {

        message = "Faculty ID must start with T followed by numbers. Example: T101, T111, T201.";
        messageType = "error";

    } else {

        Connection con = null;
        PreparedStatement check = null;
        PreparedStatement insert = null;
        ResultSet rs = null;

        try {

            con = Db.getConnection();

            // Check whether faculty ID already exists
            check = con.prepareStatement(
                "SELECT username FROM users WHERE username=?"
            );

            check.setString(1, facultyId);

            rs = check.executeQuery();

            if (rs.next()) {

                message = "Faculty ID already exists. Please use another ID.";
                messageType = "error";

            } else {

                rs.close();
                rs = null;
                check.close();
                check = null;

                insert = con.prepareStatement(
                    "INSERT INTO users " +
                    "(username, password, role, name, reg_no, email, mobile, department, designation, about, gender) " +
                    "VALUES (?, ?, 'FACULTY', ?, ?, ?, ?, ?, ?, ?, ?)"
                );

                insert.setString(1, facultyId);
                insert.setString(2, password);
                insert.setString(3, facultyName);

                // Store faculty ID also in reg_no
                insert.setString(4, facultyId);

                insert.setString(5, email);
                insert.setString(6, mobile);
                insert.setString(7, department);
                insert.setString(8, designation);
                insert.setString(9, about);
                insert.setString(10, gender);

                int result = insert.executeUpdate();

                if (result > 0) {

                    message =
                        "Faculty registration successful! You can now login with Faculty ID: "
                        + facultyId;

                    messageType = "success";

                } else {

                    message = "Registration failed.";
                    messageType = "error";
                }
            }

        } catch (Exception e) {

            message = "Database Error: " + e.getMessage();
            messageType = "error";

        } finally {

            try {
                if (rs != null) rs.close();
            } catch (Exception e) {}

            try {
                if (check != null) check.close();
            } catch (Exception e) {}

            try {
                if (insert != null) insert.close();
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

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: Arial, Helvetica, sans-serif;
    background: #eef4f8;
}

.container {
    width: 650px;
    max-width: 95%;
    margin: 30px auto;
    background: white;
    padding: 30px 35px;
    border-radius: 8px;
    box-shadow: 0 4px 18px rgba(0,0,0,0.18);
}

h1 {
    text-align: center;
    color: #174c79;
    margin-bottom: 25px;
}

.message {
    padding: 14px;
    border-radius: 5px;
    margin-bottom: 20px;
    font-size: 16px;
}

.error {
    background: #ffdede;
    color: #a00000;
}

.success {
    background: #dff5df;
    color: #176b17;
}

.form-row {
    display: flex;
    align-items: center;
    margin-bottom: 16px;
}

.form-row label {
    width: 200px;
    font-weight: bold;
    font-size: 16px;
}

.form-row input,
.form-row select,
.form-row textarea {
    flex: 1;
    padding: 12px;
    border: 1px solid #ccc;
    border-radius: 5px;
    font-size: 16px;
}

textarea {
    resize: vertical;
    min-height: 90px;
}

.required {
    color: red;
}

.buttons {
    text-align: center;
    margin-top: 25px;
}

button {
    padding: 12px 25px;
    border: none;
    border-radius: 5px;
    font-size: 16px;
    cursor: pointer;
    margin: 5px;
}

.register {
    background: #174c79;
    color: white;
}

.reset {
    background: #777;
    color: white;
}

.login {
    display: block;
    text-align: center;
    margin-top: 20px;
    color: #174c79;
    text-decoration: none;
    font-weight: bold;
}

@media(max-width:650px) {

    .form-row {
        display: block;
    }

    .form-row label {
        display: block;
        width: 100%;
        margin-bottom: 7px;
    }

}

</style>

</head>

<body>

<div class="container">

<h1>Faculty Registration</h1>

<%
if (!message.isEmpty()) {
%>

<div class="message <%= messageType %>">
    <%= message %>
</div>

<%
}
%>

<form method="post" action="faculty-signup.jsp">

    <div class="form-row">
        <label>
            Faculty ID <span class="required">*</span>
        </label>

        <input
            type="text"
            name="faculty_id"
            placeholder="Example: T101 or T111"
            required>
    </div>


    <div class="form-row">
        <label>
            Faculty Name <span class="required">*</span>
        </label>

        <input
            type="text"
            name="faculty_name"
            required>
    </div>


    <div class="form-row">
        <label>
            Password <span class="required">*</span>
        </label>

        <input
            type="password"
            name="password"
            required>
    </div>


    <div class="form-row">
        <label>
            Confirm Password <span class="required">*</span>
        </label>

        <input
            type="password"
            name="confirm_password"
            required>
    </div>


    <div class="form-row">
        <label>
            Email <span class="required">*</span>
        </label>

        <input
            type="email"
            name="email"
            required>
    </div>


    <div class="form-row">
        <label>
            Mobile <span class="required">*</span>
        </label>

        <input
            type="text"
            name="mobile"
            pattern="[0-9]{10}"
            maxlength="10"
            placeholder="10 digit mobile number"
            required>
    </div>


    <div class="form-row">
        <label>
            Department <span class="required">*</span>
        </label>

        <select name="department" required>

            <option value="">Select Department</option>

            <option value="CSE">
                Computer Science and Engineering
            </option>

            <option value="ECE">
                Electronics and Communication Engineering
            </option>

            <option value="EEE">
                Electrical and Electronics Engineering
            </option>

            <option value="MECH">
                Mechanical Engineering
            </option>

            <option value="CIVIL">
                Civil Engineering
            </option>

        </select>

    </div>


    <div class="form-row">
        <label>
            Designation <span class="required">*</span>
        </label>

        <select name="designation" required>

            <option value="">Select Designation</option>

            <option value="Assistant Professor">
                Assistant Professor
            </option>

            <option value="Associate Professor">
                Associate Professor
            </option>

            <option value="Professor">
                Professor
            </option>

            <option value="HOD">
                HOD
            </option>

        </select>

    </div>


    <div class="form-row">
        <label>
            Gender <span class="required">*</span>
        </label>

        <select name="gender" required>

            <option value="">Select Gender</option>

            <option value="Male">Male</option>

            <option value="Female">Female</option>

            <option value="Other">Other</option>

        </select>

    </div>


    <div class="form-row">

        <label>
            About
        </label>

        <textarea
            name="about"
            placeholder="Enter faculty information"></textarea>

    </div>


    <div class="buttons">

        <button
            type="submit"
            class="register">
            Register Faculty
        </button>

        <button
            type="reset"
            class="reset">
            Reset
        </button>

    </div>

</form>

<a href="index.html" class="login">
    ← Back to Login
</a>

</div>

</body>
</html>