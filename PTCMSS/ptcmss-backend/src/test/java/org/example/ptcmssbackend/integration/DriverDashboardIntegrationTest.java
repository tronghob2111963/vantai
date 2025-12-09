package org.example.ptcmssbackend.integration;

import org.example.ptcmssbackend.dto.request.Driver.DriverDayOffRequest;
import org.example.ptcmssbackend.dto.request.Driver.ReportIncidentRequest;
import org.example.ptcmssbackend.dto.response.Driver.DriverDashboardResponse;
import org.example.ptcmssbackend.dto.response.Driver.DriverDayOffResponse;
import org.example.ptcmssbackend.dto.response.Driver.DriverProfileResponse;
import org.example.ptcmssbackend.dto.response.Driver.DriverScheduleResponse;
import org.example.ptcmssbackend.dto.response.Driver.TripIncidentResponse;
import org.example.ptcmssbackend.entity.*;
import org.example.ptcmssbackend.enums.*;
import org.example.ptcmssbackend.repository.*;
import org.example.ptcmssbackend.service.DriverService;
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

class DriverDashboardIntegrationTest extends BaseIntegrationTest {

    @Autowired
    private DriverService driverService;

    @Autowired
    private DriverRepository driverRepository;

    @Autowired
    private BranchesRepository branchesRepository;

    @Autowired
    private CustomerRepository customerRepository;

    @Autowired
    private EmployeeRepository employeeRepository;

    @Autowired
    private UsersRepository usersRepository;

    @Autowired
    private RolesRepository rolesRepository;

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private TripRepository tripRepository;

    @Autowired
    private TripDriversRepository tripDriversRepository;

    @Autowired
    private VehicleRepository vehicleRepository;

    @Autowired
    private VehicleCategoryPricingRepository vehicleCategoryPricingRepository;

    @Autowired
    private TripVehicleRepository tripVehicleRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private Branches testBranch;
    private Drivers testDriver;
    private Bookings testBooking;
    private Trips testTrip;

    @BeforeEach
    void setUp() {
        // Create test branch
        testBranch = new Branches();
        testBranch.setBranchName("Test Branch");
        testBranch.setLocation("123 Test Street");
        testBranch.setStatus(BranchStatus.ACTIVE);
        testBranch = branchesRepository.save(testBranch);

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
        testDriver.setRating(new BigDecimal("4.5"));
        testDriver = driverRepository.saveAndFlush(testDriver);

        // Create a test booking and trip for driver
        Customers testCustomer = new Customers();
        testCustomer.setFullName("Test Customer");
        testCustomer.setPhone("0987654321");
        testCustomer.setStatus(CustomerStatus.ACTIVE);
        testCustomer = customerRepository.save(testCustomer);

        testBooking = new Bookings();
        testBooking.setCustomer(testCustomer);
        testBooking.setBranch(testBranch);
        testBooking.setStatus(BookingStatus.CONFIRMED);
        testBooking = bookingRepository.save(testBooking);

        // Create vehicle category and vehicle
        VehicleCategoryPricing category = new VehicleCategoryPricing();
        category.setCategoryName("Sedan");
        category.setBaseFare(new BigDecimal("500000"));
        category.setPricePerKm(new BigDecimal("10000"));
        category.setStatus(VehicleCategoryStatus.ACTIVE);
        category = vehicleCategoryPricingRepository.save(category);

        Vehicles testVehicle = new Vehicles();
        testVehicle.setCategory(category);
        testVehicle.setBranch(testBranch);
        testVehicle.setLicensePlate("30A-12345");
        testVehicle.setStatus(VehicleStatus.AVAILABLE);
        testVehicle = vehicleRepository.save(testVehicle);

        testTrip = new Trips();
        testTrip.setBooking(testBooking);
        testTrip.setStartTime(Instant.now().plusSeconds(86400));
        testTrip.setStartLocation("Location A");
        testTrip.setEndLocation("Location B");
        testTrip.setStatus(TripStatus.ASSIGNED);
        testTrip.setDistance(new BigDecimal("50.0"));
        testTrip = tripRepository.saveAndFlush(testTrip);

        // Assign vehicle to trip
        TripVehicles tripVehicle = new TripVehicles();
        tripVehicle.setTrip(testTrip);
        tripVehicle.setVehicle(testVehicle);
        tripVehicleRepository.saveAndFlush(tripVehicle);

        // Assign driver to trip - must set id manually as @MapsId may not auto-populate
        // Ensure both IDs are available
        Integer tripId = testTrip.getId();
        Integer driverId = testDriver.getId();
        if (tripId == null || driverId == null) {
            throw new IllegalStateException("Trip ID or Driver ID is null. Trip ID: " + tripId + ", Driver ID: " + driverId);
        }
        
        TripDriverId tripDriverId = new TripDriverId();
        tripDriverId.setTripId(tripId);
        tripDriverId.setDriverId(driverId);
        
        TripDrivers tripDriver = new TripDrivers();
        tripDriver.setId(tripDriverId);
        tripDriver.setTrip(testTrip);
        tripDriver.setDriver(testDriver);
        tripDriver.setDriverRole("Main Driver");
        tripDriversRepository.saveAndFlush(tripDriver);
    }

