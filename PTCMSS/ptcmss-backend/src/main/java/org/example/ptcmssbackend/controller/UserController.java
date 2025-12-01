package org.example.ptcmssbackend.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.ptcmssbackend.dto.request.User.CreateUserRequest;
import org.example.ptcmssbackend.dto.request.User.UpdateUserRequest;
import org.example.ptcmssbackend.dto.response.User.UserResponse;
import org.example.ptcmssbackend.dto.response.common.ResponseData;
import org.example.ptcmssbackend.dto.response.common.ResponseError;
import org.example.ptcmssbackend.entity.Users;
import org.example.ptcmssbackend.enums.UserStatus;
import org.example.ptcmssbackend.service.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.example.ptcmssbackend.entity.Employees;
import org.example.ptcmssbackend.repository.EmployeeRepository;
import org.example.ptcmssbackend.repository.UsersRepository;

import java.util.List;

@Slf4j(topic = "USER-CONTROLLERF")
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Tag(name = "User Management", description = "Quản lý người dùng, tạo - sửa - khóa - kích hoạt tài khoản")
public class UserController {

    private final UserService userService;
    private final EmployeeRepository employeeRepository;
    private final UsersRepository usersRepository;

    @Operation(summary = "Tạo người dùng mới", description = "Tạo tài khoản cho nhân viên. Sau này sẽ gửi email thiết lập mật khẩu.")
    @ApiResponse(responseCode = "200", description = "Tạo thành công",
            content = @Content(schema = @Schema(implementation = Users.class)))
    @PostMapping("/register")
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER')") //  Admin và Manager được tạo user
    public ResponseData<?> createUser(@Valid @RequestBody CreateUserRequest request) {
        try{
            log.info("createUser: {}", request);
            return new ResponseData<>(HttpStatus.OK.value(), "Create user successfully", userService.createUser(request));
        } catch (Exception e) {
            return new ResponseError(HttpStatus.BAD_REQUEST.value(), e.getMessage());
        }
    }

