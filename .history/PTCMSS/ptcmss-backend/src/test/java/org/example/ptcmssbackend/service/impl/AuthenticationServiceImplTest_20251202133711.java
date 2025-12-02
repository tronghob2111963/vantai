package org.example.ptcmssbackend.service.impl;

import org.example.ptcmssbackend.BaseTest;
import org.example.ptcmssbackend.dto.request.Auth.LoginRequest;
import org.example.ptcmssbackend.dto.response.Auth.TokenResponse;
import org.example.ptcmssbackend.entity.Branches;
import org.example.ptcmssbackend.entity.Roles;
import org.example.ptcmssbackend.entity.Users;
import org.example.ptcmssbackend.enums.UserStatus;
import org.example.ptcmssbackend.exception.InvalidDataException;
import org.example.ptcmssbackend.repository.UsersRepository;
import org.example.ptcmssbackend.service.JwtService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class AuthenticationServiceImplTest extends BaseTest {

    @Mock
    private UsersRepository userRepository;

    @Mock
    private AuthenticationManager authenticationManager;

    @Mock
    private JwtService jwtService;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private AuthenticationServiceImpl authenticationService;

    private Users testUser;
    private LoginRequest loginRequest;

    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();
        
        // Setup test user
        Roles role = new Roles();
        role.setId(1);
        role.setRoleName("ADMIN");

        Branches branch = new Branches();
        branch.setId(1);
        branch.setBranchName("HCM Branch");

        testUser = new Users();
        testUser.setId(1);
        testUser.setUsername("admin");
        testUser.setPassword("encodedPassword");
        testUser.setEmail("admin@ptcmss.com");
        testUser.setFullName("Admin User");
        testUser.setStatus(UserStatus.ACTIVE);
        testUser.setRole(role);
        testUser.setBranch(branch);

        loginRequest = new LoginRequest();
        loginRequest.setUsername("admin");
        loginRequest.setPassword("password123");
    }

    @Test
    void getAccessToken_Success() {
        // Given
        Authentication authentication = mock(Authentication.class);
        when(authentication.getPrincipal()).thenReturn(testUser);
        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
            .thenReturn(authentication);
        when(jwtService.generateAccessToken(anyInt(), anyString(), any())).thenReturn("access_token");
        when(jwtService.generateRefreshToken(anyInt(), anyString(), any())).thenReturn("refresh_token");

        // When
        TokenResponse response = authenticationService.getAccessToken(loginRequest);

        // Then
        assertNotNull(response);
        assertEquals("access_token", response.getAccessToken());
        assertEquals("refresh_token", response.getRefreshToken());
        
        verify(authenticationManager, times(1)).authenticate(any(UsernamePasswordAuthenticationToken.class));
        verify(jwtService, times(1)).generateAccessToken(anyInt(), anyString(), any());
    }

    @Test
    void getAccessToken_InvalidCredentials_ThrowsException() {
        // Given
        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
            .thenThrow(new org.springframework.security.core.AuthenticationException("Bad credentials") {});

        // When & Then
        assertThrows(Exception.class, () -> {
            authenticationService.getAccessToken(loginRequest);
        });

        verify(jwtService, never()).generateAccessToken(anyInt(), anyString(), any());
    }
}
