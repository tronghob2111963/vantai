package org.example.ptcmssbackend.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.ptcmssbackend.entity.Users;
import org.example.ptcmssbackend.enums.UserStatus;
import org.example.ptcmssbackend.repository.UsersRepository;
import org.example.ptcmssbackend.service.EmailService;
import org.example.ptcmssbackend.service.VerificationService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.io.UnsupportedEncodingException;
import java.util.Random;
import jakarta.mail.MessagingException;

@Slf4j(topic = "VERIFICATION_SERVICE")
@Service
@RequiredArgsConstructor
public class VerificationServiceImpl implements VerificationService {

    private final UsersRepository usersRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;

    @Override
    @Transactional
    public String verifyAccount(String token) {
        log.info("🔍 Xác thực tài khoản với token: {}", token);

        Users user = usersRepository.findByVerificationToken(token).orElse(null);
        if (user == null) {
            log.warn("❌ Token không hợp lệ hoặc đã hết hạn: {}", token);
            return "❌ Liên kết xác thực không hợp lệ hoặc đã hết hạn. Vui lòng liên hệ quản trị viên để được hỗ trợ.";
        }

        // Nếu user đã được xác thực rồi
        if (Boolean.TRUE.equals(user.getEmailVerified())) {
            log.info("⚠️ User {} đã xác thực trước đó.", user.getUsername());
            return "ℹ️ Tài khoản của bạn đã được xác thực trước đó. Bạn có thể đăng nhập vào hệ thống hoặc thiết lập lại mật khẩu nếu cần.";
        }

        // ✅ Tạo password tự động khi user verify email
        String generatedPassword = generateRandomPassword(12);
        String hashedPassword = passwordEncoder.encode(generatedPassword);
        
        // ✅ Đánh dấu email đã xác thực và lưu password
        user.setEmailVerified(true);
        user.setStatus(UserStatus.ACTIVE);
        user.setPasswordHash(hashedPassword);
        // ⚠️ KHÔNG gọi user.setVerificationToken(null); - giữ lại để có thể dùng cho reset password sau này
        usersRepository.save(user);

        log.info("✅ Tài khoản {} đã xác thực thành công. Password đã được tạo.", user.getUsername());
        
        // Gửi email chứa username và password
        try {
            String baseUrl = ServletUriComponentsBuilder.fromCurrentContextPath().build().toUriString();
            emailService.sendCredentialsEmail(
                    user.getEmail(),
                    user.getFullName(),
                    user.getUsername(),
                    generatedPassword,
                    baseUrl
            );
            log.info("✅ Credentials email sent successfully to {}", user.getEmail());
        } catch (MessagingException | UnsupportedEncodingException e) {
            log.error("❌ Failed to send credentials email: {}", e.getMessage(), e);
            // Không throw exception - user đã được verify thành công
        }
        
        return "✅ Xác thực thành công! Thông tin đăng nhập (username và password) đã được gửi đến email của bạn. Vui lòng kiểm tra email để đăng nhập vào hệ thống.";
    }
    
    /**
     * Tạo password ngẫu nhiên
     */
    private String generateRandomPassword(int length) {
        String upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        String lowerCase = "abcdefghijklmnopqrstuvwxyz";
        String numbers = "0123456789";
        String specialChars = "!@#$%^&*";
        String allChars = upperCase + lowerCase + numbers + specialChars;
        
        Random random = new Random();
        StringBuilder password = new StringBuilder();
        
        // Đảm bảo có ít nhất 1 ký tự từ mỗi loại
        password.append(upperCase.charAt(random.nextInt(upperCase.length())));
        password.append(lowerCase.charAt(random.nextInt(lowerCase.length())));
        password.append(numbers.charAt(random.nextInt(numbers.length())));
        password.append(specialChars.charAt(random.nextInt(specialChars.length())));
        
        // Điền phần còn lại
        for (int i = password.length(); i < length; i++) {
            password.append(allChars.charAt(random.nextInt(allChars.length())));
        }
        
        // Xáo trộn các ký tự
        char[] passwordArray = password.toString().toCharArray();
        for (int i = passwordArray.length - 1; i > 0; i--) {
            int j = random.nextInt(i + 1);
            char temp = passwordArray[i];
            passwordArray[i] = passwordArray[j];
            passwordArray[j] = temp;
        }
        
        return new String(passwordArray);
    }
}
