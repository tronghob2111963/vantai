package org.example.ptcmssbackend.dto.response.Trip;

import lombok.*;
import org.example.ptcmssbackend.entity.Bookings;
import org.example.ptcmssbackend.entity.Trips;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TripListItemResponse {

    private Integer tripId;
    private Integer bookingId;

    private String customerName;
    private String customerPhone;

    private String branchName;

    private String routeSummary;
    private Instant startTime;
    private Instant endTime;

    private String hireTypeName;

    private String driverName;
    private String vehicleLicensePlate;

    private String status;

    public static TripListItemResponse from(Trips trip) {
        Bookings b = trip.getBooking();

        return TripListItemResponse.builder()
                .tripId(trip.getId())
                .bookingId(b != null ? b.getId() : null)
                .customerName(b != null ? b.getCustomer().getFullName() : null)
                .customerPhone(b != null ? b.getCustomer().getPhone() : null)
                .branchName(b != null ? b.getBranch().getBranchName() : null)
                .routeSummary(trip.getStartLocation() + " → " + trip.getEndLocation())
                .startTime(trip.getStartTime())
                .endTime(trip.getEndTime())
                .hireTypeName(b != null && b.getHireType() != null ? b.getHireType().getName() : null)
                .status(trip.getStatus().name())
                .driverName(null)
                .vehicleLicensePlate(null)
                .build();
    }
}