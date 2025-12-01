package org.example.ptcmssbackend.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.ptcmssbackend.dto.request.QrSettingsUpdateRequest;
import org.example.ptcmssbackend.dto.response.common.ApiResponse;
import org.example.ptcmssbackend.dto.response.QrSettingsResponse;
import org.example.ptcmssbackend.entity.AppSetting;
import org.example.ptcmssbackend.service.AppSettingService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/settings")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Admin Settings", description = "Admin-only API for managing application settings")
public class AdminSettingsController {

    private final AppSettingService appSettingService;

    @GetMapping("/qr")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Get QR payment settings", description = "Get current QR payment configuration (Admin only)")
    public ResponseEntity<ApiResponse<QrSettingsResponse>> getQrSettings() {
        try {
            Map<String, String> settings = appSettingService.getQrSettings();
            
            // Get metadata from DB if exists
            AppSetting bankCodeSetting = appSettingService.getAllSettings().stream()
                    .filter(s -> s.getKey().equals(AppSettingService.QR_BANK_CODE))
                    .findFirst()
                    .orElse(null);
            
            QrSettingsResponse response = QrSettingsResponse.builder()
                    .bankCode(settings.get(AppSettingService.QR_BANK_CODE))
                    .accountNumber(settings.get(AppSettingService.QR_ACCOUNT_NUMBER))
                    .accountName(settings.get(AppSettingService.QR_ACCOUNT_NAME))
                    .descriptionPrefix(settings.get(AppSettingService.QR_DESCRIPTION_PREFIX))
                    .updatedAt(bankCodeSetting != null ? bankCodeSetting.getUpdatedAt() : null)
                    .updatedBy(bankCodeSetting != null ? bankCodeSetting.getUpdatedBy() : null)
                    .source(bankCodeSetting != null ? "database" : "config")
                    .build();
            
            return ResponseEntity.ok(ApiResponse.success(response));
        } catch (Exception e) {
            log.error("Error getting QR settings", e);
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Không thể tải cấu hình QR: " + e.getMessage()));
        }
    }

    @PutMapping("/qr")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Update QR payment settings", description = "Update QR payment configuration (Admin only)")
    public ResponseEntity<ApiResponse<QrSettingsResponse>> updateQrSettings(
            @Valid @RequestBody QrSettingsUpdateRequest request,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            
            // Validate and update settings
            Map<String, String> settingsMap = new HashMap<>();
            settingsMap.put(AppSettingService.QR_BANK_CODE, request.getBankCode());
            settingsMap.put(AppSettingService.QR_ACCOUNT_NUMBER, request.getAccountNumber());
            settingsMap.put(AppSettingService.QR_ACCOUNT_NAME, request.getAccountName());
            settingsMap.put(AppSettingService.QR_DESCRIPTION_PREFIX, 
                    request.getDescriptionPrefix() != null ? request.getDescriptionPrefix() : "PTCMSS");
            
            appSettingService.updateSettings(settingsMap, username);
            
            // Return updated settings
            QrSettingsResponse response = QrSettingsResponse.builder()
                    .bankCode(request.getBankCode())
                    .accountNumber(request.getAccountNumber())
                    .accountName(request.getAccountName())
                    .descriptionPrefix(request.getDescriptionPrefix())
                    .updatedAt(Instant.now())
                    .updatedBy(username)
                    .source("database")
                    .build();
            
            log.info("Admin {} updated QR settings", username);
            return ResponseEntity.ok(ApiResponse.success(response, "Cập nhật cấu hình QR thành công"));
        } catch (Exception e) {
            log.error("Error updating QR settings", e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Không thể cập nhật cấu hình QR: " + e.getMessage()));
        }
    }
}
