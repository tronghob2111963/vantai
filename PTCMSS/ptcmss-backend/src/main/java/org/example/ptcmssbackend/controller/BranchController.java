package org.example.ptcmssbackend.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.ptcmssbackend.dto.request.CreateBranchRequest;
import org.example.ptcmssbackend.dto.request.UpdateBranchRequest;
import org.example.ptcmssbackend.dto.response.common.ResponseData;
import org.example.ptcmssbackend.entity.Branches;
import org.example.ptcmssbackend.service.BranchService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/branches")
@RequiredArgsConstructor
@Tag(name = "Branch Management", description = "Quản lý chi nhánh, thêm - sửa - xem - vô hiệu hóa")
public class BranchController {

    private final BranchService branchService;

    @Operation(summary = "Tạo chi nhánh mới", description = "Thêm chi nhánh mới vào hệ thống, có thể chọn quản lý chi nhánh.")
    @PostMapping
    public ResponseData<?> createBranch(@RequestBody CreateBranchRequest request) {
        try{
            return new ResponseData<>(HttpStatus.OK.value(), "Create branch successfully", branchService.createBranch(request));
        }catch (Exception e){
            throw new RuntimeException(e);
        }
    }

    @Operation(summary = "Cập nhật chi nhánh", description = "Sửa thông tin chi nhánh, bao gồm tên, địa chỉ, quản lý, trạng thái.")
    @PutMapping("/{id}")
    public ResponseData<?> updateBranch(
            @Parameter(description = "ID chi nhánh") @PathVariable Integer id,
            @RequestBody UpdateBranchRequest request) {
        try{
            return new ResponseData<>(HttpStatus.OK.value(), "Update branch successfully", branchService.updateBranch(id, request));
        }catch (Exception e){
            throw new RuntimeException(e);
        }
    }

    @Operation(summary = "Danh sách chi nhánh", description = "Lấy danh sách toàn bộ chi nhánh trong hệ thống.")
    @GetMapping
    public ResponseData<?> getAllBranches(@RequestParam(required = false) String keyword ,
                                       @RequestParam(defaultValue = "0") int page,
                                       @RequestParam(defaultValue = "20") int size,
                                       @RequestParam(required = false) String sortBy) {
        try{
            return new ResponseData<>(HttpStatus.OK.value(), "Get all branches successfully", branchService.getAllBranches(keyword, page, size, sortBy));
        }catch (Exception e){
            throw new RuntimeException(e);
        }
    }

    @Operation(summary = "Chi tiết chi nhánh", description = "Xem thông tin cụ thể của chi nhánh.")
    @GetMapping("/{id}")
    public ResponseData<?> getBranchById(@Parameter(description = "ID chi nhánh") @PathVariable Integer id) {
        try{
            return new ResponseData<>(HttpStatus.OK.value(), "Get branch by id successfully", branchService.getBranchById(id));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }

    @Operation(summary = "Vô hiệu hóa chi nhánh", description = "Đánh dấu chi nhánh là INACTIVE.")
    @DeleteMapping("/{id}")
    public ResponseData<String> deleteBranch(@Parameter(description = "ID chi nhánh") @PathVariable Integer id) {
       try{
           log.info("Delete branch {}", id);
           branchService.deleteBranch(id);
           return new ResponseData<>(HttpStatus.OK.value(), "Delete branch successfully");
       }catch (Exception e){
           throw new RuntimeException(e);
       }
    }
}