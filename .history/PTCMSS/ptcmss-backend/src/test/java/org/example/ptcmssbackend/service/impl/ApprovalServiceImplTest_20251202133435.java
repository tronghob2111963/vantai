package org.example.ptcmssbackend.service.impl;

import org.example.ptcmssbackend.BaseTest;
import org.example.ptcmssbackend.entity.*;
import org.example.ptcmssbackend.enums.ApprovalStatus;
import org.example.ptcmssbackend.exception.ResourceNotFoundException;
import org.example.ptcmssbackend.repository.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.time.Instant;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class ApprovalServiceImplTest extends BaseTest {

    @Mock
    private ApprovalHistoryRepository approvalHistoryRepository;

    @Mock
    private ExpenseRequestRepository expenseRequestRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private ApprovalServiceImpl approvalService;

    private ExpenseRequest testExpenseRequest;
    private Users testApprover;
    private ApprovalHistory testApproval;

    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();

        testApprover = new Users();
        testApprover.setId(1);
        testApprover.setUsername("manager");
        testApprover.setFullName("Manager User");

        Users requester = new Users();
        requester.setId(2);
        requester.setUsername("staff");

        testExpenseRequest = new ExpenseRequest();
        testExpenseRequest.setId(1);
        testExpenseRequest.setRequestCode("EXP20251202001");
        testExpenseRequest.setApprovalStatus(ApprovalStatus.PENDING);
        testExpenseRequest.setRequestedBy(requester);

        testApproval = new ApprovalHistory();
        testApproval.setId(1);
        testApproval.setRelatedEntityType("EXPENSE_REQUEST");
        testApproval.setRelatedEntityId(1);
        testApproval.setApprovalStatus(ApprovalStatus.PENDING);
        testApproval.setApprovedBy(testApprover);
    }

    @Test
    void approveExpenseRequest_Success() {
        // Given
        when(expenseRequestRepository.findById(1)).thenReturn(Optional.of(testExpenseRequest));
        when(userRepository.findById(1)).thenReturn(Optional.of(testApprover));
        when(approvalHistoryRepository.save(any(ApprovalHistory.class))).thenReturn(testApproval);
        when(expenseRequestRepository.save(any(ExpenseRequest.class))).thenReturn(testExpenseRequest);

        // When
        approvalService.approveExpenseRequest(1, 1, "Approved");

        // Then
        verify(approvalHistoryRepository, times(1)).save(argThat(approval -> 
            approval.getApprovalStatus() == ApprovalStatus.APPROVED &&
            "Approved".equals(approval.getComments())
        ));
        verify(expenseRequestRepository, times(1)).save(argThat(request -> 
            request.getApprovalStatus() == ApprovalStatus.APPROVED
        ));
    }

    @Test
    void approveExpenseRequest_AlreadyApproved_ThrowsException() {
        // Given
        testExpenseRequest.setApprovalStatus(ApprovalStatus.APPROVED);
        when(expenseRequestRepository.findById(1)).thenReturn(Optional.of(testExpenseRequest));

        // When & Then
        IllegalStateException exception = assertThrows(IllegalStateException.class, () -> {
            approvalService.approveExpenseRequest(1, 1, "Approved");
        });

        assertTrue(exception.getMessage().contains("already been"));
        verify(approvalHistoryRepository, never()).save(any());
    }

    @Test
    void rejectExpenseRequest_Success() {
        // Given
        when(expenseRequestRepository.findById(1)).thenReturn(Optional.of(testExpenseRequest));
        when(userRepository.findById(1)).thenReturn(Optional.of(testApprover));
        when(approvalHistoryRepository.save(any(ApprovalHistory.class))).thenReturn(testApproval);
        when(expenseRequestRepository.save(any(ExpenseRequest.class))).thenReturn(testExpenseRequest);

        // When
        approvalService.rejectExpenseRequest(1, 1, "Not approved");

        // Then
        verify(approvalHistoryRepository, times(1)).save(argThat(approval -> 
            approval.getApprovalStatus() == ApprovalStatus.REJECTED &&
            "Not approved".equals(approval.getComments())
        ));
        verify(expenseRequestRepository, times(1)).save(argThat(request -> 
            request.getApprovalStatus() == ApprovalStatus.REJECTED
        ));
    }

    @Test
    void getApprovalHistory_Success() {
        // Given
        when(approvalHistoryRepository.findById(1)).thenReturn(Optional.of(testApproval));

        // When
        ApprovalHistory result = approvalService.getApprovalHistory(1);

        // Then
        assertNotNull(result);
        assertEquals(1, result.getId());
        assertEquals(ApprovalStatus.PENDING, result.getApprovalStatus());
    }

    @Test
    void getApprovalHistory_NotFound_ThrowsException() {
        // Given
        when(approvalHistoryRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
            approvalService.getApprovalHistory(999);
        });

        assertTrue(exception.getMessage().contains("Approval history not found"));
    }
}
