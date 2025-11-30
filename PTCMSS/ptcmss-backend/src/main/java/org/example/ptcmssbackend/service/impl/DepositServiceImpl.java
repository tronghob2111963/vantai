package org.example.ptcmssbackend.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.ptcmssbackend.dto.request.Invoice.CreateInvoiceRequest;
import org.example.ptcmssbackend.dto.response.Invoice.InvoiceResponse;
import org.example.ptcmssbackend.entity.Bookings;
import org.example.ptcmssbackend.entity.Invoices;
import org.example.ptcmssbackend.enums.InvoiceStatus;
import org.example.ptcmssbackend.enums.InvoiceType;
import org.example.ptcmssbackend.enums.PaymentStatus;
import org.example.ptcmssbackend.exception.ResourceNotFoundException;
import org.example.ptcmssbackend.repository.BookingRepository;
import org.example.ptcmssbackend.repository.InvoiceRepository;
import org.example.ptcmssbackend.repository.PaymentHistoryRepository;
import org.example.ptcmssbackend.service.DepositService;
import org.example.ptcmssbackend.service.InvoiceService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class DepositServiceImpl implements DepositService {

    private final InvoiceService invoiceService;
    private final InvoiceRepository invoiceRepository;
    private final BookingRepository bookingRepository;
    private final PaymentHistoryRepository paymentHistoryRepository;
    private final org.example.ptcmssbackend.repository.EmployeeRepository employeeRepository;

    @Override
    @Transactional
    public InvoiceResponse createDeposit(Integer bookingId, CreateInvoiceRequest request) {
        log.info("[DepositService] Creating deposit for booking: {}", bookingId);

        Bookings booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found: " + bookingId));

        // Validate deposit amount
        BigDecimal remainingAmount = getRemainingAmount(bookingId);
        if (request.getAmount().compareTo(remainingAmount) > 0) {
            throw new RuntimeException("Số tiền đặt cọc vượt quá số tiền còn lại: " + remainingAmount);
        }

        // Nếu isDeposit = false (thanh toán thường từ tài xế), tạo payment_history PENDING chờ kế toán duyệt
        if (Boolean.FALSE.equals(request.getIsDeposit())) {
            List<Invoices> existingInvoices = invoiceRepository.findByBooking_IdOrderByCreatedAtDesc(bookingId);
            // Tìm invoice INCOME UNPAID bất kỳ của booking này để gắn payment history
            Invoices targetInvoice = existingInvoices.stream()
                    .filter(inv -> inv.getType() == InvoiceType.INCOME && inv.getPaymentStatus() == PaymentStatus.UNPAID)
                    .findFirst()
                    .orElse(null);

            // Nếu không có invoice UNPAID, tạo mới invoice với status UNPAID
            if (targetInvoice == null) {
                request.setBookingId(bookingId);
                request.setCustomerId(booking.getCustomer().getId());
                request.setBranchId(booking.getBranch().getId());
                request.setType("INCOME");
                request.setIsDeposit(false);
                
                // Tạo invoice mới với status UNPAID (InvoiceService tạo với UNPAID by default)
                InvoiceResponse newInvoiceResp = invoiceService.createInvoice(request);
                targetInvoice = invoiceRepository.findById(newInvoiceResp.getInvoiceId())
                        .orElseThrow(() -> new RuntimeException("Failed to create invoice"));
            }

            // Tạo payment_history với status PENDING chờ kế toán xác nhận
            org.example.ptcmssbackend.entity.PaymentHistory paymentHistory = new org.example.ptcmssbackend.entity.PaymentHistory();
            paymentHistory.setInvoice(targetInvoice);
            paymentHistory.setPaymentDate(java.time.Instant.now());
            paymentHistory.setAmount(request.getAmount());
            paymentHistory.setPaymentMethod(request.getPaymentMethod() != null ? request.getPaymentMethod() : "CASH");
            paymentHistory.setConfirmationStatus(org.example.ptcmssbackend.enums.PaymentConfirmationStatus.PENDING);
            paymentHistory.setNote(request.getNote());
            paymentHistory.setBankName(request.getBankName());
            paymentHistory.setBankAccount(request.getBankAccount());
            paymentHistory.setReferenceNumber(request.getReferenceNumber());
            paymentHistory.setCashierName(request.getCashierName());
            
            // Generate receipt number if CASH
            if ("CASH".equalsIgnoreCase(request.getPaymentMethod())) {
                String receiptNum = request.getReceiptNumber();
                if (receiptNum == null || receiptNum.isEmpty()) {
                    receiptNum = generateReceiptNumber(booking.getBranch().getId());
                }
                paymentHistory.setReceiptNumber(receiptNum);
            } else {
                paymentHistory.setReceiptNumber(request.getReceiptNumber());
            }

            if (request.getCreatedBy() != null) {
                paymentHistory.setCreatedBy(employeeRepository.findById(request.getCreatedBy()).orElse(null));
            }

            paymentHistoryRepository.save(paymentHistory);
            log.info("[DepositService] Created payment_history PENDING for invoice: {}, amount: {}", 
                    targetInvoice.getInvoiceNumber(), request.getAmount());

            return invoiceService.getInvoiceById(targetInvoice.getId());
        }

        // Set deposit flag (nếu chưa set)
        if (request.getIsDeposit() == null) {
            request.setIsDeposit(true);
        }
        request.setBookingId(bookingId);
        request.setCustomerId(booking.getCustomer().getId());
        request.setBranchId(booking.getBranch().getId());
        request.setType("INCOME");

        // Generate receipt number if payment method is CASH and not provided
        if ("CASH".equalsIgnoreCase(request.getPaymentMethod())) {
            if (request.getReceiptNumber() == null || request.getReceiptNumber().isEmpty()) {
                request.setReceiptNumber(generateReceiptNumber(booking.getBranch().getId()));
            }
        }

        // Create invoice (deposit)
        InvoiceResponse response = invoiceService.createInvoice(request);

        log.info("[DepositService] Deposit created: {}", response.getInvoiceNumber());
        return response;
    }

    @Override
    public List<InvoiceResponse> getDepositsByBooking(Integer bookingId) {
        List<Invoices> deposits = invoiceRepository.findByBooking_IdOrderByCreatedAtDesc(bookingId);
        return deposits.stream()
                .filter(inv -> Boolean.TRUE.equals(inv.getIsDeposit()))
                .filter(inv -> inv.getType() == InvoiceType.INCOME)
                .map(inv -> invoiceService.getInvoiceById(inv.getId()))
                .collect(Collectors.toList());
    }

    @Override
    public BigDecimal getTotalDepositPaid(Integer bookingId) {
        List<Invoices> deposits = invoiceRepository.findByBooking_IdOrderByCreatedAtDesc(bookingId);
        return deposits.stream()
                .filter(inv -> Boolean.TRUE.equals(inv.getIsDeposit()))
                .filter(inv -> inv.getType() == InvoiceType.INCOME)
                .filter(inv -> inv.getPaymentStatus() == PaymentStatus.PAID)
                .map(inv -> paymentHistoryRepository.sumConfirmedByInvoiceId(inv.getId()))
                .filter(amount -> amount != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    @Override
    public BigDecimal getRemainingAmount(Integer bookingId) {
        Bookings booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found: " + bookingId));

        BigDecimal totalCost = booking.getTotalCost() != null ? booking.getTotalCost() : BigDecimal.ZERO;
        BigDecimal totalPaid = getTotalDepositPaid(bookingId);

        return totalCost.subtract(totalPaid);
    }

    @Override
    @Transactional
    public void cancelDeposit(Integer depositId, String reason) {
        Invoices deposit = invoiceRepository.findById(depositId)
                .orElseThrow(() -> new ResourceNotFoundException("Deposit not found: " + depositId));

        if (!Boolean.TRUE.equals(deposit.getIsDeposit())) {
            throw new RuntimeException("Hóa đơn không phải là tiền đặt cọc");
        }

        deposit.setStatus(InvoiceStatus.CANCELLED);
        deposit.setCancellationReason(reason);
        invoiceRepository.save(deposit);

        log.info("[DepositService] Deposit {} cancelled: {}", deposit.getInvoiceNumber(), reason);
    }

    @Override
    public String generateReceiptNumber(Integer branchId) {
        LocalDate today = LocalDate.now();
        String year = String.valueOf(today.getYear());
        String month = String.format("%02d", today.getMonthValue());
        String day = String.format("%02d", today.getDayOfMonth());
        
        // Get max sequence for today
        String pattern = "REC-" + year + month + day + "-%";
        Integer maxSeq = invoiceRepository.findMaxSequenceNumber(branchId, pattern);
        int nextSeq = (maxSeq != null ? maxSeq : 0) + 1;
        
        return String.format("REC-%s%s%s-%04d", year, month, day, nextSeq);
    }
}

