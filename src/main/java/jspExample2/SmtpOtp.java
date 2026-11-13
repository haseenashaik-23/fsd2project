package jspExample2;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;

public class SmtpOtp {

    private static final String SMTP_HOST =
            "smtp.gmail.com";

    private static final int SMTP_PORT =
            465;

    /*
     * Gmail account used to SEND OTP
     */
    private static final String FROM_EMAIL =
            "mediboyanasrisatyaganesh@gmail.com";

    /*
     * IMPORTANT:
     * Put your 16-character Gmail App Password here.
     *
     * Example:
     * abcdefghijklmnop
     */
    private static final String APP_PASSWORD =
            "YOUR_16_DIGIT_GMAIL_APP_PASSWORD";


    /*
     * Generate 6 digit OTP
     */
    public static String generateOTP() {

        SecureRandom random =
                new SecureRandom();

        int number =
                random.nextInt(1000000);

        return String.format(
                "%06d",
                number
        );
    }


    /*
     * Send OTP through Gmail SMTP
     */
    public static boolean sendOTP(
            String receiverEmail,
            String otp) {

        SSLSocket socket = null;

        BufferedReader reader = null;

        BufferedWriter writer = null;

        try {

            System.out.println(
                    "=============================="
            );

            System.out.println(
                    "SMTP OTP PROCESS START"
            );

            System.out.println(
                    "Sender : " + FROM_EMAIL
            );

            System.out.println(
                    "Receiver : " + receiverEmail
            );


            /*
             * Create SSL connection
             * Gmail SMTP SSL = port 465
             */
            SSLSocketFactory factory =
                    (SSLSocketFactory)
                    SSLSocketFactory.getDefault();


            socket =
                    (SSLSocket)
                    factory.createSocket(
                            SMTP_HOST,
                            SMTP_PORT
                    );


            socket.setSoTimeout(20000);

            socket.startHandshake();


            System.out.println(
                    "SSL connection successful."
            );


            /*
             * Input
             */
            reader =
                    new BufferedReader(
                            new InputStreamReader(
                                    socket.getInputStream(),
                                    StandardCharsets.UTF_8
                            )
                    );


            /*
             * Output
             */
            writer =
                    new BufferedWriter(
                            new OutputStreamWriter(
                                    socket.getOutputStream(),
                                    StandardCharsets.UTF_8
                            )
                    );


            /*
             * Gmail welcome message
             */
            String response =
                    readResponse(reader);


            if (!response.startsWith("220")) {

                System.out.println(
                        "ERROR: Gmail SMTP server error."
                );

                return false;
            }


            /*
             * EHLO
             */
            sendCommand(
                    writer,
                    "EHLO localhost"
            );


            response =
                    readResponse(reader);


            if (!response.startsWith("250")) {

                System.out.println(
                        "ERROR: EHLO failed."
                );

                return false;
            }


            /*
             * AUTH LOGIN
             */
            sendCommand(
                    writer,
                    "AUTH LOGIN"
            );


            response =
                    readResponse(reader);


            if (!response.startsWith("334")) {

                System.out.println(
                        "ERROR: AUTH LOGIN failed."
                );

                return false;
            }


            /*
             * Gmail email
             */
            String encodedEmail =
                    Base64.getEncoder()
                            .encodeToString(
                                    FROM_EMAIL.getBytes(
                                            StandardCharsets.UTF_8
                                    )
                            );


            sendCommand(
                    writer,
                    encodedEmail
            );


            response =
                    readResponse(reader);


            if (!response.startsWith("334")) {

                System.out.println(
                        "ERROR: Gmail username rejected."
                );

                return false;
            }


            /*
             * Gmail App Password
             */
            String cleanPassword =
                    APP_PASSWORD
                            .replace(" ", "")
                            .trim();


            String encodedPassword =
                    Base64.getEncoder()
                            .encodeToString(
                                    cleanPassword.getBytes(
                                            StandardCharsets.UTF_8
                                    )
                            );


            sendCommand(
                    writer,
                    encodedPassword
            );


            response =
                    readResponse(reader);


            System.out.println(
                    "Authentication response: "
                    + response
            );


            /*
             * 235 = Authentication successful
             */
            if (!response.startsWith("235")) {

                System.out.println(
                        "ERROR: Gmail authentication failed."
                );

                System.out.println(
                        "Check your Gmail App Password."
                );

                return false;
            }


            System.out.println(
                    "Gmail authentication successful."
            );


            /*
             * MAIL FROM
             */
            sendCommand(
                    writer,
                    "MAIL FROM:<"
                    + FROM_EMAIL
                    + ">"
            );


            response =
                    readResponse(reader);


            if (!response.startsWith("250")) {

                System.out.println(
                        "ERROR: MAIL FROM failed."
                );

                return false;
            }


            /*
             * RECEIVER
             */
            sendCommand(
                    writer,
                    "RCPT TO:<"
                    + receiverEmail
                    + ">"
            );


            response =
                    readResponse(reader);


            if (!response.startsWith("250")) {

                System.out.println(
                        "ERROR: Receiver email rejected."
                );

                return false;
            }


            /*
             * DATA
             */
            sendCommand(
                    writer,
                    "DATA"
            );


            response =
                    readResponse(reader);


            if (!response.startsWith("354")) {

                System.out.println(
                        "ERROR: DATA command failed."
                );

                return false;
            }


            /*
             * Email headers
             */
            writer.write(
                    "From: SmartAttendance <"
                    + FROM_EMAIL
                    + ">\r\n"
            );

            writer.write(
                    "To: <"
                    + receiverEmail
                    + ">\r\n"
            );

            writer.write(
                    "Subject: SmartAttendance Faculty OTP\r\n"
            );

            writer.write(
                    "MIME-Version: 1.0\r\n"
            );

            writer.write(
                    "Content-Type: text/plain; charset=UTF-8\r\n"
            );

            writer.write(
                    "\r\n"
            );


            /*
             * Email body
             */
            writer.write(
                    "Dear Faculty,\r\n"
            );

            writer.write(
                    "\r\n"
            );

            writer.write(
                    "Your SmartAttendance login OTP is:\r\n"
            );

            writer.write(
                    "\r\n"
            );

            writer.write(
                    otp
            );

            writer.write(
                    "\r\n"
            );

            writer.write(
                    "\r\n"
            );

            writer.write(
                    "This OTP is valid for 5 minutes.\r\n"
            );

            writer.write(
                    "Please do not share this OTP with anyone.\r\n"
            );

            writer.write(
                    "\r\n"
            );

            writer.write(
                    "Regards,\r\n"
            );

            writer.write(
                    "SmartAttendance System\r\n"
            );


            /*
             * End email
             */
            writer.write(
                    ".\r\n"
            );

            writer.flush();


            /*
             * Gmail response
             */
            response =
                    readResponse(reader);


            if (!response.startsWith("250")) {

                System.out.println(
                        "ERROR: Gmail did not accept email."
                );

                return false;
            }


            System.out.println(
                    "OTP EMAIL SENT SUCCESSFULLY."
            );


            /*
             * QUIT
             */
            sendCommand(
                    writer,
                    "QUIT"
            );


            readResponse(reader);


            System.out.println(
                    "SMTP OTP PROCESS END"
            );

            System.out.println(
                    "=============================="
            );


            return true;


        } catch (Exception e) {

            System.out.println(
                    "=============================="
            );

            System.out.println(
                    "SMTP ERROR"
            );

            System.out.println(
                    "=============================="
            );

            e.printStackTrace();

            return false;


        } finally {

            try {

                if (reader != null) {
                    reader.close();
                }

            } catch (Exception e) {
            }


            try {

                if (writer != null) {
                    writer.close();
                }

            } catch (Exception e) {
            }


            try {

                if (socket != null) {
                    socket.close();
                }

            } catch (Exception e) {
            }
        }
    }


    /*
     * Send SMTP command
     */
    private static void sendCommand(
            BufferedWriter writer,
            String command)
            throws Exception {

        System.out.println(
                "CLIENT: " + command
        );

        writer.write(command);

        writer.write("\r\n");

        writer.flush();
    }


    /*
     * Read SMTP response
     */
    private static String readResponse(
            BufferedReader reader)
            throws Exception {

        String line;

        String response = "";


        do {

            line =
                    reader.readLine();


            if (line == null) {

                throw new Exception(
                        "Gmail closed the connection."
                );
            }


            System.out.println(
                    "SERVER: " + line
            );


            response = line;


        } while (
                line.length() >= 4
                && line.charAt(3) == '-'
        );


        return response;
    }
}