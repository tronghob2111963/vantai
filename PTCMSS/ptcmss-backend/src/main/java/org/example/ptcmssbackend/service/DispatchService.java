package org.example.ptcmssbackend.service;

import org.example.ptcmssbackend.dto.request.dispatch.AssignRequest;
import org.example.ptcmssbackend.dto.response.dispatch.AssignRespone;
import org.example.ptcmssbackend.dto.response.dispatch.PendingTripResponse;

import java.time.Instant;
import java.util.List;

public interface DispatchService {

    // Lấy danh sách chuyến pending của 1 chi nhánh, trong khoảng thời gian (nếu null -> mặc định hôm nay)
    List<PendingTripResponse> getPendingTrips(Integer branchId);

    List<PendingTripResponse> getPendingTrips(Integer branchId, Instant from, Instant to);

    // Gán (manual hoặc auto)
    AssignRespone assign(AssignRequest request);

    // Huỷ gán (unassign driver + vehicle) -> trip quay về queue pending
    void unassign(Integer tripId);

    // (tuỳ chọn) reassign: thực chất là unassign + assign
    AssignRespone reassign(AssignRequest request);

    void driverAcceptTrip(Integer tripId);
}
