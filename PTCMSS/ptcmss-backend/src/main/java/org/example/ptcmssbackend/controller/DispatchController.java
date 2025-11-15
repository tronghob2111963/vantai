package org.example.ptcmssbackend.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.ptcmssbackend.dto.request.dispatch.AssignRequest;
import org.example.ptcmssbackend.dto.response.common.ResponseData;
import org.example.ptcmssbackend.dto.response.common.ResponseError;
import org.example.ptcmssbackend.dto.response.dispatch.AssignRespone;
import org.example.ptcmssbackend.dto.response.dispatch.PendingTripResponse;
import org.example.ptcmssbackend.service.DispatchService;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/dispatch")
@RequiredArgsConstructor
@Tag(name = "Dispatch Module", description = "API điều phối chuyến xe (Module 5): Pending, Assign, Driver Accept")
public class DispatchController {

    private final DispatchService dispatchService;

    // =====================================================================
    // 1) LẤY DANH SÁCH CHUYẾN PENDING
    // =====================================================================
    @Operation(
            summary = "Lấy danh sách chuyến *Pending* theo chi nhánh",
            description = """
                          Trả về danh sách các chuyến đã xác nhận & đủ điều kiện điều phối.
                          Chỉ ADMIN hoặc MANAGER có quyền xem.
                          """
    )
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
    @GetMapping("/pending/{branchId}")
    public ResponseData<List<PendingTripResponse>> getPendingTrips(@PathVariable Integer branchId) {
        try {
            log.info("[Dispatch] Get pending trips for branch {}", branchId);
            List<PendingTripResponse> data = dispatchService.getPendingTrips(branchId);
            return new ResponseData<>(HttpStatus.OK.value(), "Success", data);
        } catch (Exception e) {
            log.error("[Dispatch] Failed to load pending trips", e);
            return new ResponseError(HttpStatus.BAD_REQUEST.value(), e.getMessage());
        }
    }

    // =====================================================================
    // 2) GÁN XE + TÀI XẾ
    // =====================================================================
    @Operation(
            summary = "Gán tài xế + xe cho chuyến",
            description = """
                          ADMIN hoặc MANAGER mới có quyền điều phối.
                          Gán 1 hoặc nhiều trip, idempotent (gán lại không lỗi).
                          """
    )
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
    @PostMapping("/assign")
    public ResponseData<AssignRespone> assignTrip(@RequestBody AssignRequest request) {
        try {
            log.info("[Dispatch] Assign trip: {}", request);
            return new ResponseData<>(HttpStatus.OK.value(),
                    "Assign successfully",
                    dispatchService.assign(request));
        } catch (Exception e) {
            log.error("[Dispatch] Assign failed", e);
            return new ResponseError(HttpStatus.BAD_REQUEST.value(), e.getMessage());
        }
    }

    // =====================================================================
    // 3) DRIVER ACCEPT TRIP
    // =====================================================================
    @Operation(
            summary = "Driver xác nhận nhận chuyến",
            description = """
                          Chỉ tài xế được phép thao tác này.
                          Khi nhận chuyến: chuyển trạng thái từ SCHEDULED → ONGOING.
                          """
    )
    @PreAuthorize("hasRole('DRIVER')")
    @PostMapping("/driver/accept/{tripId}")
    public ResponseData<?> acceptTrip(@PathVariable Integer tripId) {
        try {
            log.info("[Dispatch] Driver accepts trip {}", tripId);
            dispatchService.driverAcceptTrip(tripId);
            return new ResponseData<>(HttpStatus.OK.value(),
                    "Driver accepted trip successfully", null);
        } catch (Exception e) {
            log.error("[Dispatch] Driver failed to accept trip {}", tripId, e);
            return new ResponseError(HttpStatus.BAD_REQUEST.value(), e.getMessage());
        }
    }
}