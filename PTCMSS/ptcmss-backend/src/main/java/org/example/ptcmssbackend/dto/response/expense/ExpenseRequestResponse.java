package org.example.ptcmssbackend.dto.response.expense;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.Instant;
@Data
@Builder
public class ExpenseRequestResponse {
    private Integer id;
    private String type;
    private BigDecimal amount;
    private String note;
    private String status;
    private Integer branchId;
    private String branchName;
    private Integer vehicleId;
    private String vehiclePlate;
    private Integer requesterUserId;
    private String requesterName;
    private Instant createdAt;
}
