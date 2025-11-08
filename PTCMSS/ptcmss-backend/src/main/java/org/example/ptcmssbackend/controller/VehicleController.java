package org.example.ptcmssbackend.controller;

import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.example.ptcmssbackend.dto.request.Vehicle.VehicleRequest;
import org.example.ptcmssbackend.dto.response.VehicleResponse;
import org.example.ptcmssbackend.dto.response.common.ApiResponse;
import org.example.ptcmssbackend.entity.Vehicles;
import org.example.ptcmssbackend.enums.VehicleStatus;
import org.example.ptcmssbackend.service.VehicleService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/vehicles")
@RequiredArgsConstructor
public class VehicleController {

    private final VehicleService vehicleService;

    @Operation(summary = "Tạo mới phương tiện")
    @PostMapping
    public ResponseEntity<ApiResponse<?>> create(@RequestBody VehicleRequest request) {
        try {
            VehicleResponse response = vehicleService.create(request);
            return ResponseEntity.ok(ApiResponse.builder()
                    .success(true)
                    .message("Tạo phương tiện thành công")
                    .data(response)
                    .build());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(ApiResponse.builder()
                    .success(false)
                    .message("Lỗi khi tạo phương tiện: " + e.getMessage())
                    .build());
        }
    }

    @Operation(summary = "Lấy danh sách phương tiện (hỗ trợ tìm kiếm/lọc)")
    @GetMapping
    public ResponseEntity<ApiResponse<?>> getAll(
            @RequestParam(required = false) String licensePlate,
            @RequestParam(required = false) Integer categoryId,
            @RequestParam(required = false) Integer branchId,
            @RequestParam(required = false) String status
    ) {
        try {
            List<VehicleResponse> list;
            if (licensePlate != null && !licensePlate.isBlank()) {
                list = vehicleService.search(licensePlate);
            } else if (categoryId != null || branchId != null || (status != null && !status.isBlank())) {
                list = vehicleService.filter(categoryId, branchId, status);
            } else {
                list = vehicleService.getAll();
            }
            return ResponseEntity.ok(ApiResponse.builder()
                    .success(true)
                    .message("Lấy danh sách phương tiện thành công")
                    .data(list)
                    .build());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(ApiResponse.builder()
                    .success(false)
                    .message("Lỗi khi lấy danh sách: " + e.getMessage())
                    .build());
        }
    }

    @Operation(summary = "Chi tiết phương tiện theo ID")
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<?>> getById(@PathVariable Integer id) {
        try {
            VehicleResponse response = vehicleService.getById(id);
            return ResponseEntity.ok(ApiResponse.builder()
                    .success(true)
                    .message("Lấy chi tiết xe thành công")
                    .data(response)
                    .build());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ApiResponse.builder()
                    .success(false)
                    .message("Không tìm thấy xe: " + e.getMessage())
                    .build());
        }
    }

    @Operation(summary = "Cập nhật thông tin xe")
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<?>> update(@PathVariable Integer id, @RequestBody VehicleRequest request) {
        try {
            VehicleResponse response = vehicleService.update(id, request);
            return ResponseEntity.ok(ApiResponse.builder()
                    .success(true)
                    .message("Cập nhật xe thành công")
                    .data(response)
                    .build());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.builder()
                    .success(false)
                    .message("Lỗi khi cập nhật xe: " + e.getMessage())
                    .build());
        }
    }

    @Operation(summary = "Xóa phương tiện")
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<?>> delete(@PathVariable Integer id) {
        try {
            vehicleService.delete(id);
            return ResponseEntity.ok(ApiResponse.builder()
                    .success(true)
                    .message("Xóa phương tiện thành công")
                    .build());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ApiResponse.builder()
                    .success(false)
                    .message("Lỗi khi xóa xe: " + e.getMessage())
                    .build());
        }
    }
}
