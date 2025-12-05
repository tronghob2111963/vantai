package org.example.ptcmssbackend.service;

import org.example.ptcmssbackend.dto.request.Driver.DriverDayOffRequest;
import org.example.ptcmssbackend.dto.request.Driver.DriverProfileUpdateRequest;
import org.example.ptcmssbackend.dto.response.Driver.DriverDayOffResponse;
import org.example.ptcmssbackend.entity.*;
import org.example.ptcmssbackend.enums.ApprovalType;
import org.example.ptcmssbackend.enums.DriverDayOffStatus;
import org.example.ptcmssbackend.enums.DriverStatus;
import org.example.ptcmssbackend.enums.TripStatus;
import org.example.ptcmssbackend.repository.*;
import org.example.ptcmssbackend.service.impl.DriverServiceImpl;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DriverServiceImplTest {

    @Mock
    private DriverRepository driverRepository;
    @Mock
    private TripRepository tripRepository;
    @Mock
    private TripDriverRepository tripDriverRepository;
    @Mock
    private TripVehicleRepository tripVehicleRepository;
    @Mock
    private DriverDayOffRepository driverDayOffRepository;
    @Mock
    private TripIncidentRepository tripIncidentRepository;
    @Mock
    private BranchesRepository branchRepository;
    @Mock
    private EmployeeRepository employeeRepository;
    @Mock
    private ApprovalService approvalService;
    @Mock
    private DriverRatingsRepository driverRatingsRepository;
    @Mock
    private GraphHopperService graphHopperService;
    @Mock
    private InvoiceRepository invoiceRepository;

    @InjectMocks
    private DriverServiceImpl driverService;

    @AfterEach
    void clearContext() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void updateProfile_coordinatorCannotSetInvalidStatus() {
        mockAuth("ROLE_COORDINATOR");

        Drivers driver = buildDriver();
        driver.setStatus(DriverStatus.ACTIVE);

        when(driverRepository.findById(1)).thenReturn(Optional.of(driver));

        DriverProfileUpdateRequest request = new DriverProfileUpdateRequest();
        request.setStatus("ON_TRIP");

        assertThatThrownBy(() -> driverService.updateProfile(1, request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Điều phối viên chỉ được phép chuyển tài xế");

        verify(driverRepository, never()).save(any());
    }

    @Test
    void updateProfile_shouldUpdateFieldsForAdmin() {
        mockAuth("ROLE_ADMIN");

        Drivers driver = buildDriver();
        driver.setStatus(DriverStatus.ACTIVE);
        when(driverRepository.findById(1)).thenReturn(Optional.of(driver));
        when(driverRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        DriverProfileUpdateRequest request = new DriverProfileUpdateRequest();
        request.setPhone("0909000999");
        request.setAddress("35 Lê Lợi");
        request.setStatus("INACTIVE");
        request.setNote("Updated");

        var response = driverService.updateProfile(1, request);

        assertThat(response.getPhone()).isEqualTo("0909000999");
        assertThat(driver.getStatus()).isEqualTo(DriverStatus.INACTIVE);
        verify(driverRepository).save(driver);
    }

    @Test
    void requestDayOff_shouldPersistAndCreateApproval() {
        Drivers driver = buildDriver();
        Branches branch = new Branches();
        branch.setId(5);
        branch.setBranchName("Chi nhánh HCM");
        driver.setBranch(branch);

        when(driverRepository.findById(1)).thenReturn(Optional.of(driver));
        when(driverDayOffRepository.save(any())).thenAnswer(inv -> {
            DriverDayOff entity = inv.getArgument(0);
            entity.setId(50);
            return entity;
        });

        DriverDayOffRequest request = new DriverDayOffRequest();
        request.setStartDate(LocalDate.of(2025, 12, 1));
        request.setEndDate(LocalDate.of(2025, 12, 3));
        request.setReason("Nghỉ ốm");

        DriverDayOffResponse response = driverService.requestDayOff(1, request);

        assertThat(response.getStatus()).isEqualTo(DriverDayOffStatus.PENDING);
        assertThat(response.getStartDate()).isEqualTo(request.getStartDate());
        verify(driverDayOffRepository).save(any());
        verify(approvalService).createApprovalRequest(eq(ApprovalType.DRIVER_DAY_OFF), eq(50), any(), eq("Nghỉ ốm"), eq(branch));
    }

    private Drivers buildDriver() {
        Users user = new Users();
        user.setFullName("Nguyễn Văn A");
        user.setPhone("0909000990");
        user.setAddress("Đà Nẵng");

        Employees employee = new Employees();
        employee.setUser(user);

        Drivers driver = new Drivers();
        driver.setId(1);
        driver.setEmployee(employee);
        driver.setStatus(DriverStatus.ACTIVE);
        driver.setBranch(new Branches());
        return driver;
    }

    private void mockAuth(String... roles) {
        List<GrantedAuthority> authorities = roles == null ? Collections.emptyList() :
                java.util.Arrays.stream(roles)
                        .map(role -> (GrantedAuthority) () -> role)
                        .collect(Collectors.toList());

        Authentication authentication = mock(Authentication.class);
        when(authentication.getAuthorities()).thenReturn((java.util.Collection) authorities);

        SecurityContext context = mock(SecurityContext.class);
        when(context.getAuthentication()).thenReturn(authentication);
        SecurityContextHolder.setContext(context);
    }

    // ==================== startTrip() Tests ====================

    @Test
    void startTrip_whenValidRequest_shouldStartTripSuccessfully() {
        // Given
        Integer tripId = 100;
        Integer driverId = 1;

        Trips trip = new Trips();
        trip.setId(tripId);
        trip.setStatus(TripStatus.SCHEDULED);
        trip.setStartTime(null);

        when(tripRepository.findById(tripId)).thenReturn(Optional.of(trip));
        when(tripDriverRepository.existsByTrip_IdAndDriver_Id(tripId, driverId)).thenReturn(true);
        when(tripRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        Integer result = driverService.startTrip(tripId, driverId);

        // Then
        assertThat(result).isEqualTo(tripId);
        assertThat(trip.getStatus()).isEqualTo(TripStatus.ONGOING);
        assertThat(trip.getStartTime()).isNotNull();
        verify(tripRepository).save(trip);
    }

    @Test
    void startTrip_whenTripNotFound_shouldThrowException() {
        // Given
        Integer tripId = 999;
        Integer driverId = 1;

        when(tripRepository.findById(tripId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> driverService.startTrip(tripId, driverId))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Không tìm thấy chuyến đi");
    }

    @Test
    void startTrip_whenDriverNotAssigned_shouldThrowException() {
        // Given
        Integer tripId = 100;
        Integer driverId = 1;

        Trips trip = new Trips();
        trip.setId(tripId);
        trip.setStatus(TripStatus.SCHEDULED);

        when(tripRepository.findById(tripId)).thenReturn(Optional.of(trip));
        when(tripDriverRepository.existsByTrip_IdAndDriver_Id(tripId, driverId)).thenReturn(false);

        // When & Then
        assertThatThrownBy(() -> driverService.startTrip(tripId, driverId))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Tài xế không được phân công cho chuyến đi này");
    }

    @Test
    void startTrip_whenInvalidStatus_shouldThrowException() {
        // Given
        Integer tripId = 100;
        Integer driverId = 1;

        Trips trip = new Trips();
        trip.setId(tripId);
        trip.setStatus(TripStatus.COMPLETED); // Invalid status

        when(tripRepository.findById(tripId)).thenReturn(Optional.of(trip));
        when(tripDriverRepository.existsByTrip_IdAndDriver_Id(tripId, driverId)).thenReturn(true);

        // When & Then
        assertThatThrownBy(() -> driverService.startTrip(tripId, driverId))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Chuyến đi không ở trạng thái ĐÃ LÊN LỊCH hoặc ĐÃ PHÂN XE");
    }

    @Test
    void startTrip_whenStatusIsAssigned_shouldStartSuccessfully() {
        // Given
        Integer tripId = 100;
        Integer driverId = 1;

        Trips trip = new Trips();
        trip.setId(tripId);
        trip.setStatus(TripStatus.ASSIGNED); // Valid status
        trip.setStartTime(null);

        when(tripRepository.findById(tripId)).thenReturn(Optional.of(trip));
        when(tripDriverRepository.existsByTrip_IdAndDriver_Id(tripId, driverId)).thenReturn(true);
        when(tripRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        Integer result = driverService.startTrip(tripId, driverId);

        // Then
        assertThat(result).isEqualTo(tripId);
        assertThat(trip.getStatus()).isEqualTo(TripStatus.ONGOING);
        verify(tripRepository).save(trip);
    }

    // ==================== completeTrip() Tests ====================

    @Test
    void completeTrip_whenValidRequest_shouldCompleteTripSuccessfully() {
        // Given
        Integer tripId = 100;
        Integer driverId = 1;

        Trips trip = new Trips();
        trip.setId(tripId);
        trip.setStatus(TripStatus.ONGOING);
        trip.setEndTime(null);

        when(tripRepository.findById(tripId)).thenReturn(Optional.of(trip));
        when(tripDriverRepository.existsByTrip_IdAndDriver_Id(tripId, driverId)).thenReturn(true);
        when(tripRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        Integer result = driverService.completeTrip(tripId, driverId);

        // Then
        assertThat(result).isEqualTo(tripId);
        assertThat(trip.getStatus()).isEqualTo(TripStatus.COMPLETED);
        assertThat(trip.getEndTime()).isNotNull();
        verify(tripRepository).save(trip);
    }

    @Test
    void completeTrip_whenTripNotFound_shouldThrowException() {
        // Given
        Integer tripId = 999;
        Integer driverId = 1;

        when(tripRepository.findById(tripId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> driverService.completeTrip(tripId, driverId))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Không tìm thấy chuyến đi");
    }

    @Test
    void completeTrip_whenDriverNotAssigned_shouldThrowException() {
        // Given
        Integer tripId = 100;
        Integer driverId = 1;

        Trips trip = new Trips();
        trip.setId(tripId);
        trip.setStatus(TripStatus.ONGOING);

        when(tripRepository.findById(tripId)).thenReturn(Optional.of(trip));
        when(tripDriverRepository.existsByTrip_IdAndDriver_Id(tripId, driverId)).thenReturn(false);

        // When & Then
        assertThatThrownBy(() -> driverService.completeTrip(tripId, driverId))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Tài xế không được phân công cho chuyến đi này");
    }

    @Test
    void completeTrip_whenInvalidStatus_shouldThrowException() {
        // Given
        Integer tripId = 100;
        Integer driverId = 1;

        Trips trip = new Trips();
        trip.setId(tripId);
        trip.setStatus(TripStatus.SCHEDULED); // Invalid status (not ONGOING or ASSIGNED)

        when(tripRepository.findById(tripId)).thenReturn(Optional.of(trip));
        when(tripDriverRepository.existsByTrip_IdAndDriver_Id(tripId, driverId)).thenReturn(true);

        // When & Then
        assertThatThrownBy(() -> driverService.completeTrip(tripId, driverId))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Chuyến đi không ở trạng thái ĐANG THỰC HIỆN hoặc ĐÃ PHÂN XE");
    }

    @Test
    void completeTrip_whenStatusIsAssigned_shouldCompleteSuccessfully() {
        // Given
        Integer tripId = 100;
        Integer driverId = 1;

        Trips trip = new Trips();
        trip.setId(tripId);
        trip.setStatus(TripStatus.ASSIGNED); // Valid status
        trip.setEndTime(null);

        when(tripRepository.findById(tripId)).thenReturn(Optional.of(trip));
        when(tripDriverRepository.existsByTrip_IdAndDriver_Id(tripId, driverId)).thenReturn(true);
        when(tripRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        Integer result = driverService.completeTrip(tripId, driverId);

        // Then
        assertThat(result).isEqualTo(tripId);
        assertThat(trip.getStatus()).isEqualTo(TripStatus.COMPLETED);
        verify(tripRepository).save(trip);
    }
}

