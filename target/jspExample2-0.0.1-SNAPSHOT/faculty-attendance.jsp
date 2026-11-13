<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="jspExample2.Db" %>

<%
/* =========================================================
   FACULTY SESSION CHECK
   ========================================================= */

String username =
    (String) session.getAttribute("username");

String role =
    (String) session.getAttribute("role");

if (username == null ||
    !"FACULTY".equalsIgnoreCase(role)) {

    response.sendRedirect("index.html");
    return;
}


/* =========================================================
   VARIABLES
   ========================================================= */

String message = "";
String errorMessage = "";

String selectedSemester =
    request.getParameter("semester");

String selectedSection =
    request.getParameter("section");

String selectedAcademicYear =
    request.getParameter("academic_year");

String selectedSubject =
    request.getParameter("subject");

String selectedDate =
    request.getParameter("attendance_date");

String action =
    request.getParameter("action");

if (selectedSemester == null)
    selectedSemester = "";

if (selectedSection == null)
    selectedSection = "";

if (selectedAcademicYear == null)
    selectedAcademicYear = "";

if (selectedSubject == null)
    selectedSubject = "";

if (selectedDate == null)
    selectedDate = "";

if (action == null)
    action = "";


/* =========================================================
   CURRENT DATE
   ========================================================= */

LocalDate today =
    LocalDate.now();

LocalDate previousDay1 =
    today.minusDays(1);

LocalDate previousDay2 =
    today.minusDays(2);

DateTimeFormatter dateFormatter =
    DateTimeFormatter.ofPattern("yyyy-MM-dd");


/* =========================================================
   INSERT / UPDATE ATTENDANCE
   ========================================================= */

if ("insert".equalsIgnoreCase(action) ||
    "update".equalsIgnoreCase(action)) {

    String semester =
        request.getParameter("semester");

    String section =
        request.getParameter("section");

    String academicYear =
        request.getParameter("academic_year");

    String subject =
        request.getParameter("subject");

    String attendanceDate =
        request.getParameter("attendance_date");

    String[] studentIds =
        request.getParameterValues("student_ids");


    /* -----------------------------------------------------
       BASIC VALIDATION
       ----------------------------------------------------- */

    if (semester == null ||
        section == null ||
        academicYear == null ||
        subject == null ||
        attendanceDate == null ||
        studentIds == null ||
        semester.trim().equals("") ||
        section.trim().equals("") ||
        academicYear.trim().equals("") ||
        subject.trim().equals("") ||
        attendanceDate.trim().equals("") ||
        studentIds.length == 0) {

        errorMessage =
            "Please select all attendance details and load students.";

    } else {

        try {

            LocalDate selectedLocalDate =
                LocalDate.parse(attendanceDate);


            /* -------------------------------------------------
               DATE VALIDATION
               Only today and previous 2 days
               ------------------------------------------------- */

            if (selectedLocalDate.isBefore(previousDay2) ||
                selectedLocalDate.isAfter(today)) {

                errorMessage =
                    "Attendance can be entered or updated only for today and the previous 2 days.";

            } else {


                Connection con =
                    null;

                PreparedStatement ps =
                    null;


                try {

                    con =
                        Db.getConnection();


                    /* =========================================
                       INSERT
                       ========================================= */

                    if ("insert".equalsIgnoreCase(action)) {

                        ps =
                            con.prepareStatement(
                                "INSERT INTO attendance " +
                                "(semester, section, academic_year, " +
                                "reg_no, subject, attendance_date, status) " +
                                "VALUES (?, ?, ?, ?, ?, ?, ?)"
                            );


                        int inserted =
                            0;


                        for (String regNo : studentIds) {

                            if (regNo == null ||
                                regNo.trim().equals("")) {

                                continue;
                            }


                            /*
                             * CHECKBOX:
                             *
                             * checked   = Present
                             * unchecked = Absent
                             */

                            String parameterName =
                                "status_" + regNo;

                            String status =
                                request.getParameter(
                                    parameterName
                                );


                            if (status != null &&
                                status.equals("Present")) {

                                status = "Present";

                            } else {

                                status = "Absent";
                            }


                            ps.setInt(
                                1,
                                Integer.parseInt(
                                    semester
                                )
                            );

                            ps.setString(
                                2,
                                section
                            );

                            ps.setString(
                                3,
                                academicYear
                            );

                            ps.setString(
                                4,
                                regNo
                            );

                            ps.setString(
                                5,
                                subject
                            );

                            ps.setDate(
                                6,
                                Date.valueOf(
                                    selectedLocalDate
                                )
                            );

                            ps.setString(
                                7,
                                status
                            );


                            try {

                                ps.executeUpdate();

                                inserted++;

                            } catch (SQLIntegrityConstraintViolationException ex) {

                                /*
                                 * If attendance already exists,
                                 * don't stop the complete process.
                                 */

                            }
                        }


                        message =
                            inserted
                            + " student attendance records inserted successfully.";
                    }


                    /* =========================================
                       UPDATE
                       ========================================= */

                    else if ("update".equalsIgnoreCase(action)) {

                        ps =
                            con.prepareStatement(
                                "UPDATE attendance " +
                                "SET status=? " +
                                "WHERE semester=? " +
                                "AND section=? " +
                                "AND academic_year=? " +
                                "AND reg_no=? " +
                                "AND subject=? " +
                                "AND attendance_date=?"
                            );


                        int updated =
                            0;


                        for (String regNo : studentIds) {

                            if (regNo == null ||
                                regNo.trim().equals("")) {

                                continue;
                            }


                            /*
                             * CHECKBOX:
                             *
                             * checked   = Present
                             * unchecked = Absent
                             */

                            String parameterName =
                                "status_" + regNo;

                            String status =
                                request.getParameter(
                                    parameterName
                                );


                            if (status != null &&
                                status.equals("Present")) {

                                status = "Present";

                            } else {

                                status = "Absent";
                            }


                            ps.setString(
                                1,
                                status
                            );

                            ps.setInt(
                                2,
                                Integer.parseInt(
                                    semester
                                )
                            );

                            ps.setString(
                                3,
                                section
                            );

                            ps.setString(
                                4,
                                academicYear
                            );

                            ps.setString(
                                5,
                                regNo
                            );

                            ps.setString(
                                6,
                                subject
                            );

                            ps.setDate(
                                7,
                                Date.valueOf(
                                    selectedLocalDate
                                )
                            );


                            updated +=
                                ps.executeUpdate();
                        }


                        message =
                            updated
                            + " student attendance records updated successfully.";
                    }


                } finally {

                    try {

                        if (ps != null)
                            ps.close();

                    } catch (Exception e) {
                    }


                    try {

                        if (con != null)
                            con.close();

                    } catch (Exception e) {
                    }
                }
            }

        } catch (Exception e) {

            errorMessage =
                "Database Error: "
                + e.getMessage();
        }
    }
}


