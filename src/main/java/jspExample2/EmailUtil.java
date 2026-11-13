package jspExample2;

import java.security.SecureRandom;

public class EmailUtil {

    private static final SecureRandom random =
            new SecureRandom();

    public static String generateOTP() {

        int otp = 100000 + random.nextInt(900000);

        return String.valueOf(otp);
    }
}