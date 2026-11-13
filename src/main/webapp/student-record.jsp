<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jspExample2.Db" %>

<%
if (session.getAttribute("role") == null ||
    !"STUDENT".equals(session.getAttribute("role"))) {

    response.sendRedirect("index.html");
    return;
}

String regNo =
    (String) session.getAttribute("reg_no");

String semester =
    request.getParameter("semester");

String subject =
    request.getParameter("subject");

String academicYear =
    request.getParameter("academic_year");

if (semester == null) semester = "";
if (subject == null) subject = "";
if (academicYear == null) academicYear = "";

semester = semester.trim();
subject = subject.trim();
academicYear = academicYear.trim();

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">

<title>Attendance Record</title>

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
    width: 95%;
    margin: 25px auto;
    background: white;
    padding: 25px;
    border-radius: 10px;
    box-shadow: 0 4px 15px rgba(0,0,0,.15);
}

h1 {
    text-align: center;
    color: #174c79;
}

.student-info {
    text-align: center;
    margin-bottom: 20px;
    font-size: 16px;
}

.filters {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    padding: 18px;
    background: #f4f7fa;
    border-radius: 8px;
}

select {
    padding: 10px;
    min-width: 180px;
    border: 1px solid #ccc;
    border-radius: 5px;
    font-size: 15px;
}

button {
    padding: 10px 18px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-size: 15px;
}

.search {
    background: #174c79;
    color: white;
}

.pdf {
    background: #b3261e;
    color: white;
}

.back {
    background: #555;
    color: white;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 25px;
}

th {
    background: #174c79;
    color: white;
    padding: 12px;
}

td {
    padding: 10px;
    border: 1px solid #ddd;
    text-align: center;
}

.present {
    color: green;
    font-weight: bold;
}

.absent {
    color: red;
    font-weight: bold;
}

.no-record {
    text-align: center;
    padding: 20px;
    color: #777;
}

@media print {

    body {
        background: white;
    }

    .filters,
    .no-print {
        display: none !important;
    }

    .container {
        width: 100%;
        margin: 0;
        box-shadow: none;
    }

}

</style>

<script>

function loadSubjects() {

    const semester =
        document.getElementById("semester").value;

    const subject =
        document.getElementById("subject");

    subject.innerHTML =
        '<option value="">Select Subject</option>';

    if (semester === "") {
        return;
    }

    fetch(
        "get-subjects.jsp?semester=" +
        encodeURIComponent(semester)
    )

    .then(response => response.json())

    .then(data => {

        data.forEach(function(item) {

            const option =
                document.createElement("option");

            option.value = item;
            option.textContent = item;

            subject.appendChild(option);

        });

    })

    .catch(error => {

        console.log(
            "Subject loading error:",
            error
        );

    });

}


function downloadPDF() {

    window.print();

}

</script>

</head>

<body>

<div class="container">

<h1>My Attendance Record</h1>


<div class="student-info">

    Student ID:
    <b><%=regNo%></b>

</div>


<form method="get">

<div class="filters">


<!-- =========================
     SEMESTER
     ========================= -->

<select
    name="semester"
    id="semester"
    onchange="loadSubjects()"
    required>

<option value="">
    Select Semester
</option>

<%
for (int i = 1; i <= 8; i++) {
%>

<option
    value="<%=i%>"
    <%=semester.equals(String.valueOf(i))
        ? "selected" : ""%>>

    Semester <%=i%>

</option>

<%
}
%>

</select>


<!-- =========================
     SUBJECT
     ========================= -->

<select
    name="subject"
    id="subject"
    required>

<option value="">
    Select Subject
</option>

<%
if (!semester.isEmpty()) {

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

%>

<option
    value="<%=sub%>"
    <%=sub.equals(subject)
        ? "selected" : ""%>>

    <%=sub%>

</option>

<%
        }

    } catch (Exception e) {

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


<!-- =========================
     ACADEMIC YEAR
     ========================= -->

<select
    name="academic_year"
    required>

<option value="">
    Select Academic Year
</option>

<%
for (int y = 2024; y <= 2034; y++) {

    String ay =
        y + "-" +
        String.valueOf(y + 1).substring(2);
%>

<option
    value="<%=ay%>"
    <%=ay.equals(academicYear)
        ? "selected" : ""%>>

    <%=ay%>

</option>

<%
}
%>

</select>


<!-- =========================
     VIEW RECORD
     ========================= -->

<button
    type="submit"
    class="search">

    View Record

</button>


<!-- =========================
     PDF
     ========================= -->

<button
    type="button"
    class="pdf"
    onclick="downloadPDF()">

    Download as PDF

</button>


</div>

</form>


<%
if (!semester.isEmpty() &&
    !subject.isEmpty() &&
    !academicYear.isEmpty()) {
%>


<h2 style="text-align:center; margin-top:30px;">

    <%=subject%>

</h2>


<p style="text-align:center;">

    Semester <b><%=semester%></b>
    |
    Academic Year <b><%=academicYear%></b>

</p>


<table>

<tr>

<th>S.No</th>

<th>Date</th>

<th>Subject</th>

<th>Status</th>

</tr>


<%

boolean hasRecord = false;

try {

    con =
        Db.getConnection();

    /*
     * Section is NOT used here.
     *
     * Student's own reg_no uniquely identifies
     * the student's attendance.
     */

    ps =
        con.prepareStatement(

            "SELECT " +
            "attendance_date, " +
            "subject, " +
            "status " +

            "FROM attendance " +

            "WHERE reg_no=? " +
            "AND semester=? " +
            "AND subject=? " +
            "AND academic_year=? " +

            "ORDER BY attendance_date"
        );


    ps.setString(
        1,
        regNo
    );

    ps.setInt(
        2,
        Integer.parseInt(semester)
    );

    ps.setString(
        3,
        subject
    );

    ps.setString(
        4,
        academicYear
    );


    rs =
        ps.executeQuery();


    int count = 1;


    while (rs.next()) {

        hasRecord = true;

        String status =
            rs.getString("status");

%>

<tr>

<td>
    <%=count++%>
</td>

<td>
    <%=rs.getDate("attendance_date")%>
</td>

<td>
    <%=rs.getString("subject")%>
</td>

<td
    class="<%=

        "Present".equals(status)
        ? "present"

        : "Absent".equals(status)
        ? "absent"

        : ""

    %>">

    <%=status%>

</td>

</tr>

<%
    }


    if (!hasRecord) {
%>

<tr>

<td
    colspan="4"
    class="no-record">

    No attendance records found.

</td>

</tr>

<%
    }


} catch (Exception e) {
%>

<tr>

<td
    colspan="4"
    class="no-record">

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

</table>


<%
}
%>


<br>


<div class="no-print">

<button
    class="back"
    onclick="location.href='student-dashboard.jsp'">

    Back to Dashboard

</button>

</div>


</div>

</body>

</html>