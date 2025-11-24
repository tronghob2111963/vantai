// Thêm method này vào AccountingServiceImpl để debug

@Override
public ExpenseReportResponse getExpenseReport(ExpenseReportRequest request) {
    log.info("[AccountingService] Getting expense report: {}", request);
    
    LocalDate[] dateRange = getDateRangeFromRequest(request);
    LocalDate startDate = dateRange[0];
    LocalDate endDate = dateRange[1];
    
    log.info("[DEBUG] Date range: {} to {}", startDate, endDate);
    log.info("[DEBUG] Request filters - branchId: {}, vehicleId: {}, driverId: {}, expenseType: {}", 
        request.getBranchId(), request.getVehicleId(), request.getDriverId(), request.getExpenseType());
    
    ExpenseReportResponse response = new ExpenseReportResponse();
    
    // Get expense invoices
    Instant start = startDate.atStartOfDay(ZoneId.systemDefault()).toInstant();
    Instant end = endDate.atTime(23, 59, 59).atZone(ZoneId.systemDefault()).toInstant();
    
    log.info("[DEBUG] Instant range: {} to {}", start, end);
    
    List<Invoices> expenses = invoiceRepository.findInvoicesWithFilters(
            request.getBranchId(),
            InvoiceType.EXPENSE,
            InvoiceStatus.ACTIVE,
            start,
            end,
            null,
            null
    );
    
    log.info("[DEBUG] Found {} expense invoices before filtering", expenses.size());
    
    // Log first few expenses for debugging
    if (!expenses.isEmpty()) {
        expenses.stream().limit(3).forEach(exp -> 
            log.info("[DEBUG] Sample expense: id={}, amount={}, costType={}, date={}", 
                exp.getId(), exp.getAmount(), exp.getCostType(), exp.getInvoiceDate())
        );
    } else {
        log.warn("[DEBUG] No expense invoices found! Checking without filters...");
        
        // Try without date filter to see if there's any data at all
        List<Invoices> allExpenses = invoiceRepository.findInvoicesWithFilters(
                request.getBranchId(),
                InvoiceType.EXPENSE,
                InvoiceStatus.ACTIVE,
                null,
                null,
                null,
                null
        );
        log.info("[DEBUG] Total expense invoices in DB (no date filter): {}", allExpenses.size());
        
        if (!allExpenses.isEmpty()) {
            allExpenses.stream().limit(3).forEach(exp -> 
                log.info("[DEBUG] Sample expense (all time): id={}, amount={}, costType={}, date={}", 
                    exp.getId(), exp.getAmount(), exp.getCostType(), exp.getInvoiceDate())
            );
        }
    }
    
    // Filter by expense type if provided
    if (request.getExpenseType() != null) {
        int beforeFilter = expenses.size();
        expenses = expenses.stream()
                .filter(e -> request.getExpenseType().equals(e.getCostType()))
                .collect(Collectors.toList());
        log.info("[DEBUG] After expenseType filter: {} -> {} invoices", beforeFilter, expenses.size());
    }
    
    BigDecimal totalExpense = expenses.stream()
            .map(Invoices::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    
    log.info("[DEBUG] Total expense calculated: {}", totalExpense);
    
    response.setTotalExpense(totalExpense);
    response.setTotalExpenseRequests(expenses.size());
    
    // Breakdowns
    response.setExpenseByCategory(getExpenseByCategoryMap(expenses));
    response.setExpenseByDate(getExpenseByDate(expenses, startDate, endDate));
    response.setExpenseByCategoryDonut(getExpenseByCategoryDonut(expenses));
    
    // Top items
    response.setTopExpenseItems(getTopExpenseItems(expenses));
    
    // Map expenses list for table display
    List<ExpenseReportResponse.ExpenseItem> expenseItems = expenses.stream()
            .map(inv -> {
                ExpenseReportResponse.ExpenseItem item = new ExpenseReportResponse.ExpenseItem();
                item.setInvoiceId(inv.getId());
                item.setInvoiceDate(inv.getInvoiceDate() != null
                     ? inv.getInvoiceDate().toString()
                     : null);
                item.setBranchName(inv.getBranch() != null
                     ? inv.getBranch().getBranchName()
                     : null);
                item.setVehicleLicensePlate(null);
                item.setCostType(inv.getCostType());
                item.setAmount(inv.getAmount());
                item.setNote(inv.getNote());
                return item;
            })
            .collect(Collectors.toList());
    response.setExpenses(expenseItems);
    
    log.info("[DEBUG] Final response: totalExpense={}, totalRequests={}, categories={}", 
        response.getTotalExpense(), response.getTotalExpenseRequests(), 
        response.getExpenseByCategory().size());
    
    return response;
}

// Cũng cần fix method getDateRangeFromRequest để xử lý đúng
private LocalDate[] getDateRangeFromRequest(ExpenseReportRequest request) {
    if (request.getStartDate() != null && request.getEndDate() != null) {
        log.info("[DEBUG] Using custom date range from request");
        return new LocalDate[]{request.getStartDate(), request.getEndDate()};
    }
    
    // Nếu không có startDate/endDate, mặc định lấy tháng hiện tại
    LocalDate today = LocalDate.now();
    LocalDate startDate = today.withDayOfMonth(1);
    LocalDate endDate = today;
    
    log.info("[DEBUG] Using default date range (this month): {} to {}", startDate, endDate);
    return new LocalDate[]{startDate, endDate};
}
