package dev.matheuscruz.infra.security;

import java.security.SecureRandom;
import java.util.Base64;
import java.util.Map;
import java.util.Set;
import org.eclipse.microprofile.config.spi.ConfigSource;

/**
 * Supplies a random AES key as SECURITY_KEY for tests, so no key needs to be committed. A real SECURITY_KEY environment
 * variable still wins because of the low ordinal.
 */
public class RandomSecurityKeyConfigSource implements ConfigSource {

    private static final String SECURITY_KEY = "SECURITY_KEY";
    private static final String VALUE = generate();

    private static String generate() {
        byte[] key = new byte[16];
        new SecureRandom().nextBytes(key);
        return Base64.getEncoder().encodeToString(key);
    }

    @Override
    public Set<String> getPropertyNames() {
        return Set.of(SECURITY_KEY);
    }

    @Override
    public Map<String, String> getProperties() {
        return Map.of(SECURITY_KEY, VALUE);
    }

    @Override
    public String getValue(String propertyName) {
        return SECURITY_KEY.equals(propertyName) ? VALUE : null;
    }

    @Override
    public String getName() {
        return RandomSecurityKeyConfigSource.class.getSimpleName();
    }

    @Override
    public int getOrdinal() {
        return 50;
    }
}
