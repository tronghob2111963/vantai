package org.example.ptcmssbackend.service;

import org.example.ptcmssbackend.dto.request.Booking.CreateDepositRequest;
import org.example.ptcmssbackend.dto.response.Booking.PaymentResponse;
import org.example.ptcmssbackend.dto.response.Booking.QRCodeResponse;

import java.math.BigDecimal;
import java.util.List;

public interface PaymentService {
    /**
     * Generate QR code thanh toán cho booking
     * @param bookingId ID đơn hàng
     * @param amount Số tiền cần thanh toán (null = depositAmount hoặc remainingAmount)
     * @return QRCodeResponse với QR image base64
     */
    QRCodeResponse generateQRCode(Integer bookingId, BigDecimal amount);
    
    /**
     * Ghi nhận tiền cọc/thanh toán
     * @param bookingId ID đơn hàng
     * @param request Thông tin thanh toán
     * @param createdByEmployeeId ID nhân viên tạo
     * @return PaymentResponse
     */
    PaymentResponse createDeposit(Integer bookingId, CreateDepositRequest request, Integer createdByEmployeeId);
    
    /**
     * Lấy lịch sử thanh toán của booking
     * @param bookingId ID đơn hàng
     * @return Danh sách payments
     */
    List<PaymentResponse> getPaymentHistory(Integer bookingId);
}