    @Test
    void getDashboard_shouldReturnDriverDashboard() {
        // When
        DriverDashboardResponse dashboard = driverService.getDashboard(testDriver.getId());

        // Then
        assertThat(dashboard).isNotNull();
        assertThat(dashboard.getDriverName()).isNotNull();
    }

    @Test
    void getDashboard_withInvalidDriverId_shouldThrowException() {
        // When & Then
        assertThatThrownBy(() -> driverService.getDashboard(99999))
                .isInstanceOf(RuntimeException.class);
    }

    @Test
    void getSchedule_shouldReturnSchedule() {
        // When
        List<DriverScheduleResponse> schedule = driverService.getSchedule(
            testDriver.getId(),
            Instant.now(),
            Instant.now().plusSeconds(86400 * 7) // Next 7 days
        );

        // Then
        assertThat(schedule).isNotNull();
    }

    @Test
    void getSchedule_withNullDates_shouldReturnSchedule() {
        // When
        List<DriverScheduleResponse> schedule = driverService.getSchedule(
            testDriver.getId(),
            null,
            null
        );

        // Then
        assertThat(schedule).isNotNull();
    }

    @Test
    void getProfile_shouldReturnDriverProfile() {
        // When
        DriverProfileResponse profile = driverService.getProfile(testDriver.getId());

        // Then
        assertThat(profile).isNotNull();
        assertThat(profile.getDriverId()).isEqualTo(testDriver.getId());
        assertThat(profile.getLicenseNumber()).isEqualTo("TEST-D001");
    }

    @Test
    void getProfileByUserId_shouldReturnDriverProfile() {
        // Given
        Integer userId = testDriver.getEmployee().getUser().getId();

        // When
        DriverProfileResponse profile = driverService.getProfileByUserId(userId);

        // Then
        assertThat(profile).isNotNull();
        assertThat(profile.getDriverId()).isEqualTo(testDriver.getId());
    }

    @Test
    void requestDayOff_shouldCreateDayOffRequest() {
        // Given
        DriverDayOffRequest request = new DriverDayOffRequest();
        request.setStartDate(LocalDate.now().plusDays(7));
        request.setEndDate(LocalDate.now().plusDays(8));
        request.setReason("Personal matter");

        // When
        DriverDayOffResponse response = driverService.requestDayOff(testDriver.getId(), request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getStatus()).isEqualTo("PENDING");
    }

    @Test
    void requestDayOff_withInvalidDateRange_shouldThrowException() {
        // Given
        DriverDayOffRequest request = new DriverDayOffRequest();
        request.setStartDate(LocalDate.now().plusDays(8));
        request.setEndDate(LocalDate.now().plusDays(7)); // End before start
        request.setReason("Test");

        // When & Then
        assertThatThrownBy(() -> driverService.requestDayOff(testDriver.getId(), request))
                .isInstanceOf(RuntimeException.class);
    }

    @Test
    void getDayOffHistory_shouldReturnHistory() {
        // Given - Create a day off request first
        DriverDayOffRequest request = new DriverDayOffRequest();
        request.setStartDate(LocalDate.now().plusDays(7));
        request.setEndDate(LocalDate.now().plusDays(8));
        request.setReason("Test");
        driverService.requestDayOff(testDriver.getId(), request);

        // When
        List<DriverDayOffResponse> history = driverService.getDayOffHistory(testDriver.getId());

        // Then
        assertThat(history).isNotNull();
        assertThat(history.size()).isGreaterThanOrEqualTo(1);
    }

    @Test
    void reportIncident_shouldCreateIncident() {
        // Given
        ReportIncidentRequest request = new ReportIncidentRequest();
        request.setTripId(testTrip.getId());
        request.setDriverId(testDriver.getId());
        request.setDescription("Test incident");
        request.setSeverity("LOW");

        // When
        TripIncidentResponse response = driverService.reportIncident(request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getDescription()).isEqualTo("Test incident");
    }

    @Test
    void reportIncident_withInvalidTrip_shouldThrowException() {
        // Given
        ReportIncidentRequest request = new ReportIncidentRequest();
        request.setTripId(99999); // Invalid trip
        request.setDriverId(testDriver.getId());
        request.setDescription("Test");
        request.setSeverity("LOW");

        // When & Then
        assertThatThrownBy(() -> driverService.reportIncident(request))
                .isInstanceOf(RuntimeException.class);
    }

    @Test
    void startTrip_shouldStartTrip() {
        // When
        Integer result = driverService.startTrip(testTrip.getId(), testDriver.getId());

        // Then
        assertThat(result).isNotNull();
        
        // Verify trip status changed
        Trips trip = tripRepository.findById(testTrip.getId()).orElse(null);
        assertThat(trip).isNotNull();
        assertThat(trip.getStatus()).isEqualTo(TripStatus.ONGOING);
    }

    @Test
    void completeTrip_shouldCompleteTrip() {
        // Given - First start the trip
        driverService.startTrip(testTrip.getId(), testDriver.getId());

        // When
        Integer result = driverService.completeTrip(testTrip.getId(), testDriver.getId());

        // Then
        assertThat(result).isNotNull();
        
        // Verify trip status changed
        Trips trip = tripRepository.findById(testTrip.getId()).orElse(null);
        assertThat(trip).isNotNull();
        assertThat(trip.getStatus()).isEqualTo(TripStatus.COMPLETED);
    }
}

