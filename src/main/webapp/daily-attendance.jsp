<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="jspExample2.Db" %>

<%
/* =========================================================
   FACULTY LOGIN CHECK
   ========================================================= */

String role = (String) session.getAttribute("role");

if (role == null || !"FACULTY".equalsIgnoreCase(role)) {
    response.sendRedirect("index.html");
    return;
}


/* =========================================================
   TODAY'S DATE
   ========================================================= */

LocalDate today = LocalDate.now();

String todayDate = today.toString();


/* =========================================================
   FILTER VALUES
   ========================================================= */

String semester =
        request.getParameter("semester");

String section =
        request.getParameter("section");

String academicYear =
        request.getParameter("academic_year");

String subject =
        request.getParameter("subject");

String view =
        request.getParameter("view");


if (semester == null) semester = "ALL";
if (section == null) section = "ALL";
if (academicYear == null) academicYear = "ALL";
if (subject == null) subject = "ALL";


/* =========================================================
   DELETE ATTENDANCE
   ONLY TODAY
   ========================================================= */

String deleteId =
        request.getParameter("delete_id");

if (deleteId != null &&
    !deleteId.trim().equals("")) {

    Connection deleteCon = null;
    PreparedStatement deletePs = null;

    try {

        deleteCon = Db.getConnection();

        deletePs = deleteCon.prepareStatement(
            "DELETE FROM attendance " +
            "WHERE id=? " +
            "AND attendance_date=?"
        );

        deletePs.setInt(
            1,
            Integer.parseInt(deleteId)
        );

        deletePs.setDate(
            2,
            Date.valueOf(today)
        );

        deletePs.executeUpdate();

    } catch (Exception e) {

        e.printStackTrace();

    } finally {

        try {
            if (deletePs != null)
                deletePs.close();
        } catch (Exception e) {}

        try {
            if (deleteCon != null)
                deleteCon.close();
        } catch (Exception e) {}
    }

    response.sendRedirect(
        "daily-attendance.jsp" +
        "?view=1" +
        "&semester=" + semester +
        "&section=" + section +
        "&academic_year=" + academicYear +
        "&subject=" + java.net.URLEncoder.encode(
            subject,
            "UTF-8"
        )
    );

    return;
}
%>


<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">

<title>Daily Attendance</title>

<style>

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: Arial, Helvetica, sans-serif;
    background: #f1f5f9;
    color: #222;
}


/* =========================================================
   HEADER
   ========================================================= */

.header {
    background: #174c79;
    color: white;
    padding: 18px 30px;

    display: flex;
    justify-content: space-between;
    align-items: center;
}

.header h1 {
    margin: 0;
    font-size: 24px;
}

.header-right {
    display: flex;
    gap: 10px;
}

.header a {
    text-decoration: none;
    color: white;
    padding: 9px 16px;
    border-radius: 5px;
    font-size: 14px;
}

.dashboard-btn {
    background: #287bb5;
}

.logout-btn {
    background: #dc3545;
}

.header a:hover {
    opacity: 0.9;
}


/* =========================================================
   MAIN
   ========================================================= */

.container {
    width: 95%;
    max-width: 1400px;
    margin: 25px auto;
}


/* =========================================================
   FILTER CARD
   ========================================================= */

.filter-card {
    background: white;
    padding: 25px;
    border-radius: 10px;

    box-shadow:
        0 3px 12px rgba(0,0,0,0.10);

    margin-bottom: 25px;
}

.filter-card h2 {
    margin-top: 0;
    margin-bottom: 20px;
    color: #174c79;
}

.today-box {
    background: #e8f4ff;
    color: #174c79;
    padding: 12px 15px;
    border-radius: 6px;
    margin-bottom: 20px;
    font-weight: bold;
}


/* =========================================================
   FILTER GRID
   ========================================================= */

.filter-grid {
    display: grid;

    grid-template-columns:
        repeat(4, 1fr);

    gap: 15px;
}

.field label {
    display: block;
    font-weight: bold;
    margin-bottom: 7px;
}

