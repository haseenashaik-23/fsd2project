<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jspExample2.Db" %>

<%
String message = "";
String messageType = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {

    String studentId = request.getParameter("student_id");
    String studentName = request.getParameter("student_name");
    String email = request.getParameter("email");
    String mobile = request.getParameter("mobile");
    String department = request.getParameter("department");
    String year = request.getParameter("year");
    String section = request.getParameter("section");
    String address = request.getParameter("address");
    String gender = request.getParameter("gender");

    if (studentId == null) studentId = "";
    if (studentName == null) studentName = "";
    if (email == null) email = "";
    if (mobile == null) mobile = "";
    if (department == null) department = "";
    if (year == null) year = "";
    if (section == null) section = "";
    if (address == null) address = "";
    if (gender == null) gender = "";

    studentId = studentId.trim();
    studentName = studentName.trim();
    email = email.trim();
    mobile = mobile.trim();
    department = department.trim();
    year = year.trim();
    section = section.trim();
    address = address.trim();
    gender = gender.trim();

    if (studentId.isEmpty() ||
        studentName.isEmpty() ||
        email.isEmpty() ||
        mobile.isEmpty() ||
        department.isEmpty() ||
        year.isEmpty() ||
        section.isEmpty() ||
        gender.isEmpty()) {

        message = "Please fill all required fields.";
        messageType = "error";

    } else if (!studentId.matches("24761A05[A-Z][0-9]")) {

        message =
            "Invalid Student ID. Example: 24761A05G2";

        messageType = "error";

    } else if (!mobile.matches("[0-9]{10}")) {

        message =
            "Mobile number must contain exactly 10 digits.";

        messageType = "error";

    } else {

        Connection con = null;
        PreparedStatement checkStudent = null;
        PreparedStatement checkUser = null;
        PreparedStatement insertStudent = null;
        PreparedStatement insertUser = null;
        ResultSet rs1 = null;
        ResultSet rs2 = null;

        try {

            con = Db.getConnection();

            // Start transaction
            con.setAutoCommit(false);

            // ------------------------------------------------
            // 1. Check students table
            // ------------------------------------------------
            checkStudent = con.prepareStatement(
                "SELECT reg_no FROM students WHERE reg_no=?"
            );

            checkStudent.setString(1, studentId);

            rs1 = checkStudent.executeQuery();

            if (rs1.next()) {

                message =
                    "Student ID already exists in students table.";

                messageType = "error";

                con.rollback();

            } else {

                rs1.close();
                rs1 = null;

                checkStudent.close();
                checkStudent = null;

                // ------------------------------------------------
                // 2. Check users table
                // ------------------------------------------------
                checkUser = con.prepareStatement(
                    "SELECT username FROM users WHERE username=?"
                );

                checkUser.setString(1, studentId);

                rs2 = checkUser.executeQuery();

                if (rs2.next()) {

                    message =
                        "Student login account already exists.";

                    messageType = "error";

                    con.rollback();

                } else {

                    rs2.close();
                    rs2 = null;

                    checkUser.close();
                    checkUser = null;

                    // ------------------------------------------------
                    // 3. Insert into students table
                    // ------------------------------------------------
                    insertStudent = con.prepareStatement(
                        "INSERT INTO students " +
                        "(reg_no, name, email, mobile, department, year, section, address, gender) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
                    );

                    insertStudent.setString(1, studentId);
                    insertStudent.setString(2, studentName);
                    insertStudent.setString(3, email);
                    insertStudent.setString(4, mobile);
                    insertStudent.setString(5, department);
                    insertStudent.setString(6, year);
                    insertStudent.setString(7, section);
                    insertStudent.setString(8, address);
                    insertStudent.setString(9, gender);

                    int studentResult =
                        insertStudent.executeUpdate();

                    // ------------------------------------------------
                    // 4. Insert login account into users table
                    // ------------------------------------------------
                    insertUser = con.prepareStatement(
                        "INSERT INTO users " +
                        "(username, password, role, name, reg_no, email, mobile, department, gender) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
                    );

                    // Username = Student ID
                    insertUser.setString(1, studentId);

                    // Password = Student ID
                    insertUser.setString(2, studentId);

                    // Role
                    insertUser.setString(3, "STUDENT");

                    // Name
                    insertUser.setString(4, studentName);

                    // Registration number
                    insertUser.setString(5, studentId);

                    // Email
                    insertUser.setString(6, email);

                    // Mobile
                    insertUser.setString(7, mobile);

                    // Department
                    insertUser.setString(8, department);

                    // Gender
                    insertUser.setString(9, gender);

                    int userResult =
                        insertUser.executeUpdate();

                    // ------------------------------------------------
                    // 5. Check both inserts
                    // ------------------------------------------------
                    if (studentResult > 0 && userResult > 0) {

                        con.commit();

                        message =
                            "Student registration successful! " +
                            "Username and Password are both: " +
                            studentId;

                        messageType = "success";

                    } else {

                        con.rollback();

                        message =
                            "Registration failed. Please try again.";

                        messageType = "error";
                    }
                }
            }

        } catch (Exception e) {

            try {
                if (con != null) {
                    con.rollback();
                }
            } catch (Exception rollbackError) {
            }

            message =
                "Database Error: " + e.getMessage();

            messageType = "error";

        } finally {

            try {
                if (rs1 != null) rs1.close();
            } catch (Exception e) {
            }

            try {
                if (rs2 != null) rs2.close();
            } catch (Exception e) {
            }

            try {
                if (checkStudent != null) checkStudent.close();
            } catch (Exception e) {
            }

            try {
                if (checkUser != null) checkUser.close();
            } catch (Exception e) {
            }

            try {
                if (insertStudent != null) insertStudent.close();
            } catch (Exception e) {
            }

            try {
                if (insertUser != null) insertUser.close();
            } catch (Exception e) {
            }

            try {
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (Exception e) {
            }
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

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: Arial, Helvetica, sans-serif;
    background: #eef4f8;
}

.container {
    width: 700px;
    max-width: 95%;
    margin: 30px auto;
    background: white;
    padding: 30px 35px;
    border-radius: 10px;
    box-shadow: 0 4px 18px rgba(0,0,0,0.18);
}

h1 {
    text-align: center;
    color: #174c79;
    margin-bottom: 25px;
}

.message {
    padding: 15px;
    border-radius: 6px;
    margin-bottom: 20px;
    font-size: 16px;
}

.error {
    background: #ffdede;
    color: #a00000;
}

.success {
    background: #ddf5df;
    color: #176b17;
}

.form-row {
    display: flex;
    align-items: center;
    margin-bottom: 16px;
}

.form-row label {
    width: 210px;
    font-weight: bold;
    font-size: 16px;
}

.form-row input,
.form-row select,
.form-row textarea {
    flex: 1;
    padding: 12px;
    border: 1px solid #c8c8c8;
    border-radius: 5px;
    font-size: 15px;
}

.form-row textarea {
    min-height: 80px;
    resize: vertical;
}

.required {
    color: red;
}

.note {
    background: #e8f2ff;
    color: #174c79;
    padding: 12px;
    border-radius: 5px;
    margin-bottom: 20px;
}

.buttons {
    text-align: center;
    margin-top: 25px;
}

button {
    border: none;
    padding: 12px 25px;
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

<h1>Student Registration</h1>

<div class="note">
    <b>Login Information:</b><br>
    Student ID will be used as both Username and Password.
    <br>
    Example: <b>24761A05G2</b>
</div>

<%
if (!message.isEmpty()) {
%>

<div class="message <%= messageType %>">
    <%= message %>
</div>

<%
}
%>

<form method="post" action="student-signup.jsp">

    <div class="form-row">

        <label>
            Student ID <span class="required">*</span>
        </label>

        <input
            type="text"
            name="student_id"
            placeholder="Example: 24761A05G2"
            required>

    </div>


    <div class="form-row">

        <label>
            Student Name <span class="required">*</span>
        </label>

        <input
            type="text"
            name="student_name"
            placeholder="Enter student name"
            required>

    </div>


    <div class="form-row">

        <label>
            Email <span class="required">*</span>
        </label>

        <input
            type="email"
            name="email"
            placeholder="student@gmail.com"
            required>

    </div>


    <div class="form-row">

        <label>
            Mobile <span class="required">*</span>
        </label>

        <input
            type="text"
            name="mobile"
            maxlength="10"
            pattern="[0-9]{10}"
            placeholder="10 digit mobile number"
            required>

    </div>


    <div class="form-row">

        <label>
            Department <span class="required">*</span>
        </label>

        <select name="department" required>

            <option value="">
                Select Department
            </option>

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
            Year <span class="required">*</span>
        </label>

        <select name="year" required>

            <option value="">
                Select Year
            </option>

            <option value="1st Year">
                1st Year
            </option>

            <option value="2nd Year">
                2nd Year
            </option>

            <option value="3rd Year">
                3rd Year
            </option>

            <option value="4th Year">
                4th Year
            </option>

        </select>

    </div>


    <div class="form-row">

        <label>
            Section <span class="required">*</span>
        </label>

        <select name="section" required>

            <option value="">
                Select Section
            </option>

            <option value="A">
                A
            </option>

            <option value="B">
                B
            </option>

        </select>

    </div>


    <div class="form-row">

        <label>
            Gender <span class="required">*</span>
        </label>

        <select name="gender" required>

            <option value="">
                Select Gender
            </option>

            <option value="Male">
                Male
            </option>

            <option value="Female">
                Female
            </option>

            <option value="Other">
                Other
            </option>

        </select>

    </div>


    <div class="form-row">

        <label>
            Address
        </label>

        <textarea
            name="address"
            placeholder="Enter address"></textarea>

    </div>


    <div class="buttons">

        <button
            type="submit"
            class="register">
            Register Student
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