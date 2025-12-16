package org.example.ptcmssbackend.config;

import lombok.RequiredArgsConstructor;
import org.example.ptcmssbackend.entity.SystemSetting;
import org.example.ptcmssbackend.enums.SettingStatus;
import org.example.ptcmssbackend.enums.ValueType;
import org.example.ptcmssbackend.repository.SystemSettingRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@RequiredArgsConstructor
public class SampleDataConfig {

    private final SystemSettingRepository repo;

    @Bean
    CommandLineRunner seed() {
        return args -> {
            // Tự động tạo các SystemSettings cho cảnh báo hết hạn nếu chưa có
            createSettingIfNotExists("EXPIRY_WARNING_DAYS", "30", 
                "Số ngày cảnh báo trước khi hết hạn (đăng kiểm, bảo hiểm, GPLX)", 
                "ALERT", ValueType.INT);
            
            createSettingIfNotExists("CRITICAL_WARNING_DAYS", "7", 
                "Số ngày cảnh báo khẩn cấp trước khi hết hạn", 
                "ALERT", ValueType.INT);
            
            createSettingIfNotExists("HEALTH_CHECK_WARNING_DAYS", "30", 
                "Số ngày cảnh báo trước khi đến hạn khám sức khỏe định kỳ", 
                "ALERT", ValueType.INT);

            // Hạn công nợ: số ngày cộng thêm sau khi kết thúc chuyến
            createSettingIfNotExists("DUE_DATE_DEBT_DAYS", "7",
                "Số ngày cộng thêm để tính hạn công nợ sau khi kết thúc chuyến",
                "INVOICE", ValueType.INT);
        };
    }
    
    private void createSettingIfNotExists(String key, String value, String description, 
                                         String category, ValueType valueType) {
        if (!repo.existsBySettingKey(key)) {
            SystemSetting setting = SystemSetting.builder()
                    .settingKey(key)
                    .settingValue(value)
                    .valueType(valueType)
                    .category(category)
                    .description(description)
                    .status(SettingStatus.ACTIVE)
                    .effectiveStartDate(java.time.LocalDate.now())
                    .build();
            repo.save(setting);
            System.out.println("Đã tạo SystemSetting: " + key + " = " + value);
        }
    }
}