    @Operation(summary = "Cập nhật người dùng", description = "Cập nhật thông tin người dùng (Admin và Manager).")
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')") //  Admin và Manager được cập nhật thông tin user
    public ResponseData<?> updateUser(
            @Parameter(description = "ID người dùng") @PathVariable Integer id,
            @Valid @RequestBody UpdateUserRequest request) {
        try{
            log.info("updateUser: {}", request);
            
            // Kiểm tra quyền: Manager chỉ được update nhân viên cùng chi nhánh
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.getPrincipal() instanceof Users) {
                Users currentUser = (Users) authentication.getPrincipal();
                String currentUserRole = currentUser.getRole() != null ? currentUser.getRole().getRoleName().toUpperCase() : "";
                
                // Nếu là Manager, kiểm tra chi nhánh
                if ("MANAGER".equals(currentUserRole)) {
                    try {
                        // Lấy chi nhánh của Manager
                        Employees managerEmployee = employeeRepository.findByUserId(currentUser.getId()).orElse(null);
                        if (managerEmployee == null || managerEmployee.getBranch() == null) {
                            log.warn("Manager {} has no branch assigned", currentUser.getId());
                            return new ResponseError(HttpStatus.FORBIDDEN.value(), "Manager chưa được gán chi nhánh. Vui lòng liên hệ Admin.");
                        }
                        Integer managerBranchId = managerEmployee.getBranch().getId();
                        log.info("Manager {} belongs to branch {}", currentUser.getId(), managerBranchId);
                        
                        // Lấy target user entity
                        Users targetUser = usersRepository.findById(id).orElse(null);
                        if (targetUser == null) {
                            log.warn("Target user {} not found", id);
                            return new ResponseError(HttpStatus.NOT_FOUND.value(), "Không tìm thấy người dùng.");
                        }
                        
                        // Kiểm tra target user có phải Manager hoặc Admin không
                        String targetRole = targetUser.getRole() != null ? targetUser.getRole().getRoleName().toUpperCase() : "";
                        if ("ADMIN".equals(targetRole) || "MANAGER".equals(targetRole)) {
                            log.warn("Manager {} attempted to update {} user {}", currentUser.getId(), targetRole, id);
                            return new ResponseError(HttpStatus.FORBIDDEN.value(), "Manager không được phép cập nhật tài khoản Admin hoặc Manager khác.");
                        }
                        
                        // Lấy chi nhánh của target user
                        Employees targetEmployee = employeeRepository.findByUserId(id).orElse(null);
                        if (targetEmployee == null || targetEmployee.getBranch() == null) {
                            log.warn("Target user {} has no branch assigned", id);
                            return new ResponseError(HttpStatus.FORBIDDEN.value(), "Người dùng này chưa được gán chi nhánh.");
                        }
                        Integer targetBranchId = targetEmployee.getBranch().getId();
                        log.info("Target user {} belongs to branch {}", id, targetBranchId);
                        
                        // Kiểm tra cùng chi nhánh - CHỈ CHẶN nếu KHÁC chi nhánh
                        if (!managerBranchId.equals(targetBranchId)) {
                            log.warn("Manager {} (branch {}) attempted to update user {} (branch {}) - DIFFERENT branch", 
                                    currentUser.getId(), managerBranchId, id, targetBranchId);
                            return new ResponseError(HttpStatus.FORBIDDEN.value(), "Manager chỉ được phép cập nhật nhân viên thuộc chi nhánh của mình.");
                        }
                        
                        // Nếu cùng chi nhánh, cho phép update
                        log.info("Manager {} (branch {}) updating user {} (branch {}) - SAME branch, ALLOWED", 
                                currentUser.getId(), managerBranchId, id, targetBranchId);
                    } catch (Exception e) {
                        log.error("Error validating manager permission for user update", e);
                        return new ResponseError(HttpStatus.INTERNAL_SERVER_ERROR.value(), "Lỗi kiểm tra quyền: " + e.getMessage());
                    }
                }
            }
            
            return new ResponseData<>(HttpStatus.OK.value(), "Update user successfully", userService.updateUser(id, request));
        } catch (Exception e) {
            return new ResponseError(HttpStatus.BAD_REQUEST.value(), e.getMessage());
        }
    }

    @Operation(summary = "Cập nhật thông tin cá nhân", description = "Người dùng tự cập nhật số điện thoại và địa chỉ của mình.")
    @PatchMapping("/{id}/profile")
    @PreAuthorize("#id == authentication.principal.id") //  Chỉ cho phép user tự cập nhật profile của mình
    public ResponseData<?> updateProfile(
            @Parameter(description = "ID người dùng") @PathVariable Integer id,
            @Valid @RequestBody org.example.ptcmssbackend.dto.request.User.UpdateProfileRequest request) {
        try{
            log.info("updateProfile: {}", request);
            return new ResponseData<>(HttpStatus.OK.value(), "Update profile successfully", userService.updateProfile(id, request));
        } catch (Exception e) {
            return new ResponseError(HttpStatus.BAD_REQUEST.value(), e.getMessage());
        }
    }

    @Operation(summary = "Lấy danh sách người dùng", description = "Lọc theo từ khóa, vai trò, trạng thái.")
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseData<List<UserResponse>> getAllUsers(
            @Parameter(description = "Từ khóa tìm kiếm (tên hoặc email)") @RequestParam(required = false) String keyword,
            @Parameter(description = "ID vai trò") @RequestParam(required = false) Integer roleId,
            @Parameter(description = "Trạng thái người dùng") @RequestParam(required = false) UserStatus status) {
        try{
            log.info("getAllUsers: {}", keyword, roleId, status);
            return new ResponseData<>(HttpStatus.OK.value(), "Get all users successfully", userService.getAllUsers(keyword, roleId, status));
        } catch (Exception e) {
           return new ResponseError(HttpStatus.BAD_REQUEST.value(), e.getMessage());
        }
    }

    @Operation(summary = "Xem chi tiết người dùng", description = "Lấy thông tin chi tiết của 1 người dùng.")
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER') or #id == authentication.principal.id") /// Admin, Manager hoặc chính người đó
    public ResponseData<?> getUserById(
            @Parameter(description = "ID người dùng") @PathVariable Integer id) {
            try {
                log.info("getUserById: {}", id);
                return new ResponseData<>(HttpStatus.OK.value(), "Get user by id successfully", userService.getUserById(id));
            } catch (Exception e) {
                return new ResponseError(HttpStatus.BAD_REQUEST.value(), e.getMessage());
            }
    }

    @Operation(summary = "Kích hoạt / Vô hiệu hóa tài khoản", description = "Đổi trạng thái người dùng ACTIVE ↔ INACTIVE.")
    @PatchMapping("/{id}/toggle-status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseData<String> toggleStatus(
            @Parameter(description = "ID người dùng") @PathVariable Integer id) {
       try{
           log.info("toggleStatus: {}", id);
           userService.toggleUserStatus(id);
           return new ResponseData<>(HttpStatus.OK.value(), "Toggle user status successfully", null);
       } catch (Exception e) {
          return new ResponseError(HttpStatus.BAD_REQUEST.value(), e.getMessage());
       }
    }

    // ------------------- Upload Avatar -------------------

    @Operation(
            summary = "Cập nhật ảnh đại diện người dùng",
            description = "Người dùng hoặc Admin có thể tải lên ảnh đại diện mới",
            responses = {
                    @ApiResponse(responseCode = "200", description = "Cập nhật ảnh thành công"),
                    @ApiResponse(responseCode = "404", description = "Không tìm thấy người dùng")
            }
    )
    @PostMapping(
            value = "/{id}/avatar",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    @PreAuthorize("hasRole('ADMIN') or #id == authentication.principal.id")
    public ResponseData<?> uploadAvatar(
            @PathVariable Integer id,
            @Parameter(description = "File ảnh cần upload", required = true)
            @RequestParam("file") MultipartFile file)
    {

        try{
            log.info("uploadAvatar: {}", id);
            return new ResponseData<>(HttpStatus.OK.value(), "update avartar", userService.updateAvatar(id, file));
        } catch (Exception e) {
           return new ResponseError(HttpStatus.BAD_REQUEST.value(), e.getMessage());
        }
    }


    @Operation(
            summary = "Tìm kiếm và lọc người dùng",
            description = "API cho phép tìm kiếm và lọc user theo nhiều điều kiện: keyword (tìm theo họ tên, email, số điện thoại), roleId, branchId, status (ACTIVE/INACTIVE)"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lấy danh sách thành công",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = UserResponse.class))),
            @ApiResponse(responseCode = "500", description = "Lỗi hệ thống")
    })
    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    public ResponseData<List<UserResponse>> searchUsers(

            @Parameter(description = "Từ khóa tìm kiếm (tên, email, số điện thoại)", example = "trong")
            @RequestParam(required = false) String keyword,

            @Parameter(description = "Lọc theo quyền (roleId)", example = "2")
            @RequestParam(required = false) Integer roleId,

            @Parameter(description = "Lọc theo chi nhánh", example = "3")
            @RequestParam(required = false) Integer branchId,

            @Parameter(description = "Lọc theo trạng thái", example = "ACTIVE")
            @RequestParam(required = false) UserStatus status
    ) {
        try{
            log.info("searchUsers: {}", keyword);
            return new ResponseData<>(HttpStatus.OK.value(), "search users successfully", userService.searchUsers(keyword, roleId, branchId, status));
        } catch (Exception e) {
            return new ResponseError(HttpStatus.BAD_REQUEST.value(), e.getMessage());
        }
    }



    @Operation(
            summary = "Lấy danh sách user theo chi nhánh",
            description = "API trả về danh sách người dùng thuộc một chi nhánh cụ thể. Luồng dữ liệu: Branch -> Employees -> Users. Hệ thống tự JOIN Employees -> Users để trả về danh sách đúng."
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Lấy danh sách user thành công",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = UserResponse.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Không tìm thấy chi nhánh"
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "Lỗi hệ thống"
            )
    })
    @GetMapping("/branch/{branchId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
    public ResponseData<?> getUsersByBranch(
            @Parameter(
                    description = "ID chi nhánh cần lọc user",
                    example = "3"
            )
            @PathVariable Integer branchId
    ) {
       try {
           log.info("getUsersByBranch: {}", branchId);
           return new ResponseData<>(HttpStatus.OK.value(), "get users successfully", userService.getUsersByBranch(branchId));
       } catch (Exception e) {
           return new ResponseError(HttpStatus.BAD_REQUEST.value(), e.getMessage());
       }
    }
}

