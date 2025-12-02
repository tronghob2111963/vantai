package org.example.ptcmssbackend.service.impl;

import org.example.ptcmssbackend.BaseTest;
import org.example.ptcmssbackend.dto.request.Booking.CreateBookingRequest;
import org.example.ptcmssbackend.dto.request.Booking.VehicleDetailRequest;
import org.example.ptcmssbackend.dto.response.Booking.BookingResponse;
import org.example.ptcmssbackend.entity.*;
import org.example.ptcmssbackend.enums.BookingStatus;
import org.example.ptcmssbackend.enums.InvoiceType;
import org.example.ptcmssbackend.exception.ResourceNotFoundException;
import org.example.ptcmssbackend.repository.*;
import org.example.ptcmssbackend.service.InvoiceService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

class BookingServiceImplTest extends BaseTest {

    @Mock
    private BookingRepository bookingRepository;

    @Mock
    private CustomerRepository customerRepository;

    @Mock
    private BranchRepository branchRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private BookingVehicleDetailsRepository vehicleDetailsRepository;

    @Mock
    private HireTypeRepository hireTypeRepository;

    @Mock
    private TripRepository tripRepository;

    @Mock
    private InvoiceService invoiceService;

    @InjectMocks
    private BookingServiceImpl bookingService;

    private Customers testCustomer;
    private Branches testBranch;
    private Users testUser;
    private HireTypes testHireType;
    private Bookings testBooking;

    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();

        testCustomer = new Customers();
        testCustomer.setId(1);
        testCustomer.setFullName("Nguyen Van A");
        testCustomer.setPhone("0901234567");

        testBranch = new Branches();
        testBranch.setId(1);
        testBranch.setBranchName("HCM Branch");

        testUser = new Users();
        testUser.setId(1);
        testUser.setUsername("staff1");

        testHireType = new HireTypes();
        testHireType.setId(1);
        testHireType.setHireTypeName("Thuê theo chuyến");

        testBooking = new Bookings();
        testBooking.setId(1);
        testBooking.setBookingCode("BK20251202001");
        testBooking.setCustomer(testCustomer);
        testBooking.setBranch(testBranch);
        testBooking.setPickupLocation("123 Nguyen Hue, Q1");
        testBooking.setDropoffLocation("456 Le Loi, Q3");
        testBooking.setPickupTime(LocalDateTime.now().plusDays(1));
        testBooking.setHireType(testHireType);
        testBooking.setEstimatedCost(BigDecimal.valueOf(5000000));
        testBooking.setStatus(BookingStatus.PENDING);
        testBooking.setCreatedBy(testUser);
    }

    @Test
    void createBooking_Success() {
        // Given
        CreateBookingRequest request = new CreateBookingRequest();
        request.setCustomerId(1);
        request.setBranchId(1);
        request.setPickupLocation("123 Nguyen Hue, Q1");
        request.setDropoffLocation("456 Le Loi, Q3");
        request.setPickupTime(LocalDateTime.now().plusDays(1));
        request.setHireTypeId(1);
        request.setEstimatedCost(BigDecimal.valueOf(5000000));
        request.setDepositAmount(BigDecimal.valueOf(1000000));
        
        VehicleDetailRequest vehicleDetail = new VehicleDetailRequest();
        vehicleDetail.setVehicleCategoryId(1);
        vehicleDetail.setQuantity(1);
        request.setVehicleDetails(List.of(vehicleDetail));

        when(customerRepository.findById(1)).thenReturn(Optional.of(testCustomer));
        when(branchRepository.findById(1)).thenReturn(Optional.of(testBranch));
        when(userRepository.findById(anyInt())).thenReturn(Optional.of(testUser));
        when(hireTypeRepository.findById(1)).thenReturn(Optional.of(testHireType));
        when(bookingRepository.save(any(Bookings.class))).thenReturn(testBooking);

        // When
        BookingResponse response = bookingService.createBooking(request, 1);

        // Then
        assertNotNull(response);
        assertEquals(1, response.getBookingId());
        assertEquals("BK20251202001", response.getBookingCode());
        assertEquals(BookingStatus.PENDING.name(), response.getStatus());
        
        verify(bookingRepository, times(2)).save(any(Bookings.class)); // 1 for create, 1 for update code
        verify(customerRepository, times(1)).findById(1);
    }

    @Test
    void createBooking_CustomerNotFound_ThrowsException() {
        // Given
        CreateBookingRequest request = new CreateBookingRequest();
        request.setCustomerId(999);
        
        when(customerRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
            bookingService.createBooking(request, 1);
        });

        assertTrue(exception.getMessage().contains("Customer not found"));
        verify(bookingRepository, never()).save(any());
    }

    @Test
    void confirmBooking_Success() {
        // Given
        when(bookingRepository.findById(1)).thenReturn(Optional.of(testBooking));
        when(bookingRepository.save(any(Bookings.class))).thenReturn(testBooking);

        // When
        BookingResponse response = bookingService.confirmBooking(1);

        // Then
        assertNotNull(response);
        assertEquals(BookingStatus.CONFIRMED.name(), response.getStatus());
        verify(bookingRepository, times(1)).save(any(Bookings.class));
    }

    @Test
    void confirmBooking_AlreadyConfirmed_ThrowsException() {
        // Given
        testBooking.setStatus(BookingStatus.CONFIRMED);
        when(bookingRepository.findById(1)).thenReturn(Optional.of(testBooking));

        // When & Then
        IllegalStateException exception = assertThrows(IllegalStateException.class, () -> {
            bookingService.confirmBooking(1);
        });

        assertTrue(exception.getMessage().contains("Booking is already confirmed"));
    }

    @Test
    void cancelBooking_Success() {
        // Given
        when(bookingRepository.findById(1)).thenReturn(Optional.of(testBooking));
        when(bookingRepository.save(any(Bookings.class))).thenReturn(testBooking);

        // When
        bookingService.cancelBooking(1, "Customer request");

        // Then
        verify(bookingRepository, times(1)).save(argThat(booking -> 
            booking.getStatus() == BookingStatus.CANCELLED &&
            "Customer request".equals(booking.getCancelReason())
        ));
    }

    @Test
    void completeBooking_Success() {
        // Given
        testBooking.setStatus(BookingStatus.INPROGRESS);
        when(bookingRepository.findById(1)).thenReturn(Optional.of(testBooking));
        when(bookingRepository.save(any(Bookings.class))).thenReturn(testBooking);

        // When
        BookingResponse response = bookingService.completeBooking(1);

        // Then
        assertNotNull(response);
        assertEquals(BookingStatus.COMPLETED.name(), response.getStatus());
    }

    @Test
    void getBookingById_Success() {
        // Given
        when(bookingRepository.findById(1)).thenReturn(Optional.of(testBooking));
        when(tripRepository.findByBooking_Id(1)).thenReturn(new ArrayList<>());
        when(vehicleDetailsRepository.findByBookingId(1)).thenReturn(new ArrayList<>());

        // When
        BookingResponse response = bookingService.getBookingById(1);

        // Then
        assertNotNull(response);
        assertEquals(1, response.getBookingId());
        assertEquals("BK20251202001", response.getBookingCode());
    }

    @Test
    void getBookingById_NotFound_ThrowsException() {
        // Given
        when(bookingRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
            bookingService.getBookingById(999);
        });

        assertTrue(exception.getMessage().contains("Booking not found"));
    }
}
