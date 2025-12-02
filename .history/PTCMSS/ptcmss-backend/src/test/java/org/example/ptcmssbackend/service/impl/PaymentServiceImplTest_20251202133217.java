package org.example.ptcmssbackend.service.impl;

import org.example.ptcmssbackend.BaseTest;
import org.example.ptcmssbackend.dto.request.Payment.ConfirmPaymentRequest;
import org.example.ptcmssbackend.dto.request.Payment.CreatePaymentRequest;
import org.example.ptcmssbackend.dto.response.Payment.PaymentHistoryResponse;
import org.example.ptcmssbackend.entity.*;
import org.example.ptcmssbackend.enums.InvoiceStatus;
import org.example.ptcmssbackend.enums.PaymentMethod;
import org.example.ptcmssbackend.enums.PaymentStatus;
import org.example.ptcmssbackend.exception.ResourceNotFoundException;
import org.example.ptcmssbackend.repository.*;
import org.example.ptcmssbackend.service.InvoiceService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

class PaymentServiceImplTest extends BaseTest {

    @Mock
    private PaymentHistoryRepository paymentHistoryRepository;

    @Mock
    private InvoiceRepository invoiceRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private BookingRepository bookingRepository;

    @Mock
    private InvoiceService invoiceService;

    @InjectMocks
    private PaymentServiceImpl paymentService;

    private Invoices testInvoice;
    private Users testUser;
    private PaymentHistory testPayment;
    private Bookings testBooking;

    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();

        testUser = new Users();
        testUser.setId(1);
        testUser.setUsername("cashier");

        Customers customer = new Customers();
        customer.setId(1);
        customer.setFullName("Nguyen Van A");

        testBooking = new Bookings();
        testBooking.setId(1);
        testBooking.setBookingCode("BK20251202001");

        testInvoice = new Invoices();
        testInvoice.setId(1);
        testInvoice.setInvoiceNumber("INV20251202001");
        testInvoice.setCustomer(customer);
        testInvoice.setBooking(testBooking);
        testInvoice.setAmount(BigDecimal.valueOf(5000000));
        testInvoice.setPaymentStatus(PaymentStatus.PENDING);
        testInvoice.setInvoiceStatus(InvoiceStatus.ISSUED);