.field select {
    width: 100%;
    padding: 11px;

    border: 1px solid #ccc;
    border-radius: 5px;

    background: white;
    font-size: 14px;
}


/* =========================================================
   VIEW BUTTON
   ========================================================= */

.view-btn {
    margin-top: 20px;

    background: #174c79;
    color: white;

    border: none;

    padding: 12px 25px;

    border-radius: 5px;

    font-size: 15px;

    cursor: pointer;
}

.view-btn:hover {
    background: #0d3c61;
}


/* =========================================================
   TABLE CARD
   ========================================================= */

.table-card {
    background: white;

    padding: 25px;

    border-radius: 10px;

    box-shadow:
        0 3px 12px rgba(0,0,0,0.10);

    overflow-x: auto;
}

.table-card h2 {
    color: #174c79;
    margin-top: 0;
}


/* =========================================================
   TABLE
   ========================================================= */

table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 15px;
}

th {
    background: #174c79;
    color: white;

    padding: 12px;

    text-align: center;

    font-size: 14px;
}

td {
    padding: 11px;

    border-bottom: 1px solid #ddd;

    text-align: center;

    font-size: 14px;
}

tr:hover {
    background: #f5f9fc;
}


/* =========================================================
   STATUS
   ========================================================= */

.present {
    color: #16803c;
    font-weight: bold;
}

.absent {
    color: #d62828;
    font-weight: bold;
}


/* =========================================================
   DELETE BUTTON
   ========================================================= */

.delete-btn {
    background: #dc3545;

    color: white;

    border: none;

    padding: 7px 12px;

    border-radius: 4px;

    cursor: pointer;
}

.delete-btn:hover {
    background: #b02a37;
}


/* =========================================================
   NO DATA
   ========================================================= */

.no-data {
    text-align: center;

    padding: 30px;

    color: #777;

    font-size: 16px;
}


/* =========================================================
   RESPONSIVE
   ========================================================= */

@media(max-width: 900px) {

    .filter-grid {
        grid-template-columns:
            repeat(2, 1fr);
    }
}

@media(max-width: 600px) {

    .filter-grid {
        grid-template-columns: 1fr;
    }

    .header {
        flex-direction: column;
        gap: 15px;
    }
}

</style>


<script>

/* =========================================================
   LOAD SUBJECTS ACCORDING TO SEMESTER
   ========================================================= */

function loadSubjects() {

    var semester =
        document.getElementById("semester").value;

    var subject =
        document.getElementById("subject");

    subject.innerHTML =
        '<option value="ALL">All Subjects</option>';

    if (semester === "ALL") {
        return;
    }

    fetch(
        "get-subjects.jsp?semester="
        + encodeURIComponent(semester)
    )

    .then(function(response) {
        return response.json();
    })

    .then(function(data) {

        subject.innerHTML =
            '<option value="ALL">All Subjects</option>';

        data.forEach(function(item) {

            if (item.error) {
                return;
            }

            var option =
                document.createElement("option");

            option.value = item;
            option.textContent = item;

            subject.appendChild(option);

        });

    })

    .catch(function(error) {

        console.log(
            "Subject loading error:",
            error
        );

    });
}


/* =========================================================
   CONFIRM DELETE
   ========================================================= */

function confirmDelete(id) {

    var result =
        confirm(
            "Are you sure you want to delete this today's attendance record?"
        );

    if (result) {

        window.location.href =
            "daily-attendance.jsp"
            + "?delete_id="
            + encodeURIComponent(id)
            + "&view=1"
            + "&semester="
            + encodeURIComponent(
                document.getElementById("semester").value
            )
            + "&section="
            + encodeURIComponent(
                document.getElementById("section").value
            )
            + "&academic_year="
            + encodeURIComponent(
                document.getElementById("academic_year").value
            )
            + "&subject="
            + encodeURIComponent(
                document.getElementById("subject").value
            );
    }
}

</script>

</head>


<body>


<!-- =========================================================
     HEADER
     ========================================================= -->

