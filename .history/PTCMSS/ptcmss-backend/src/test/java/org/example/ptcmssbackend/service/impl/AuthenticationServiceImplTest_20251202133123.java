package org.example.ptcmssbackend.service.impl;

import org.example.ptcmssbackend.BaseTest;
import org.example.ptcmssbackend.dto.request.Auth.LoginRequest;
import org.example.ptcmssbackend.dto.response.Auth.TokenResponse;
import org.example.ptcmssbackend.entity.Branches;
import org.example.ptcmssbackend.entity.Roles;
import org.example.ptcmssbackend.entity.Users;
import org.example.ptcmssbackend.enums.UserStatus;
import org.example.ptcmssbackend.exception.BadRequestException;
import org.example.ptcmssbackend.repository.UserRepository;
import org.example.ptcmssbackend.service.JwtService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

class AuthenticationServiceImplTest extends BaseTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private JwtService jwtService;

    @InjectMocks
    private AuthenticationServiceImpl authenticationService;

    private Users testUser;
    private LoginRequest loginRequest;
    private BCryptPasswordEncoder passwordEncoder;

    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();
        passwordEncoder = new BCryptPasswordEncoder();
        
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
        testUser.setPassword(passwordEncoder.encode("password123"));
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
        when(userRepository.findByUsername("admin")).thenReturn(Optional.of(testUser));
        when(jwtService.generateAccessToken(anyInt(), anyString(), any())).thenReturn("access_token");
        when(jwtService.generateRefreshToken(anyInt(), anyString(), any())).thenReturn("refresh_token");

        // When
        TokenResponse response = authenticationService.getAccessToken(loginRequest);

        // Then
        assertNotNull(response);
        assertEquals("access_token", response.getAccessToken());
        assertEquals("refresh_token", response.getRefreshToken());
        assertEquals(1, response.getUserId());
        assertEquals("admin", response.getUsername());
        assertEquals("ADMIN", response.getRole());
        
        verify(userRepository, times(1)).findByUsername("admin");
        verify(jwtService, times(1)).generateAccessToken(anyInt(), anyString(), any());
        verify(jwtService, times(1)).generateRefreshToken(anyInt(), anyString(), any());
    }

    @Test
    void getAccessToken_UserNotFound_ThrowsException() {
        // Given
        when(userRepository.findByUsername("admin")).thenReturn(Optional.empty());

        // When & Then
        BadRequestException exception = assertThrows(BadRequestException.class, () -> {
            authenticationService.getAccessToken(loginRequest);
        });

        assertEquals("Tài khoản hoặc mật khẩu không đúng", exception.getMessage());
        verify(userRepository, times(1)).findByUsername("admin");
        verify(jwtService, never()).generateAccessToken(anyInt(), anyString(), any());
    }

    @Test
    void getAccessToken_WrongPassword_ThrowsException() {
        // Given
        loginRequest.setPassword("wrongpassword");
        when(userRepository.findByUsername("admin")).thenReturn(Optional.of(testUser));

        // When & Then
        BadRequestException exception = assertThrows(BadRequestException.class, () -> {
            authenticationService.getAccessToken(loginRequest);
        });

        assertEquals("Tài khoản hoặc mật khẩu không đúng", exception.getMessage());
        verify(jwtService, never()).generateAccessToken(anyInt(), anyString(), any());
    }

    @Test
    void getAccessToken_InactiveUser_ThrowsException() {
        // Given
        testUser.setStatus(UserStatus.INACTIVE);
        when(userRepository.findByUsername("admin")).thenReturn(Optional.of(testUser));

        // When & Then
        BadRequestException exception = assertThrows(BadRequestException.class, () -> {
            authenticationService.getAccessToken(loginRequest);
        });

        assertEquals("Tài khoản đã bị khóa", exception.getMessage());
    }

    @Test
    void getRefreshToken_Success() {
        // Given
        String refreshToken = "valid_refresh_token";
        when(jwtService.extractUsername(refreshToken, JwtServiceImpl.TokenType.REFRESH_TOKEN))
            .thenReturn("admin");
        when(userRepository.findByUsername("admin")).thenReturn(Optional.of(testUser));
        when(jwtService.generateAccessToken(anyInt(), anyString(), any())).thenReturn("new_access_token");

        // When
        TokenResponse response = authenticationService.getRefreshToken(refreshToken);

        // Then
        assertNotNull(response);
        assertEquals("new_access_token", response.getAccessToken());
        assertEquals("admin", response.getUsername());
        
        verify(jwtService, times(1)).extractUsername(refreshToken, JwtServiceImpl.TokenType.REFRESH_TOKEN);
        verify(jwtService, times(1)).generateAccessToken(anyInt(), anyString(), any());
    }

    @Test
    void getRefreshToken_EmptyToken_ThrowsException() {
        // When & Then
        BadRequestException exception = assertThrows(BadRequestException.class, () -> {
            authenticationService.getRefreshToken("");
        });

        assertEquals("Refresh token is required", exception.getMessage());
    }
}
