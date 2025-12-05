package org.example.ptcmssbackend.service;

import org.example.ptcmssbackend.dto.response.dispatch.PendingTripResponse;
import org.example.ptcmssbackend.entity.*;
import org.example.ptcmssbackend.enums.BookingStatus;
import org.example.ptcmssbackend.enums.TripStatus;
import org.example.ptcmssbackend.repository.*;
import org.example.ptcmssbackend.service.impl.DispatchServiceImpl;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.Collections;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class DispatchServiceImplTest {

    @Mock
    private TripRepository tripRepository;
    @Mock
    private BookingRepository bookingRepository;
    @Mock
    private TripDriverRepository tripDriverRepository;
    @Mock
    private TripVehicleRepository tripVehicleRepository;
    @Mock
    private DriverRepository driverRepository;
    @Mock
    private VehicleRepository vehicleRepository;
    @Mock
    private DriverDayOffRepository driverDayOffRepository;
    @Mock
    private BookingService bookingService;
    @Mock
    private org.example.ptcmssbackend.service.WebSocketNotificationService webSocketNotificationService;
    @Mock
    private SystemSettingService systemSettingService;
    @Mock
    private BookingVehicleDetailsRepository bookingVehicleDetailsRepository;
    @Mock
    private InvoiceRepository invoiceRepository;
    @Mock
    private PaymentHistoryRepository paymentHistoryRepository;
    @Mock
    private DriverRatingsRepository driverRatingsRepository;

    @InjectMocks
    private DispatchServiceImpl dispatchService;

    @Test
    void getPendingTrips_shouldReturnOnlyUnassignedTripsWithDispatchableBookings() {
        Integer branchId = 1;
        Instant from = Instant.parse("2025-12-04T00:00:00Z");
        Instant to = Instant.parse("2025-12-05T00:00:00Z");

        // Booking dispatchable (PENDING)
        Bookings bookingPending = new Bookings();
        bookingPending.setId(10);
        bookingPending.setStatus(BookingStatus.PENDING);
        Customers customer = new Customers();
        customer.setFullName("Nguyễn Văn A");
        customer.setPhone("0909");
        bookingPending.setCustomer(customer);
        Branches branch = new Branches();
        branch.setId(branchId);
        branch.setBranchName("Chi nhánh A");
        bookingPending.setBranch(branch);

        // Booking không dispatchable (CANCELLED)
        Bookings bookingCancelled = new Bookings();
        bookingCancelled.setId(11);
        bookingCancelled.setStatus(BookingStatus.CANCELLED);
        bookingCancelled.setCustomer(customer);
        bookingCancelled.setBranch(branch);

        // Trip 1: SCHEDULED, chưa gán driver/vehicle -> phải được trả về
        Trips trip1 = new Trips();
        trip1.setId(100);
        trip1.setStatus(TripStatus.SCHEDULED);
        trip1.setStartTime(from.plusSeconds(3600));
        trip1.setEndTime(from.plusSeconds(7200));
        trip1.setBooking(bookingPending);

        // Trip 2: SCHEDULED nhưng đã gán driver -> loại bỏ
        Trips trip2 = new Trips();
        trip2.setId(200);
        trip2.setStatus(TripStatus.SCHEDULED);
        trip2.setStartTime(from.plusSeconds(3600));
        trip2.setEndTime(from.plusSeconds(7200));
        trip2.setBooking(bookingPending);

        // Trip 3: SCHEDULED, chưa gán nhưng booking CANCELLED -> loại bỏ
        Trips trip3 = new Trips();
        trip3.setId(300);
        trip3.setStatus(TripStatus.SCHEDULED);
        trip3.setStartTime(from.plusSeconds(3600));
        trip3.setEndTime(from.plusSeconds(7200));
        trip3.setBooking(bookingCancelled);

        when(tripRepository.findByBooking_Branch_IdAndStatusAndStartTimeBetween(
                eq(branchId), eq(TripStatus.SCHEDULED), eq(from), eq(to)))
                .thenReturn(List.of(trip1, trip2, trip3));
        when(tripRepository.findByBooking_Branch_IdAndStatusAndStartTimeBetween(
                eq(branchId), eq(TripStatus.ASSIGNED), eq(from), eq(to)))
                .thenReturn(Collections.emptyList());

        // Trip1: chưa gán
        when(tripDriverRepository.findByTripId(100)).thenReturn(Collections.emptyList());
        when(tripVehicleRepository.findByTripId(100)).thenReturn(Collections.emptyList());
        // Trip2: đã gán driver
        TripDrivers td = new TripDrivers();
        td.setId(new TripDriverId());
        when(tripDriverRepository.findByTripId(200)).thenReturn(List.of(td));
        when(tripVehicleRepository.findByTripId(200)).thenReturn(Collections.emptyList());
        // Trip3: chưa gán nhưng booking CANCELLED
        when(tripDriverRepository.findByTripId(300)).thenReturn(Collections.emptyList());
        when(tripVehicleRepository.findByTripId(300)).thenReturn(Collections.emptyList());

        List<PendingTripResponse> result = dispatchService.getPendingTrips(branchId, from, to);

        assertThat(result).hasSize(1);
        PendingTripResponse r = result.get(0);
        assertThat(r.getTripId()).isEqualTo(100);
        assertThat(r.getBookingId()).isEqualTo(10);
        assertThat(r.getBranchId()).isEqualTo(branchId);
        assertThat(r.getCustomerName()).isEqualTo("Nguyễn Văn A");
        assertThat(r.getBookingStatus()).isEqualTo(BookingStatus.PENDING);
    }
}