        testPayment = new PaymentHistory();
        testPayment.setId(1);
        testPayment.setInvoice(testInvoice);
        testPayment.setAmount(BigDecimal.valueOf(1000000));
        testPayment.setPaymentMethod(PaymentMethod.CASH);
        testPayment.setPaymentStatus(org.example.ptcmssbackend.enums.PaymentStatus.PENDING);
        testPayment.setIsDeposit(true);
        testPayment.setCreatedBy(testUser);
        testPayment.setPaymentDate(Instant.now());
    }

    @Test
    void recordPayment_DepositPayment_Success() {
        // Given
        CreatePaymentRequest request = new CreatePaymentRequest();
        request.setInvoiceId(1);
        request.setAmount(BigDecimal.valueOf(1000000));
        request.setPaymentMethod(PaymentMethod.CASH);
        request.setIsDeposit(true);

        when(invoiceRepository.findById(1)).thenReturn(Optional.of(testInvoice));
        when(userRepository.findById(anyInt())).thenReturn(Optional.of(testUser));
        when(paymentHistoryRepository.save(any(PaymentHistory.class))).thenReturn(testPayment);

        // When
        PaymentHistoryResponse response = paymentService.recordPayment(request, 1);

        // Then
        assertNotNull(response);
        assertEquals(BigDecimal.valueOf(1000000), response.getAmount());
        assertEquals(PaymentMethod.CASH.name(), response.getPaymentMethod());
        assertTrue(response.getIsDeposit());
        assertEquals(PaymentStatus.PENDING.name(), response.getPaymentStatus());

        verify(paymentHistoryRepository, times(1)).save(any(PaymentHistory.class));
        verify(invoiceRepository, times(1)).findById(1);
    }

    @Test
    void recordPayment_FullPayment_Success() {
        // Given
        CreatePaymentRequest request = new CreatePaymentRequest();
        request.setInvoiceId(1);
        request.setAmount(BigDecimal.valueOf(5000000));
        request.setPaymentMethod(PaymentMethod.BANK_TRANSFER);
        request.setIsDeposit(false);

        testPayment.setAmount(BigDecimal.valueOf(5000000));
        testPayment.setIsDeposit(false);

        when(invoiceRepository.findById(1)).thenReturn(Optional.of(testInvoice));
        when(userRepository.findById(anyInt())).thenReturn(Optional.of(testUser));
        when(paymentHistoryRepository.save(any(PaymentHistory.class))).thenReturn(testPayment);

        // When
        PaymentHistoryResponse response = paymentService.recordPayment(request, 1);

        // Then
        assertNotNull(response);
        assertEquals(BigDecimal.valueOf(5000000), response.getAmount());
        assertFalse(response.getIsDeposit());
    }

    @Test
    void recordPayment_InvoiceNotFound_ThrowsException() {
        // Given
        CreatePaymentRequest request = new CreatePaymentRequest();
        request.setInvoiceId(999);

        when(invoiceRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
            paymentService.recordPayment(request, 1);
        });

        assertTrue(exception.getMessage().contains("Invoice not found"));
        verify(paymentHistoryRepository, never()).save(any());
    }

    @Test
    void confirmPayment_Success() {
        // Given
        when(paymentHistoryRepository.findById(1)).thenReturn(Optional.of(testPayment));
        when(paymentHistoryRepository.save(any(PaymentHistory.class))).thenReturn(testPayment);
        when(invoiceRepository.findById(anyInt())).thenReturn(Optional.of(testInvoice));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(anyInt())).thenReturn(BigDecimal.valueOf(1000000));

        // When
        PaymentHistoryResponse response = paymentService.confirmPayment(1, "CONFIRMED");

        // Then
        assertNotNull(response);
        verify(paymentHistoryRepository, times(1)).save(argThat(payment -> 
            payment.getPaymentStatus() == PaymentStatus.CONFIRMED
        ));
    }

    @Test
    void confirmPayment_AlreadyConfirmed_ThrowsException() {
        // Given
        testPayment.setPaymentStatus(PaymentStatus.CONFIRMED);
        when(paymentHistoryRepository.findById(1)).thenReturn(Optional.of(testPayment));

        // When & Then
        IllegalStateException exception = assertThrows(IllegalStateException.class, () -> {
            paymentService.confirmPayment(1, "CONFIRMED");
        });

        assertTrue(exception.getMessage().contains("already been confirmed"));
    }

    @Test
    void rejectPayment_Success() {
        // Given
        when(paymentHistoryRepository.findById(1)).thenReturn(Optional.of(testPayment));
        when(paymentHistoryRepository.save(any(PaymentHistory.class))).thenReturn(testPayment);

        // When
        PaymentHistoryResponse response = paymentService.confirmPayment(1, "REJECTED");

        // Then
        assertNotNull(response);
        verify(paymentHistoryRepository, times(1)).save(argThat(payment -> 
            payment.getPaymentStatus() == PaymentStatus.REJECTED
        ));
    }

    @Test
    void getPaymentById_Success() {
        // Given
        when(paymentHistoryRepository.findById(1)).thenReturn(Optional.of(testPayment));

        // When
        PaymentHistoryResponse response = paymentService.getPaymentById(1);

        // Then
        assertNotNull(response);
        assertEquals(1, response.getPaymentId());
        assertEquals(BigDecimal.valueOf(1000000), response.getAmount());
    }

    @Test
    void getPaymentById_NotFound_ThrowsException() {
        // Given
        when(paymentHistoryRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
            paymentService.getPaymentById(999);
        });

        assertTrue(exception.getMessage().contains("Payment not found"));
    }
}
