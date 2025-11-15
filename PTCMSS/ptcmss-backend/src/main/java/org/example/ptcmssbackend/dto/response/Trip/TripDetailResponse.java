package org.example.ptcmssbackend.dto.response.Trip;

import lombok.*;
import org.example.ptcmssbackend.entity.*;
import java.time.Instant;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TripDetailResponse {

    private Integer tripId;
    private Integer bookingId;

    private String customerName;
    private String customerPhone;

    private Integer branchId;
    private String branchName;

    private String startLocation;
    private String endLocation;
    private Instant startTime;
    private Instant endTime;
    private Boolean useHighway;

    private String hireTypeName;
    private String bookingStatus;

    private Integer driverId;
    private String driverName;

    private Integer vehicleId;
    private String vehicleLicensePlate;

    private String status;
    private String assignMethod;

    private List<AssignmentHistoryItem> assignmentHistory;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AssignmentHistoryItem {
        private Integer id;
        private String actionType;
        private String assignMethod;
        private String oldDriverName;
        private String newDriverName;
        private String oldVehiclePlate;
        private String newVehiclePlate;
        private String reason;
        private Instant createdAt;
    }

    public static TripDetailResponse from(
            Trips trip,
            Bookings b,
            TripDrivers td,
            TripVehicles tv,
            List<TripAssignmentHistory> histories
    ) {
        if (b == null) b = trip.getBooking();

        List<AssignmentHistoryItem> historyItems = histories.stream().map(h ->
                AssignmentHistoryItem.builder()
                        .id(h.getId())
                        .actionType(h.getActionType())
                        .assignMethod(h.getAssignMethod())
                        .oldDriverName(h.getOldDriver() != null ?
                                h.getOldDriver().getEmployee().getUser().getFullName() : null)
                        .newDriverName(h.getNewDriver() != null ?
                                h.getNewDriver().getEmployee().getUser().getFullName() : null)
                        .oldVehiclePlate(h.getOldVehicle() != null ?
                                h.getOldVehicle().getLicensePlate() : null)
                        .newVehiclePlate(h.getNewVehicle() != null ?
                                h.getNewVehicle().getLicensePlate() : null)
                        .reason(h.getReason())
                        .createdAt(h.getCreatedAt())
                        .build()
        ).collect(Collectors.toList());

        String latestAssignMethod = historyItems.stream()
                .filter(h -> Objects.equals(h.getActionType(), "ASSIGN") ||
                        Objects.equals(h.getActionType(), "REASSIGN"))
                .sorted((a, b2) -> b2.getCreatedAt().compareTo(a.getCreatedAt()))
                .map(AssignmentHistoryItem::getAssignMethod)
                .findFirst()
                .orElse(null);

        return TripDetailResponse.builder()
                .tripId(trip.getId())
                .bookingId(b.getId())
                .customerName(b.getCustomer().getFullName())
                .customerPhone(b.getCustomer().getPhone())
                .branchId(b.getBranch().getId())
                .branchName(b.getBranch().getBranchName())
                .startLocation(trip.getStartLocation())
                .endLocation(trip.getEndLocation())
                .startTime(trip.getStartTime())
                .endTime(trip.getEndTime())
                .useHighway(trip.getUseHighway())
                .hireTypeName(b.getHireType().getName())
                .bookingStatus(b.getStatus().name())
                .driverId(td != null ? td.getDriver().getId() : null)
                .driverName(td != null ? td.getDriver().getEmployee().getUser().getFullName() : null)
                .vehicleId(tv != null ? tv.getVehicle().getId() : null)
                .vehicleLicensePlate(tv != null ? tv.getVehicle().getLicensePlate() : null)
                .status(trip.getStatus().name())
                .assignMethod(latestAssignMethod)
                .assignmentHistory(historyItems)
                .build();
    }
}