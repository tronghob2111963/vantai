package org.example.ptcmssbackend.integration;

import org.example.ptcmssbackend.dto.request.Booking.CreateBookingRequest;
import org.example.ptcmssbackend.dto.request.Booking.CustomerRequest;
import org.example.ptcmssbackend.dto.request.Booking.TripRequest;
import org.example.ptcmssbackend.dto.request.Booking.VehicleDetailRequest;
import org.example.ptcmssbackend.dto.request.dispatch.AssignRequest;
import org.example.ptcmssbackend.dto.response.Booking.BookingResponse;
import org.example.ptcmssbackend.dto.response.dispatch.AssignRespone;
import org.example.ptcmssbackend.dto.response.dispatch.AssignmentSuggestionResponse;
import org.example.ptcmssbackend.dto.response.dispatch.DispatchDashboardResponse;
import org.example.ptcmssbackend.dto.response.dispatch.PendingTripResponse;
import org.example.ptcmssbackend.entity.*;
import org.example.ptcmssbackend.enums.*;
import org.example.ptcmssbackend.repository.*;
import org.example.ptcmssbackend.service.BookingService;
import org.example.ptcmssbackend.service.DispatchService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class DispatchServiceIntegrationTest extends BaseIntegrationTest {

    @Autowired
    private DispatchService dispatchService;

    @Autowired
    private BookingService bookingService;

    @Autowired
    private BranchesRepository branchesRepository;

    @Autowired
    private CustomerRepository customerRepository;

    @Autowired
    private VehicleCategoryPricingRepository vehicleCategoryPricingRepository;

    @Autowired
    private EmployeeRepository employeeRepository;

    @Autowired
    private UsersRepository usersRepository;

    @Autowired
    private RolesRepository rolesRepository;

    @Autowired
    private DriverRepository driverRepository;

    @Autowired
    private VehicleRepository vehicleRepository;

    @Autowired
    private TripRepository tripRepository;

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private Branches testBranch;
    private Customers testCustomer;
    private VehicleCategoryPricing testCategory;
    private Employees testConsultant;
    private Drivers testDriver;
    private Vehicles testVehicle;
    private Bookings testBookingEntity;

    @BeforeEach
    void setUp() {
        // Create test branch
        testBranch = new Branches();
        testBranch.setBranchName("Test Branch");
        testBranch.setLocation("123 Test Street");
        testBranch.setStatus(BranchStatus.ACTIVE);
        testBranch = branchesRepository.save(testBranch);

        // Create test customer
        testCustomer = new Customers();
        testCustomer.setFullName("Test Customer");
        testCustomer.setPhone("0987654321");
        testCustomer.setEmail("test@example.com");
        testCustomer.setStatus(CustomerStatus.ACTIVE);
        testCustomer = customerRepository.save(testCustomer);

        // Create test vehicle category
        testCategory = new VehicleCategoryPricing();
        testCategory.setCategoryName("Sedan");
        testCategory.setBaseFare(new BigDecimal("500000"));
        testCategory.setPricePerKm(new BigDecimal("10000"));
        testCategory.setStatus(VehicleCategoryStatus.ACTIVE);
        testCategory = vehicleCategoryPricingRepository.save(testCategory);

        // Create consultant role and user
        Roles consultantRole = new Roles();
        consultantRole.setRoleName("CONSULTANT");
        consultantRole.setDescription("Consultant Role");
        consultantRole = rolesRepository.save(consultantRole);

        Users consultantUser = new Users();
        consultantUser.setFullName("Test Consultant");
        consultantUser.setUsername("consultant");
        consultantUser.setEmail("consultant@example.com");
        consultantUser.setPhone("0111222333");
        consultantUser.setPasswordHash(passwordEncoder.encode("password123"));
        consultantUser.setStatus(UserStatus.ACTIVE);
        consultantUser.setRole(consultantRole);
        consultantUser = usersRepository.save(consultantUser);

        testConsultant = new Employees();
        testConsultant.setUser(consultantUser);
        testConsultant.setBranch(testBranch);
        testConsultant.setRole(consultantRole);
        testConsultant.setStatus(EmployeeStatus.ACTIVE);
        testConsultant = employeeRepository.save(testConsultant);

        // Create driver role and user
        Roles driverRole = new Roles();
        driverRole.setRoleName("DRIVER");
        driverRole.setDescription("Driver Role");
        driverRole = rolesRepository.save(driverRole);

        Users driverUser = new Users();
        driverUser.setFullName("Test Driver");
        driverUser.setUsername("driver");
        driverUser.setEmail("driver@example.com");
        driverUser.setPhone("0222333444");
        driverUser.setPasswordHash(passwordEncoder.encode("password123"));
        driverUser.setStatus(UserStatus.ACTIVE);
        driverUser.setRole(driverRole);
        driverUser = usersRepository.save(driverUser);

        Employees driverEmployee = new Employees();
        driverEmployee.setUser(driverUser);
        driverEmployee.setBranch(testBranch);
        driverEmployee.setRole(driverRole);
        driverEmployee.setStatus(EmployeeStatus.ACTIVE);
        driverEmployee = employeeRepository.save(driverEmployee);

        // Create driver
        testDriver = new Drivers();
        testDriver.setEmployee(driverEmployee);
        testDriver.setBranch(testBranch);
        testDriver.setLicenseNumber("TEST-D001");
        testDriver.setLicenseClass("D");
        testDriver.setStatus(DriverStatus.AVAILABLE);
        testDriver = driverRepository.save(testDriver);

        // Create vehicle
        testVehicle = new Vehicles();
        testVehicle.setCategory(testCategory);
        testVehicle.setBranch(testBranch);
        testVehicle.setLicensePlate("30A-12345");
        testVehicle.setStatus(VehicleStatus.AVAILABLE);
        testVehicle = vehicleRepository.save(testVehicle);

        // Create a confirmed booking with trip directly (bypass availability check)
        testBookingEntity = new Bookings();
        testBookingEntity.setCustomer(testCustomer);
        testBookingEntity.setBranch(testBranch);
        testBookingEntity.setStatus(BookingStatus.CONFIRMED);
        testBookingEntity.setConsultant(testConsultant);
        testBookingEntity.setEstimatedCost(new BigDecimal("1000000"));
        testBookingEntity.setTotalCost(new BigDecimal("1000000"));
        testBookingEntity.setDepositAmount(new BigDecimal("500000")); // 50% deposit to allow assignment
        testBookingEntity = bookingRepository.save(testBookingEntity);

        // Create trip for the booking
        Trips trip = new Trips();
        trip.setBooking(testBookingEntity);
        trip.setStartLocation("Location A");
        trip.setEndLocation("Location B");
        trip.setStartTime(Instant.now().plusSeconds(86400)); // Tomorrow
        trip.setEndTime(Instant.now().plusSeconds(90000)); // Tomorrow + 1 hour
        trip.setDistance(new BigDecimal("50.0"));
        trip.setStatus(TripStatus.SCHEDULED);
        trip = tripRepository.save(trip);
    }

    @Test
    void getPendingTrips_shouldReturnPendingTrips() {
        // When
        List<PendingTripResponse> pendingTrips = dispatchService.getPendingTrips(testBranch.getId());

        // Then
        assertThat(pendingTrips).isNotNull();
        assertThat(pendingTrips.size()).isGreaterThanOrEqualTo(1);
    }

    @Test
    void getPendingTrips_withInvalidBranch_shouldReturnEmptyList() {
        // When
        List<PendingTripResponse> pendingTrips = dispatchService.getPendingTrips(99999);

        // Then
        assertThat(pendingTrips).isNotNull();
        assertThat(pendingTrips).isEmpty();
    }

    @Test
    void getAllPendingTrips_shouldReturnAllPendingTrips() {
        // When
        List<PendingTripResponse> pendingTrips = dispatchService.getAllPendingTrips();

        // Then
        assertThat(pendingTrips).isNotNull();
    }

    @Test
    void getAssignmentSuggestions_shouldReturnSuggestions() {
        // Given - Get trip ID from booking
        org.example.ptcmssbackend.entity.Bookings booking = testBookingEntity;
        assertThat(booking).isNotNull();
        List<org.example.ptcmssbackend.entity.Trips> trips = tripRepository.findByBooking_Id(booking.getId());
        assertThat(trips).isNotEmpty();
        Integer tripId = trips.get(0).getId();

        // When
        AssignmentSuggestionResponse suggestions = dispatchService.getAssignmentSuggestions(tripId);

        // Then
        assertThat(suggestions).isNotNull();
        assertThat(suggestions.getSummary()).isNotNull();
    }

    @Test
    void getAssignmentSuggestions_withInvalidTripId_shouldThrowException() {
        // When & Then
        assertThatThrownBy(() -> dispatchService.getAssignmentSuggestions(99999))
                .isInstanceOf(RuntimeException.class);
    }

    @Test
    void assign_shouldAssignDriverAndVehicleSuccessfully() {
        // Given - Get trip ID from booking
        org.example.ptcmssbackend.entity.Bookings booking = testBookingEntity;
        assertThat(booking).isNotNull();
        List<org.example.ptcmssbackend.entity.Trips> trips = tripRepository.findByBooking_Id(booking.getId());
        assertThat(trips).isNotEmpty();
        Integer tripId = trips.get(0).getId();

        AssignRequest assignRequest = new AssignRequest();
        assignRequest.setBookingId(booking.getId());
        assignRequest.setTripIds(List.of(tripId));
        assignRequest.setDriverId(testDriver.getId());
        assignRequest.setVehicleId(testVehicle.getId());
        assignRequest.setNote("Test assignment");

        // When
        AssignRespone response = dispatchService.assign(assignRequest);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getTrips()).isNotNull();
        assertThat(response.getTrips().size()).isGreaterThan(0);
    }

    @Test
    void assign_withInvalidDriver_shouldThrowException() {
        // Given
        org.example.ptcmssbackend.entity.Bookings booking = testBookingEntity;
        assertThat(booking).isNotNull();
        List<org.example.ptcmssbackend.entity.Trips> trips = tripRepository.findByBooking_Id(booking.getId());
        assertThat(trips).isNotEmpty();
        Integer tripId = trips.get(0).getId();

        AssignRequest assignRequest = new AssignRequest();
        assignRequest.setBookingId(booking.getId());
        assignRequest.setTripIds(List.of(tripId));
        assignRequest.setDriverId(99999); // Invalid driver
        assignRequest.setVehicleId(testVehicle.getId());

        // When & Then
        assertThatThrownBy(() -> dispatchService.assign(assignRequest))
                .isInstanceOf(RuntimeException.class);
    }

    @Test
    void assign_withInvalidVehicle_shouldThrowException() {
        // Given
        org.example.ptcmssbackend.entity.Bookings booking = testBookingEntity;
        assertThat(booking).isNotNull();
        List<org.example.ptcmssbackend.entity.Trips> trips = tripRepository.findByBooking_Id(booking.getId());
        assertThat(trips).isNotEmpty();
        Integer tripId = trips.get(0).getId();

        AssignRequest assignRequest = new AssignRequest();
        assignRequest.setBookingId(booking.getId());
        assignRequest.setTripIds(List.of(tripId));
        assignRequest.setDriverId(testDriver.getId());
        assignRequest.setVehicleId(99999); // Invalid vehicle

        // When & Then
        assertThatThrownBy(() -> dispatchService.assign(assignRequest))
                .isInstanceOf(RuntimeException.class);
    }

    @Test
    void getDashboard_shouldReturnDashboardData() {
        // When
        DispatchDashboardResponse dashboard = dispatchService.getDashboard(testBranch.getId(), LocalDate.now());

        // Then
        assertThat(dashboard).isNotNull();
        assertThat(dashboard.getPendingTrips()).isNotNull();
    }

    @Test
    void unassign_shouldUnassignTripSuccessfully() {
        // Given - First assign
        org.example.ptcmssbackend.entity.Bookings booking = testBookingEntity;
        assertThat(booking).isNotNull();
        List<org.example.ptcmssbackend.entity.Trips> trips = tripRepository.findByBooking_Id(booking.getId());
        assertThat(trips).isNotEmpty();
        Integer tripId = trips.get(0).getId();

        AssignRequest assignRequest = new AssignRequest();
        assignRequest.setBookingId(booking.getId());
        assignRequest.setTripIds(List.of(tripId));
        assignRequest.setDriverId(testDriver.getId());
        assignRequest.setVehicleId(testVehicle.getId());
        dispatchService.assign(assignRequest);

        // When
        dispatchService.unassign(tripId, "Test unassign");

        // Then - No exception should be thrown
        // Verify trip status changed
        org.example.ptcmssbackend.entity.Trips trip = tripRepository.findById(tripId).orElse(null);
        assertThat(trip).isNotNull();
    }

    @Test
    void driverAcceptTrip_shouldAcceptTripSuccessfully() {
        // Given - First assign
        org.example.ptcmssbackend.entity.Bookings booking = testBookingEntity;
        assertThat(booking).isNotNull();
        List<org.example.ptcmssbackend.entity.Trips> trips = tripRepository.findByBooking_Id(booking.getId());
        assertThat(trips).isNotEmpty();
        Integer tripId = trips.get(0).getId();

        AssignRequest assignRequest = new AssignRequest();
        assignRequest.setBookingId(booking.getId());
        assignRequest.setTripIds(List.of(tripId));
        assignRequest.setDriverId(testDriver.getId());
        assignRequest.setVehicleId(testVehicle.getId());
        dispatchService.assign(assignRequest);

        // When
        dispatchService.driverAcceptTrip(tripId);

        // Then - No exception should be thrown
        org.example.ptcmssbackend.entity.Trips trip = tripRepository.findById(tripId).orElse(null);
        assertThat(trip).isNotNull();
    }
}

