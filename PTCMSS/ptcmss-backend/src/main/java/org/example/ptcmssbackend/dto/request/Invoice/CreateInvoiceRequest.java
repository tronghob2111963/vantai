package org.example.ptcmssbackend.dto.request.Invoice;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class CreateInvoiceRequest {
    @NotNull
    private Integer branchId;

    private Integer bookingId;

    private Integer customerId;

    @NotNull
    private String type; // INCOME, EXPENSE

    private Boolean isDeposit = false;

    @NotNull
    @Min(0)
    private BigDecimal amount;

    private String paymentTerms = "NET_7"; // NET_7, NET_14, NET_30, NET_60

    private LocalDate dueDate;

    private String note;

    private Integer createdBy;
}

