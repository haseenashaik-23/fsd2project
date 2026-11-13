package jspExample2;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;

public class GmailSender {

    private static final String FROM_EMAIL =
            "mediboyanasrisatyaganesh@gmail.com";

    private static final String APP_PASSWORD =
            "YOUR_16_DIGIT_APP_PASSWORD";

    private static final String TO_EMAIL =
            "mediboyanasrisatyaganesh@gmail.com";


    public static void sendOTP(
            String facultyId,
            String otp) throws Exception {

        System.out.println("Starting Gmail SMTP...");

        SSLSocketFactory factory =
                (SSLSocketFactory)
                SSLSocketFactory.getDefault();

        SSLSocket socket =
                (SSLSocket) factory.createSocket(
                        "smtp.gmail.com",
                        465
                );

        socket.setSoTimeout(20000);

        BufferedReader in =
                new BufferedReader(
                        new InputStreamReader(
                                socket.getInputStream(),
                                StandardCharsets.UTF_8
                        )
                );

        OutputStream out =
                socket.getOutputStream();


        readResponse(in);


        send(out, "EHLO localhost");
        readResponse(in);


        send(out, "AUTH LOGIN");
        readResponse(in);


        String encodedEmail =
                Base64.getEncoder().encodeToString(
                        FROM_EMAIL.getBytes(
                                StandardCharsets.UTF_8
                        )
                );

        send(out, encodedEmail);
        readResponse(in);


        String encodedPassword =
                Base64.getEncoder().encodeToString(
                        APP_PASSWORD.getBytes(
                                StandardCharsets.UTF_8
                        )
                );

        send(out, encodedPassword);
        readResponse(in);


        send(
            out,
            "MAIL FROM:<" +
            FROM_EMAIL +
            ">"
        );

        readResponse(in);


        send(
            out,
            "RCPT TO:<" +
            TO_EMAIL +
            ">"
        );

        readResponse(in);


        send(out, "DATA");
        readResponse(in);


        String message =
                "From: " + FROM_EMAIL + "\r\n" +
                "To: " + TO_EMAIL + "\r\n" +
                "Subject: Faculty Login OTP\r\n" +
                "MIME-Version: 1.0\r\n" +
                "Content-Type: text/plain; charset=UTF-8\r\n" +
                "\r\n" +
                "Smart Student Management and Attendance Portal\r\n" +
                "\r\n" +
                "Faculty ID: " + facultyId + "\r\n" +
                "\r\n" +
                "Your OTP is: " + otp + "\r\n" +
                "\r\n" +
                "OTP validity: 5 minutes.\r\n" +
                "\r\n" +
                "Do not share this OTP with anyone.\r\n" +
                "\r\n" +
                ".\r\n";


        out.write(
                message.getBytes(
                        StandardCharsets.UTF_8
                )
        );

        out.flush();

        readResponse(in);


        send(out, "QUIT");
        readResponse(in);

        socket.close();

        System.out.println(
                "OTP email sent successfully."
        );
    }


    private static void send(
            OutputStream out,
            String text) throws Exception {

        out.write(
                (text + "\r\n")
                .getBytes(
                        StandardCharsets.UTF_8
                )
        );

        out.flush();
    }


    private static String readResponse(
            BufferedReader in) throws Exception {

        String response =
                in.readLine();

        System.out.println(
                "GMAIL: " + response
        );

        if (response == null) {

            throw new Exception(
                "Gmail closed the connection."
            );
        }

        return response;
    }
}