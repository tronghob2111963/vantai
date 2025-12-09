package org.example.ptcmssbackend.integration;

import org.example.ptcmssbackend.dto.request.Accounting.ExpenseReportRequest;
import org.example.ptcmssbackend.dto.request.Accounting.RevenueReportRequest;
import org.example.ptcmssbackend.dto.request.Invoice.CreateInvoiceRequest;
import org.example.ptcmssbackend.dto.response.Accounting.AccountingDashboardResponse;
import org.example.ptcmssbackend.dto.response.Accounting.ExpenseReportResponse;
import org.example.ptcmssbackend.dto.response.Accounting.RevenueReportResponse;
import org.example.ptcmssbackend.entity.*;
import org.example.ptcmssbackend.enums.*;
import org.example.ptcmssbackend.repository.*;
import org.example.ptcmssbackend.service.AccountingService;
import org.example.ptcmssbackend.service.InvoiceService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.math.BigDecimal;
import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;

class AccountingDashboardIntegrationTest extends BaseIntegrationTest {

    @Autowired
    private AccountingService accountingService;

    @Autowired
    private InvoiceService invoiceService;

    @Autowired
    private BranchesRepository branchesRepository;

    @Autowired
    private CustomerRepository customerRepository;

    @Autowired
    private EmployeeRepository employeeRepository;

    @Autowired
    private UsersRepository usersRepository;

    @Autowired
    private RolesRepository rolesRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private Branches testBranch;
    private Customers testCustomer;
    private Employees testAccountant;

    @BeforeEach
    void setUp() {
        // Create test branch
        testBranch = new Branches();
        testBranch.setBranchName("Test Branch");
        testBranch.setLocation("123 Test Street");
        testBranch.setStatus(BranchStatus.ACTIVE);
        testBranch = branchesRepository.save(testBranch);

        // Create test customer
        testCustomer = new Customers();
        testCustomer.setFullName("Test Customer");
        testCustomer.setPhone("0987654321");
        testCustomer.setEmail("test@example.com");
        testCustomer.setStatus(CustomerStatus.ACTIVE);
        testCustomer = customerRepository.save(testCustomer);

        // Create accountant role and user
        Roles accountantRole = new Roles();
        accountantRole.setRoleName("ACCOUNTANT");
        accountantRole.setDescription("Accountant Role");
        accountantRole = rolesRepository.save(accountantRole);

        Users accountantUser = new Users();
        accountantUser.setFullName("Test Accountant");
        accountantUser.setUsername("accountant");
        accountantUser.setEmail("accountant@example.com");
        accountantUser.setPhone("0111222333");
        accountantUser.setPasswordHash(passwordEncoder.encode("password123"));
        accountantUser.setStatus(UserStatus.ACTIVE);
        accountantUser.setRole(accountantRole);
        accountantUser = usersRepository.save(accountantUser);

        testAccountant = new Employees();
        testAccountant.setUser(accountantUser);
        testAccountant.setBranch(testBranch);
        testAccountant.setRole(accountantRole);
        testAccountant.setStatus(EmployeeStatus.ACTIVE);
        testAccountant = employeeRepository.save(testAccountant);

        // Create some test invoices
        createTestInvoices();
    }

    private void createTestInvoices() {
        // Create income invoice
        CreateInvoiceRequest incomeRequest = new CreateInvoiceRequest();
        incomeRequest.setBranchId(testBranch.getId());
        incomeRequest.setCustomerId(testCustomer.getId());
        incomeRequest.setType("INCOME");
        incomeRequest.setAmount(new BigDecimal("1000000"));
        incomeRequest.setIsDeposit(false);
        incomeRequest.setCreatedBy(testAccountant.getEmployeeId());
        invoiceService.createInvoice(incomeRequest);

        // Create expense invoice
        CreateInvoiceRequest expenseRequest = new CreateInvoiceRequest();
        expenseRequest.setBranchId(testBranch.getId());
        expenseRequest.setType("EXPENSE");
        expenseRequest.setAmount(new BigDecimal("500000"));
        expenseRequest.setIsDeposit(false);
        expenseRequest.setCreatedBy(testAccountant.getEmployeeId());
        invoiceService.createInvoice(expenseRequest);
    }