<div class="header">

    <h1>Daily Attendance</h1>

    <div class="header-right">

        <a
            href="faculty-dashboard.jsp"
            class="dashboard-btn"
        >
            Dashboard
        </a>

        <a
            href="logout.jsp"
            class="logout-btn"
        >
            Logout
        </a>

    </div>

</div>



<div class="container">


<!-- =========================================================
     FILTER CARD
     ========================================================= -->

<div class="filter-card">

    <h2>View Today's Attendance</h2>


    <div class="today-box">

        Attendance Date:
        <%= todayDate %>

        &nbsp; — &nbsp;

        Only Today's Attendance Will Be Displayed

    </div>


    <form
        method="get"
        action="daily-attendance.jsp"
    >

        <input
            type="hidden"
            name="view"
            value="1"
        >


        <div class="filter-grid">


            <!-- =================================================
                 SEMESTER
                 ================================================= -->

            <div class="field">

                <label>
                    Semester
                </label>

                <select
                    name="semester"
                    id="semester"
                    onchange="loadSubjects()"
                >

                    <option value="ALL"
                        <%= "ALL".equals(semester)
                            ? "selected"
                            : "" %>>
                        All Semesters
                    </option>

                    <option value="1"
                        <%= "1".equals(semester)
                            ? "selected"
                            : "" %>>
                        Semester 1
                    </option>

                    <option value="2"
                        <%= "2".equals(semester)
                            ? "selected"
                            : "" %>>
                        Semester 2
                    </option>

                    <option value="3"
                        <%= "3".equals(semester)
                            ? "selected"
                            : "" %>>
                        Semester 3
                    </option>

                    <option value="4"
                        <%= "4".equals(semester)
                            ? "selected"
                            : "" %>>
                        Semester 4
                    </option>

                    <option value="5"
                        <%= "5".equals(semester)
                            ? "selected"
                            : "" %>>
                        Semester 5
                    </option>

                    <option value="6"
                        <%= "6".equals(semester)
                            ? "selected"
                            : "" %>>
                        Semester 6
                    </option>

                    <option value="7"
                        <%= "7".equals(semester)
                            ? "selected"
                            : "" %>>
                        Semester 7
                    </option>

                    <option value="8"
                        <%= "8".equals(semester)
                            ? "selected"
                            : "" %>>
                        Semester 8
                    </option>

                </select>

            </div>



            <!-- =================================================
                 SECTION
                 ================================================= -->

            <div class="field">

                <label>
                    Section
                </label>

                <select
                    name="section"
                    id="section"
                >

                    <option value="ALL"
                        <%= "ALL".equals(section)
                            ? "selected"
                            : "" %>>
                        All Sections
                    </option>

                    <option value="A"
                        <%= "A".equals(section)
                            ? "selected"
                            : "" %>>
                        Section A
                    </option>

                    <option value="B"
                        <%= "B".equals(section)
                            ? "selected"
                            : "" %>>
                        Section B
                    </option>

                </select>

            </div>



            <!-- =================================================
                 ACADEMIC YEAR
                 ================================================= -->

            <div class="field">

                <label>
                    Academic Year
                </label>

                <select
                    name="academic_year"
                    id="academic_year"
                >

                    <option value="ALL"
                        <%= "ALL".equals(academicYear)
                            ? "selected"
                            : "" %>>
                        All Academic Years
                    </option>

                    <option value="2024-25"
                        <%= "2024-25".equals(academicYear)
                            ? "selected"
                            : "" %>>
                        2024-25
                    </option>

                    <option value="2025-26"
                        <%= "2025-26".equals(academicYear)
                            ? "selected"
                            : "" %>>
                        2025-26
                    </option>

                    <option value="2026-27"
                        <%= "2026-27".equals(academicYear)
                            ? "selected"
                            : "" %>>
                        2026-27
                    </option>

                    <option value="2027-28"
                        <%= "2027-28".equals(academicYear)
                            ? "selected"
                            : "" %>>
                        2027-28
                    </option>

                    <option value="2028-29"
                        <%= "2028-29".equals(academicYear)
                            ? "selected"
                            : "" %>>
                        2028-29
                    </option>

                    <option value="2029-30"
                        <%= "2029-30".equals(academicYear)
                            ? "selected"
                            : "" %>>
                        2029-30
                    </option>

                    <option value="2030-31"
                        <%= "2030-31".equals(academicYear)
                            ? "selected"
                            : "" %>>
                        2030-31
                    </option>

                    <option value="2031-32"
                        <%= "2031-32".equals(academicYear)
                            ? "selected"
                            : "" %>>
                        2031-32
                    </option>

                    <option value="2032-33"
                        <%= "2032-33".equals(academicYear)
                            ? "selected"
                            : "" %>>
                        2032-33
                    </option>

                    <option value="2033-34"
                        <%= "2033-34".equals(academicYear)
                            ? "selected"
                            : "" %>>
                        2033-34
                    </option>

                    <option value="2034-35"
                        <%= "2034-35".equals(academicYear)
                            ? "selected"
                            : "" %>>
                        2034-35
                    </option>

                </select>

            </div>



            <!-- =================================================
                 SUBJECT
                 ================================================= -->

            <div class="field">

                <label>
                    Subject
                </label>

                <select
                    name="subject"
                    id="subject"
                >

                    <option value="ALL">
                        All Subjects
                    </option>