/* =========================================================
   LOAD STUDENTS
   ========================================================= */

String[] studentRegNos = null;
String[] studentNames = null;

String[] existingStatuses = null;

int studentCount = 0;


boolean loadStudents =
    request.getParameter("load") != null;


if (loadStudents) {

    try {

        Connection con =
            Db.getConnection();


        PreparedStatement ps =
            con.prepareStatement(
                "SELECT reg_no, name " +
                "FROM students " +
                "WHERE section=? " +
                "ORDER BY reg_no"
            );


        ps.setString(
            1,
            selectedSection
        );


        ResultSet rs =
            ps.executeQuery();


        java.util.ArrayList<String> regList =
            new java.util.ArrayList<String>();

        java.util.ArrayList<String> nameList =
            new java.util.ArrayList<String>();


        while (rs.next()) {

            regList.add(
                rs.getString("reg_no")
            );

            nameList.add(
                rs.getString("name")
            );
        }


        studentCount =
            regList.size();


        studentRegNos =
            regList.toArray(
                new String[0]
            );

        studentNames =
            nameList.toArray(
                new String[0]
            );


        rs.close();
        ps.close();
        con.close();


        /* =========================================
           GET EXISTING ATTENDANCE
           ========================================= */

        existingStatuses =
            new String[studentCount];


        for (int i = 0;
             i < studentCount;
             i++) {

            existingStatuses[i] =
                "";
        }


        if (!selectedSemester.equals("") &&
            !selectedAcademicYear.equals("") &&
            !selectedSubject.equals("") &&
            !selectedDate.equals("")) {


            Connection con2 =
                Db.getConnection();


            PreparedStatement ps2 =
                con2.prepareStatement(
                    "SELECT reg_no, status " +
                    "FROM attendance " +
                    "WHERE semester=? " +
                    "AND section=? " +
                    "AND academic_year=? " +
                    "AND subject=? " +
                    "AND attendance_date=?"
                );


            ps2.setInt(
                1,
                Integer.parseInt(
                    selectedSemester
                )
            );

            ps2.setString(
                2,
                selectedSection
            );

            ps2.setString(
                3,
                selectedAcademicYear
            );

            ps2.setString(
                4,
                selectedSubject
            );

            ps2.setDate(
                5,
                Date.valueOf(
                    selectedDate
                )
            );


            ResultSet rs2 =
                ps2.executeQuery();


            while (rs2.next()) {

                String regNo =
                    rs2.getString("reg_no");

                String status =
                    rs2.getString("status");


                for (int i = 0;
                     i < studentCount;
                     i++) {

                    if (studentRegNos[i]
                            .equals(regNo)) {

                        existingStatuses[i] =
                            status;

                        break;
                    }
                }
            }


            rs2.close();
            ps2.close();
            con2.close();
        }


    } catch (Exception e) {

        errorMessage =
            "Student Loading Error: "
            + e.getMessage();
    }
}

