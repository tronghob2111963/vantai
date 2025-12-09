package org.example.ptcmssbackend.integration;

import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;
import org.example.ptcmssbackend.config.IntegrationTestConfiguration;

@SpringBootTest
@ActiveProfiles("test")
@Import(IntegrationTestConfiguration.class)
@Transactional
public abstract class BaseIntegrationTest {
}

