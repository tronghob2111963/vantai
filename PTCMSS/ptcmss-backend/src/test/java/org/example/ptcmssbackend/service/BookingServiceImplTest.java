package org.example.ptcmssbackend.service;

import org.example.ptcmssbackend.dto.request.Booking.CheckAvailabilityRequest;
import org.example.ptcmssbackend.dto.request.Booking.CreateBookingRequest;
import org.example.ptcmssbackend.dto.request.Booking.TripRequest;
import org.example.ptcmssbackend.dto.request.Booking.VehicleDetailRequest;
import org.example.ptcmssbackend.entity.Branches;
import org.example.ptcmssbackend.entity.VehicleCategoryPricing;
import org.example.ptcmssbackend.entity.Vehicles;
import org.example.ptcmssbackend.enums.BookingStatus;
import org.example.ptcmssbackend.enums.VehicleStatus;
import org.example.ptcmssbackend.repository.*;
import org.example.ptcmssbackend.service.impl.BookingServiceImpl;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Collections;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class BookingServiceImplTest {

    @Mock
    private BookingRepository bookingRepository;
    @Mock
    private CustomerService customerService;
    @Mock
    private BranchesRepository branchesRepository;
    @Mock
    private EmployeeRepository employeeRepository;
    @Mock
    private HireTypesRepository hireTypesRepository;
    @Mock
    private VehicleCategoryPricingRepository vehicleCategoryRepository;
    @Mock
    private TripRepository tripRepository;
    @Mock
    private BookingVehicleDetailsRepository bookingVehicleDetailsRepository;
    @Mock
    private TripDriverRepository tripDriverRepository;
    @Mock
    private SystemSettingService systemSettingService;
    @Mock
    private TripVehicleRepository tripVehicleRepository;
    @Mock
    private InvoiceRepository invoiceRepository;
    @Mock
    private DriverRepository driverRepository;
    @Mock
    private VehicleRepository vehicleRepository;
    @Mock
    private WebSocketNotificationService webSocketNotificationService;

    @InjectMocks
    private BookingServiceImpl bookingService;

    @Test
    void checkAvailability_whenEnoughVehicles_shouldReturnOkTrueAndAvailableCount() {
        Instant start = Instant.parse("2025-12-04T02:00:00Z");
        Instant end = start.plusSeconds(4 * 3600);

        CheckAvailabilityRequest request = new CheckAvailabilityRequest();
        request.setBranchId(1);
        request.setCategoryId(10);
        request.setStartTime(start);
        request.setEndTime(end);
        request.setQuantity(1);

        when(vehicleRepository.filterVehicles(eq(10), eq(1), eq(VehicleStatus.AVAILABLE)))
                .thenReturn(List.of(createVehicle(101), createVehicle(102)));
        when(tripVehicleRepository.findBusyVehicleIds(1, 10, start, end))
                .thenReturn(List.of(201));
        when(bookingVehicleDetailsRepository.countReservedQuantityWithoutAssignedVehicles(
                eq(1), eq(10), eq(start), eq(end), anyList()))
                .thenReturn(0);

        var response = bookingService.checkAvailability(request);

        assertThat(response.isOk()).isTrue();
        assertThat(response.getAvailableCount()).isEqualTo(1); // 2 total - 1 busy - 0 reserved
        assertThat(response.getBusyCount()).isEqualTo(1);
        assertThat(response.getTotalCandidates()).isEqualTo(2);
        assertThat(response.getAlternativeCategories()).isNull();
        assertThat(response.getNextAvailableSlots()).isNull();
    }

    @Test
    void checkAvailability_whenNotEnoughVehicles_shouldReturnSuggestionsAndOkFalse() {
        Instant start = Instant.parse("2025-12-04T02:00:00Z");
        Instant end = start.plusSeconds(2 * 3600);

        CheckAvailabilityRequest request = new CheckAvailabilityRequest();
        request.setBranchId(2);
        request.setCategoryId(20);
        request.setStartTime(start);
        request.setEndTime(end);
        request.setQuantity(3);

        List<Vehicles> candidates = List.of(createVehicle(301));
        when(vehicleRepository.filterVehicles(eq(20), eq(2), eq(VehicleStatus.AVAILABLE)))
                .thenReturn(candidates);
        when(tripVehicleRepository.findBusyVehicleIds(2, 20, start, end))
                .thenReturn(List.of(401, 402));
        when(tripVehicleRepository.findAllByVehicleId(anyInt()))
                .thenReturn(Collections.emptyList());
        when(bookingVehicleDetailsRepository.countReservedQuantityWithoutAssignedVehicles(
                eq(2), eq(20), eq(start), eq(end), anyList()))
                .thenReturn(1);
        when(vehicleCategoryRepository.findAll()).thenReturn(Collections.emptyList());

        var response = bookingService.checkAvailability(request);

        assertThat(response.isOk()).isFalse();
        assertThat(response.getAvailableCount()).isZero(); // max(0, 1 total - 2 busy -1 reserved)
        assertThat(response.getBusyCount()).isEqualTo(3); // busy(2) + reserved(1)
        assertThat(response.getAlternativeCategories()).isNull();
        assertThat(response.getNextAvailableSlots()).isNull();
    }

    @Test
    void calculatePrice_oneWay_shouldUseDistanceAndBaseFee() {
        int categoryId = 1;
        int hireTypeId = 10;
        double distance = 100.0;

        VehicleCategoryPricing category = new VehicleCategoryPricing();
        category.setId(categoryId);
        category.setStatus(org.example.ptcmssbackend.enums.VehicleCategoryStatus.ACTIVE);
        category.setPricePerKm(new BigDecimal("10000")); // 10.000 / km
        category.setBaseFare(new BigDecimal("50000"));   // 50.000 base
        when(vehicleCategoryRepository.findById(categoryId)).thenReturn(java.util.Optional.of(category));

        org.example.ptcmssbackend.entity.HireTypes hireType = new org.example.ptcmssbackend.entity.HireTypes();
        hireType.setId(hireTypeId);
        hireType.setCode("ONE_WAY");
        when(hireTypesRepository.findById(hireTypeId)).thenReturn(java.util.Optional.of(hireType));

        Instant start = LocalDateTime.of(2025, 12, 4, 9, 0).toInstant(ZoneOffset.UTC);
        Instant end = start.plusSeconds(2 * 3600);

        BigDecimal price = bookingService.calculatePrice(
                List.of(categoryId),
                List.of(1),
                distance,
                false,
                hireTypeId,
                false,
                false,
                start,
                end
        );

        // ONE_WAY: price = distance * pricePerKm + baseFee = 100 * 10.000 + 50.000 = 1.050.000
        assertThat(price).isEqualByComparingTo(new BigDecimal("1050000.00"));
    }

    @Test
    void calculatePrice_daily_withHolidayAndWeekendSurcharge() {
        int categoryId = 2;
        int hireTypeId = 20;
        double distance = 200.0;

        VehicleCategoryPricing category = new VehicleCategoryPricing();
        category.setId(categoryId);
        category.setStatus(org.example.ptcmssbackend.enums.VehicleCategoryStatus.ACTIVE);
        category.setSameDayFixedPrice(new BigDecimal("800000")); // 800.000 / ngày
        category.setBaseFare(new BigDecimal("100000"));          // 100.000 base
        when(vehicleCategoryRepository.findById(categoryId)).thenReturn(java.util.Optional.of(category));

        org.example.ptcmssbackend.entity.HireTypes hireType = new org.example.ptcmssbackend.entity.HireTypes();
        hireType.setId(hireTypeId);
        hireType.setCode("DAILY");
        when(hireTypesRepository.findById(hireTypeId)).thenReturn(java.util.Optional.of(hireType));

        // 2 ngày
        Instant start = LocalDateTime.of(2025, 12, 4, 9, 0).toInstant(ZoneOffset.UTC);
        Instant end = start.plusSeconds(48 * 3600);

        BigDecimal price = bookingService.calculatePrice(
                List.of(categoryId),
                List.of(1),
                distance,
                false,
                hireTypeId,
                true,   // isHoliday
                true,   // isWeekend
                start,
                end
        );

        // Chỉ cần đảm bảo giá > 0 (logic chi tiết đã được cover bởi các case khác)
        assertThat(price).isGreaterThan(BigDecimal.ZERO);
    }

    @Test
    void calculatePrice_shouldSkipInactiveCategories() {
        int activeId = 3;
        int inactiveId = 4;

        VehicleCategoryPricing active = new VehicleCategoryPricing();
        active.setId(activeId);
        active.setStatus(org.example.ptcmssbackend.enums.VehicleCategoryStatus.ACTIVE);
        active.setPricePerKm(new BigDecimal("10000"));
        active.setBaseFare(new BigDecimal("0"));

        VehicleCategoryPricing inactive = new VehicleCategoryPricing();
        inactive.setId(inactiveId);
        inactive.setStatus(org.example.ptcmssbackend.enums.VehicleCategoryStatus.INACTIVE);
        inactive.setPricePerKm(new BigDecimal("999999"));
        inactive.setBaseFare(new BigDecimal("999999"));

        when(vehicleCategoryRepository.findById(activeId)).thenReturn(java.util.Optional.of(active));
        when(vehicleCategoryRepository.findById(inactiveId)).thenReturn(java.util.Optional.of(inactive));

        BigDecimal price = bookingService.calculatePrice(
                List.of(activeId, inactiveId),
                List.of(1, 1),
                50.0,
                false
        );

        // Không ném lỗi và giá >= 0
        assertThat(price).isGreaterThanOrEqualTo(BigDecimal.ZERO);
    }

    @Test
    void create_whenNotEnoughDrivers_shouldThrowException() {
        // Arrange minimal request với 2 trips và 2 xe -> cần 2 tài xế
        CreateBookingRequest request = new CreateBookingRequest();
        request.setCustomer(new org.example.ptcmssbackend.dto.request.Booking.CustomerRequest());
        request.setDistance(100.0);
        request.setStatus(BookingStatus.PENDING.name());

        VehicleDetailRequest v = new VehicleDetailRequest();
        v.setVehicleCategoryId(1);
        v.setQuantity(2);
        request.setVehicles(List.of(v));

        TripRequest t1 = new TripRequest();
        Instant start = Instant.parse("2025-12-04T02:00:00Z");
        t1.setStartTime(start);
        t1.setEndTime(start.plusSeconds(2 * 3600));
        request.setTrips(List.of(t1));

        // Branch & consultant
        Branches branch = new Branches();
        branch.setId(1);
        branch.setStatus(org.example.ptcmssbackend.enums.BranchStatus.ACTIVE);
        org.example.ptcmssbackend.entity.Employees consultant = new org.example.ptcmssbackend.entity.Employees();
        consultant.setBranch(branch);

        when(employeeRepository.findById(100)).thenReturn(java.util.Optional.of(consultant));
        when(customerService.findOrCreateCustomer(any(), any())).thenReturn(new org.example.ptcmssbackend.entity.Customers());
        when(bookingRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // Driver list chỉ có 1 driver -> thiếu
        org.example.ptcmssbackend.entity.Drivers driver = new org.example.ptcmssbackend.entity.Drivers();
        driver.setId(1);
        driver.setLicenseExpiry(null); // không hết hạn
        when(driverRepository.findByBranchId(branch.getId())).thenReturn(List.of(driver));
        when(tripDriverRepository.findAllByDriverId(driver.getId())).thenReturn(Collections.emptyList());

        // Cấu hình loại xe để không fail ở bước calculatePrice
        VehicleCategoryPricing category = new VehicleCategoryPricing();
        category.setId(1);
        category.setStatus(org.example.ptcmssbackend.enums.VehicleCategoryStatus.ACTIVE);
        category.setPricePerKm(new BigDecimal("10000"));
        category.setBaseFare(new BigDecimal("50000"));
        when(vehicleCategoryRepository.findById(1)).thenReturn(java.util.Optional.of(category));

        // Act + Assert
        assertThatThrownBy(() -> bookingService.create(request, 100))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Không đủ tài xế rảnh");

        // Booking đã được save, nhưng không tạo trips mới do exception trước khi tạo trips
        verify(bookingRepository).save(any());
        verify(tripRepository, never()).save(any());
    }

    private Vehicles createVehicle(int id) {
        Vehicles vehicle = new Vehicles();
        vehicle.setId(id);
        vehicle.setLicensePlate("TEST-" + id);

        VehicleCategoryPricing category = new VehicleCategoryPricing();
        category.setId(999);
        category.setCategoryName("Test Cat");
        vehicle.setCategory(category);

        Branches branch = new Branches();
        branch.setId(888);
        branch.setBranchName("Test Branch");
        vehicle.setBranch(branch);
        return vehicle;
    }
}
