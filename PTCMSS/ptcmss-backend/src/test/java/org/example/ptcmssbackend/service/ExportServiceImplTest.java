package org.example.ptcmssbackend.service;

import org.example.ptcmssbackend.dto.request.Accounting.ExpenseReportRequest;
import org.example.ptcmssbackend.dto.request.Accounting.RevenueReportRequest;
import org.example.ptcmssbackend.dto.response.Accounting.ExpenseReportResponse;
import org.example.ptcmssbackend.dto.response.Accounting.RevenueReportResponse;
import org.example.ptcmssbackend.dto.response.Invoice.InvoiceListResponse;
import org.example.ptcmssbackend.dto.response.Invoice.InvoiceResponse;
import org.example.ptcmssbackend.enums.PaymentStatus;
import org.example.ptcmssbackend.service.impl.ExportServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ExportServiceImplTest {

    @Mock
    private AccountingService accountingService;

    @Mock
    private InvoiceService invoiceService;

    @InjectMocks
    private ExportServiceImpl exportService;

    private RevenueReportRequest revenueReportRequest;
    private ExpenseReportRequest expenseReportRequest;
    private RevenueReportResponse revenueReportResponse;
    private ExpenseReportResponse expenseReportResponse;

    @BeforeEach
    void setUp() {
        // Setup RevenueReportRequest
        revenueReportRequest = new RevenueReportRequest();
        revenueReportRequest.setBranchId(1);
        revenueReportRequest.setPeriod("MONTHLY");

        // Setup ExpenseReportRequest
        expenseReportRequest = new ExpenseReportRequest();
        expenseReportRequest.setBranchId(1);
        expenseReportRequest.setStartDate(LocalDate.of(2025, 1, 1));
        expenseReportRequest.setEndDate(LocalDate.of(2025, 1, 31));

        // Setup RevenueReportResponse
        revenueReportResponse = new RevenueReportResponse();
        revenueReportResponse.setTotalRevenue(new BigDecimal("10000000"));
        revenueReportResponse.setTotalPaid(new BigDecimal("8000000"));
        revenueReportResponse.setTotalBalance(new BigDecimal("2000000"));
        revenueReportResponse.setTotalInvoices(50);

        List<RevenueReportResponse.ChartDataPoint> chartData = new ArrayList<>();
        RevenueReportResponse.ChartDataPoint point1 = new RevenueReportResponse.ChartDataPoint();
        point1.setDate("2025-01-15");
        point1.setValue(new BigDecimal("2000000"));
        chartData.add(point1);
        revenueReportResponse.setRevenueByDate(chartData);

        // Setup ExpenseReportResponse
        expenseReportResponse = new ExpenseReportResponse();
        expenseReportResponse.setTotalExpense(new BigDecimal("5000000"));
        expenseReportResponse.setTotalExpenseRequests(25);

        Map<String, BigDecimal> expenseByCategory = new HashMap<>();
        expenseByCategory.put("Fuel", new BigDecimal("3000000"));
        expenseByCategory.put("Maintenance", new BigDecimal("2000000"));
        expenseReportResponse.setExpenseByCategory(expenseByCategory);
    }

    // ==================== exportRevenueReportToExcel() Tests ====================

    @Test
    void exportRevenueReportToExcel_whenValidRequest_shouldReturnResource() throws Exception {
        // Given
        when(accountingService.getRevenueReport(revenueReportRequest)).thenReturn(revenueReportResponse);

        // When
        Resource result = exportService.exportRevenueReportToExcel(revenueReportRequest);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.exists()).isTrue();
        assertThat(result.contentLength()).isGreaterThan(0);
        verify(accountingService).getRevenueReport(revenueReportRequest);
    }

    @Test
    void exportRevenueReportToExcel_whenNullPeriod_shouldHandleGracefully() throws Exception {
        // Given
        revenueReportRequest.setPeriod(null);
        when(accountingService.getRevenueReport(revenueReportRequest)).thenReturn(revenueReportResponse);

        // When
        Resource result = exportService.exportRevenueReportToExcel(revenueReportRequest);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.exists()).isTrue();
        verify(accountingService).getRevenueReport(revenueReportRequest);
    }

    @Test
    void exportRevenueReportToExcel_whenNullChartData_shouldHandleGracefully() throws Exception {
        // Given
        revenueReportResponse.setRevenueByDate(null);
        when(accountingService.getRevenueReport(revenueReportRequest)).thenReturn(revenueReportResponse);

        // When
        Resource result = exportService.exportRevenueReportToExcel(revenueReportRequest);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.exists()).isTrue();
        verify(accountingService).getRevenueReport(revenueReportRequest);
    }

    @Test
    void exportRevenueReportToExcel_whenServiceThrowsException_shouldThrowRuntimeException() {
        // Given
        when(accountingService.getRevenueReport(revenueReportRequest))
                .thenThrow(new RuntimeException("Database error"));

        // When & Then
        assertThatThrownBy(() -> exportService.exportRevenueReportToExcel(revenueReportRequest))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Không thể xuất báo cáo doanh thu");
        verify(accountingService).getRevenueReport(revenueReportRequest);
    }

    // ==================== exportExpenseReportToExcel() Tests ====================

    @Test
    void exportExpenseReportToExcel_whenValidRequest_shouldReturnResource() throws Exception {
        // Given
        when(accountingService.getExpenseReport(expenseReportRequest)).thenReturn(expenseReportResponse);

        // When
        Resource result = exportService.exportExpenseReportToExcel(expenseReportRequest);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.exists()).isTrue();
        assertThat(result.contentLength()).isGreaterThan(0);
        verify(accountingService).getExpenseReport(expenseReportRequest);
    }

    @Test
    void exportExpenseReportToExcel_whenNullCategoryData_shouldHandleGracefully() throws Exception {
        // Given
        expenseReportResponse.setExpenseByCategory(null);
        when(accountingService.getExpenseReport(expenseReportRequest)).thenReturn(expenseReportResponse);

        // When
        Resource result = exportService.exportExpenseReportToExcel(expenseReportRequest);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.exists()).isTrue();
        verify(accountingService).getExpenseReport(expenseReportRequest);
    }

    @Test
    void exportExpenseReportToExcel_whenServiceThrowsException_shouldThrowRuntimeException() {
        // Given
        when(accountingService.getExpenseReport(expenseReportRequest))
                .thenThrow(new RuntimeException("Database error"));

        // When & Then
        assertThatThrownBy(() -> exportService.exportExpenseReportToExcel(expenseReportRequest))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Không thể xuất báo cáo chi phí");
        verify(accountingService).getExpenseReport(expenseReportRequest);
    }

    // ==================== exportInvoiceListToExcel() Tests ====================

    @Test
    void exportInvoiceListToExcel_whenValidRequest_shouldReturnResource() throws Exception {
        // Given
        List<InvoiceListResponse> invoices = new ArrayList<>();
        InvoiceListResponse invoice1 = new InvoiceListResponse();
        invoice1.setInvoiceNumber("INV-001");
        invoice1.setCustomerName("Customer 1");
        invoice1.setAmount(new BigDecimal("1000000"));
        invoice1.setPaidAmount(new BigDecimal("500000"));
        invoice1.setBalance(new BigDecimal("500000"));
        invoice1.setDueDate(LocalDate.of(2025, 2, 1));
        invoice1.setPaymentStatus(PaymentStatus.UNPAID.toString());
        invoices.add(invoice1);

        Page<InvoiceListResponse> invoicePage = new PageImpl<>(invoices, PageRequest.of(0, 10), 1);
        when(invoiceService.getInvoices(eq(1), eq("INCOME"), eq("UNPAID"), 
                isNull(), isNull(), isNull(), isNull(), isNull(), any(Pageable.class)))
                .thenReturn(invoicePage);

        // When
        Resource result = exportService.exportInvoiceListToExcel(1, "INCOME", "UNPAID");

        // Then
        assertThat(result).isNotNull();
        assertThat(result.exists()).isTrue();
        assertThat(result.contentLength()).isGreaterThan(0);
        verify(invoiceService).getInvoices(eq(1), eq("INCOME"), eq("UNPAID"), 
                isNull(), isNull(), isNull(), isNull(), isNull(), any(Pageable.class));
    }

    @Test
    void exportInvoiceListToExcel_whenNullCustomerName_shouldHandleGracefully() throws Exception {
        // Given
        List<InvoiceListResponse> invoices = new ArrayList<>();
        InvoiceListResponse invoice1 = new InvoiceListResponse();
        invoice1.setInvoiceNumber("INV-001");
        invoice1.setCustomerName(null);
        invoice1.setAmount(new BigDecimal("1000000"));
        invoice1.setPaidAmount(new BigDecimal("1000000"));
        invoice1.setBalance(new BigDecimal("0"));
        invoice1.setDueDate(null);
        invoice1.setPaymentStatus(PaymentStatus.PAID.toString());
        invoices.add(invoice1);

        Page<InvoiceListResponse> invoicePage = new PageImpl<>(invoices, PageRequest.of(0, 10), 1);
        when(invoiceService.getInvoices(eq(1), eq("INCOME"), eq("PAID"), 
                isNull(), isNull(), isNull(), isNull(), isNull(), any(Pageable.class)))
                .thenReturn(invoicePage);

        // When
        Resource result = exportService.exportInvoiceListToExcel(1, "INCOME", "PAID");

        // Then
        assertThat(result).isNotNull();
        assertThat(result.exists()).isTrue();
        verify(invoiceService).getInvoices(eq(1), eq("INCOME"), eq("PAID"), 
                isNull(), isNull(), isNull(), isNull(), isNull(), any(Pageable.class));
    }

    @Test
    void exportInvoiceListToExcel_whenEmptyInvoiceList_shouldReturnResource() throws Exception {
        // Given
        Page<InvoiceListResponse> emptyPage = new PageImpl<>(new ArrayList<>(), PageRequest.of(0, 10), 0);
        when(invoiceService.getInvoices(eq(1), eq("INCOME"), eq("UNPAID"), 
                isNull(), isNull(), isNull(), isNull(), isNull(), any(Pageable.class)))
                .thenReturn(emptyPage);

        // When
        Resource result = exportService.exportInvoiceListToExcel(1, "INCOME", "UNPAID");

        // Then
        assertThat(result).isNotNull();
        assertThat(result.exists()).isTrue();
        verify(invoiceService).getInvoices(eq(1), eq("INCOME"), eq("UNPAID"), 
                isNull(), isNull(), isNull(), isNull(), isNull(), any(Pageable.class));
    }

    @Test
    void exportInvoiceListToExcel_whenServiceThrowsException_shouldThrowRuntimeException() {
        // Given
        when(invoiceService.getInvoices(eq(1), eq("INCOME"), eq("UNPAID"), 
                isNull(), isNull(), isNull(), isNull(), isNull(), any(Pageable.class)))
                .thenThrow(new RuntimeException("Database error"));

        // When & Then
        assertThatThrownBy(() -> exportService.exportInvoiceListToExcel(1, "INCOME", "UNPAID"))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Không thể xuất danh sách hóa đơn");
        verify(invoiceService).getInvoices(eq(1), eq("INCOME"), eq("UNPAID"), 
                isNull(), isNull(), isNull(), isNull(), isNull(), any(Pageable.class));
    }

    // ==================== exportInvoiceToPDF() Tests ====================

    @Test
    void exportInvoiceToPDF_whenValidInvoiceId_shouldReturnResource() throws Exception {
        // Given
        InvoiceResponse invoiceResponse = new InvoiceResponse();
        invoiceResponse.setInvoiceId(1);
        invoiceResponse.setInvoiceNumber("INV-2025-001");
        invoiceResponse.setCustomerName("Nguyễn Văn A");
        invoiceResponse.setAmount(new BigDecimal("1000000"));
        invoiceResponse.setPaidAmount(new BigDecimal("500000"));
        invoiceResponse.setBalance(new BigDecimal("500000"));
        invoiceResponse.setInvoiceDate(Instant.now());
        invoiceResponse.setDueDate(LocalDate.of(2025, 2, 1));
        invoiceResponse.setPaymentStatus(PaymentStatus.UNPAID.toString());
        invoiceResponse.setNote("Transportation service");

        when(invoiceService.getInvoiceById(1)).thenReturn(invoiceResponse);

        // When
        Resource result = exportService.exportInvoiceToPDF(1);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.exists()).isTrue();
        assertThat(result.contentLength()).isGreaterThan(0);
        verify(invoiceService).getInvoiceById(1);
    }

    @Test
    void exportInvoiceToPDF_whenNullFields_shouldHandleGracefully() throws Exception {
        // Given
        InvoiceResponse invoiceResponse = new InvoiceResponse();
        invoiceResponse.setInvoiceId(1);
        invoiceResponse.setInvoiceNumber(null);
        invoiceResponse.setCustomerName(null);
        invoiceResponse.setAmount(new BigDecimal("1000000"));
        invoiceResponse.setPaidAmount(new BigDecimal("0"));
        invoiceResponse.setBalance(new BigDecimal("1000000"));
        invoiceResponse.setInvoiceDate(null);
        invoiceResponse.setDueDate(null);
        invoiceResponse.setPaymentStatus(null);
        invoiceResponse.setNote(null);
        invoiceResponse.setBookingId(null);

        when(invoiceService.getInvoiceById(1)).thenReturn(invoiceResponse);

        // When
        Resource result = exportService.exportInvoiceToPDF(1);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.exists()).isTrue();
        verify(invoiceService).getInvoiceById(1);
    }

    @Test
    void exportInvoiceToPDF_whenServiceThrowsException_shouldThrowRuntimeException() {
        // Given
        when(invoiceService.getInvoiceById(1))
                .thenThrow(new RuntimeException("Invoice not found"));

        // When & Then
        assertThatThrownBy(() -> exportService.exportInvoiceToPDF(1))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Không thể xuất hóa đơn sang PDF");
        verify(invoiceService).getInvoiceById(1);
    }

    // ==================== exportRevenueReportToPDF() Tests ====================

    @Test
    void exportRevenueReportToPDF_whenValidRequest_shouldReturnResource() throws Exception {
        // Given
        when(accountingService.getRevenueReport(revenueReportRequest)).thenReturn(revenueReportResponse);

        // When
        Resource result = exportService.exportRevenueReportToPDF(revenueReportRequest);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.exists()).isTrue();
        verify(accountingService).getRevenueReport(revenueReportRequest);
    }

    // ==================== exportExpenseReportToPDF() Tests ====================

    @Test
    void exportExpenseReportToPDF_whenValidRequest_shouldReturnResource() throws Exception {
        // Given
        when(accountingService.getExpenseReport(expenseReportRequest)).thenReturn(expenseReportResponse);

        // When
        Resource result = exportService.exportExpenseReportToPDF(expenseReportRequest);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.exists()).isTrue();
        verify(accountingService).getExpenseReport(expenseReportRequest);
    }

    // ==================== exportRevenueReportToCSV() Tests ====================

    @Test
    void exportRevenueReportToCSV_whenValidRequest_shouldReturnResource() throws Exception {
        // Given
        when(accountingService.getRevenueReport(revenueReportRequest)).thenReturn(revenueReportResponse);

        // When
        Resource result = exportService.exportRevenueReportToCSV(revenueReportRequest);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.exists()).isTrue();
        verify(accountingService).getRevenueReport(revenueReportRequest);
    }

    // ==================== exportExpenseReportToCSV() Tests ====================

    @Test
    void exportExpenseReportToCSV_whenValidRequest_shouldReturnResource() throws Exception {
        // Given
        when(accountingService.getExpenseReport(expenseReportRequest)).thenReturn(expenseReportResponse);

        // When
        Resource result = exportService.exportExpenseReportToCSV(expenseReportRequest);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.exists()).isTrue();
        verify(accountingService).getExpenseReport(expenseReportRequest);
    }
}






























