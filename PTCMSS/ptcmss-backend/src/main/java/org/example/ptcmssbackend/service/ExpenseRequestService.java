package org.example.ptcmssbackend.service;

import org.example.ptcmssbackend.dto.request.expense.CreateExpenseRequest;
import org.example.ptcmssbackend.dto.response.expense.ExpenseRequestResponse;
public interface ExpenseRequestService {
    ExpenseRequestResponse createExpenseRequest(CreateExpenseRequest request);
}
