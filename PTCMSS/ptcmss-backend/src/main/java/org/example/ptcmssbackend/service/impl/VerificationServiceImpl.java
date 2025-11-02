package org.example.ptcmssbackend.service.impl;

import lombok.RequiredArgsConstructor;
import org.example.ptcmssbackend.entity.Users;
import org.example.ptcmssbackend.repository.UsersRepository;
import org.example.ptcmssbackend.service.VerificationService;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class VerificationServiceImpl implements VerificationService {

    private final UsersRepository usersRepository;

    @Override
    public String verifyAccount(String token) {
        Users user = usersRepository.findByVerificationToken(token).orElse(null);

        if (user == null) {
            return "Liên kết xác thực không hợp lệ hoặc đã hết hạn!";
        }

        if (Boolean.TRUE.equals(user.getEmailVerified())) {
            return "Tài khoản này đã được xác thực trước đó.";
        }

        user.setEmailVerified(true);
        user.setVerificationToken(null);
        usersRepository.save(user);

        return "Xác thực tài khoản thành công! Bạn có thể thiết lập mật khẩu.";
    }
}