%>


<!DOCTYPE html>

<html>

<head>

<meta charset="UTF-8">

<title>Mark Attendance</title>


<style>

* {
    box-sizing: border-box;
}


body {

    margin: 0;

    font-family:
        Arial,
        Helvetica,
        sans-serif;

    background: #f1f5f9;

    color: #222;
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

    font-size: 24px;
}


.header-right a {

    color: white;

    text-decoration: none;

    margin-left: 20px;

    font-weight: bold;
}


.container {

    width: 95%;

    max-width: 1200px;

    margin: 25px auto;
}


.card {

    background: white;

    border-radius: 10px;

    padding: 25px;

    margin-bottom: 20px;

    box-shadow:
        0 3px 12px
        rgba(0,0,0,0.10);
}


.card h2 {

    color: #174c79;

    margin-top: 0;
}


.message {

    background: #dff5e5;

    color: #176b2c;

    padding: 14px;

    border-radius: 6px;

    margin-bottom: 20px;

    font-weight: bold;
}


.error {

    background: #ffe0e0;

    color: #b00000;

    padding: 14px;

    border-radius: 6px;

    margin-bottom: 20px;

    font-weight: bold;
}


.form-grid {

    display: grid;

    grid-template-columns:
        repeat(3, 1fr);

    gap: 18px;
}


.form-group {

    display: flex;

    flex-direction: column;
}


.form-group label {

    font-weight: bold;

    margin-bottom: 7px;

    color: #333;
}


.form-group select,
.form-group input {

    padding: 11px;

    border: 1px solid #bbb;

    border-radius: 5px;

    font-size: 15px;

    background: white;
}


.load-btn {

    margin-top: 20px;

    background: #174c79;

    color: white;

    border: none;

    padding: 12px 25px;

    border-radius: 6px;

    font-size: 16px;

    font-weight: bold;

    cursor: pointer;
}


.load-btn:hover {

    background: #0d3c61;
}


.attendance-header {

    display: flex;

    justify-content: space-between;

    align-items: center;

    margin-bottom: 15px;
}


.attendance-header h2 {

    margin: 0;
}


.select-all-box {

    background: #eef6fb;

    border: 1px solid #b8d8ea;

    padding: 12px 15px;

    border-radius: 6px;

    font-weight: bold;
}


table {

    width: 100%;

    border-collapse: collapse;

    margin-top: 15px;
}


th {

    background: #174c79;

    color: white;

    padding: 13px;

    text-align: left;
}


td {

    padding: 12px;

    border-bottom:
        1px solid #ddd;
}


tr:hover {

    background: #f7fbff;
}


.status-checkbox {

    width: 22px;

    height: 22px;

    cursor: pointer;

    accent-color: #28a745;
}


.present-text {

    color: #16833c;

    font-weight: bold;

    margin-left: 8px;
}


.absent-text {

    color: #c00000;

    font-weight: bold;

    margin-left: 8px;
}


.action-buttons {

    display: flex;

    gap: 15px;

    margin-top: 20px;
}


.insert-btn {

    background: #1688bd;

    color: white;

    border: none;

    padding: 13px 25px;

    border-radius: 6px;

    font-size: 16px;

    font-weight: bold;

    cursor: pointer;
}


