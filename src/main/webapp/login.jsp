<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jspExample2.Db" %>

<%
String username = request.getParameter("username");
String password = request.getParameter("password");
String role = request.getParameter("role");

if (username == null) username = "";
if (password == null) password = "";
if (role == null) role = "";

username = username.trim();
password = password.trim();
role = role.trim();

String errorMessage = "";

if (username.isEmpty() || password.isEmpty() || role.isEmpty()) {

    errorMessage = "Please enter all login details.";

} else {

    Connection con = null;

    try {

        con = Db.getConnection();

        // =========================================================
        // STUDENT LOGIN
        // =========================================================
        if ("STUDENT".equalsIgnoreCase(role)) {

            /*
             * First check the students table.
             *
             * Student username = Student ID
             * Student password = Student ID
             */
            PreparedStatement studentPs = con.prepareStatement(
                "SELECT reg_no, name, email, mobile, department, year, section, gender " +
                "FROM students " +
                "WHERE reg_no=?"
            );

            studentPs.setString(1, username);

            ResultSet studentRs = studentPs.executeQuery();

            if (!studentRs.next()) {

                errorMessage =
                    "Student ID not found in students database.";

            } else {

                String studentId =
                    studentRs.getString("reg_no");

                String studentName =
                    studentRs.getString("name");

                /*
                 * Password must be the same as Student ID.
                 */
                if (!password.equals(studentId)) {

                    errorMessage =
                        "Incorrect student password.";

                } else {

                    /*
                     * Check whether login account exists
                     * in users table.
                     */
                    PreparedStatement userCheckPs =
                        con.prepareStatement(
                            "SELECT username " +
                            "FROM users " +
                            "WHERE username=? AND role='STUDENT'"
                        );

                    userCheckPs.setString(1, studentId);

                    ResultSet userCheckRs =
                        userCheckPs.executeQuery();

                    /*
                     * If users account does not exist,
                     * automatically create it.
                     */
                    if (!userCheckRs.next()) {

                        PreparedStatement createUserPs =
                            con.prepareStatement(
                                "INSERT INTO users " +
                                "(username, password, role, name, reg_no, email, mobile, department, gender) " +
                                "SELECT " +
                                "reg_no, " +
                                "reg_no, " +
                                "'STUDENT', " +
                                "name, " +
                                "reg_no, " +
                                "email, " +
                                "mobile, " +
                                "department, " +
                                "gender " +
                                "FROM students " +
                                "WHERE reg_no=?"
                            );

                        createUserPs.setString(1, studentId);

                        createUserPs.executeUpdate();

                        createUserPs.close();
                    }

                    userCheckRs.close();
                    userCheckPs.close();

                    /*
                     * Store login session.
                     */
                    session.setAttribute(
                        "username",
                        studentId
                    );

                    session.setAttribute(
                        "role",
                        "STUDENT"
                    );

                    session.setAttribute(
                        "name",
                        studentName
                    );

                    session.setAttribute(
                        "reg_no",
                        studentId
                    );

                    session.setAttribute(
                        "otpVerified",
                        true
                    );

                    studentRs.close();
                    studentPs.close();

                    response.sendRedirect(
                        "student-dashboard.jsp"
                    );

                    return;
                }
            }

            studentRs.close();
            studentPs.close();

        }

        // =========================================================
        // FACULTY LOGIN
        // =========================================================
        else if ("FACULTY".equalsIgnoreCase(role)) {

            PreparedStatement facultyPs =
                con.prepareStatement(
                    "SELECT username, password, role, name, reg_no " +
                    "FROM users " +
                    "WHERE username=? AND role='FACULTY'"
                );

            facultyPs.setString(1, username);

            ResultSet facultyRs =
                facultyPs.executeQuery();

            if (!facultyRs.next()) {

                errorMessage =
                    "Faculty account not found. Please register first.";

            } else {

                String dbPassword =
                    facultyRs.getString("password");

                if (!password.equals(dbPassword)) {

                    errorMessage =
                        "Incorrect faculty password.";

                } else {

                    session.setAttribute(
                        "username",
                        facultyRs.getString("username")
                    );

                    session.setAttribute(
                        "role",
                        "FACULTY"
                    );

                    session.setAttribute(
                        "name",
                        facultyRs.getString("name")
                    );

                    session.setAttribute(
                        "reg_no",
                        facultyRs.getString("reg_no")
                    );

                    session.setAttribute(
                        "otpVerified",
                        false
                    );

                    facultyRs.close();
                    facultyPs.close();

                    response.sendRedirect(
                        "faculty-auth.jsp"
                    );

                    return;
                }
            }

            facultyRs.close();
            facultyPs.close();

        }

        // =========================================================
        // INVALID ROLE
        // =========================================================
        else {

            errorMessage =
                "Invalid login type.";

        }

    } catch (Exception e) {

        errorMessage =
            "Database Error: " + e.getMessage();

    } finally {

        try {
            if (con != null) {
                con.close();
            }
        } catch (Exception e) {
        }
    }
}
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">

<title>Login Error</title>

<style>

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: Arial, Helvetica, sans-serif;
    background: #eef4f8;
    text-align: center;
    padding-top: 100px;
}

.box {
    background: white;
    width: 500px;
    max-width: 90%;
    margin: auto;
    padding: 35px;
    border-radius: 8px;
    box-shadow: 0 4px 18px rgba(0,0,0,0.18);
}

.error {
    background: #ffdede;
    color: #a00000;
    padding: 16px;
    border-radius: 6px;
    margin-bottom: 25px;
    font-size: 17px;
}

a {
    display: inline-block;
    background: #174c79;
    color: white;
    padding: 12px 25px;
    text-decoration: none;
    border-radius: 5px;
    font-size: 16px;
}

a:hover {
    background: #0d3c61;
}

</style>

</head>

<body>

<div class="box">

    <div class="error">
        <%= errorMessage %>
    </div>

    <a href="index.html">
        Back to Login
    </a>

</div>

</body>

</html>