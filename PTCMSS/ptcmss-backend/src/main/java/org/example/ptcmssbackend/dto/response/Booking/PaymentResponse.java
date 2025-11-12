package org.example.ptcmssbackend.dto.response.Booking;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.Instant;

@Data
@Builder
public class PaymentResponse {
    private Integer invoiceId;
    private BigDecimal amount;
    private String paymentMethod;
    private String paymentStatus;
    private Boolean isDeposit;
    private String note;
    private String referenceCode;
    private Instant invoiceDate;
    private Instant createdAt;
    private String createdByName;
    private String approvedByName;
    private Instant approvedAt;
}

