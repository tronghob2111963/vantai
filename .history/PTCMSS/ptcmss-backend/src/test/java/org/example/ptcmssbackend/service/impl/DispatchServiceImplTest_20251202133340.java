package org.example.ptcmssbackend.service.impl;

import org.example.ptcmssbackend.BaseTest;
import org.example.ptcmssbackend.dto.request.Trip.AssignDriverRequest;
import org.example.ptcmssbackend.dto.request.Trip.AssignVehicleRequest;
import org.example.ptcmssbackend.dto.response.Trip.TripResponse;
import org.example.ptcmssbackend.entity.*;
import org.example.ptcmssbackend.enums.TripStatus;
import org.example.ptcmssbackend.enums.VehicleStatus;
import org.example.ptcmssbackend.enums.DriverStatus;
import org.example.ptcmssbackend.exception.ResourceNotFoundException;
import org.example.ptcmssbackend.repository.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class DispatchServiceImplTest extends BaseTest {

    @Mock
    private TripRepository tripRepository;

    @Mock
    private BookingRepository bookingRepository;

    @Mock
    private DriverRepository driverRepository;

    @Mock
    private VehicleRepository vehicleRepository;

    @Mock
    private TripDriverRepository tripDriverRepository;

    @Mock
    private TripVehicleRepository tripVehicleRepository;

    @Mock
    private TripAssignmentHistoryRepository assignmentHistoryRepository;

    @InjectMocks
    private DispatchServiceImpl dispatchService;

    private Trips testTrip;
    private Bookings testBooking;
    private Drivers testDriver;
    private Vehicles testVehicle;

    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();

        testBooking = new Bookings();
        testBooking.setId(1);
        testBooking.setBookingCode("BK20251202001");

        testTrip = new Trips();
        testTrip.setId(1);
        testTrip.setBooking(testBooking);
        testTrip.setTripStatus(TripStatus.PENDING);
        testTrip.setStartTime(LocalDateTime.now().plusDays(1));

        Employees employee = new Employees();
        employee.setId(1);
        employee.setFullName("Nguyen Van B");

        testDriver = new Drivers();
        testDriver.setId(1);
        testDriver.setEmployee(employee);
        testDriver.setStatus(DriverStatus.AVAILABLE);

        VehicleCategories category = new VehicleCategories();
        category.setId(1);

        testVehicle = new Vehicles();
        testVehicle.setId(1);
        testVehicle.setLicensePlate("51A-12345");
        testVehicle.setCategory(category);
        testVehicle.setStatus(VehicleStatus.AVAILABLE);
    }

    @Test
    void assignDriver_Success() {
        // Given
        AssignDriverRequest request = new AssignDriverRequest();
        request.setTripId(1);
        request.setDriverId(1);

        when(tripRepository.findById(1)).thenReturn(Optional.of(testTrip));
        when(driverRepository.findById(1)).thenReturn(Optional.of(testDriver));
        when(tripDriverRepository.existsByTripIdAndDriverId(1, 1)).thenReturn(false);
        when(tripDriverRepository.save(any(TripDrivers.class))).thenAnswer(i -> i.getArgument(0));

        // When
        TripResponse response = dispatchService.assignDriver(request);

        // Then
        assertNotNull(response);
        verify(tripDriverRepository, times(1)).save(any(TripDrivers.class));
        verify(assignmentHistoryRepository, times(1)).save(any(TripAssignmentHistory.class));
    }

    @Test
    void assignDriver_DriverNotAvailable_ThrowsException() {
        // Given
        AssignDriverRequest request = new AssignDriverRequest();
        request.setTripId(1);
        request.setDriverId(1);

        testDriver.setStatus(DriverStatus.ON_TRIP);

        when(tripRepository.findById(1)).thenReturn(Optional.of(testTrip));
        when(driverRepository.findById(1)).thenReturn(Optional.of(testDriver));

        // When & Then
        IllegalStateException exception = assertThrows(IllegalStateException.class, () -> {
            dispatchService.assignDriver(request);
        });

        assertTrue(exception.getMessage().contains("not available"));
        verify(tripDriverRepository, never()).save(any());
    }

    @Test
    void assignDriver_AlreadyAssigned_ThrowsException() {
        // Given
        AssignDriverRequest request = new AssignDriverRequest();
        request.setTripId(1);
        request.setDriverId(1);

        when(tripRepository.findById(1)).thenReturn(Optional.of(testTrip));
        when(driverRepository.findById(1)).thenReturn(Optional.of(testDriver));
        when(tripDriverRepository.existsByTripIdAndDriverId(1, 1)).thenReturn(true);

        // When & Then
        IllegalStateException exception = assertThrows(IllegalStateException.class, () -> {
            dispatchService.assignDriver(request);
        });

        assertTrue(exception.getMessage().contains("already assigned"));
    }

    @Test
    void assignVehicle_Success() {
        // Given
        AssignVehicleRequest request = new AssignVehicleRequest();
        request.setTripId(1);
        request.setVehicleId(1);

        when(tripRepository.findById(1)).thenReturn(Optional.of(testTrip));
        when(vehicleRepository.findById(1)).thenReturn(Optional.of(testVehicle));
        when(tripVehicleRepository.existsByTripIdAndVehicleId(1, 1)).thenReturn(false);
        when(tripVehicleRepository.save(any(TripVehicles.class))).thenAnswer(i -> i.getArgument(0));

        // When
        TripResponse response = dispatchService.assignVehicle(request);

        // Then
        assertNotNull(response);
        verify(tripVehicleRepository, times(1)).save(any(TripVehicles.class));
        verify(assignmentHistoryRepository, times(1)).save(any(TripAssignmentHistory.class));
    }

    @Test
    void assignVehicle_VehicleNotAvailable_ThrowsException() {
        // Given
        AssignVehicleRequest request = new AssignVehicleRequest();
        request.setTripId(1);
        request.setVehicleId(1);

        testVehicle.setStatus(VehicleStatus.IN_USE);

        when(tripRepository.findById(1)).thenReturn(Optional.of(testTrip));
        when(vehicleRepository.findById(1)).thenReturn(Optional.of(testVehicle));

        // When & Then
        IllegalStateException exception = assertThrows(IllegalStateException.class, () -> {
            dispatchService.assignVehicle(request);
        });

        assertTrue(exception.getMessage().contains("not available"));
        verify(tripVehicleRepository, never()).save(any());
    }

    @Test
    void startTrip_Success() {
        // Given
        TripDrivers tripDriver = new TripDrivers();
        tripDriver.setTrip(testTrip);
        tripDriver.setDriver(testDriver);

        TripVehicles tripVehicle = new TripVehicles();
        tripVehicle.setTrip(testTrip);
        tripVehicle.setVehicle(testVehicle);

        when(tripRepository.findById(1)).thenReturn(Optional.of(testTrip));
        when(tripDriverRepository.findByTripId(1)).thenReturn(List.of(tripDriver));
        when(tripVehicleRepository.findByTripId(1)).thenReturn(List.of(tripVehicle));
        when(tripRepository.save(any(Trips.class))).thenReturn(testTrip);

        // When
        TripResponse response = dispatchService.startTrip(1);

        // Then
        assertNotNull(response);
        verify(tripRepository, times(1)).save(argThat(trip -> 
            trip.getTripStatus() == TripStatus.INPROGRESS
        ));
        verify(driverRepository, times(1)).save(argThat(driver -> 
            driver.getStatus() == DriverStatus.ON_TRIP
        ));
        verify(vehicleRepository, times(1)).save(argThat(vehicle -> 
            vehicle.getStatus() == VehicleStatus.IN_USE
        ));
    }

    @Test
    void startTrip_NoDriverAssigned_ThrowsException() {
        // Given
        when(tripRepository.findById(1)).thenReturn(Optional.of(testTrip));
        when(tripDriverRepository.findByTripId(1)).thenReturn(List.of());

        // When & Then
        IllegalStateException exception = assertThrows(IllegalStateException.class, () -> {
            dispatchService.startTrip(1);
        });

        assertTrue(exception.getMessage().contains("No driver assigned"));
    }

    @Test
    void completeTrip_Success() {
        // Given
        testTrip.setTripStatus(TripStatus.INPROGRESS);
        testDriver.setStatus(DriverStatus.ON_TRIP);
        testVehicle.setStatus(VehicleStatus.IN_USE);

        TripDrivers tripDriver = new TripDrivers();
        tripDriver.setTrip(testTrip);
        tripDriver.setDriver(testDriver);

        TripVehicles tripVehicle = new TripVehicles();
        tripVehicle.setTrip(testTrip);
        tripVehicle.setVehicle(testVehicle);

        when(tripRepository.findById(1)).thenReturn(Optional.of(testTrip));
        when(tripDriverRepository.findByTripId(1)).thenReturn(List.of(tripDriver));
        when(tripVehicleRepository.findByTripId(1)).thenReturn(List.of(tripVehicle));
        when(tripRepository.save(any(Trips.class))).thenReturn(testTrip);

        // When
        TripResponse response = dispatchService.completeTrip(1);

        // Then
        assertNotNull(response);
        verify(tripRepository, times(1)).save(argThat(trip -> 
            trip.getTripStatus() == TripStatus.COMPLETED
        ));
        verify(driverRepository, times(1)).save(argThat(driver -> 
            driver.getStatus() == DriverStatus.AVAILABLE
        ));
        verify(vehicleRepository, times(1)).save(argThat(vehicle -> 
            vehicle.getStatus() == VehicleStatus.AVAILABLE
        ));
    }

    @Test
    void getTripById_Success() {
        // Given
        when(tripRepository.findById(1)).thenReturn(Optional.of(testTrip));
        when(tripDriverRepository.findByTripId(1)).thenReturn(List.of());
        when(tripVehicleRepository.findByTripId(1)).thenReturn(List.of());

        // When
        TripResponse response = dispatchService.getTripById(1);

        // Then
        assertNotNull(response);
        assertEquals(1, response.getTripId());
    }

    @Test
    void getTripById_NotFound_ThrowsException() {
        // Given
        when(tripRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
            dispatchService.getTripById(999);
        });

        assertTrue(exception.getMessage().contains("Trip not found"));
    }
}
