package org.example.ptcmssbackend.service.impl;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.ptcmssbackend.dto.request.Booking.CreateDepositRequest;
import org.example.ptcmssbackend.dto.response.Booking.PaymentResponse;
import org.example.ptcmssbackend.dto.response.Booking.QRCodeResponse;
import org.example.ptcmssbackend.entity.Bookings;
import org.example.ptcmssbackend.entity.Employees;
import org.example.ptcmssbackend.entity.Invoices;
import org.example.ptcmssbackend.enums.InvoiceStatus;
import org.example.ptcmssbackend.enums.InvoiceType;
import org.example.ptcmssbackend.enums.PaymentStatus;
import org.example.ptcmssbackend.repository.BookingRepository;
import org.example.ptcmssbackend.repository.EmployeeRepository;
import org.example.ptcmssbackend.repository.InvoiceRepository;
import org.example.ptcmssbackend.service.PaymentService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentServiceImpl implements PaymentService {
    
    private final BookingRepository bookingRepository;
    private final InvoiceRepository invoiceRepository;
    private final EmployeeRepository employeeRepository;
    
    // Bank account config (đọc từ application.yml hoặc environment variables)
    @Value("${payment.bank.code:970418}")
    private String bankCode;
    
    @Value("${payment.bank.account.number:}")
    private String accountNumber;
    
    @Value("${payment.bank.account.name:CONG TY PTCMSS}")
    private String accountName;
    
    // VietQR API config (đọc từ environment variables)
    @Value("${vietqr.client-id:}")
    private String vietqrClientId;
    
    @Value("${vietqr.api-key:}")
    private String vietqrApiKey;
    
    @Override
    public QRCodeResponse generateQRCode(Integer bookingId, BigDecimal amount) {
        log.info("[PaymentService] Generating QR code for booking {} with amount {}", bookingId, amount);
        
        Bookings booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Booking not found: " + bookingId));
        
        // Xác định số tiền cần thanh toán
        BigDecimal paymentAmount = amount;
        if (paymentAmount == null) {
            // Nếu không có amount, dùng depositAmount hoặc remainingAmount
            BigDecimal paidAmount = invoiceRepository.calculatePaidAmountByBookingId(bookingId);
            BigDecimal remainingAmount = booking.getTotalCost() != null
                    ? booking.getTotalCost().subtract(paidAmount)
                    : BigDecimal.ZERO;
            
            if (remainingAmount.compareTo(BigDecimal.ZERO) > 0) {
                paymentAmount = remainingAmount;
            } else {
                paymentAmount = booking.getDepositAmount() != null && booking.getDepositAmount().compareTo(BigDecimal.ZERO) > 0
                        ? booking.getDepositAmount()
                        : BigDecimal.ZERO;
            }
        }
        
        if (paymentAmount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("Số tiền thanh toán phải lớn hơn 0");
        }
        
        // Tạo nội dung chuyển khoản
        String description = String.format("PTCMSS BK%d %s", 
                bookingId, 
                paymentAmount.equals(booking.getDepositAmount()) ? "Tien Coc" : "Thanh Toan");
        
        // Tạo VietQR payload (format đơn giản - có thể mở rộng sau)
        // Format: Bank Code + Account Number + Amount + Description
        String qrContent = buildVietQRPayload(paymentAmount, description);
        
        // Generate QR code image
        String qrImageBase64 = generateQRImage(qrContent);
        
        // QR code hết hạn sau 24h
        Instant expiresAt = Instant.now().plus(24, ChronoUnit.HOURS);
        
        return QRCodeResponse.builder()
                .bookingId(bookingId)
                .amount(paymentAmount)
                .currency("VND")
                .description(description)
                .qrImageBase64(qrImageBase64)
                .bankAccount(QRCodeResponse.BankAccountInfo.builder()
                        .bankCode(bankCode)
                        .accountNumber(accountNumber)
                        .accountName(accountName)
                        .build())
                .expiresAt(expiresAt)
                .build();
    }
    
    @Override
    @Transactional
    public PaymentResponse createDeposit(Integer bookingId, CreateDepositRequest request, Integer createdByEmployeeId) {
        log.info("[PaymentService] Creating deposit for booking {} with amount {}", bookingId, request.getAmount());
        
        Bookings booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Booking not found: " + bookingId));
        
        // Kiểm tra số tiền
        BigDecimal totalCost = booking.getTotalCost() != null ? booking.getTotalCost() : BigDecimal.ZERO;
        BigDecimal paidAmount = invoiceRepository.calculatePaidAmountByBookingId(bookingId);
        BigDecimal remainingAmount = totalCost.subtract(paidAmount);
        
        if (request.getAmount().compareTo(remainingAmount) > 0) {
            throw new RuntimeException("Số tiền thanh toán không được vượt quá số tiền còn lại: " + remainingAmount);
        }
        
        // Tạo Invoice cho payment
        Invoices invoice = new Invoices();
        invoice.setBranch(booking.getBranch());
        invoice.setBooking(booking);
        invoice.setCustomer(booking.getCustomer());
        invoice.setType(InvoiceType.INCOME);
        invoice.setIsDeposit(request.getAmount().equals(booking.getDepositAmount()));
        invoice.setAmount(request.getAmount());
        invoice.setPaymentMethod(request.getPaymentMethod());
        invoice.setPaymentStatus(PaymentStatus.PAID); // Đã thanh toán
        invoice.setStatus(InvoiceStatus.ACTIVE);
        invoice.setNote(request.getNote());
        
        // Set createdBy
        if (createdByEmployeeId != null) {
            Employees createdBy = employeeRepository.findById(createdByEmployeeId).orElse(null);
            invoice.setCreatedBy(createdBy);
        }
        
        invoice = invoiceRepository.save(invoice);
        
        // Auto-approve nếu là Accountant hoặc Manager
        // (Có thể mở rộng logic approval sau)
        if (createdByEmployeeId != null) {
            Employees createdBy = employeeRepository.findById(createdByEmployeeId).orElse(null);
            if (createdBy != null && (createdBy.getRole().getRoleName().equals("Accountant") || 
                                      createdBy.getRole().getRoleName().equals("Manager") ||
                                      createdBy.getRole().getRoleName().equals("Admin"))) {
                invoice.setApprovedBy(createdBy);
                invoice.setApprovedAt(Instant.now());
                invoice = invoiceRepository.save(invoice);
            }
        }
        
        return toPaymentResponse(invoice);
    }
    
    @Override
    public List<PaymentResponse> getPaymentHistory(Integer bookingId) {
        log.info("[PaymentService] Getting payment history for booking {}", bookingId);
        
        List<Invoices> payments = invoiceRepository.findPaymentsByBookingId(bookingId);
        return payments.stream()
                .map(this::toPaymentResponse)
                .collect(Collectors.toList());
    }
    
    // Helper methods
    private String buildVietQRPayload(BigDecimal amount, String description) {
        // VietQR format đơn giản (có thể mở rộng theo chuẩn VietQR chính thức)
        // Format: BankCode|AccountNumber|Amount|Description
        // Ví dụ: 970418|1234567890|1500000|PTCMSS BK123 Tien Coc
        
        // Lưu ý: Đây là format đơn giản, nếu cần tích hợp VietQR chính thức,
        // cần sử dụng thư viện VietQR SDK hoặc API của ngân hàng
        return String.format("%s|%s|%s|%s", 
                bankCode, 
                accountNumber, 
                amount.toBigInteger().toString(),
                description);
    }
    
    private String generateQRImage(String content) {
        try {
            int width = 300;
            int height = 300;
            
            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H);
            hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
            hints.put(EncodeHintType.MARGIN, 1);
            
            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            BitMatrix bitMatrix = qrCodeWriter.encode(content, BarcodeFormat.QR_CODE, width, height, hints);
            
            BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
            Graphics2D graphics = (Graphics2D) image.getGraphics();
            graphics.setColor(Color.WHITE);
            graphics.fillRect(0, 0, width, height);
            graphics.setColor(Color.BLACK);
            
            for (int x = 0; x < width; x++) {
                for (int y = 0; y < height; y++) {
                    if (bitMatrix.get(x, y)) {
                        graphics.fillRect(x, y, 1, 1);
                    }
                }
            }
            
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ImageIO.write(image, "PNG", baos);
            byte[] imageBytes = baos.toByteArray();
            
            return "data:image/png;base64," + Base64.getEncoder().encodeToString(imageBytes);
        } catch (WriterException | IOException e) {
            log.error("Error generating QR code", e);
            throw new RuntimeException("Không thể tạo QR code: " + e.getMessage());
        }
    }
    
    private PaymentResponse toPaymentResponse(Invoices invoice) {
        return PaymentResponse.builder()
                .invoiceId(invoice.getId())
                .amount(invoice.getAmount())
                .paymentMethod(invoice.getPaymentMethod())
                .paymentStatus(invoice.getPaymentStatus() != null ? invoice.getPaymentStatus().name() : null)
                .isDeposit(invoice.getIsDeposit())
                .note(invoice.getNote())
                .referenceCode(null) // TODO: Thêm field referenceCode vào Invoices entity nếu cần
                .invoiceDate(invoice.getInvoiceDate())
                .createdAt(invoice.getCreatedAt())
                .createdByName(invoice.getCreatedBy() != null && invoice.getCreatedBy().getUser() != null
                        ? invoice.getCreatedBy().getUser().getFullName() : null)
                .approvedByName(invoice.getApprovedBy() != null && invoice.getApprovedBy().getUser() != null
                        ? invoice.getApprovedBy().getUser().getFullName() : null)
                .approvedAt(invoice.getApprovedAt())
                .build();
    }
}

