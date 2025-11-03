package org.example.ptcmssbackend.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.ptcmssbackend.entity.Users;
import org.example.ptcmssbackend.enums.UserStatus;
import org.example.ptcmssbackend.repository.UsersRepository;
import org.example.ptcmssbackend.service.VerificationService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j(topic = "VERIFICATION_SERVICE")
@Service
@RequiredArgsConstructor
public class VerificationServiceImpl implements VerificationService {

    private final UsersRepository usersRepository;

    @Override
    @Transactional
    public String verifyAccount(String token) {
        log.info("🔍 Xác thực tài khoản với token: {}", token);

        Users user = usersRepository.findByVerificationToken(token).orElse(null);
        if (user == null) {
            log.warn("❌ Token không hợp lệ hoặc đã hết hạn: {}", token);
            return "Liên kết xác thực không hợp lệ hoặc đã hết hạn!";
        }

        // Nếu user đã được xác thực rồi
        if (Boolean.TRUE.equals(user.getEmailVerified())) {
            log.info("⚠️ User {} đã xác thực trước đó.", user.getUsername());
            return "Tài khoản này đã được xác thực trước đó. Bạn có thể đăng nhập hoặc thiết lập lại mật khẩu.";
        }

        // ✅ Đánh dấu email đã xác thực nhưng KHÔNG xóa token
        user.setEmailVerified(true);
        user.setStatus(UserStatus.ACTIVE);
        // ⚠️ KHÔNG gọi user.setVerificationToken(null);
        usersRepository.save(user);

        log.info("✅ Tài khoản {} đã xác thực thành công, token sẽ được giữ lại để đặt mật khẩu.", user.getUsername());
        return "Xác thực thành công! Vui lòng thiết lập mật khẩu mới để hoàn tất kích hoạt tài khoản.";
    }
}