.update-btn {

    background: #28a745;

    color: white;

    border: none;

    padding: 13px 25px;

    border-radius: 6px;

    font-size: 16px;

    font-weight: bold;

    cursor: pointer;
}


.insert-btn:hover {

    background: #0d6f9d;
}


.update-btn:hover {

    background: #218838;
}


.no-students {

    text-align: center;

    padding: 25px;

    color: #777;
}


@media(max-width: 800px) {

    .form-grid {

        grid-template-columns: 1fr;
    }

    .attendance-header {

        flex-direction: column;

        align-items: flex-start;

        gap: 15px;
    }

    .action-buttons {

        flex-direction: column;
    }

    .insert-btn,
    .update-btn {

        width: 100%;
    }
}

</style>


<script>

/* =========================================================
   LOAD SUBJECTS BY SEMESTER
   ========================================================= */

function loadSubjects() {

    var semester =
        document.getElementById(
            "semester"
        ).value;

    var subject =
        document.getElementById(
            "subject"
        );


    subject.innerHTML =
        '<option value="">Loading...</option>';


    if (semester === "") {

        subject.innerHTML =
            '<option value="">Select Subject</option>';

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
            '<option value="">Select Subject</option>';


        data.forEach(function(item) {

            if (item.error) {
                return;
            }


            var option =
                document.createElement(
                    "option"
                );

            option.value =
                item;

            option.textContent =
                item;


            subject.appendChild(
                option
            );


            <% if (selectedSubject != null &&
                   !selectedSubject.equals("")) { %>

                if (item ===
                    "<%= selectedSubject.replace("\\","\\\\").replace("\"","\\\"") %>") {

                    option.selected = true;
                }

            <% } %>

        });

    })

    .catch(function(error) {

        subject.innerHTML =
            '<option value="">Unable to load subjects</option>';

    });
}


/* =========================================================
   SELECT ALL
   ========================================================= */

function selectAllStudents(source) {

    var checkboxes =
        document.querySelectorAll(
            ".student-checkbox"
        );


    checkboxes.forEach(
        function(checkbox) {

            checkbox.checked =
                source.checked;

            updateStatusText(
                checkbox
            );
        }
    );
}


/* =========================================================
   INDIVIDUAL STATUS TEXT
   ========================================================= */

function updateStatusText(checkbox) {

    var text =
        checkbox.parentElement
        .querySelector(".status-text");


    if (!text) {
        return;
    }


    if (checkbox.checked) {

        text.textContent =
            "Present";

        text.className =
            "status-text present-text";

    } else {

        text.textContent =
            "Absent";

        text.className =
            "status-text absent-text";
    }
}


/* =========================================================
   CHECK ALL STATE
   ========================================================= */

function updateSelectAll() {

    var checkboxes =
        document.querySelectorAll(
            ".student-checkbox"
        );

    var selectAll =
        document.getElementById(
            "selectAll"
        );


    if (checkboxes.length === 0) {
        return;
    }


    var checkedCount = 0;


    checkboxes.forEach(
        function(checkbox) {

            if (checkbox.checked) {
                checkedCount++;
            }
        }
    );


    selectAll.checked =
        checkedCount ===
        checkboxes.length;
}


/* =========================================================
   PAGE LOAD
   ========================================================= */

window.onload = function() {

    var semester =
        document.getElementById(
            "semester"
        );


    if (semester.value !== "") {

        loadSubjects();
    }


    var checkboxes =
        document.querySelectorAll(
            ".student-checkbox"
        );


    checkboxes.forEach(
        function(checkbox) {

            updateStatusText(
                checkbox
            );

            checkbox.addEventListener(
                "change",
                function() {

                    updateStatusText(
                        checkbox
                    );

                    updateSelectAll();

                }
            );
        }
    );
};

</script>

</head>


<body>


<!-- =====================================================
     HEADER
===================================================== -->

<div class="header">

    <h1>
        Faculty Attendance
    </h1>

    <div class="header-right">

        <a href="faculty-dashboard.jsp">
            Dashboard
        </a>

        <a href="logout.jsp">
            Logout
        </a>

    </div>

</div>


