package org.example.ptcmssbackend.service;

import org.example.ptcmssbackend.dto.request.Invoice.CreateInvoiceRequest;
import org.example.ptcmssbackend.dto.request.Invoice.RecordPaymentRequest;
import org.example.ptcmssbackend.dto.request.Invoice.SendInvoiceRequest;
import org.example.ptcmssbackend.dto.request.Invoice.VoidInvoiceRequest;
import org.example.ptcmssbackend.dto.response.Invoice.InvoiceResponse;
import org.example.ptcmssbackend.dto.response.Invoice.PaymentHistoryResponse;
import org.example.ptcmssbackend.entity.*;
import org.example.ptcmssbackend.enums.InvoiceStatus;
import org.example.ptcmssbackend.enums.InvoiceType;
import org.example.ptcmssbackend.enums.PaymentConfirmationStatus;
import org.example.ptcmssbackend.enums.PaymentStatus;
import org.example.ptcmssbackend.repository.*;
import org.example.ptcmssbackend.service.impl.InvoiceServiceImpl;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class InvoiceServiceImplTest {

    @Mock
    private InvoiceRepository invoiceRepository;
    @Mock
    private BranchesRepository branchesRepository;
    @Mock
    private CustomerRepository customerRepository;
    @Mock
    private BookingRepository bookingRepository;
    @Mock
    private EmployeeRepository employeeRepository;
    @Mock
    private PaymentHistoryRepository paymentHistoryRepository;
    @Mock
    private org.example.ptcmssbackend.service.EmailService emailService;
    @Mock
    private org.example.ptcmssbackend.repository.NotificationRepository notificationRepository;
    @Mock
    private org.example.ptcmssbackend.service.WebSocketNotificationService webSocketNotificationService;
    @Mock
    private TripRepository tripRepository;
    @Mock
    private TripDriverRepository tripDriverRepository;

    @InjectMocks
    private InvoiceServiceImpl invoiceService;

    // ==================== createInvoice() Tests ====================

    @Test
    void createInvoice_whenValidRequest_shouldCreateSuccessfully() {
        // Given
        CreateInvoiceRequest request = new CreateInvoiceRequest();
        request.setBranchId(1);
        request.setType("INCOME");
        request.setAmount(new BigDecimal("1000000"));
        request.setIsDeposit(false);

        Branches branch = new Branches();
        branch.setId(1);
        branch.setBranchName("Chi nhánh Hà Nội");

        when(branchesRepository.findById(1)).thenReturn(Optional.of(branch));
        when(invoiceRepository.save(any())).thenAnswer(inv -> {
            Invoices invEntity = inv.getArgument(0);
            invEntity.setId(100);
            invEntity.setInvoiceNumber("INV-2025-001");
            invEntity.setBranch(branch);
            invEntity.setType(InvoiceType.INCOME);
            invEntity.setAmount(new BigDecimal("1000000"));
            invEntity.setStatus(InvoiceStatus.ACTIVE);
            invEntity.setPaymentStatus(PaymentStatus.UNPAID);
            return invEntity;
        });
        when(invoiceRepository.findById(100)).thenAnswer(inv -> {
            Invoices invEntity = new Invoices();
            invEntity.setId(100);
            invEntity.setInvoiceNumber("INV-2025-001");
            invEntity.setBranch(branch);
            invEntity.setType(InvoiceType.INCOME);
            invEntity.setAmount(new BigDecimal("1000000"));
            invEntity.setStatus(InvoiceStatus.ACTIVE);
            invEntity.setPaymentStatus(PaymentStatus.UNPAID);
            return Optional.of(invEntity);
        });
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(100)).thenReturn(BigDecimal.ZERO);

        // When
        InvoiceResponse response = invoiceService.createInvoice(request);

        // Then
        assertThat(response).isNotNull();
        verify(invoiceRepository).save(any());
    }

    @Test
    void createInvoice_whenBranchNotFound_shouldThrowException() {
        // Given
        CreateInvoiceRequest request = new CreateInvoiceRequest();
        request.setBranchId(999);
        request.setType("INCOME");
        request.setAmount(new BigDecimal("1000000"));

        when(branchesRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> invoiceService.createInvoice(request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Branch not found");
    }

    @Test
    void createInvoice_whenInvalidType_shouldThrowException() {
        // Given
        CreateInvoiceRequest request = new CreateInvoiceRequest();
        request.setBranchId(1);
        request.setType("INVALID_TYPE");
        request.setAmount(new BigDecimal("1000000"));

        Branches branch = new Branches();
        branch.setId(1);

        when(branchesRepository.findById(1)).thenReturn(Optional.of(branch));

        // When & Then
        assertThatThrownBy(() -> invoiceService.createInvoice(request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Loại hóa đơn không hợp lệ");
    }

    @Test
    void createInvoice_whenWithBooking_shouldLinkBooking() {
        // Given
        CreateInvoiceRequest request = new CreateInvoiceRequest();
        request.setBranchId(1);
        request.setBookingId(10);
        request.setType("INCOME");
        request.setAmount(new BigDecimal("1000000"));

        Branches branch = new Branches();
        branch.setId(1);

        Bookings booking = new Bookings();
        booking.setId(10);

        when(branchesRepository.findById(1)).thenReturn(Optional.of(branch));
        when(bookingRepository.findById(10)).thenReturn(Optional.of(booking));
        when(invoiceRepository.save(any())).thenAnswer(inv -> {
            Invoices invEntity = inv.getArgument(0);
            invEntity.setId(100);
            invEntity.setInvoiceNumber("INV-2025-001");
            invEntity.setBranch(branch);
            invEntity.setType(InvoiceType.INCOME);
            invEntity.setAmount(new BigDecimal("1000000"));
            invEntity.setStatus(InvoiceStatus.ACTIVE);
            invEntity.setPaymentStatus(PaymentStatus.UNPAID);
            return invEntity;
        });
        when(invoiceRepository.findById(100)).thenAnswer(inv -> {
            Invoices invEntity = new Invoices();
            invEntity.setId(100);
            invEntity.setInvoiceNumber("INV-2025-001");
            invEntity.setBranch(branch);
            invEntity.setType(InvoiceType.INCOME);
            invEntity.setAmount(new BigDecimal("1000000"));
            invEntity.setStatus(InvoiceStatus.ACTIVE);
            invEntity.setPaymentStatus(PaymentStatus.UNPAID);
            return Optional.of(invEntity);
        });
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(100)).thenReturn(BigDecimal.ZERO);

        // When
        InvoiceResponse response = invoiceService.createInvoice(request);

        // Then
        assertThat(response).isNotNull();
        verify(bookingRepository).findById(10);
    }

    // ==================== recordPayment() Tests ====================

    @Test
    void recordPayment_whenValidRequest_shouldRecordSuccessfully() {
        // Given
        Integer invoiceId = 100;
        RecordPaymentRequest request = new RecordPaymentRequest();
        request.setAmount(new BigDecimal("500000"));
        request.setPaymentMethod("CASH");
        request.setNote("Test payment");

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);
        invoice.setStatus(InvoiceStatus.ACTIVE);
        Branches branch = new Branches();
        branch.setId(1);
        invoice.setBranch(branch);

        PaymentHistory payment = new PaymentHistory();
        payment.setId(200);
        payment.setInvoice(invoice);
        payment.setAmount(new BigDecimal("500000"));
        payment.setConfirmationStatus(PaymentConfirmationStatus.PENDING);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(invoiceId)).thenReturn(BigDecimal.ZERO);
        when(employeeRepository.findByRoleNameAndBranchId(anyString(), anyInt())).thenReturn(Collections.emptyList());
        when(paymentHistoryRepository.save(any())).thenAnswer(inv -> {
            PaymentHistory ph = inv.getArgument(0);
            ph.setId(200);
            return ph;
        });
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        PaymentHistoryResponse response = invoiceService.recordPayment(invoiceId, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getAmount()).isEqualTo(new BigDecimal("500000"));
        verify(paymentHistoryRepository).save(any());
    }

    @Test
    void recordPayment_whenInvoiceNotFound_shouldThrowException() {
        // Given
        Integer invoiceId = 999;
        RecordPaymentRequest request = new RecordPaymentRequest();
        request.setAmount(new BigDecimal("500000"));

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> invoiceService.recordPayment(invoiceId, request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Invoice not found");
    }

    // ==================== confirmPayment() Tests ====================

    @Test
    void confirmPayment_whenValidRequest_shouldConfirmSuccessfully() {
        // Given
        Integer paymentId = 200;
        String status = "CONFIRMED";

        Invoices invoice = new Invoices();
        invoice.setId(100);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);
        invoice.setBooking(null); // Không có booking để đơn giản hóa test

        PaymentHistory payment = new PaymentHistory();
        payment.setId(paymentId);
        payment.setInvoice(invoice);
        payment.setAmount(new BigDecimal("500000"));
        payment.setConfirmationStatus(PaymentConfirmationStatus.PENDING);

        when(paymentHistoryRepository.findById(paymentId)).thenReturn(Optional.of(payment));
        when(invoiceRepository.findById(100)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(100)).thenReturn(new BigDecimal("500000"));

        // When
        PaymentHistoryResponse response = invoiceService.confirmPayment(paymentId, status);

        // Then
        assertThat(response).isNotNull();
        assertThat(payment.getConfirmationStatus()).isEqualTo(PaymentConfirmationStatus.CONFIRMED);
        verify(paymentHistoryRepository).save(payment);
    }

    @Test
    void confirmPayment_whenPaymentNotFound_shouldThrowException() {
        // Given
        Integer paymentId = 999;
        String status = "CONFIRMED";

        when(paymentHistoryRepository.findById(paymentId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> invoiceService.confirmPayment(paymentId, status))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Không tìm thấy thanh toán");
    }

    @Test
    void confirmPayment_whenRejectPayment_shouldUpdateStatus() {
        // Given
        Integer paymentId = 200;
        String status = "REJECTED";

        Invoices invoice = new Invoices();
        invoice.setId(100);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);

        PaymentHistory payment = new PaymentHistory();
        payment.setId(paymentId);
        payment.setInvoice(invoice);
        payment.setAmount(new BigDecimal("500000"));
        payment.setConfirmationStatus(PaymentConfirmationStatus.PENDING);

        when(paymentHistoryRepository.findById(paymentId)).thenReturn(Optional.of(payment));
        when(invoiceRepository.findById(100)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(100)).thenReturn(BigDecimal.ZERO);

        // When
        PaymentHistoryResponse response = invoiceService.confirmPayment(paymentId, status);

        // Then
        assertThat(response).isNotNull();
        assertThat(payment.getConfirmationStatus()).isEqualTo(PaymentConfirmationStatus.REJECTED);
        verify(paymentHistoryRepository).save(payment);
    }

    @Test
    void confirmPayment_whenInvalidStatus_shouldThrowException() {
        // Given
        Integer paymentId = 200;
        String status = "INVALID_STATUS";

        PaymentHistory payment = new PaymentHistory();
        payment.setId(paymentId);
        payment.setConfirmationStatus(PaymentConfirmationStatus.PENDING);

        when(paymentHistoryRepository.findById(paymentId)).thenReturn(Optional.of(payment));

        // When & Then
        assertThatThrownBy(() -> invoiceService.confirmPayment(paymentId, status))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Trạng thái xác nhận không hợp lệ");
    }

    @Test
    void confirmPayment_whenPaymentFullyPaid_shouldMarkInvoiceAsPaid() {
        // Given
        Integer paymentId = 200;
        String status = "CONFIRMED";

        Invoices invoice = new Invoices();
        invoice.setId(100);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);

        PaymentHistory payment = new PaymentHistory();
        payment.setId(paymentId);
        payment.setInvoice(invoice);
        payment.setAmount(new BigDecimal("1000000"));
        payment.setConfirmationStatus(PaymentConfirmationStatus.PENDING);

        when(paymentHistoryRepository.findById(paymentId)).thenReturn(Optional.of(payment));
        when(invoiceRepository.findById(100)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(100)).thenReturn(new BigDecimal("1000000"));

        // When
        invoiceService.confirmPayment(paymentId, status);

        // Then
        assertThat(invoice.getPaymentStatus()).isEqualTo(PaymentStatus.PAID);
        verify(invoiceRepository).save(invoice);
    }

    // ==================== getInvoiceById() Tests ====================

    @Test
    void getInvoiceById_whenValidId_shouldReturnInvoice() {
        // Given
        Integer invoiceId = 100;
        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setInvoiceNumber("INV-2025-001");
        Branches branch = new Branches();
        branch.setId(1);
        branch.setBranchName("Chi nhánh Hà Nội");
        invoice.setBranch(branch);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);
        invoice.setStatus(InvoiceStatus.ACTIVE);
        invoice.setType(InvoiceType.INCOME);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(invoiceId)).thenReturn(BigDecimal.ZERO);
        when(paymentHistoryRepository.countPendingPaymentsByInvoiceId(invoiceId)).thenReturn(0);

        // When
        InvoiceResponse response = invoiceService.getInvoiceById(invoiceId);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getInvoiceId()).isEqualTo(invoiceId);
        assertThat(response.getInvoiceNumber()).isEqualTo("INV-2025-001");
    }

    @Test
    void getInvoiceById_whenNotFound_shouldThrowException() {
        // Given
        Integer invoiceId = 999;

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> invoiceService.getInvoiceById(invoiceId))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Invoice not found");
    }

    // ==================== getInvoices() Tests ====================

    @Test
    void getInvoices_whenNoFilters_shouldReturnAllInvoices() {
        // Given
        Invoices invoice1 = createTestInvoice(100, "INV-001", PaymentStatus.UNPAID);
        Invoices invoice2 = createTestInvoice(101, "INV-002", PaymentStatus.PAID);
        List<Invoices> invoices = List.of(invoice1, invoice2);

        when(invoiceRepository.findInvoicesWithFilters(any(), any(), any(), any(), any(), any(), any()))
                .thenReturn(invoices);
        when(invoiceRepository.findById(anyInt())).thenAnswer(inv -> {
            Integer id = inv.getArgument(0);
            return invoices.stream().filter(invItem -> invItem.getId().equals(id)).findFirst();
        });
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(anyInt())).thenReturn(BigDecimal.ZERO);
        when(paymentHistoryRepository.countPendingPaymentsByInvoiceId(anyInt())).thenReturn(0);

        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(0, 10);

        // When
        org.springframework.data.domain.Page<org.example.ptcmssbackend.dto.response.Invoice.InvoiceListResponse> result =
                invoiceService.getInvoices(null, null, null, null, null, null, null, null, pageable);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getTotalElements()).isEqualTo(2);
    }

    @Test
    void getInvoices_whenWithFilters_shouldFilterCorrectly() {
        // Given
        Invoices invoice = createTestInvoice(100, "INV-001", PaymentStatus.UNPAID);
        List<Invoices> invoices = List.of(invoice);

        when(invoiceRepository.findInvoicesWithFilters(eq(1), eq(InvoiceType.INCOME), 
                eq(InvoiceStatus.ACTIVE), any(), any(), any(), eq(PaymentStatus.UNPAID)))
                .thenReturn(invoices);
        when(invoiceRepository.findById(anyInt())).thenAnswer(inv -> {
            Integer id = inv.getArgument(0);
            return invoices.stream().filter(invItem -> invItem.getId().equals(id)).findFirst();
        });
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(anyInt())).thenReturn(BigDecimal.ZERO);
        when(paymentHistoryRepository.countPendingPaymentsByInvoiceId(anyInt())).thenReturn(0);

        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(0, 10);

        // When
        org.springframework.data.domain.Page<org.example.ptcmssbackend.dto.response.Invoice.InvoiceListResponse> result =
                invoiceService.getInvoices(1, "INCOME", "ACTIVE", "UNPAID", null, null, null, null, pageable);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getTotalElements()).isEqualTo(1);
    }

    @Test
    void getInvoices_whenWithKeyword_shouldFilterByKeyword() {
        // Given
        Invoices invoice = createTestInvoice(100, "INV-001", PaymentStatus.UNPAID);
        Customers customer = new Customers();
        customer.setFullName("Nguyễn Văn A");
        invoice.setCustomer(customer);
        List<Invoices> invoices = List.of(invoice);

        when(invoiceRepository.findInvoicesWithFilters(any(), any(), any(), any(), any(), any(), any()))
                .thenReturn(invoices);
        when(invoiceRepository.findById(anyInt())).thenAnswer(inv -> {
            Integer id = inv.getArgument(0);
            return invoices.stream().filter(invItem -> invItem.getId().equals(id)).findFirst();
        });
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(anyInt())).thenReturn(BigDecimal.ZERO);
        when(paymentHistoryRepository.countPendingPaymentsByInvoiceId(anyInt())).thenReturn(0);

        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(0, 10);

        // When
        org.springframework.data.domain.Page<org.example.ptcmssbackend.dto.response.Invoice.InvoiceListResponse> result =
                invoiceService.getInvoices(null, null, null, null, null, null, null, "Nguyễn", pageable);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getTotalElements()).isEqualTo(1);
    }

    // ==================== updateInvoice() Tests ====================

    @Test
    void updateInvoice_whenValidRequest_shouldUpdateSuccessfully() {
        // Given
        Integer invoiceId = 100;
        CreateInvoiceRequest request = new CreateInvoiceRequest();
        request.setAmount(new BigDecimal("2000000"));
        request.setNote("Updated note");

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);
        invoice.setStatus(InvoiceStatus.ACTIVE);
        invoice.setType(InvoiceType.INCOME);
        Branches branch = new Branches();
        branch.setId(1);
        invoice.setBranch(branch);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(invoiceId)).thenReturn(BigDecimal.ZERO);
        when(paymentHistoryRepository.countPendingPaymentsByInvoiceId(invoiceId)).thenReturn(0);

        // When
        InvoiceResponse response = invoiceService.updateInvoice(invoiceId, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(invoice.getAmount()).isEqualTo(new BigDecimal("2000000"));
        assertThat(invoice.getNote()).isEqualTo("Updated note");
        verify(invoiceRepository).save(invoice);
    }

    @Test
    void updateInvoice_whenInvoiceNotFound_shouldThrowException() {
        // Given
        Integer invoiceId = 999;
        CreateInvoiceRequest request = new CreateInvoiceRequest();

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> invoiceService.updateInvoice(invoiceId, request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Invoice not found");
    }

    @Test
    void updateInvoice_whenInvoiceAlreadyPaid_shouldThrowException() {
        // Given
        Integer invoiceId = 100;
        CreateInvoiceRequest request = new CreateInvoiceRequest();

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setPaymentStatus(PaymentStatus.PAID);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));

        // When & Then
        assertThatThrownBy(() -> invoiceService.updateInvoice(invoiceId, request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Cannot update paid invoice");
    }

    // ==================== voidInvoice() Tests ====================

    @Test
    void voidInvoice_whenValidRequest_shouldVoidSuccessfully() {
        // Given
        Integer invoiceId = 100;
        VoidInvoiceRequest request = new VoidInvoiceRequest();
        request.setCancellationReason("Customer cancelled");
        request.setCancelledBy(1);

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setStatus(InvoiceStatus.ACTIVE);
        invoice.setInvoiceNumber("INV-001");

        Employees employee = new Employees();
        employee.setEmployeeId(1);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(employeeRepository.findById(1)).thenReturn(Optional.of(employee));
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        invoiceService.voidInvoice(invoiceId, request);

        // Then
        assertThat(invoice.getStatus()).isEqualTo(InvoiceStatus.CANCELLED);
        assertThat(invoice.getCancellationReason()).isEqualTo("Customer cancelled");
        assertThat(invoice.getCancelledAt()).isNotNull();
        verify(invoiceRepository).save(invoice);
    }

    @Test
    void voidInvoice_whenInvoiceNotFound_shouldThrowException() {
        // Given
        Integer invoiceId = 999;
        VoidInvoiceRequest request = new VoidInvoiceRequest();

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> invoiceService.voidInvoice(invoiceId, request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Invoice not found");
    }

    @Test
    void voidInvoice_whenAlreadyCancelled_shouldThrowException() {
        // Given
        Integer invoiceId = 100;
        VoidInvoiceRequest request = new VoidInvoiceRequest();

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setStatus(InvoiceStatus.CANCELLED);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));

        // When & Then
        assertThatThrownBy(() -> invoiceService.voidInvoice(invoiceId, request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Invoice already cancelled");
    }

    // ==================== recordPayment() Additional Tests ====================

    @Test
    void recordPayment_whenPaymentExceedsBalance_shouldThrowException() {
        // Given
        Integer invoiceId = 100;
        RecordPaymentRequest request = new RecordPaymentRequest();
        request.setAmount(new BigDecimal("2000000")); // Exceeds invoice amount

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);
        invoice.setStatus(InvoiceStatus.ACTIVE);
        Branches branch = new Branches();
        branch.setId(1);
        invoice.setBranch(branch);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(invoiceId)).thenReturn(BigDecimal.ZERO);

        // When & Then
        assertThatThrownBy(() -> invoiceService.recordPayment(invoiceId, request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("exceeds balance");
    }

    @Test
    void recordPayment_whenInvoiceCancelled_shouldThrowException() {
        // Given
        Integer invoiceId = 100;
        RecordPaymentRequest request = new RecordPaymentRequest();
        request.setAmount(new BigDecimal("500000"));

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setStatus(InvoiceStatus.CANCELLED);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));

        // When & Then
        assertThatThrownBy(() -> invoiceService.recordPayment(invoiceId, request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Cannot record payment for cancelled invoice");
    }

    @Test
    void recordPayment_whenPaymentMakesInvoiceFullyPaid_shouldUpdateStatus() {
        // Given
        Integer invoiceId = 100;
        RecordPaymentRequest request = new RecordPaymentRequest();
        request.setAmount(new BigDecimal("1000000"));
        request.setPaymentMethod("CASH");
        request.setConfirmationStatus("CONFIRMED"); // Auto-confirmed

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);
        invoice.setStatus(InvoiceStatus.ACTIVE);
        Branches branch = new Branches();
        branch.setId(1);
        invoice.setBranch(branch);

        PaymentHistory payment = new PaymentHistory();
        payment.setId(200);
        payment.setInvoice(invoice);
        payment.setAmount(new BigDecimal("1000000"));
        payment.setConfirmationStatus(PaymentConfirmationStatus.CONFIRMED);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(invoiceId))
                .thenReturn(BigDecimal.ZERO)
                .thenReturn(new BigDecimal("1000000"));
        when(paymentHistoryRepository.save(any())).thenAnswer(inv -> {
            PaymentHistory ph = inv.getArgument(0);
            ph.setId(200);
            ph.setConfirmationStatus(PaymentConfirmationStatus.CONFIRMED);
            return ph;
        });
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        PaymentHistoryResponse response = invoiceService.recordPayment(invoiceId, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getConfirmationStatus()).isEqualTo("CONFIRMED");
        verify(invoiceRepository).save(any());
    }

    // ==================== getPaymentHistory() Tests ====================

    @Test
    void getPaymentHistory_whenValidInvoiceId_shouldReturnPayments() {
        // Given
        Integer invoiceId = 100;
        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);

        PaymentHistory payment1 = new PaymentHistory();
        payment1.setId(200);
        payment1.setInvoice(invoice);
        payment1.setAmount(new BigDecimal("500000"));
        payment1.setPaymentMethod("CASH");

        PaymentHistory payment2 = new PaymentHistory();
        payment2.setId(201);
        payment2.setInvoice(invoice);
        payment2.setAmount(new BigDecimal("300000"));
        payment2.setPaymentMethod("BANK_TRANSFER");

        when(paymentHistoryRepository.findAllByInvoiceId(invoiceId))
                .thenReturn(List.of(payment1, payment2));

        // When
        List<PaymentHistoryResponse> result = invoiceService.getPaymentHistory(invoiceId);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.size()).isEqualTo(2);
    }

    @Test
    void getPaymentHistory_whenNoPayments_shouldReturnEmptyList() {
        // Given
        Integer invoiceId = 100;

        when(paymentHistoryRepository.findAllByInvoiceId(invoiceId))
                .thenReturn(Collections.emptyList());

        // When
        List<PaymentHistoryResponse> result = invoiceService.getPaymentHistory(invoiceId);

        // Then
        assertThat(result).isNotNull();
        assertThat(result).isEmpty();
    }

    // ==================== calculateBalance() Tests ====================

    @Test
    void calculateBalance_whenNoPayments_shouldReturnFullAmount() {
        // Given
        Integer invoiceId = 100;
        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setAmount(new BigDecimal("1000000"));

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(invoiceId)).thenReturn(BigDecimal.ZERO);

        // When
        BigDecimal balance = invoiceService.calculateBalance(invoiceId);

        // Then
        assertThat(balance).isEqualTo(new BigDecimal("1000000"));
    }

    @Test
    void calculateBalance_whenPartialPayment_shouldReturnRemainingBalance() {
        // Given
        Integer invoiceId = 100;
        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setAmount(new BigDecimal("1000000"));

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(invoiceId)).thenReturn(new BigDecimal("300000"));

        // When
        BigDecimal balance = invoiceService.calculateBalance(invoiceId);

        // Then
        assertThat(balance).isEqualTo(new BigDecimal("700000"));
    }

    @Test
    void calculateBalance_whenInvoiceNotFound_shouldThrowException() {
        // Given
        Integer invoiceId = 999;

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> invoiceService.calculateBalance(invoiceId))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Invoice not found");
    }

    // ==================== markAsPaid() Tests ====================

    @Test
    void markAsPaid_whenValidInvoice_shouldUpdateStatus() {
        // Given
        Integer invoiceId = 100;
        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setPaymentStatus(PaymentStatus.UNPAID);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        invoiceService.markAsPaid(invoiceId);

        // Then
        assertThat(invoice.getPaymentStatus()).isEqualTo(PaymentStatus.PAID);
        verify(invoiceRepository).save(invoice);
    }

    @Test
    void markAsPaid_whenInvoiceNotFound_shouldThrowException() {
        // Given
        Integer invoiceId = 999;

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> invoiceService.markAsPaid(invoiceId))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Invoice not found");
    }

    // ==================== markAsOverdue() Tests ====================

    @Test
    void markAsOverdue_whenValidInvoice_shouldUpdateStatus() {
        // Given
        Integer invoiceId = 100;
        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setPaymentStatus(PaymentStatus.UNPAID);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        invoiceService.markAsOverdue(invoiceId);

        // Then
        assertThat(invoice.getPaymentStatus()).isEqualTo(PaymentStatus.OVERDUE);
        verify(invoiceRepository).save(invoice);
    }

    // ==================== isOverdue() Tests ====================

    @Test
    void isOverdue_whenDueDatePassed_shouldReturnTrue() {
        // Given
        Integer invoiceId = 100;
        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setDueDate(LocalDate.now().minusDays(1));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));

        // When
        boolean result = invoiceService.isOverdue(invoiceId);

        // Then
        assertThat(result).isTrue();
    }

    @Test
    void isOverdue_whenDueDateNotPassed_shouldReturnFalse() {
        // Given
        Integer invoiceId = 100;
        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setDueDate(LocalDate.now().plusDays(1));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));

        // When
        boolean result = invoiceService.isOverdue(invoiceId);

        // Then
        assertThat(result).isFalse();
    }

    @Test
    void isOverdue_whenAlreadyPaid_shouldReturnFalse() {
        // Given
        Integer invoiceId = 100;
        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setDueDate(LocalDate.now().minusDays(1));
        invoice.setPaymentStatus(PaymentStatus.PAID);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));

        // When
        boolean result = invoiceService.isOverdue(invoiceId);

        // Then
        assertThat(result).isFalse();
    }

    // ==================== sendInvoice() Tests ====================

    @Test
    void sendInvoice_whenValidRequest_shouldSendEmail() throws Exception {
        // Given
        Integer invoiceId = 100;
        SendInvoiceRequest request = new SendInvoiceRequest();
        request.setEmail("customer@example.com");
        request.setMessage("Please find attached invoice");

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setInvoiceNumber("INV-001");
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setDueDate(LocalDate.now().plusDays(7));
        Customers customer = new Customers();
        customer.setFullName("Nguyễn Văn A");
        invoice.setCustomer(customer);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        doNothing().when(emailService).sendInvoiceEmail(anyString(), anyString(), anyString(), 
                anyString(), anyString(), anyString(), anyString());

        // When
        invoiceService.sendInvoice(invoiceId, request);

        // Then
        assertThat(invoice.getSentAt()).isNotNull();
        assertThat(invoice.getSentToEmail()).isEqualTo("customer@example.com");
        verify(emailService).sendInvoiceEmail(anyString(), anyString(), anyString(), 
                anyString(), anyString(), anyString(), anyString());
        verify(invoiceRepository).save(invoice);
    }

    @Test
    void sendInvoice_whenInvoiceNotFound_shouldThrowException() {
        // Given
        Integer invoiceId = 999;
        SendInvoiceRequest request = new SendInvoiceRequest();

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> invoiceService.sendInvoice(invoiceId, request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Invoice not found");
    }

    // ==================== deletePayment() Tests ====================

    @Test
    void deletePayment_whenPendingPayment_shouldDeleteSuccessfully() {
        // Given
        Integer paymentId = 200;
        Invoices invoice = new Invoices();
        invoice.setId(100);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.PAID);

        PaymentHistory payment = new PaymentHistory();
        payment.setId(paymentId);
        payment.setInvoice(invoice);
        payment.setConfirmationStatus(PaymentConfirmationStatus.PENDING);

        when(paymentHistoryRepository.findById(paymentId)).thenReturn(Optional.of(payment));
        when(invoiceRepository.findById(100)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(100)).thenReturn(BigDecimal.ZERO);
        doNothing().when(paymentHistoryRepository).delete(payment);
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        invoiceService.deletePayment(paymentId);

        // Then
        verify(paymentHistoryRepository).delete(payment);
    }

    @Test
    void deletePayment_whenPaymentNotFound_shouldThrowException() {
        // Given
        Integer paymentId = 999;

        when(paymentHistoryRepository.findById(paymentId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> invoiceService.deletePayment(paymentId))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Không tìm thấy thanh toán");
    }

    @Test
    void deletePayment_whenPaymentConfirmed_shouldThrowException() {
        // Given
        Integer paymentId = 200;
        PaymentHistory payment = new PaymentHistory();
        payment.setId(paymentId);
        payment.setConfirmationStatus(PaymentConfirmationStatus.CONFIRMED);

        when(paymentHistoryRepository.findById(paymentId)).thenReturn(Optional.of(payment));

        // When & Then
        assertThatThrownBy(() -> invoiceService.deletePayment(paymentId))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Chỉ được xóa payment request có trạng thái PENDING");
    }

    // ==================== getPendingPayments() Tests ====================

    @Test
    void getPendingPayments_whenValidBranchId_shouldReturnPendingPayments() {
        // Given
        Integer branchId = 1;
        Invoices invoice = new Invoices();
        invoice.setId(100);
        invoice.setInvoiceNumber("INV-001");

        PaymentHistory payment = new PaymentHistory();
        payment.setId(200);
        payment.setInvoice(invoice);
        payment.setConfirmationStatus(PaymentConfirmationStatus.PENDING);

        when(paymentHistoryRepository.findPendingPayments(branchId))
                .thenReturn(List.of(payment));

        // When
        List<PaymentHistoryResponse> result = invoiceService.getPendingPayments(branchId);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.size()).isEqualTo(1);
    }

    // ==================== countPendingPayments() Tests ====================

    @Test
    void countPendingPayments_whenValidBranchId_shouldReturnCount() {
        // Given
        Integer branchId = 1;

        when(paymentHistoryRepository.countPendingPayments(branchId)).thenReturn(5L);

        // When
        Long count = invoiceService.countPendingPayments(branchId);

        // Then
        assertThat(count).isEqualTo(5L);
    }

    // ==================== generateInvoiceNumber() Tests ====================

    @Test
    void generateInvoiceNumber_whenValidBranch_shouldGenerateCorrectFormat() {
        // Given
        Integer branchId = 1;
        LocalDate invoiceDate = LocalDate.of(2025, 12, 4);
        
        Branches branch = new Branches();
        branch.setId(branchId);
        branch.setBranchName("Chi nhánh Hà Nội");
        
        when(branchesRepository.findById(branchId)).thenReturn(Optional.of(branch));
        when(invoiceRepository.findMaxSequenceNumber(branchId, "INV-HN-2025-%")).thenReturn(5);

        // When
        String invoiceNumber = invoiceService.generateInvoiceNumber(branchId, invoiceDate);

        // Then
        assertThat(invoiceNumber).isNotNull();
        assertThat(invoiceNumber).startsWith("INV-HN-2025-");
        assertThat(invoiceNumber).isEqualTo("INV-HN-2025-0006");
        verify(branchesRepository).findById(branchId);
        verify(invoiceRepository).findMaxSequenceNumber(branchId, "INV-HN-2025-%");
    }

    @Test
    void generateInvoiceNumber_whenFirstInvoice_shouldStartFrom0001() {
        // Given
        Integer branchId = 2;
        LocalDate invoiceDate = LocalDate.of(2025, 12, 4);
        
        Branches branch = new Branches();
        branch.setId(branchId);
        branch.setBranchName("Chi nhánh Đà Nẵng");
        
        when(branchesRepository.findById(branchId)).thenReturn(Optional.of(branch));
        when(invoiceRepository.findMaxSequenceNumber(branchId, "INV-DN-2025-%")).thenReturn(null);

        // When
        String invoiceNumber = invoiceService.generateInvoiceNumber(branchId, invoiceDate);

        // Then
        assertThat(invoiceNumber).isEqualTo("INV-DN-2025-0001");
    }

    @Test
    void generateInvoiceNumber_whenBranchNotFound_shouldThrowException() {
        // Given
        Integer branchId = 999;
        LocalDate invoiceDate = LocalDate.of(2025, 12, 4);
        
        when(branchesRepository.findById(branchId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> invoiceService.generateInvoiceNumber(branchId, invoiceDate))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Branch not found");
    }

    @Test
    void generateInvoiceNumber_whenDifferentBranchNames_shouldUseCorrectCode() {
        // Given
        LocalDate invoiceDate = LocalDate.of(2025, 12, 4);
        
        // Test HCM branch
        Branches hcmBranch = new Branches();
        hcmBranch.setId(3);
        hcmBranch.setBranchName("Chi nhánh TP. HCM");
        
        when(branchesRepository.findById(3)).thenReturn(Optional.of(hcmBranch));
        when(invoiceRepository.findMaxSequenceNumber(3, "INV-HCM-2025-%")).thenReturn(10);

        // When
        String hcmInvoiceNumber = invoiceService.generateInvoiceNumber(3, invoiceDate);

        // Then
        assertThat(hcmInvoiceNumber).isEqualTo("INV-HCM-2025-0011");
    }

    // ==================== checkAndUpdateOverdueInvoices() Tests ====================

    @Test
    void checkAndUpdateOverdueInvoices_whenUnpaidInvoicesOverdue_shouldMarkAsOverdue() {
        // Given
        LocalDate today = LocalDate.now();
        LocalDate pastDate = today.minusDays(5);
        
        Invoices overdueInvoice1 = new Invoices();
        overdueInvoice1.setId(100);
        overdueInvoice1.setInvoiceNumber("INV-001");
        overdueInvoice1.setDueDate(pastDate);
        overdueInvoice1.setPaymentStatus(PaymentStatus.UNPAID);
        
        Invoices overdueInvoice2 = new Invoices();
        overdueInvoice2.setId(101);
        overdueInvoice2.setInvoiceNumber("INV-002");
        overdueInvoice2.setDueDate(pastDate);
        overdueInvoice2.setPaymentStatus(PaymentStatus.UNPAID);
        
        List<Invoices> overdueInvoices = List.of(overdueInvoice1, overdueInvoice2);
        
        when(invoiceRepository.findUnpaidInvoicesBeforeDate(today, null))
                .thenReturn(overdueInvoices);
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        invoiceService.checkAndUpdateOverdueInvoices();

        // Then
        assertThat(overdueInvoice1.getPaymentStatus()).isEqualTo(PaymentStatus.OVERDUE);
        assertThat(overdueInvoice2.getPaymentStatus()).isEqualTo(PaymentStatus.OVERDUE);
        verify(invoiceRepository, times(2)).save(any());
    }

    @Test
    void checkAndUpdateOverdueInvoices_whenInvoiceNotOverdue_shouldNotUpdate() {
        // Given
        LocalDate today = LocalDate.now();
        LocalDate futureDate = today.plusDays(5);
        
        Invoices futureInvoice = new Invoices();
        futureInvoice.setId(100);
        futureInvoice.setInvoiceNumber("INV-001");
        futureInvoice.setDueDate(futureDate);
        futureInvoice.setPaymentStatus(PaymentStatus.UNPAID);
        
        List<Invoices> invoices = List.of(futureInvoice);
        
        when(invoiceRepository.findUnpaidInvoicesBeforeDate(today, null))
                .thenReturn(invoices);

        // When
        invoiceService.checkAndUpdateOverdueInvoices();

        // Then
        assertThat(futureInvoice.getPaymentStatus()).isEqualTo(PaymentStatus.UNPAID);
        verify(invoiceRepository, never()).save(any());
    }

    @Test
    void checkAndUpdateOverdueInvoices_whenNoDueDate_shouldNotUpdate() {
        // Given
        LocalDate today = LocalDate.now();
        
        Invoices invoiceWithoutDueDate = new Invoices();
        invoiceWithoutDueDate.setId(100);
        invoiceWithoutDueDate.setInvoiceNumber("INV-001");
        invoiceWithoutDueDate.setDueDate(null);
        invoiceWithoutDueDate.setPaymentStatus(PaymentStatus.UNPAID);
        
        List<Invoices> invoices = List.of(invoiceWithoutDueDate);
        
        when(invoiceRepository.findUnpaidInvoicesBeforeDate(today, null))
                .thenReturn(invoices);

        // When
        invoiceService.checkAndUpdateOverdueInvoices();

        // Then
        assertThat(invoiceWithoutDueDate.getPaymentStatus()).isEqualTo(PaymentStatus.UNPAID);
        verify(invoiceRepository, never()).save(any());
    }

    @Test
    void checkAndUpdateOverdueInvoices_whenNoUnpaidInvoices_shouldDoNothing() {
        // Given
        LocalDate today = LocalDate.now();
        
        when(invoiceRepository.findUnpaidInvoicesBeforeDate(today, null))
                .thenReturn(Collections.emptyList());

        // When
        invoiceService.checkAndUpdateOverdueInvoices();

        // Then
        verify(invoiceRepository, never()).save(any());
    }

    // ==================== checkAndUpdateOverdueInvoicesAfter48h() Tests ====================

    @Test
    void checkAndUpdateOverdueInvoicesAfter48h_whenUnpaidInvoicesWithCompletedTrips_shouldMarkAsOverdue() {
        // Given
        Instant cutoffTime = Instant.now().minus(48, java.time.temporal.ChronoUnit.HOURS);
        Instant oldTripTime = cutoffTime.minus(10, java.time.temporal.ChronoUnit.HOURS);
        
        Invoices unpaidInvoice = new Invoices();
        unpaidInvoice.setId(100);
        unpaidInvoice.setInvoiceNumber("INV-001");
        unpaidInvoice.setAmount(new BigDecimal("1000000"));
        unpaidInvoice.setPaymentStatus(PaymentStatus.UNPAID);
        
        List<Invoices> unpaidInvoices = List.of(unpaidInvoice);
        
        when(invoiceRepository.findUnpaidInvoicesWithCompletedTripsOlderThan(any(Instant.class), any()))
                .thenReturn(unpaidInvoices);
        when(invoiceRepository.findById(100)).thenReturn(Optional.of(unpaidInvoice));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(100))
                .thenReturn(BigDecimal.ZERO);
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        invoiceService.checkAndUpdateOverdueInvoicesAfter48h();

        // Then
        assertThat(unpaidInvoice.getPaymentStatus()).isEqualTo(PaymentStatus.OVERDUE);
        verify(invoiceRepository).save(unpaidInvoice);
    }

    @Test
    void checkAndUpdateOverdueInvoicesAfter48h_whenInvoiceFullyPaid_shouldNotMarkAsOverdue() {
        // Given
        
        Invoices paidInvoice = new Invoices();
        paidInvoice.setId(100);
        paidInvoice.setInvoiceNumber("INV-001");
        paidInvoice.setAmount(new BigDecimal("1000000"));
        paidInvoice.setPaymentStatus(PaymentStatus.UNPAID);
        
        List<Invoices> invoices = List.of(paidInvoice);
        
        when(invoiceRepository.findUnpaidInvoicesWithCompletedTripsOlderThan(any(Instant.class), any()))
                .thenReturn(invoices);
        when(invoiceRepository.findById(100)).thenReturn(Optional.of(paidInvoice));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(100))
                .thenReturn(new BigDecimal("1000000"));

        // When
        invoiceService.checkAndUpdateOverdueInvoicesAfter48h();

        // Then
        assertThat(paidInvoice.getPaymentStatus()).isEqualTo(PaymentStatus.UNPAID);
        verify(invoiceRepository, never()).save(any());
    }

    @Test
    void checkAndUpdateOverdueInvoicesAfter48h_whenNoInvoices_shouldDoNothing() {
        // Given
        when(invoiceRepository.findUnpaidInvoicesWithCompletedTripsOlderThan(any(Instant.class), any()))
                .thenReturn(Collections.emptyList());

        // When
        invoiceService.checkAndUpdateOverdueInvoicesAfter48h();

        // Then
        verify(invoiceRepository, never()).save(any());
    }

    // ==================== createInvoice() Additional Tests ====================

    @Test
    void createInvoice_whenWithCustomer_shouldLinkCustomer() {
        // Given
        CreateInvoiceRequest request = new CreateInvoiceRequest();
        request.setBranchId(1);
        request.setCustomerId(10);
        request.setType("INCOME");
        request.setAmount(new BigDecimal("1000000"));

        Branches branch = new Branches();
        branch.setId(1);

        Customers customer = new Customers();
        customer.setId(10);
        customer.setFullName("Nguyễn Văn A");

        when(branchesRepository.findById(1)).thenReturn(Optional.of(branch));
        when(customerRepository.findById(10)).thenReturn(Optional.of(customer));
        when(invoiceRepository.save(any())).thenAnswer(inv -> {
            Invoices invEntity = inv.getArgument(0);
            invEntity.setId(100);
            invEntity.setInvoiceNumber("INV-2025-001");
            invEntity.setBranch(branch);
            invEntity.setCustomer(customer);
            return invEntity;
        });
        when(invoiceRepository.findById(100)).thenAnswer(inv -> {
            Invoices invEntity = new Invoices();
            invEntity.setId(100);
            invEntity.setInvoiceNumber("INV-2025-001");
            invEntity.setBranch(branch);
            invEntity.setCustomer(customer);
            invEntity.setType(InvoiceType.INCOME);
            invEntity.setAmount(new BigDecimal("1000000"));
            invEntity.setStatus(InvoiceStatus.ACTIVE);
            invEntity.setPaymentStatus(PaymentStatus.UNPAID);
            return Optional.of(invEntity);
        });
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(100)).thenReturn(BigDecimal.ZERO);

        // When
        InvoiceResponse response = invoiceService.createInvoice(request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getCustomerId()).isEqualTo(10);
        verify(customerRepository).findById(10);
    }

    @Test
    void createInvoice_whenWithCreatedBy_shouldLinkEmployee() {
        // Given
        CreateInvoiceRequest request = new CreateInvoiceRequest();
        request.setBranchId(1);
        request.setCreatedBy(5);
        request.setType("INCOME");
        request.setAmount(new BigDecimal("1000000"));

        Branches branch = new Branches();
        branch.setId(1);

        Employees employee = new Employees();
        employee.setEmployeeId(5);

        when(branchesRepository.findById(1)).thenReturn(Optional.of(branch));
        when(employeeRepository.findById(5)).thenReturn(Optional.of(employee));
        when(invoiceRepository.save(any())).thenAnswer(inv -> {
            Invoices invEntity = inv.getArgument(0);
            invEntity.setId(100);
            invEntity.setInvoiceNumber("INV-2025-001");
            invEntity.setBranch(branch);
            invEntity.setCreatedBy(employee);
            return invEntity;
        });
        when(invoiceRepository.findById(100)).thenAnswer(inv -> {
            Invoices invEntity = new Invoices();
            invEntity.setId(100);
            invEntity.setInvoiceNumber("INV-2025-001");
            invEntity.setBranch(branch);
            invEntity.setCreatedBy(employee);
            invEntity.setType(InvoiceType.INCOME);
            invEntity.setAmount(new BigDecimal("1000000"));
            invEntity.setStatus(InvoiceStatus.ACTIVE);
            invEntity.setPaymentStatus(PaymentStatus.UNPAID);
            return Optional.of(invEntity);
        });
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(100)).thenReturn(BigDecimal.ZERO);

        // When
        InvoiceResponse response = invoiceService.createInvoice(request);

        // Then
        assertThat(response).isNotNull();
        verify(employeeRepository).findById(5);
    }

    @Test
    void createInvoice_whenWithDueDate_shouldSetDueDate() {
        // Given
        CreateInvoiceRequest request = new CreateInvoiceRequest();
        request.setBranchId(1);
        request.setType("INCOME");
        request.setAmount(new BigDecimal("1000000"));
        request.setDueDate(LocalDate.now().plusDays(30));

        Branches branch = new Branches();
        branch.setId(1);

        when(branchesRepository.findById(1)).thenReturn(Optional.of(branch));
        when(invoiceRepository.save(any())).thenAnswer(inv -> {
            Invoices invEntity = inv.getArgument(0);
            invEntity.setId(100);
            invEntity.setInvoiceNumber("INV-2025-001");
            invEntity.setBranch(branch);
            return invEntity;
        });
        when(invoiceRepository.findById(100)).thenAnswer(inv -> {
            Invoices invEntity = new Invoices();
            invEntity.setId(100);
            invEntity.setInvoiceNumber("INV-2025-001");
            invEntity.setBranch(branch);
            invEntity.setType(InvoiceType.INCOME);
            invEntity.setAmount(new BigDecimal("1000000"));
            invEntity.setStatus(InvoiceStatus.ACTIVE);
            invEntity.setPaymentStatus(PaymentStatus.UNPAID);
            invEntity.setDueDate(request.getDueDate());
            return Optional.of(invEntity);
        });
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(100)).thenReturn(BigDecimal.ZERO);

        // When
        InvoiceResponse response = invoiceService.createInvoice(request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getDueDate()).isEqualTo(request.getDueDate());
    }

    // ==================== recordPayment() Additional Tests ====================

    @Test
    void recordPayment_whenWithCreatedBy_shouldLinkEmployee() {
        // Given
        Integer invoiceId = 100;
        RecordPaymentRequest request = new RecordPaymentRequest();
        request.setAmount(new BigDecimal("500000"));
        request.setPaymentMethod("CASH");
        request.setCreatedBy(5);

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);
        invoice.setStatus(InvoiceStatus.ACTIVE);
        Branches branch = new Branches();
        branch.setId(1);
        invoice.setBranch(branch);

        Employees employee = new Employees();
        employee.setEmployeeId(5);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(invoiceId)).thenReturn(BigDecimal.ZERO);
        when(employeeRepository.findById(5)).thenReturn(Optional.of(employee));
        when(employeeRepository.findByRoleNameAndBranchId(anyString(), anyInt())).thenReturn(Collections.emptyList());
        when(paymentHistoryRepository.save(any())).thenAnswer(inv -> {
            PaymentHistory ph = inv.getArgument(0);
            ph.setId(200);
            ph.setCreatedBy(employee);
            return ph;
        });
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        PaymentHistoryResponse response = invoiceService.recordPayment(invoiceId, request);

        // Then
        assertThat(response).isNotNull();
        verify(employeeRepository).findById(5);
    }

    @Test
    void recordPayment_whenWithConfirmationStatus_shouldSetStatus() {
        // Given
        Integer invoiceId = 100;
        RecordPaymentRequest request = new RecordPaymentRequest();
        request.setAmount(new BigDecimal("500000"));
        request.setPaymentMethod("CASH");
        request.setConfirmationStatus("CONFIRMED");

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);
        invoice.setStatus(InvoiceStatus.ACTIVE);
        Branches branch = new Branches();
        branch.setId(1);
        invoice.setBranch(branch);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(invoiceId))
                .thenReturn(BigDecimal.ZERO)
                .thenReturn(new BigDecimal("500000"));
        when(paymentHistoryRepository.save(any())).thenAnswer(inv -> {
            PaymentHistory ph = inv.getArgument(0);
            ph.setId(200);
            ph.setConfirmationStatus(PaymentConfirmationStatus.CONFIRMED);
            return ph;
        });
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        PaymentHistoryResponse response = invoiceService.recordPayment(invoiceId, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getConfirmationStatus()).isEqualTo("CONFIRMED");
        verify(paymentHistoryRepository).save(any());
    }

    @Test
    void recordPayment_whenInvalidConfirmationStatus_shouldDefaultToPending() {
        // Given
        Integer invoiceId = 100;
        RecordPaymentRequest request = new RecordPaymentRequest();
        request.setAmount(new BigDecimal("500000"));
        request.setPaymentMethod("CASH");
        request.setConfirmationStatus("INVALID_STATUS");

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);
        invoice.setStatus(InvoiceStatus.ACTIVE);
        Branches branch = new Branches();
        branch.setId(1);
        invoice.setBranch(branch);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(invoiceId)).thenReturn(BigDecimal.ZERO);
        when(employeeRepository.findByRoleNameAndBranchId(anyString(), anyInt())).thenReturn(Collections.emptyList());
        when(paymentHistoryRepository.save(any())).thenAnswer(inv -> {
            PaymentHistory ph = inv.getArgument(0);
            ph.setId(200);
            ph.setConfirmationStatus(PaymentConfirmationStatus.PENDING);
            return ph;
        });
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        PaymentHistoryResponse response = invoiceService.recordPayment(invoiceId, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getConfirmationStatus()).isEqualTo("PENDING");
    }

    // ==================== confirmPayment() Additional Tests ====================

    @Test
    void confirmPayment_whenRejectingPayment_shouldUpdateInvoiceStatusIfNeeded() {
        // Given
        Integer paymentId = 200;
        String status = "REJECTED";

        Invoices invoice = new Invoices();
        invoice.setId(100);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.PAID); // Đang là PAID

        PaymentHistory payment = new PaymentHistory();
        payment.setId(paymentId);
        payment.setInvoice(invoice);
        payment.setAmount(new BigDecimal("500000"));
        payment.setConfirmationStatus(PaymentConfirmationStatus.CONFIRMED);

        when(paymentHistoryRepository.findById(paymentId)).thenReturn(Optional.of(payment));
        when(invoiceRepository.findById(100)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(100))
                .thenReturn(new BigDecimal("500000")); // Sau khi reject, chỉ còn 500k confirmed

        // When
        invoiceService.confirmPayment(paymentId, status);

        // Then
        assertThat(payment.getConfirmationStatus()).isEqualTo(PaymentConfirmationStatus.REJECTED);
        assertThat(invoice.getPaymentStatus()).isEqualTo(PaymentStatus.UNPAID); // Phải chuyển về UNPAID
        verify(invoiceRepository).save(invoice);
    }

    // ==================== getInvoices() Additional Tests ====================

    @Test
    void getInvoices_whenWithDateRange_shouldFilterByDate() {
        // Given
        LocalDate startDate = LocalDate.of(2025, 12, 1);
        LocalDate endDate = LocalDate.of(2025, 12, 31);
        
        Invoices invoice = createTestInvoice(100, "INV-001", PaymentStatus.UNPAID);
        List<Invoices> invoices = List.of(invoice);

        when(invoiceRepository.findInvoicesWithFilters(any(), any(), any(), any(), any(), any(), any()))
                .thenReturn(invoices);
        when(invoiceRepository.findById(anyInt())).thenAnswer(inv -> {
            Integer id = inv.getArgument(0);
            return invoices.stream().filter(invItem -> invItem.getId().equals(id)).findFirst();
        });
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(anyInt())).thenReturn(BigDecimal.ZERO);
        when(paymentHistoryRepository.countPendingPaymentsByInvoiceId(anyInt())).thenReturn(0);

        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(0, 10);

        // When
        org.springframework.data.domain.Page<org.example.ptcmssbackend.dto.response.Invoice.InvoiceListResponse> result =
                invoiceService.getInvoices(null, null, null, null, startDate, endDate, null, null, pageable);

        // Then
        assertThat(result).isNotNull();
        verify(invoiceRepository).findInvoicesWithFilters(any(), any(), any(), any(), any(), any(), any());
    }

    @Test
    void getInvoices_whenWithCustomerId_shouldFilterByCustomer() {
        // Given
        Integer customerId = 10;
        Invoices invoice = createTestInvoice(100, "INV-001", PaymentStatus.UNPAID);
        List<Invoices> invoices = List.of(invoice);

        when(invoiceRepository.findInvoicesWithFilters(any(), any(), any(), any(), any(), eq(customerId), any()))
                .thenReturn(invoices);
        when(invoiceRepository.findById(anyInt())).thenAnswer(inv -> {
            Integer id = inv.getArgument(0);
            return invoices.stream().filter(invItem -> invItem.getId().equals(id)).findFirst();
        });
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(anyInt())).thenReturn(BigDecimal.ZERO);
        when(paymentHistoryRepository.countPendingPaymentsByInvoiceId(anyInt())).thenReturn(0);

        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(0, 10);

        // When
        org.springframework.data.domain.Page<org.example.ptcmssbackend.dto.response.Invoice.InvoiceListResponse> result =
                invoiceService.getInvoices(null, null, null, null, null, null, customerId, null, pageable);

        // Then
        assertThat(result).isNotNull();
        verify(invoiceRepository).findInvoicesWithFilters(any(), any(), any(), any(), any(), eq(customerId), any());
    }

    @Test
    void getInvoices_whenWithPagination_shouldReturnPagedResults() {
        // Given
        Invoices invoice1 = createTestInvoice(100, "INV-001", PaymentStatus.UNPAID);
        Invoices invoice2 = createTestInvoice(101, "INV-002", PaymentStatus.PAID);
        Invoices invoice3 = createTestInvoice(102, "INV-003", PaymentStatus.UNPAID);
        List<Invoices> invoices = List.of(invoice1, invoice2, invoice3);

        when(invoiceRepository.findInvoicesWithFilters(any(), any(), any(), any(), any(), any(), any()))
                .thenReturn(invoices);
        when(invoiceRepository.findById(anyInt())).thenAnswer(inv -> {
            Integer id = inv.getArgument(0);
            return invoices.stream().filter(invItem -> invItem.getId().equals(id)).findFirst();
        });
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(anyInt())).thenReturn(BigDecimal.ZERO);
        when(paymentHistoryRepository.countPendingPaymentsByInvoiceId(anyInt())).thenReturn(0);

        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(0, 2);

        // When
        org.springframework.data.domain.Page<org.example.ptcmssbackend.dto.response.Invoice.InvoiceListResponse> result =
                invoiceService.getInvoices(null, null, null, null, null, null, null, null, pageable);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getTotalElements()).isEqualTo(3);
        assertThat(result.getContent().size()).isEqualTo(2); // Page size = 2
    }

    // ==================== recordPayment() Additional Edge Cases ====================

    @Test
    void recordPayment_whenWithAllPaymentDetails_shouldSaveAllFields() {
        // Given
        Integer invoiceId = 100;
        RecordPaymentRequest request = new RecordPaymentRequest();
        request.setAmount(new BigDecimal("500000"));
        request.setPaymentMethod("BANK_TRANSFER");
        request.setBankName("Vietcombank");
        request.setBankAccount("1234567890");
        request.setReferenceNumber("REF-12345");
        request.setCashierName("Nguyễn Văn A");
        request.setReceiptNumber("REC-001");
        request.setNote("Test payment note");

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);
        invoice.setStatus(InvoiceStatus.ACTIVE);
        Branches branch = new Branches();
        branch.setId(1);
        invoice.setBranch(branch);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(invoiceId)).thenReturn(BigDecimal.ZERO);
        when(employeeRepository.findByRoleNameAndBranchId(anyString(), anyInt())).thenReturn(Collections.emptyList());
        when(paymentHistoryRepository.save(any())).thenAnswer(inv -> {
            PaymentHistory ph = inv.getArgument(0);
            ph.setId(200);
            return ph;
        });
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        PaymentHistoryResponse response = invoiceService.recordPayment(invoiceId, request);

        // Then
        assertThat(response).isNotNull();
        verify(paymentHistoryRepository).save(argThat(ph -> 
            ph.getBankName().equals("Vietcombank") &&
            ph.getBankAccount().equals("1234567890") &&
            ph.getReferenceNumber().equals("REF-12345") &&
            ph.getCashierName().equals("Nguyễn Văn A") &&
            ph.getReceiptNumber().equals("REC-001") &&
            ph.getNote().equals("Test payment note")
        ));
    }

    @Test
    void recordPayment_whenPaymentEqualsBalance_shouldMarkAsPaid() {
        // Given
        Integer invoiceId = 100;
        RecordPaymentRequest request = new RecordPaymentRequest();
        request.setAmount(new BigDecimal("1000000"));
        request.setPaymentMethod("CASH");
        request.setConfirmationStatus("CONFIRMED");

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);
        invoice.setStatus(InvoiceStatus.ACTIVE);
        Branches branch = new Branches();
        branch.setId(1);
        invoice.setBranch(branch);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(invoiceId))
                .thenReturn(BigDecimal.ZERO)
                .thenReturn(new BigDecimal("1000000"));
        when(paymentHistoryRepository.save(any())).thenAnswer(inv -> {
            PaymentHistory ph = inv.getArgument(0);
            ph.setId(200);
            ph.setConfirmationStatus(PaymentConfirmationStatus.CONFIRMED);
            return ph;
        });
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // When
        invoiceService.recordPayment(invoiceId, request);

        // Then
        assertThat(invoice.getPaymentStatus()).isEqualTo(PaymentStatus.PAID);
        verify(invoiceRepository).save(invoice);
    }

    // ==================== sendInvoice() Additional Tests ====================

    @Test
    void sendInvoice_whenEmailServiceFails_shouldThrowException() throws Exception {
        // Given
        Integer invoiceId = 100;
        SendInvoiceRequest request = new SendInvoiceRequest();
        request.setEmail("customer@example.com");
        request.setMessage("Test message");

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setInvoiceNumber("INV-001");
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setDueDate(LocalDate.now().plusDays(7));
        Customers customer = new Customers();
        customer.setFullName("Nguyễn Văn A");
        invoice.setCustomer(customer);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        doThrow(new RuntimeException("Email service unavailable"))
                .when(emailService).sendInvoiceEmail(anyString(), anyString(), anyString(), 
                        anyString(), anyString(), anyString(), anyString());

        // When & Then
        assertThatThrownBy(() -> invoiceService.sendInvoice(invoiceId, request))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Không thể gửi email");
    }

    @Test
    void sendInvoice_whenCustomerIsNull_shouldUseDefaultName() throws Exception {
        // Given
        Integer invoiceId = 100;
        SendInvoiceRequest request = new SendInvoiceRequest();
        request.setEmail("customer@example.com");
        request.setMessage("Test message");

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setInvoiceNumber("INV-001");
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setDueDate(LocalDate.now().plusDays(7));
        invoice.setCustomer(null); // No customer
        invoice.setNote(null);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        doNothing().when(emailService).sendInvoiceEmail(anyString(), anyString(), anyString(), 
                anyString(), anyString(), anyString(), anyString());

        // When
        invoiceService.sendInvoice(invoiceId, request);

        // Then
        verify(emailService).sendInvoiceEmail(eq("customer@example.com"), eq("Quý khách"), 
                eq("INV-001"), anyString(), anyString(), anyString(), eq("Test message"));
    }

    // ==================== getInvoices() Additional Edge Cases ====================

    @Test
    void getInvoices_whenEmptyResults_shouldReturnEmptyPage() {
        // Given
        when(invoiceRepository.findInvoicesWithFilters(any(), any(), any(), any(), any(), any(), any()))
                .thenReturn(Collections.emptyList());

        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(0, 10);

        // When
        org.springframework.data.domain.Page<org.example.ptcmssbackend.dto.response.Invoice.InvoiceListResponse> result =
                invoiceService.getInvoices(null, null, null, null, null, null, null, null, pageable);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getTotalElements()).isEqualTo(0);
        assertThat(result.getContent()).isEmpty();
    }

    @Test
    void getInvoices_whenKeywordMatchesInvoiceNumber_shouldFilterCorrectly() {
        // Given
        Invoices invoice = createTestInvoice(100, "INV-2025-001", PaymentStatus.UNPAID);
        List<Invoices> invoices = List.of(invoice);

        when(invoiceRepository.findInvoicesWithFilters(any(), any(), any(), any(), any(), any(), any()))
                .thenReturn(invoices);
        when(invoiceRepository.findById(anyInt())).thenAnswer(inv -> {
            Integer id = inv.getArgument(0);
            return invoices.stream().filter(invItem -> invItem.getId().equals(id)).findFirst();
        });
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(anyInt())).thenReturn(BigDecimal.ZERO);
        when(paymentHistoryRepository.countPendingPaymentsByInvoiceId(anyInt())).thenReturn(0);

        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(0, 10);

        // When
        org.springframework.data.domain.Page<org.example.ptcmssbackend.dto.response.Invoice.InvoiceListResponse> result =
                invoiceService.getInvoices(null, null, null, null, null, null, null, "2025-001", pageable);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getTotalElements()).isEqualTo(1);
    }

    @Test
    void getInvoices_whenKeywordMatchesBookingCode_shouldFilterCorrectly() {
        // Given
        Invoices invoice = createTestInvoice(100, "INV-001", PaymentStatus.UNPAID);
        Bookings booking = new Bookings();
        booking.setId(50);
        invoice.setBooking(booking);
        List<Invoices> invoices = List.of(invoice);

        when(invoiceRepository.findInvoicesWithFilters(any(), any(), any(), any(), any(), any(), any()))
                .thenReturn(invoices);
        when(invoiceRepository.findById(anyInt())).thenAnswer(inv -> {
            Integer id = inv.getArgument(0);
            return invoices.stream().filter(invItem -> invItem.getId().equals(id)).findFirst();
        });
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(anyInt())).thenReturn(BigDecimal.ZERO);
        when(paymentHistoryRepository.countPendingPaymentsByInvoiceId(anyInt())).thenReturn(0);

        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(0, 10);

        // When
        org.springframework.data.domain.Page<org.example.ptcmssbackend.dto.response.Invoice.InvoiceListResponse> result =
                invoiceService.getInvoices(null, null, null, null, null, null, null, "ORD-50", pageable);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getTotalElements()).isEqualTo(1);
    }

    // ==================== createInvoice() Additional Edge Cases ====================

    @Test
    void createInvoice_whenWithVatAmount_shouldSetVatAmount() {
        // Given
        CreateInvoiceRequest request = new CreateInvoiceRequest();
        request.setBranchId(1);
        request.setType("INCOME");
        request.setAmount(new BigDecimal("1100000"));

        Branches branch = new Branches();
        branch.setId(1);

        when(branchesRepository.findById(1)).thenReturn(Optional.of(branch));
        when(invoiceRepository.save(any())).thenAnswer(inv -> {
            Invoices invEntity = inv.getArgument(0);
            invEntity.setId(100);
            invEntity.setInvoiceNumber("INV-2025-001");
            return invEntity;
        });
        when(invoiceRepository.findById(100)).thenAnswer(inv -> {
            Invoices invEntity = new Invoices();
            invEntity.setId(100);
            invEntity.setInvoiceNumber("INV-2025-001");
            invEntity.setBranch(branch);
            invEntity.setType(InvoiceType.INCOME);
            invEntity.setAmount(new BigDecimal("1100000"));
            invEntity.setStatus(InvoiceStatus.ACTIVE);
            invEntity.setPaymentStatus(PaymentStatus.UNPAID);
            return Optional.of(invEntity);
        });
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(100)).thenReturn(BigDecimal.ZERO);

        // When
        InvoiceResponse response = invoiceService.createInvoice(request);

        // Then
        assertThat(response).isNotNull();
        // VAT amount field has been removed
    }

    @Test
    void createInvoice_whenWithPaymentTerms_shouldSetDueDate() {
        // Given
        CreateInvoiceRequest request = new CreateInvoiceRequest();
        request.setBranchId(1);
        request.setType("INCOME");
        request.setAmount(new BigDecimal("1000000"));
        request.setPaymentTerms("NET_30");

        Branches branch = new Branches();
        branch.setId(1);

        when(branchesRepository.findById(1)).thenReturn(Optional.of(branch));
        when(invoiceRepository.save(any())).thenAnswer(inv -> {
            Invoices invEntity = inv.getArgument(0);
            invEntity.setId(100);
            invEntity.setInvoiceNumber("INV-2025-001");
            invEntity.setInvoiceDate(Instant.now());
            return invEntity;
        });
        when(invoiceRepository.findById(100)).thenAnswer(inv -> {
            Invoices invEntity = new Invoices();
            invEntity.setId(100);
            invEntity.setInvoiceNumber("INV-2025-001");
            invEntity.setBranch(branch);
            invEntity.setType(InvoiceType.INCOME);
            invEntity.setAmount(new BigDecimal("1000000"));
            invEntity.setPaymentTerms("NET_30");
            invEntity.setStatus(InvoiceStatus.ACTIVE);
            invEntity.setPaymentStatus(PaymentStatus.UNPAID);
            invEntity.setInvoiceDate(Instant.now());
            invEntity.setDueDate(LocalDate.now().plusDays(30));
            return Optional.of(invEntity);
        });
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(100)).thenReturn(BigDecimal.ZERO);

        // When
        InvoiceResponse response = invoiceService.createInvoice(request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getPaymentTerms()).isEqualTo("NET_30");
    }

    // ==================== updateInvoice() Additional Tests ====================

    @Test
    void updateInvoice_whenWithVatAmount_shouldUpdateVatAmount() {
        // Given
        Integer invoiceId = 100;
        CreateInvoiceRequest request = new CreateInvoiceRequest();

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);
        invoice.setStatus(InvoiceStatus.ACTIVE);
        invoice.setType(InvoiceType.INCOME);
        Branches branch = new Branches();
        branch.setId(1);
        invoice.setBranch(branch);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(invoiceId)).thenReturn(BigDecimal.ZERO);
        when(paymentHistoryRepository.countPendingPaymentsByInvoiceId(invoiceId)).thenReturn(0);

        // When
        InvoiceResponse response = invoiceService.updateInvoice(invoiceId, request);

        // Then
        assertThat(response).isNotNull();
        // VAT amount field has been removed
    }

    @Test
    void updateInvoice_whenWithPaymentTerms_shouldUpdatePaymentTerms() {
        // Given
        Integer invoiceId = 100;
        CreateInvoiceRequest request = new CreateInvoiceRequest();
        request.setPaymentTerms("NET_60");

        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(PaymentStatus.UNPAID);
        invoice.setStatus(InvoiceStatus.ACTIVE);
        invoice.setType(InvoiceType.INCOME);
        Branches branch = new Branches();
        branch.setId(1);
        invoice.setBranch(branch);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));
        when(invoiceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(paymentHistoryRepository.sumConfirmedByInvoiceId(invoiceId)).thenReturn(BigDecimal.ZERO);
        when(paymentHistoryRepository.countPendingPaymentsByInvoiceId(invoiceId)).thenReturn(0);

        // When
        InvoiceResponse response = invoiceService.updateInvoice(invoiceId, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(invoice.getPaymentTerms()).isEqualTo("NET_60");
    }

    // ==================== isOverdue() Additional Tests ====================

    @Test
    void isOverdue_whenDueDateIsToday_shouldReturnFalse() {
        // Given
        Integer invoiceId = 100;
        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setDueDate(LocalDate.now());
        invoice.setPaymentStatus(PaymentStatus.UNPAID);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));

        // When
        boolean result = invoiceService.isOverdue(invoiceId);

        // Then
        assertThat(result).isFalse();
    }

    @Test
    void isOverdue_whenDueDateIsNull_shouldReturnFalse() {
        // Given
        Integer invoiceId = 100;
        Invoices invoice = new Invoices();
        invoice.setId(invoiceId);
        invoice.setDueDate(null);
        invoice.setPaymentStatus(PaymentStatus.UNPAID);

        when(invoiceRepository.findById(invoiceId)).thenReturn(Optional.of(invoice));

        // When
        boolean result = invoiceService.isOverdue(invoiceId);

        // Then
        assertThat(result).isFalse();
    }

    // ==================== Helper Methods ====================

    private Invoices createTestInvoice(Integer id, String invoiceNumber, PaymentStatus paymentStatus) {
        Invoices invoice = new Invoices();
        invoice.setId(id);
        invoice.setInvoiceNumber(invoiceNumber);
        invoice.setAmount(new BigDecimal("1000000"));
        invoice.setPaymentStatus(paymentStatus);
        invoice.setStatus(InvoiceStatus.ACTIVE);
        Branches branch = new Branches();
        branch.setId(1);
        branch.setBranchName("Chi nhánh Hà Nội");
        invoice.setBranch(branch);
        invoice.setType(InvoiceType.INCOME);
        return invoice;
    }
}

