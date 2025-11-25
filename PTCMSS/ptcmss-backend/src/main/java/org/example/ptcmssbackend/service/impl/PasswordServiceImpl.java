package org.example.ptcmssbackend.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.ptcmssbackend.common.TokenType;
import org.example.ptcmssbackend.entity.Users;
import org.example.ptcmssbackend.enums.UserStatus;
import org.example.ptcmssbackend.repository.UsersRepository;
import org.example.ptcmssbackend.service.PasswordService;
import org.example.ptcmssbackend.service.JwtService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class PasswordServiceImpl implements PasswordService {

    private final UsersRepository usersRepository;
    private final JwtService jwtService;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    public String showSetPasswordPage(String token) {
        Users user = resolveUserFromToken(token);
        return (user == null) ? "Liên kết không hợp lệ hoặc đã hết hạn!" : null;
    }

    @Override
    @Transactional
    public String setNewPassword(String token, String password, String confirmPassword) {
        Users user = resolveUserFromToken(token);
        if (user == null) return "Liên kết không hợp lệ hoặc đã hết hạn!";
        if (!password.equals(confirmPassword)) return "Mật khẩu xác nhận không khớp!";

        log.info("🔑 Cập nhật mật khẩu cho user: {}", user.getUsername());
        user.setPasswordHash(passwordEncoder.encode(password));
        user.setVerificationToken(null);
        user.setStatus(UserStatus.ACTIVE);
        Users savedUser = usersRepository.save(user);
        log.info("✅ Mật khẩu mới (đã mã hóa): {}", savedUser.getPasswordHash());

        return "Mật khẩu đã được thiết lập thành công! Bạn có thể đăng nhập.";
    }

    private Users resolveUserFromToken(String token) {
        try {
            String username = jwtService.extractUsername(token, TokenType.ACCESS_TOKEN);
            if (!org.springframework.util.StringUtils.hasText(username)) {
                log.warn("Password reset token did not contain username");
                return null;
            }
            return usersRepository.findByUsername(username).orElse(null);
        } catch (Exception e) {
            log.error("Failed to resolve user from password reset token: {}", e.getMessage());
            return null;
        }
    }
}
