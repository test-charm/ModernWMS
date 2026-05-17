package org.testcharm;

import lombok.SneakyThrows;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

public final class TestConstants {
    public static final long LOGIN_TENANT_ID = 9001L;
    public static final String LOGIN_ROLE_NAME = "e2e-login-role";
    public static final String TEST_CREATOR = "e2e-tests";

    private TestConstants() {
    }

    @SneakyThrows
    public static String md5(String value) {
        MessageDigest messageDigest = MessageDigest.getInstance("MD5");
        byte[] digest = messageDigest.digest(value.getBytes(StandardCharsets.UTF_8));
        StringBuilder builder = new StringBuilder();
        for (byte current : digest) {
            builder.append(String.format("%02x", current));
        }
        return builder.toString();
    }
}