    @Test
    void getDashboard_shouldReturnDashboardData() {
        // When
        AccountingDashboardResponse dashboard = accountingService.getDashboard(testBranch.getId(), "THIS_MONTH");

        // Then
        assertThat(dashboard).isNotNull();
        assertThat(dashboard.getTotalRevenue()).isNotNull();
        assertThat(dashboard.getTotalExpense()).isNotNull();
        assertThat(dashboard.getNetProfit()).isNotNull();
    }

    @Test
    void getDashboard_withNullBranch_shouldReturnData() {
        // When
        AccountingDashboardResponse dashboard = accountingService.getDashboard(null, "THIS_MONTH");

        // Then
        assertThat(dashboard).isNotNull();
    }

    @Test
    void getDashboard_withDifferentPeriods_shouldReturnData() {
        // Test different periods
        String[] periods = {"TODAY", "THIS_WEEK", "THIS_MONTH", "THIS_QUARTER", "YTD"};
        
        for (String period : periods) {
            AccountingDashboardResponse dashboard = accountingService.getDashboard(testBranch.getId(), period);
            assertThat(dashboard).isNotNull();
        }
    }

    @Test
    void getRevenueReport_shouldReturnRevenueReport() {
        // Given
        RevenueReportRequest request = new RevenueReportRequest();
        request.setBranchId(testBranch.getId());
        request.setStartDate(LocalDate.now().minusDays(30));
        request.setEndDate(LocalDate.now());
        request.setPeriod("30D");

        // When
        RevenueReportResponse response = accountingService.getRevenueReport(request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getTotalRevenue()).isNotNull();
        assertThat(response.getRevenueByDate()).isNotNull();
    }

    @Test
    void getExpenseReport_shouldReturnExpenseReport() {
        // Given
        ExpenseReportRequest request = new ExpenseReportRequest();
        request.setBranchId(testBranch.getId());
        request.setStartDate(LocalDate.now().minusDays(30));
        request.setEndDate(LocalDate.now());

        // When
        ExpenseReportResponse response = accountingService.getExpenseReport(request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getTotalExpense()).isNotNull();
        assertThat(response.getExpenseByCategory()).isNotNull();
    }

    @Test
    void getTotalRevenue_shouldReturnTotalRevenue() {
        // When
        BigDecimal totalRevenue = accountingService.getTotalRevenue(
            testBranch.getId(),
            LocalDate.now().minusDays(30),
            LocalDate.now()
        );

        // Then
        assertThat(totalRevenue).isNotNull();
        assertThat(totalRevenue).isGreaterThanOrEqualTo(BigDecimal.ZERO);
    }

    @Test
    void getTotalExpense_shouldReturnTotalExpense() {
        // When
        BigDecimal totalExpense = accountingService.getTotalExpense(
            testBranch.getId(),
            LocalDate.now().minusDays(30),
            LocalDate.now()
        );

        // Then
        assertThat(totalExpense).isNotNull();
        assertThat(totalExpense).isGreaterThanOrEqualTo(BigDecimal.ZERO);
    }

    @Test
    void getARBalance_shouldReturnARBalance() {
        // When
        BigDecimal arBalance = accountingService.getARBalance(testBranch.getId());

        // Then
        assertThat(arBalance).isNotNull();
        assertThat(arBalance).isGreaterThanOrEqualTo(BigDecimal.ZERO);
    }

    @Test
    void getInvoicesDueIn7Days_shouldReturnCount() {
        // When
        int count = accountingService.getInvoicesDueIn7Days(testBranch.getId());

        // Then
        assertThat(count).isGreaterThanOrEqualTo(0);
    }

    @Test
    void getOverdueInvoices_shouldReturnCount() {
        // When
        int count = accountingService.getOverdueInvoices(testBranch.getId());

        // Then
        assertThat(count).isGreaterThanOrEqualTo(0);
    }
}

