<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jspExample2.Db" %>

<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

String semester =
    request.getParameter("semester");

if (semester == null ||
    semester.trim().equals("")) {

    out.print("[]");
    return;
}

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {

    con = Db.getConnection();

    ps = con.prepareStatement(
        "SELECT subject_name " +
        "FROM subjects " +
        "WHERE semester=? " +
        "ORDER BY id"
    );

    ps.setInt(
        1,
        Integer.parseInt(
            semester.trim()
        )
    );

    rs = ps.executeQuery();

    StringBuilder json =
        new StringBuilder();

    json.append("[");

    boolean first = true;

    while (rs.next()) {

        if (!first) {
            json.append(",");
        }

        String subject =
            rs.getString(
                "subject_name"
            );

        if (subject == null) {
            subject = "";
        }

        subject =
            subject
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\r", "")
            .replace("\n", "\\n");

        json.append("\"")
            .append(subject)
            .append("\"");

        first = false;
    }

    json.append("]");

    out.print(
        json.toString()
    );

} catch (Exception e) {

    String error =
        e.getMessage();

    if (error == null) {
        error = "Unknown database error";
    }

    error =
        error
        .replace("\\", "\\\\")
        .replace("\"", "\\\"")
        .replace("\r", "")
        .replace("\n", " ");

    out.print(
        "[{\"error\":\"" +
        error +
        "\"}]"
    );

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