<%
/* =========================================================
   LOAD SUBJECTS FOR SELECTED SEMESTER
   ========================================================= */

if (!"ALL".equals(semester)) {

    Connection subjectCon = null;
    PreparedStatement subjectPs = null;
    ResultSet subjectRs = null;

    try {

        subjectCon =
            Db.getConnection();

        subjectPs =
            subjectCon.prepareStatement(
                "SELECT subject_name " +
                "FROM subjects " +
                "WHERE semester=? " +
                "ORDER BY id"
            );

        subjectPs.setInt(
            1,
            Integer.parseInt(semester)
        );

        subjectRs =
            subjectPs.executeQuery();

        while (subjectRs.next()) {

            String sub =
                subjectRs.getString(
                    "subject_name"
                );

            boolean selected =
                sub.equals(subject);
%>

                    <option
                        value="<%= sub %>"
                        <%= selected
                            ? "selected"
                            : "" %>
                    >
                        <%= sub %>
                    </option>

<%
        }

    } catch (Exception e) {

        e.printStackTrace();

    } finally {

        try {
            if (subjectRs != null)
                subjectRs.close();
        } catch (Exception e) {}

        try {
            if (subjectPs != null)
                subjectPs.close();
        } catch (Exception e) {}

        try {
            if (subjectCon != null)
                subjectCon.close();
        } catch (Exception e) {}
    }
}
%>

                </select>

            </div>

        </div>


        <button
            type="submit"
            class="view-btn"
        >
            View Attendance
        </button>

    </form>

</div>



<%
/* =========================================================
   SHOW DATA ONLY AFTER VIEW ATTENDANCE IS CLICKED
   ========================================================= */

