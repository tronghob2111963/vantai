package org.example.ptcmssbackend.config;

import lombok.RequiredArgsConstructor;
import org.example.ptcmssbackend.entity.SystemSetting;
import org.example.ptcmssbackend.enums.SettingStatus;
import org.example.ptcmssbackend.enums.ValueType; // Import Enum
import org.example.ptcmssbackend.repository.SystemSettingRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List; // Import List

@Configuration
@RequiredArgsConstructor
public class SampleDataConfig {

    private final SystemSettingRepository repo;

    @Bean
    CommandLineRunner seed() {
        return args -> {
            // DISABLED: DB đã có seed data từ SQL script (00_full_setup.sql)
            // Không cần seed data nữa vì đã có sẵn trong database
            // 
            // if (repo.count() == 0) {
            //     SystemSetting siteName = SystemSetting.builder()
            //             .settingKey("site_name")
            //             .settingValue("PTCMSS - PassengerTransportCompanyManagementSupportedSystem")
            //             .valueType(ValueType.STRING)
            //             .category("General")
            //             .description("Tên của hệ thống")
            //             .status(SettingStatus.ACTIVE)
            //             .build();
            //     repo.saveAll(List.of(siteName, maintenanceMode, hotline));
            //     System.out.println("Đã seed 3 system settings vào database.");
            // }
        };
    }
}