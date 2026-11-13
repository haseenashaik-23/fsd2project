package jspExample2;

import java.sql.Connection;
import java.sql.DriverManager;

public class Db {

    private static final String URL =
        "jdbc:mysql://localhost:3306/attendance_db"
        + "?useSSL=false"
        + "&serverTimezone=Asia/Kolkata"
        + "&allowPublicKeyRetrieval=true";

    private static final String USER = "root";

    private static final String PASSWORD = "Haseena@2026";

    public static Connection getConnection() throws Exception {

        Class.forName("com.mysql.cj.jdbc.Driver");

        return DriverManager.getConnection(
            URL,
            USER,
            PASSWORD
        );
    }
}