package org.example.ptcmssbackend.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.ptcmssbackend.entity.Users;
import org.example.ptcmssbackend.enums.UserStatus;
import org.example.ptcmssbackend.repository.UsersRepository;
import org.example.ptcmssbackend.service.VerificationService;
import org.example.ptcmssbackend.service.EmailService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;

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
            return "ℹ️ Tài khoản của bạn đã được xác thực trước đó. Bạn có thể đăng nhập vào hệ thống.";
        }

        // ✅ Tạo mật khẩu tự động
        String generatedPassword = generateRandomPassword();
        log.info("🔑 Generated password for user {}: {}", user.getUsername(), generatedPassword);
        
        // Cập nhật user
        user.setEmailVerified(true);
        user.setStatus(UserStatus.ACTIVE);
        user.setPasswordHash(passwordEncoder.encode(generatedPassword));
        user.setVerificationToken(null); // Xóa token sau khi verify
        usersRepository.save(user);

        // Gửi email chứa password
        try {
            sendPasswordEmail(user.getEmail(), user.getFullName(), user.getUsername(), generatedPassword);
            log.info("✉️ Password email sent to: {}", user.getEmail());
        } catch (Exception e) {
            log.error("❌ Failed to send password email: {}", e.getMessage());
            // Không throw exception - user vẫn được kích hoạt
        }

        log.info("✅ Tài khoản {} đã xác thực thành công và mật khẩu đã được gửi qua email.", user.getUsername());
        return "✅ Xác thực thành công! Mật khẩu đăng nhập đã được gửi đến email của bạn. Vui lòng kiểm tra hộp thư.";
    }
    
    /**
     * Tạo mật khẩu ngẫu nhiên an toàn
     * Format: 8 ký tự gồm chữ hoa, chữ thường, số và ký tự đặc biệt
     */
    private String generateRandomPassword() {
        String upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        String lowerCase = "abcdefghijklmnopqrstuvwxyz";
        String digits = "0123456789";
        String special = "@#$%";
        String allChars = upperCase + lowerCase + digits + special;
        
        SecureRandom random = new SecureRandom();
        StringBuilder password = new StringBuilder(8);
        
        // Đảm bảo có ít nhất 1 ký tự mỗi loại
        password.append(upperCase.charAt(random.nextInt(upperCase.length())));
        password.append(lowerCase.charAt(random.nextInt(lowerCase.length())));
        password.append(digits.charAt(random.nextInt(digits.length())));
        password.append(special.charAt(random.nextInt(special.length())));
        
        // Thêm 4 ký tự ngẫu nhiên nữa
        for (int i = 0; i < 4; i++) {
            password.append(allChars.charAt(random.nextInt(allChars.length())));
        }
        
        // Shuffle để không có pattern cố định
        char[] passwordArray = password.toString().toCharArray();
        for (int i = passwordArray.length - 1; i > 0; i--) {
            int j = random.nextInt(i + 1);
            char temp = passwordArray[i];
            passwordArray[i] = passwordArray[j];
            passwordArray[j] = temp;
        }
        
        return new String(passwordArray);
    }
    
    /**
     * Gửi email chứa mật khẩu
     */
    private void sendPasswordEmail(String toEmail, String fullName, String username, String password) {
        try {
            String subject = "Thông tin đăng nhập hệ thống TranspoManager";
            String htmlContent = buildPasswordEmailHtml(fullName, username, password);
            
            emailService.sendSimpleEmail(toEmail, subject, htmlContent);
        } catch (Exception e) {
            log.error("Failed to send password email", e);
            throw new RuntimeException("Failed to send password email: " + e.getMessage());
        }
    }
    
    /**
     * Tạo HTML email chứa mật khẩu - Professional design
     */
    private String buildPasswordEmailHtml(String fullName, String username, String password) {
        return "<!DOCTYPE html>" +
                "<html>" +
                "<head>" +
                "<meta charset='UTF-8'>" +
                "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
                "</head>" +
                "<body style='margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, sans-serif; background-color: #f4f4f4;'>" +
                "<table width='100%' cellpadding='0' cellspacing='0' style='background-color: #f4f4f4; padding: 40px 0;'>" +
                "<tr>" +
                "<td align='center'>" +
                "<table width='600' cellpadding='0' cellspacing='0' style='background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);'>" +
                
                "<!-- Header -->" +
                "<tr>" +
                "<td style='background: linear-gradient(135deg, #0079BC 0%, #005a8f 100%); padding: 30px; text-align: center;'>" +
                "<h1 style='margin: 0; color: #ffffff; font-size: 24px; font-weight: 600;'>TranspoManager</h1>" +
                "<p style='margin: 8px 0 0 0; color: #e3f2fd; font-size: 14px;'>Hệ thống quản lý vận tải</p>" +
                "</td>" +
                "</tr>" +
                
                "<!-- Content -->" +
                "<tr>" +
                "<td style='padding: 40px 30px;'>" +
                "<h2 style='margin: 0 0 20px 0; color: #333333; font-size: 20px; font-weight: 600;'>Chào mừng đến với TranspoManager</h2>" +
                "<p style='margin: 0 0 20px 0; color: #666666; font-size: 15px; line-height: 1.6;'>Kính gửi <strong>" + fullName + "</strong>,</p>" +
                "<p style='margin: 0 0 30px 0; color: #666666; font-size: 15px; line-height: 1.6;'>Tài khoản của bạn đã được kích hoạt thành công. Dưới đây là thông tin đăng nhập của bạn:</p>" +
                
                "<!-- Credentials Box -->" +
                "<table width='100%' cellpadding='0' cellspacing='0' style='background-color: #f8f9fa; border: 1px solid #e0e0e0; border-radius: 6px; margin-bottom: 30px;'>" +
                "<tr>" +
                "<td style='padding: 25px;'>" +
                "<table width='100%' cellpadding='0' cellspacing='0'>" +
                "<tr>" +
                "<td style='padding-bottom: 15px;'>" +
                "<p style='margin: 0; color: #888888; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;'>Tên đăng nhập</p>" +
                "<p style='margin: 5px 0 0 0; color: #333333; font-size: 16px; font-weight: 600;'>" + username + "</p>" +
                "</td>" +
                "</tr>" +
                "<tr>" +
                "<td style='border-top: 1px solid #e0e0e0; padding-top: 15px;'>" +
                "<p style='margin: 0; color: #888888; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;'>Mật khẩu</p>" +
                "<p style='margin: 5px 0 0 0; color: #d32f2f; font-size: 20px; font-weight: 700; letter-spacing: 2px; font-family: \"Courier New\", monospace;'>" + password + "</p>" +
                "</td>" +
                "</tr>" +
                "</table>" +
                "</td>" +
                "</tr>" +
                "</table>" +
                
                "<!-- Login Button -->" +
                "<table width='100%' cellpadding='0' cellspacing='0' style='margin-bottom: 30px;'>" +
                "<tr>" +
                "<td align='center'>" +
                "<a href='http://localhost:5173/login' style='display: inline-block; padding: 14px 40px; background-color: #0079BC; color: #ffffff; text-decoration: none; border-radius: 6px; font-size: 15px; font-weight: 600;'>Đăng nhập ngay</a>" +
                "</td>" +
                "</tr>" +
                "</table>" +
                
                "<!-- Security Notice -->" +
                "<table width='100%' cellpadding='0' cellspacing='0' style='background-color: #fff3cd; border-left: 4px solid #ffc107; border-radius: 4px; margin-bottom: 20px;'>" +
                "<tr>" +
                "<td style='padding: 20px;'>" +
                "<p style='margin: 0 0 10px 0; color: #856404; font-size: 14px; font-weight: 600;'>Lưu ý bảo mật</p>" +
                "<ul style='margin: 0; padding-left: 20px; color: #856404; font-size: 14px; line-height: 1.8;'>" +
                "<li>Vui lòng đổi mật khẩu ngay sau khi đăng nhập lần đầu</li>" +
                "<li>Không chia sẻ thông tin đăng nhập với bất kỳ ai</li>" +
                "<li>Lưu mật khẩu ở nơi an toàn</li>" +
                "</ul>" +
                "</td>" +
                "</tr>" +
                "</table>" +
                
                "<p style='margin: 0; color: #666666; font-size: 14px; line-height: 1.6;'>Nếu bạn cần hỗ trợ, vui lòng liên hệ với quản trị viên hệ thống.</p>" +
                "</td>" +
                "</tr>" +
                
                "<!-- Footer -->" +
                "<tr>" +
                "<td style='background-color: #f8f9fa; padding: 25px 30px; border-top: 1px solid #e0e0e0;'>" +
                "<p style='margin: 0 0 5px 0; color: #666666; font-size: 13px;'>Trân trọng,</p>" +
                "<p style='margin: 0; color: #333333; font-size: 14px; font-weight: 600;'>TranspoManager Team</p>" +
                "</td>" +
                "</tr>" +
                
                "<!-- Copyright -->" +
                "<tr>" +
                "<td style='padding: 20px 30px; text-align: center;'>" +
                "<p style='margin: 0; color: #999999; font-size: 12px;'>&copy; 2025 TranspoManager. All rights reserved.</p>" +
                "</td>" +
                "</tr>" +
                
                "</table>" +
                "</td>" +
                "</tr>" +
                "</table>" +
                "</body>" +
                "</html>";
    }
}
