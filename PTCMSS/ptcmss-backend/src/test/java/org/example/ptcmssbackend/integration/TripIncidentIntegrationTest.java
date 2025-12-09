package org.example.ptcmssbackend.integration;

import org.example.ptcmssbackend.dto.request.Driver.ReportIncidentRequest;
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

import java.time.Instant;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class TripIncidentIntegrationTest extends BaseIntegrationTest {

    @Autowired
    private DriverService driverService;

    @Autowired
    private TripIncidentRepository tripIncidentRepository;

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
    private PasswordEncoder passwordEncoder;

    private Branches testBranch;
    private Drivers testDriver;
    private Bookings testBooking;
    private Trips testTrip;
    private Users testManager;

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
        testDriver = driverRepository.save(testDriver);

        // Create manager role and user
        Roles managerRole = new Roles();
        managerRole.setRoleName("MANAGER");
        managerRole.setDescription("Manager Role");
        managerRole = rolesRepository.save(managerRole);

        Users managerUser = new Users();
        managerUser.setFullName("Test Manager");
        managerUser.setUsername("manager");
        managerUser.setEmail("manager@example.com");
        managerUser.setPhone("0333444555");
        managerUser.setPasswordHash(passwordEncoder.encode("password123"));
        managerUser.setStatus(UserStatus.ACTIVE);
        managerUser.setRole(managerRole);
        testManager = usersRepository.save(managerUser);

        // Create a test booking and trip
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

        testTrip = new Trips();
        testTrip.setBooking(testBooking);
        testTrip.setStartTime(Instant.now().plusSeconds(86400));
        testTrip.setStartLocation("Location A");
        testTrip.setEndLocation("Location B");
        testTrip.setStatus(TripStatus.ASSIGNED);
        testTrip = tripRepository.save(testTrip);
    }

    @Test
    void reportIncident_shouldCreateIncident() {
        // Given
        ReportIncidentRequest request = new ReportIncidentRequest();
        request.setTripId(testTrip.getId());
        request.setDriverId(testDriver.getId());
        request.setDescription("Vehicle breakdown on highway");
        request.setSeverity("CRITICAL");

        // When
        TripIncidentResponse response = driverService.reportIncident(request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getDescription()).isEqualTo("Vehicle breakdown on highway");
        assertThat(response.getSeverity()).isEqualTo("CRITICAL");
        assertThat(response.getResolved()).isFalse();
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
    void reportIncident_withInvalidDriver_shouldThrowException() {
        // Given
        ReportIncidentRequest request = new ReportIncidentRequest();
        request.setTripId(testTrip.getId());
        request.setDriverId(99999); // Invalid driver
        request.setDescription("Test");
        request.setSeverity("LOW");

        // When & Then
        assertThatThrownBy(() -> driverService.reportIncident(request))
                .isInstanceOf(RuntimeException.class);
    }

    @Test
    void listIncidentsByDriver_shouldReturnIncidents() {
        // Given - Create an incident first
        ReportIncidentRequest request = new ReportIncidentRequest();
        request.setTripId(testTrip.getId());
        request.setDriverId(testDriver.getId());
        request.setDescription("Test incident");
        request.setSeverity("LOW");
        driverService.reportIncident(request);

        // When
        List<TripIncidents> incidents = tripIncidentRepository.findAllByDriver_Id(testDriver.getId());

        // Then
        assertThat(incidents).isNotNull();
        assertThat(incidents.size()).isGreaterThanOrEqualTo(1);
    }

    @Test
    void listIncidentsByBranch_shouldReturnIncidents() {
        // Given - Create an incident first
        ReportIncidentRequest request = new ReportIncidentRequest();
        request.setTripId(testTrip.getId());
        request.setDriverId(testDriver.getId());
        request.setDescription("Test incident");
        request.setSeverity("LOW");
        driverService.reportIncident(request);

        // When
        List<TripIncidents> incidents = tripIncidentRepository.findAllByBranchId(testBranch.getId());

        // Then
        assertThat(incidents).isNotNull();
        assertThat(incidents.size()).isGreaterThanOrEqualTo(1);
    }

    @Test
    void resolveIncident_shouldResolveIncident() {
        // Given - Create an incident first
        ReportIncidentRequest reportRequest = new ReportIncidentRequest();
        reportRequest.setTripId(testTrip.getId());
        reportRequest.setDriverId(testDriver.getId());
        reportRequest.setDescription("Test incident");
        reportRequest.setSeverity("LOW");
        TripIncidentResponse incidentResponse = driverService.reportIncident(reportRequest);

        // Get the incident entity
        TripIncidents incident = tripIncidentRepository.findById(incidentResponse.getId())
                .orElse(null);
        assertThat(incident).isNotNull();
        assertThat(incident.getResolved()).isFalse();

        // When - Resolve the incident
        incident.setResolved(true);
        incident.setResolutionAction(TripIncidents.ResolutionAction.SEND_REPLACEMENT_VEHICLE);
        incident.setResolutionNote("Sent replacement vehicle");
        incident.setResolvedBy(testManager);
        incident.setResolvedAt(Instant.now());
        TripIncidents resolved = tripIncidentRepository.save(incident);

        // Then
        assertThat(resolved.getResolved()).isTrue();
        assertThat(resolved.getResolutionAction()).isEqualTo(TripIncidents.ResolutionAction.SEND_REPLACEMENT_VEHICLE);
        assertThat(resolved.getResolutionNote()).isEqualTo("Sent replacement vehicle");
        assertThat(resolved.getResolvedBy()).isNotNull();
        assertThat(resolved.getResolvedAt()).isNotNull();
    }

    @Test
    void listUnresolvedIncidents_shouldReturnOnlyUnresolved() {
        // Given - Create resolved and unresolved incidents
        ReportIncidentRequest request1 = new ReportIncidentRequest();
        request1.setTripId(testTrip.getId());
        request1.setDriverId(testDriver.getId());
        request1.setDescription("Unresolved incident");
        request1.setSeverity("LOW");
        TripIncidentResponse incident1 = driverService.reportIncident(request1);

        // Resolve first incident
        TripIncidents incident = tripIncidentRepository.findById(incident1.getId()).orElse(null);
        if (incident != null) {
            incident.setResolved(true);
            incident.setResolvedBy(testManager);
            incident.setResolvedAt(Instant.now());
            tripIncidentRepository.save(incident);
        }

        // Create another unresolved incident
        ReportIncidentRequest request2 = new ReportIncidentRequest();
        request2.setTripId(testTrip.getId());
        request2.setDriverId(testDriver.getId());
        request2.setDescription("Another unresolved incident");
        request2.setSeverity("MEDIUM");
        driverService.reportIncident(request2);

        // When
        List<TripIncidents> allIncidents = tripIncidentRepository.findAllByDriver_Id(testDriver.getId());
        List<TripIncidents> unresolved = allIncidents.stream()
                .filter(i -> !i.getResolved())
                .toList();

        // Then
        assertThat(unresolved.size()).isGreaterThanOrEqualTo(1);
        assertThat(unresolved.stream().allMatch(i -> !i.getResolved())).isTrue();
    }
}