if ("1".equals(view)) {

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {

        con = Db.getConnection();


        /* =====================================================
           BASE QUERY

           IMPORTANT:
           attendance_date = TODAY ONLY
           ===================================================== */

        String sql =
            "SELECT " +
            "a.id, " +
            "a.attendance_date, " +
            "a.semester, " +
            "a.section, " +
            "a.academic_year, " +
            "a.reg_no, " +
            "s.name, " +
            "a.subject, " +
            "a.status " +
            "FROM attendance a " +
            "JOIN students s " +
            "ON a.reg_no=s.reg_no " +
            "WHERE a.attendance_date=?";


        /* =====================================================
           SEMESTER FILTER
           ===================================================== */

        if (!"ALL".equals(semester)) {

            sql +=
                " AND a.semester=?";

        }


        /* =====================================================
           SECTION FILTER
           ===================================================== */

        if (!"ALL".equals(section)) {

            sql +=
                " AND a.section=?";

        }


        /* =====================================================
           ACADEMIC YEAR FILTER
           ===================================================== */

        if (!"ALL".equals(academicYear)) {

            sql +=
                " AND a.academic_year=?";

        }


        /* =====================================================
           SUBJECT FILTER
           ===================================================== */

        if (!"ALL".equals(subject)) {

            sql +=
                " AND a.subject=?";

        }


        sql +=
            " ORDER BY " +
            "a.attendance_date DESC, " +
            "a.semester, " +
            "a.section, " +
            "a.reg_no, " +
            "a.subject";


        ps =
            con.prepareStatement(sql);


        int parameter = 1;


        /* TODAY ONLY */

        ps.setDate(
            parameter++,
            Date.valueOf(today)
        );


        /* SEMESTER */

        if (!"ALL".equals(semester)) {

            ps.setInt(
                parameter++,
                Integer.parseInt(semester)
            );

        }


        /* SECTION */

        if (!"ALL".equals(section)) {

            ps.setString(
                parameter++,
                section
            );

        }


        /* ACADEMIC YEAR */

        if (!"ALL".equals(academicYear)) {

            ps.setString(
                parameter++,
                academicYear
            );

        }


        /* SUBJECT */

        if (!"ALL".equals(subject)) {

            ps.setString(
                parameter++,
                subject
            );

        }


        rs =
            ps.executeQuery();


%>


<!-- =========================================================
     TODAY'S ATTENDANCE TABLE
     ========================================================= -->

<div class="table-card">

    <h2>
        Today's Attendance
    </h2>

    <div class="today-box">

        Date:
        <%= todayDate %>

        &nbsp; | &nbsp;

        Semester:
        <%= semester.equals("ALL")
            ? "All"
            : semester %>

        &nbsp; | &nbsp;

        Section:
        <%= section.equals("ALL")
            ? "All"
            : section %>

    </div>


    <table>

        <thead>

            <tr>

                <th>ID</th>

                <th>Date</th>

                <th>Semester</th>

                <th>Section</th>

                <th>Academic Year</th>

                <th>Student ID</th>

                <th>Student Name</th>

                <th>Subject</th>

                <th>Status</th>

                <th>Action</th>

            </tr>

        </thead>


        <tbody>

<%

boolean hasData = false;

while (rs.next()) {

    hasData = true;

    String status =
        rs.getString("status");

%>

            <tr>

                <td>
                    <%= rs.getInt("id") %>
                </td>

                <td>
                    <%= rs.getDate(
                        "attendance_date"
                    ) %>
                </td>

                <td>
                    <%= rs.getInt(
                        "semester"
                    ) %>
                </td>

                <td>
                    <%= rs.getString(
                        "section"
                    ) %>
                </td>

                <td>
                    <%= rs.getString(
                        "academic_year"
                    ) %>
                </td>

                <td>
                    <%= rs.getString(
                        "reg_no"
                    ) %>
                </td>

                <td>
                    <%= rs.getString(
                        "name"
                    ) %>
                </td>

                <td>
                    <%= rs.getString(
                        "subject"
                    ) %>
                </td>

                <td>

<%
if ("Present".equalsIgnoreCase(status)) {
%>

                    <span class="present">
                        Present
                    </span>

<%
} else {
%>

                    <span class="absent">
                        Absent
                    </span>

<%
}
%>

                </td>

                <td>

                    <button
                        type="button"
                        class="delete-btn"
                        onclick="confirmDelete(
                            '<%= rs.getInt("id") %>'
                        )"
                    >
                        Delete
                    </button>

                </td>

            </tr>

<%
}

if (!hasData) {
%>

            <tr>

                <td
                    colspan="10"
                    class="no-data"
                >
                    No attendance found for
                    <%= todayDate %>
                    with the selected filters.
                </td>

            </tr>

<%
}

%>

        </tbody>

    </table>

</div>


<%

    } catch (Exception e) {

%>

<div class="table-card">

    <div class="no-data">

        Database Error:

        <%= e.getMessage() %>

    </div>

</div>

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

}

%>


</div>

</body>

</html>