package com.github.leeonky.dal.extensions;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.leeonky.dal.DAL;
import com.github.leeonky.dal.runtime.Extension;
import lombok.SneakyThrows;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.*;

import static com.github.leeonky.dal.Assertions.expect;
import static org.assertj.core.api.Assertions.assertThat;

public class TokenExtension implements Extension {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    private static final TypeReference<Map<String, Object>> MAP_TYPE = new TypeReference<Map<String, Object>>() {
    };
    private static final List<String> USER_FIELDS = Arrays.asList("user_id", "user_name", "user_num", "user_role", "tenant_id");

    @Override
    public void extend(DAL dal) {
        dal.getRuntimeContextBuilder().registerStaticMethodExtension(TokenExtension.class);
    }

    public static Map<String, Object> decrypt(String token) {
        String[] segments = token.split("\\.");
        expect(verifySignature(segments[0] + "." + segments[1], segments[2])).should("= true");
        return normalizeUserClaim(decodeTokenSegment(segments[1]));
    }

    @SneakyThrows
    private static Map<String, Object> decodeTokenSegment(String segment) {
        return OBJECT_MAPPER.readValue(Base64.getUrlDecoder().decode(segment), MAP_TYPE);
    }

    private static boolean verifySignature(String signingInput, String signature) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(tokenSigningKey().getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            String expected = Base64.getUrlEncoder()
                    .withoutPadding()
                    .encodeToString(mac.doFinal(signingInput.getBytes(StandardCharsets.UTF_8)));
            return expected.equals(signature);
        } catch (Exception e) {
            throw new IllegalStateException("verify jwt signature failed", e);
        }
    }

    private static Map<String, Object> normalizeUserClaim(Map<String, Object> payload) {
        Map<String, Object> user = payload.entrySet().stream()
                .filter(entry -> !Arrays.asList("iss", "aud", "exp").contains(entry.getKey()))
                .filter(entry -> !("sid".equals(entry.getKey()) || entry.getKey().endsWith("/sid")))
                .map(Map.Entry::getValue)
                .map(TokenExtension::asMap)
                .filter(Objects::nonNull)
                .filter(candidate -> candidate.keySet().containsAll(USER_FIELDS))
                .findFirst()
                .orElseThrow(() -> new AssertionError("missing user claim"));

        assertThat(user.keySet()).containsExactlyInAnyOrderElementsOf(USER_FIELDS);
        Map<String, Object> normalized = new LinkedHashMap<>();
        USER_FIELDS.forEach(field -> normalized.put(field, user.get(field)));
        return normalized;
    }

    @SneakyThrows
    private static Map<String, Object> asMap(Object value) {
        if (value instanceof Map) {
            return (Map<String, Object>) value;
        }
        if (value instanceof String) {
            String stringValue = ((String) value).trim();
            if (stringValue.startsWith("{") && stringValue.endsWith("}")) {
                return OBJECT_MAPPER.readValue(stringValue, MAP_TYPE);
            }
        }
        return null;
    }

    private static String tokenSigningKey() {
        String property = System.getProperty("TESTCHARM_TOKEN_SIGNING_KEY");
        if (property != null && !property.isEmpty()) {
            return property;
        }
        String environment = System.getenv("TESTCHARM_TOKEN_SIGNING_KEY");
        if (environment != null && !environment.isEmpty()) {
            return environment;
        }
        return "ModernWMS_SigningKey";
    }

}
