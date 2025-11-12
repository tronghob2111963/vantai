package org.example.ptcmssbackend.controller;

import lombok.RequiredArgsConstructor;
import org.example.ptcmssbackend.entity.Users;
import org.example.ptcmssbackend.repository.UsersRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/test")
@RequiredArgsConstructor
public class TestController {

    private final UsersRepository usersRepository;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    /**
     * Endpoint để generate BCrypt hash cho password
     * PUBLIC - không cần authentication
     */
    @GetMapping("/generate-hash")
    public ResponseEntity<Map<String, String>> generateHash(@RequestParam String password) {
        String hash = passwordEncoder.encode(password);
        
        Map<String, String> response = new HashMap<>();
        response.put("password", password);
        response.put("hash", hash);
        response.put("sql", "UPDATE Users SET passwordHash = '" + hash + "' WHERE username = 'your_username';");
        
        return ResponseEntity.ok(response);
    }

    /**
     * Endpoint để test password hash với user trong DB
     * PUBLIC - không cần authentication
     */
    @GetMapping("/test-password")
    public ResponseEntity<Map<String, Object>> testPassword(
            @RequestParam String username,
            @RequestParam String password) {
        
        Map<String, Object> response = new HashMap<>();
        
        Users user = usersRepository.findByUsername(username).orElse(null);
        
        if (user == null) {
            response.put("error", "User not found");
            return ResponseEntity.ok(response);
        }
        
        String dbHash = user.getPasswordHash();
        boolean matches = passwordEncoder.matches(password, dbHash);
        
        response.put("username", username);
        response.put("password", password);
        response.put("dbHash", dbHash);
        response.put("matches", matches);
        response.put("status", user.getStatus().toString());
        response.put("isEnabled", user.isEnabled());
        
        if (!matches) {
            // Generate hash mới
            String newHash = passwordEncoder.encode(password);
            response.put("newHash", newHash);
            response.put("sqlUpdate", "UPDATE Users SET passwordHash = '" + newHash + "' WHERE username = '" + username + "';");
        }
        
        return ResponseEntity.ok(response);
    }

    /**
     * Endpoint để test authentication và authorities
     * Cần authentication
     */
    @GetMapping("/auth-info")
    public ResponseEntity<Map<String, Object>> getAuthInfo() {
        Map<String, Object> response = new HashMap<>();
        
        var auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        
        if (auth == null) {
            response.put("error", "No authentication found");
            return ResponseEntity.ok(response);
        }
        
        response.put("authenticated", auth.isAuthenticated());
        response.put("principal", auth.getPrincipal().getClass().getSimpleName());
        response.put("authorities", auth.getAuthorities().stream()
                .map(org.springframework.security.core.GrantedAuthority::getAuthority)
                .toList());
        response.put("name", auth.getName());
        
        if (auth.getPrincipal() instanceof org.example.ptcmssbackend.entity.Users) {
            var user = (org.example.ptcmssbackend.entity.Users) auth.getPrincipal();
            response.put("userId", user.getId());
            response.put("username", user.getUsername());
            response.put("role", user.getRole() != null ? user.getRole().getRoleName() : null);
        }
        
        return ResponseEntity.ok(response);
    }
}

