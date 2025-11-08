package org.example.ptcmssbackend.controller;

import lombok.RequiredArgsConstructor;
import org.example.ptcmssbackend.dto.request.Vehicle.VehicleCategoryRequest;
import org.example.ptcmssbackend.dto.response.VehicleCategoryResponse;
import org.example.ptcmssbackend.dto.response.common.ApiResponse;
import org.example.ptcmssbackend.service.VehicleCategoryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/vehicle-categories")
@RequiredArgsConstructor
public class VehicleCategoryController {

    private final VehicleCategoryService categoryService;

    @GetMapping
    public ResponseEntity<ApiResponse<?>> list() {
        List<VehicleCategoryResponse> data = categoryService.listAll();
        return ResponseEntity.ok(ApiResponse.builder().success(true).message("OK").data(data).build());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<?>> get(@PathVariable Integer id) {
        return ResponseEntity.ok(ApiResponse.builder().success(true).message("OK").data(categoryService.getById(id)).build());
    }

    @PostMapping
    public ResponseEntity<ApiResponse<?>> create(@RequestBody VehicleCategoryRequest req) {
        return ResponseEntity.ok(ApiResponse.builder().success(true).message("Created").data(categoryService.create(req)).build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<?>> update(@PathVariable Integer id, @RequestBody VehicleCategoryRequest req) {
        return ResponseEntity.ok(ApiResponse.builder().success(true).message("Updated").data(categoryService.update(id, req)).build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<?>> delete(@PathVariable Integer id) {
        categoryService.delete(id);
        return ResponseEntity.ok(ApiResponse.builder().success(true).message("Deleted").build());
    }
}