<div class="container">


    <!-- =================================================
         MESSAGES
    ================================================== -->

    <% if (!message.equals("")) { %>

        <div class="message">

            <%= message %>

        </div>

    <% } %>


    <% if (!errorMessage.equals("")) { %>

        <div class="error">

            <%= errorMessage %>

        </div>

    <% } %>


    <!-- =================================================
         ATTENDANCE DETAILS
    ================================================== -->

    <div class="card">

        <h2>
            Mark Attendance
        </h2>


        <form
            action="faculty-attendance.jsp"
            method="get"
        >

            <div class="form-grid">


                <!-- SEMESTER -->

                <div class="form-group">

                    <label>
                        Semester
                    </label>

                    <select
                        name="semester"
                        id="semester"
                        onchange="loadSubjects()"
                        required
                    >

                        <option value="">
                            Select Semester
                        </option>

                        <option
                            value="1"
                            <%= "1".equals(selectedSemester)
                                ? "selected" : "" %>
                        >
                            Semester 1
                        </option>

                        <option
                            value="2"
                            <%= "2".equals(selectedSemester)
                                ? "selected" : "" %>
                        >
                            Semester 2
                        </option>

                        <option
                            value="3"
                            <%= "3".equals(selectedSemester)
                                ? "selected" : "" %>
                        >
                            Semester 3
                        </option>

                        <option
                            value="4"
                            <%= "4".equals(selectedSemester)
                                ? "selected" : "" %>
                        >
                            Semester 4
                        </option>

                        <option
                            value="5"
                            <%= "5".equals(selectedSemester)
                                ? "selected" : "" %>
                        >
                            Semester 5
                        </option>

                        <option
                            value="6"
                            <%= "6".equals(selectedSemester)
                                ? "selected" : "" %>
                        >
                            Semester 6
                        </option>

                        <option
                            value="7"
                            <%= "7".equals(selectedSemester)
                                ? "selected" : "" %>
                        >
                            Semester 7
                        </option>

                        <option
                            value="8"
                            <%= "8".equals(selectedSemester)
                                ? "selected" : "" %>
                        >
                            Semester 8
                        </option>

                    </select>

                </div>


                <!-- SECTION -->

                <div class="form-group">

                    <label>
                        Section
                    </label>

                    <select
                        name="section"
                        required
                    >

                        <option value="">
                            Select Section
                        </option>

                        <option
                            value="A"
                            <%= "A".equals(selectedSection)
                                ? "selected" : "" %>
                        >
                            A
                        </option>

                        <option
                            value="B"
                            <%= "B".equals(selectedSection)
                                ? "selected" : "" %>
                        >
                            B
                        </option>

                    </select>

                </div>


                <!-- ACADEMIC YEAR -->

                <div class="form-group">

                    <label>
                        Academic Year
                    </label>

                    <select
                        name="academic_year"
                        required
                    >

                        <option value="">
                            Select Academic Year
                        </option>

                        <option
                            value="2024-25"
                            <%= "2024-25".equals(selectedAcademicYear)
                                ? "selected" : "" %>
                        >
                            2024-25
                        </option>

                        <option
                            value="2025-26"
                            <%= "2025-26".equals(selectedAcademicYear)
                                ? "selected" : "" %>
                        >
                            2025-26
                        </option>

                        <option
                            value="2026-27"
                            <%= "2026-27".equals(selectedAcademicYear)
                                ? "selected" : "" %>
                        >
                            2026-27
                        </option>

                        <option
                            value="2027-28"
                            <%= "2027-28".equals(selectedAcademicYear)
                                ? "selected" : "" %>
                        >
                            2027-28
                        </option>

                        <option
                            value="2028-29"
                            <%= "2028-29".equals(selectedAcademicYear)
                                ? "selected" : "" %>
                        >
                            2028-29
                        </option>

                        <option
                            value="2029-30"
                            <%= "2029-30".equals(selectedAcademicYear)
                                ? "selected" : "" %>
                        >
                            2029-30
                        </option>

                        <option
                            value="2030-31"
                            <%= "2030-31".equals(selectedAcademicYear)
                                ? "selected" : "" %>
                        >
                            2030-31
                        </option>

                        <option
                            value="2031-32"
                            <%= "2031-32".equals(selectedAcademicYear)
                                ? "selected" : "" %>
                        >
                            2031-32
                        </option>

                        <option
                            value="2032-33"
                            <%= "2032-33".equals(selectedAcademicYear)
                                ? "selected" : "" %>
                        >
                            2032-33
                        </option>

                        <option
                            value="2033-34"
                            <%= "2033-34".equals(selectedAcademicYear)
                                ? "selected" : "" %>
                        >
                            2033-34
                        </option>

                        <option
                            value="2034-35"
                            <%= "2034-35".equals(selectedAcademicYear)
                                ? "selected" : "" %>
                        >
                            2034-35
                        </option>

                    </select>

                </div>


                <!-- SUBJECT -->

                <div class="form-group">

                    <label>
                        Subject
                    </label>

                    <select
                        name="subject"
                        id="subject"
                        required
                    >

                        <option value="">
                            Select Subject
                        </option>

                    </select>

                </div>


                <!-- DATE -->

                <div class="form-group">

                    <label>
                        Attendance Date
                    </label>

                    <input
                        type="date"
                        name="attendance_date"
                        value="<%= selectedDate %>"
                        min="<%= previousDay2.format(dateFormatter) %>"
                        max="<%= today.format(dateFormatter) %>"
                        required
                    >

                </div>


            </div>


            <button
                type="submit"
                name="load"
                value="1"
                class="load-btn"
            >

                Load Students

            </button>

        </form>

    </div>


    <!-- =================================================
         STUDENT LIST
    ================================================== -->

    <% if (loadStudents &&
           studentCount > 0) { %>


        <div class="card">


            <div class="attendance-header">

                <h2>
                    Student Attendance
                </h2>


                <!-- ONLY SELECT ALL -->
                <div class="select-all-box">

                    <label>

                        <input
                            type="checkbox"
                            id="selectAll"
                            onchange="selectAllStudents(this)"
                        >

                        Select All Students

                    </label>

                </div>

            </div>


            <!-- ATTENDANCE FORM -->

            <form
                action="faculty-attendance.jsp"
                method="post"
            >


                <!-- Hidden values -->

                <input
                    type="hidden"
                    name="semester"
                    value="<%= selectedSemester %>"
                >

                <input
                    type="hidden"
                    name="section"
                    value="<%= selectedSection %>"
                >

                <input
                    type="hidden"
                    name="academic_year"
                    value="<%= selectedAcademicYear %>"
                >

                <input
                    type="hidden"
                    name="subject"
                    value="<%= selectedSubject %>"
                >

                <input
                    type="hidden"
                    name="attendance_date"
                    value="<%= selectedDate %>"
                >


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
                                Student Name
                            </th>

                            <th>
                                Attendance
                            </th>

                        </tr>

                    </thead>


                    <tbody>


                    <%
                    for (int i = 0;
                         i < studentCount;
                         i++) {

                        String regNo =
                            studentRegNos[i];

                        String studentName =
                            studentNames[i];

                        String existingStatus =
                            existingStatuses[i];


                        /*
                         * Existing Present =
                         * checked
                         *
                         * Existing Absent =
                         * unchecked
                         */

                        boolean checked =
                            "Present".equalsIgnoreCase(
                                existingStatus
                            );
                    %>


                        <tr>


                            <td>
                                <%= i + 1 %>
                            </td>


                            <td>

                                <%= regNo %>

                                <!--
                                   Hidden student ID
                                -->

                                <input
                                    type="hidden"
                                    name="student_ids"
                                    value="<%= regNo %>"
                                >

                            </td>


                            <td>
                                <%= studentName %>
                            </td>


                            <td>


                                <!--
                                   CHECKED =
                                   PRESENT

                                   UNCHECKED =
                                   ABSENT
                                -->

                                <label>

                                    <input
                                        type="checkbox"
                                        class="student-checkbox"
                                        name="status_<%= regNo %>"
                                        value="Present"
                                        <%= checked ? "checked" : "" %>
                                    >


                                    <span
                                        class="status-text"
                                    >
                                    </span>

                                </label>


                            </td>


                        </tr>


                    <%
                    }
                    %>


                    </tbody>

                </table>


                <!-- ACTION BUTTONS -->

                <div class="action-buttons">


                    <button
                        type="submit"
                        name="action"
                        value="insert"
                        class="insert-btn"
                    >

                        Save Attendance

                    </button>


                    <button
                        type="submit"
                        name="action"
                        value="update"
                        class="update-btn"
                    >

                        Update Attendance

                    </button>


                </div>


            </form>


        </div>


    <% } else if (loadStudents &&
                  studentCount == 0) { %>


        <div class="card">

            <div class="no-students">

                No students found for
                Section
                <b><%= selectedSection %></b>.

            </div>

        </div>


    <% } %>


</div>


</body>

</html>