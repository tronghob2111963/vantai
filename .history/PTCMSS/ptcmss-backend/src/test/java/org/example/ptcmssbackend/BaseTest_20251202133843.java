package org.example.ptcmssbackend;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

/**
 * Base test class với common setup
 * Extends class này để sử dụng Mockito và Spring Boot test context
 */
@ExtendWith(MockitoExtension.class)
@ActiveProfiles("test")
public abstract class BaseTest {

    @BeforeEach
    public void setUp() {
        // Common setup nếu cần
    }
}
