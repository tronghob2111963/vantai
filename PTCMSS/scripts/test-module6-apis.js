/**
 * Module 6 API Test Script
 * Test tất cả 38 endpoints của Module 6 với authentication đầy đủ
 * 
 * Usage: node test-module6-apis.js
 * 
 * Requirements: npm install axios
 */

const axios = require('axios');

// Configuration
const BASE_URL = 'http://localhost:8080';
const USERNAME = process.argv[2] || 'admin'; // Có thể truyền từ command line: node test-module6-apis.js manager_hn
const PASSWORD = '123456';

// Test results
const results = {
    passed: 0,
    failed: 0,
    errors: []
};

// Helper function to make authenticated requests
async function makeRequest(method, url, data = null, params = null) {
    try {
        const config = {
            method,
            url: `${BASE_URL}${url}`,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            }
        };
        
        if (data) config.data = data;
        if (params) config.params = params;
        
        const response = await axios(config);
        return { success: true, status: response.status, data: response.data };
    } catch (error) {
        return {
            success: false,
            status: error.response?.status || 0,
            message: error.response?.data?.message || error.message,
            data: error.response?.data
        };
    }
}

// Login and get token
let token = '';
let userId = null;
let username = '';
let roleName = '';

async function login() {
    console.log('\n🔐 Logging in...');
    try {
        const response = await axios.post(`${BASE_URL}/api/auth/login`, {
            username: USERNAME,
            password: PASSWORD
        });
        
        token = response.data.AccessToken || response.data.accessToken;
        userId = response.data.userId;
        username = response.data.username;
        roleName = response.data.roleName;
        
        console.log(`✅ Login successful!`);
        console.log(`   User: ${username} (${roleName})`);
        console.log(`   User ID: ${userId}`);
        console.log(`   Token: ${token.substring(0, 20)}...`);
        return true;
    } catch (error) {
        console.error('❌ Login failed:', error.response?.data || error.message);
        return false;
    }
}

// Test function
async function test(name, method, url, data = null, params = null, expectedStatus = 200) {
    process.stdout.write(`Testing: ${name}... `);
    const result = await makeRequest(method, url, data, params);
    
    if (result.success && result.status === expectedStatus) {
        console.log('✅ PASSED');
        results.passed++;
        return result.data;
    } else {
        console.log(`❌ FAILED (Status: ${result.status})`);
        console.log(`   Error: ${result.message || JSON.stringify(result.data)}`);
        results.failed++;
        results.errors.push({ name, error: result.message || result.data });
        return null;
    }
}

// Main test function
async function runTests() {
    console.log('='.repeat(80));
    console.log('🧪 MODULE 6 API TEST SUITE');
    console.log('='.repeat(80));
    
    // Login first
    const loginSuccess = await login();
    if (!loginSuccess) {
        console.error('\n❌ Cannot proceed without authentication');
        return;
    }
    
    console.log('\n' + '='.repeat(80));
    console.log('📋 STARTING TESTS...');
    console.log('='.repeat(80));
    
    // ============================================================
    // 1. INVOICE MANAGEMENT (11 endpoints)
    // ============================================================
    console.log('\n📄 1. INVOICE MANAGEMENT');
    console.log('-'.repeat(80));
    
    // 1.1 Generate invoice number
    const invoiceNumber = await test(
        'Generate Invoice Number',
        'GET',
        '/api/invoices/generate-number',
        null,
        { branchId: 1 }
    );
    
    // 1.2 Create invoice (Income)
    const invoice1 = await test(
        'Create Invoice (Income)',
        'POST',
        '/api/invoices',
        {
            branchId: 1,
            customerId: 2,
            type: 'INCOME',
            amount: 5000000.00,
            paymentMethod: 'BANK_TRANSFER',
            paymentTerms: 'NET_7',
            vatRate: 0.08,
            note: 'Test invoice from script'
        }
    );
    const invoiceId1 = invoice1?.data?.invoiceId || 1;
    
    // 1.3 Create invoice (Expense)
    const invoice2 = await test(
        'Create Invoice (Expense)',
        'POST',
        '/api/invoices',
        {
            branchId: 1,
            type: 'EXPENSE',
            costType: 'fuel',
            amount: 2000000.00,
            paymentMethod: 'CASH',
            note: 'Test expense invoice'
        }
    );
    const invoiceId2 = invoice2?.data?.invoiceId || 2;
    
    // 1.4 Get invoice by ID
    await test(
        'Get Invoice by ID',
        'GET',
        `/api/invoices/${invoiceId1}`
    );
    
    // 1.5 Get invoices list
    await test(
        'Get Invoices List',
        'GET',
        '/api/invoices',
        null,
        {
            branchId: 1,
            type: 'INCOME',
            page: 0,
            size: 10
        }
    );
    
    // 1.6 Update invoice
    await test(
        'Update Invoice',
        'PUT',
        `/api/invoices/${invoiceId1}`,
        {
            branchId: 1,
            customerId: 2,
            type: 'INCOME',
            amount: 5500000.00,
            paymentMethod: 'BANK_TRANSFER',
            paymentTerms: 'NET_14',
            note: 'Updated invoice'
        }
    );
    
    // 1.7 Record payment
    await test(
        'Record Payment',
        'POST',
        `/api/invoices/${invoiceId1}/payments`,
        {
            amount: 2000000.00,
            paymentMethod: 'CASH',
            paymentDate: new Date().toISOString().split('T')[0],
            note: 'Partial payment test'
        }
    );
    
    // 1.8 Get payment history
    await test(
        'Get Payment History',
        'GET',
        `/api/invoices/${invoiceId1}/payments`
    );
    
    // 1.9 Get balance
    await test(
        'Get Invoice Balance',
        'GET',
        `/api/invoices/${invoiceId1}/balance`
    );
    
    // 1.10 Send invoice
    await test(
        'Send Invoice via Email',
        'POST',
        `/api/invoices/${invoiceId1}/send`,
        {
            email: 'test@example.com',
            message: 'Please find attached invoice'
        }
    );
    
    // 1.11 Mark as paid
    await test(
        'Mark Invoice as Paid',
        'POST',
        `/api/invoices/${invoiceId1}/mark-paid`
    );
    
    // ============================================================
    // 2. DEPOSIT MANAGEMENT (6 endpoints)
    // ============================================================
    console.log('\n💰 2. DEPOSIT MANAGEMENT');
    console.log('-'.repeat(80));
    
    // 2.1 Generate receipt number
    const receiptNumber = await test(
        'Generate Receipt Number',
        'GET',
        '/api/deposits/generate-receipt-number',
        null,
        { branchId: 1 }
    );
    
    // 2.2 Create deposit
    const deposit = await test(
        'Create Deposit',
        'POST',
        '/api/deposits/bookings/1',
        {
            branchId: 1,
            bookingId: 1,
            customerId: 2,
            type: 'INCOME',
            amount: 500000.00,
            paymentMethod: 'CASH',
            isDeposit: true,
            receiptNumber: receiptNumber?.data || 'REC-20251122-0001',
            note: 'Test deposit'
        }
    );
    const depositId = deposit?.data?.invoiceId || 1;
    
    // 2.3 Get deposits by booking
    await test(
        'Get Deposits by Booking',
        'GET',
        '/api/deposits/bookings/1'
    );
    
    // 2.4 Get total deposit paid
    await test(
        'Get Total Deposit Paid',
        'GET',
        '/api/deposits/bookings/1/total-paid'
    );
    
    // 2.5 Get remaining amount
    await test(
        'Get Remaining Amount',
        'GET',
        '/api/deposits/bookings/1/remaining'
    );
    
    // 2.6 Cancel deposit (skip if deposit doesn't exist)
    // await test(
    //     'Cancel Deposit',
    //     'POST',
    //     `/api/deposits/${depositId}/cancel`,
    //     null,
    //     { reason: 'Test cancellation' }
    // );
    
    // ============================================================
    // 3. DEBT MANAGEMENT (7 endpoints)
    // ============================================================
    console.log('\n💳 3. DEBT MANAGEMENT');
    console.log('-'.repeat(80));
    
    // 3.1 Get debts list
    await test(
        'Get Debts List',
        'GET',
        '/api/debts',
        null,
        {
            branchId: 1,
            overdueOnly: false,
            page: 0,
            size: 10
        }
    );
    
    // 3.2 Get aging buckets
    await test(
        'Get Aging Buckets',
        'GET',
        '/api/debts/aging',
        null,
        { branchId: 1 }
    );
    
    // 3.3 Send debt reminder
    await test(
        'Send Debt Reminder',
        'POST',
        `/api/debts/${invoiceId1}/reminder`,
        {
            reminderType: 'EMAIL',
            message: 'Please pay your invoice as soon as possible'
        }
    );
    
    // 3.4 Get reminder history
    await test(
        'Get Reminder History',
        'GET',
        `/api/debts/${invoiceId1}/reminders`
    );
    
    // 3.5 Update debt info
    await test(
        'Update Debt Info',
        'PUT',
        `/api/debts/${invoiceId1}/info`,
        {
            promiseToPayDate: '2025-12-01',
            debtLabel: 'VIP',
            contactNote: 'Customer promised to pay by Dec 1'
        }
    );
    
    // 3.6 Set promise to pay
    await test(
        'Set Promise to Pay',
        'PUT',
        `/api/debts/${invoiceId1}/promise-to-pay`,
        null,
        { promiseDate: '2025-12-15' }
    );
    
    // 3.7 Set debt label
    await test(
        'Set Debt Label',
        'PUT',
        `/api/debts/${invoiceId1}/label`,
        null,
        { label: 'NORMAL' }
    );
    
    // ============================================================
    // 4. ACCOUNTING & REPORTS (8 endpoints)
    // ============================================================
    console.log('\n📊 4. ACCOUNTING & REPORTS');
    console.log('-'.repeat(80));
    
    // 4.1 Get dashboard
    await test(
        'Get Accounting Dashboard',
        'GET',
        '/api/accounting/dashboard',
        null,
        { branchId: 1, period: 'THIS_MONTH' }
    );
    
    // 4.2 Get revenue report
    await test(
        'Get Revenue Report',
        'GET',
        '/api/accounting/revenue',
        null,
        {
            branchId: 1,
            period: '30D'
        }
    );
    
    // 4.3 Get expense report
    await test(
        'Get Expense Report',
        'GET',
        '/api/accounting/expense',
        null,
        {
            branchId: 1,
            startDate: '2025-11-01',
            endDate: '2025-11-30'
        }
    );
    
    // 4.4 Get total revenue
    await test(
        'Get Total Revenue',
        'GET',
        '/api/accounting/stats/revenue',
        null,
        {
            branchId: 1,
            startDate: '2025-11-01',
            endDate: '2025-11-30'
        }
    );
    
    // 4.5 Get total expense
    await test(
        'Get Total Expense',
        'GET',
        '/api/accounting/stats/expense',
        null,
        {
            branchId: 1,
            startDate: '2025-11-01',
            endDate: '2025-11-30'
        }
    );
    
    // 4.6 Get AR balance
    await test(
        'Get AR Balance',
        'GET',
        '/api/accounting/stats/ar-balance',
        null,
        { branchId: 1 }
    );
    
    // 4.7 Get invoices due in 7 days
    await test(
        'Get Invoices Due in 7 Days',
        'GET',
        '/api/accounting/stats/invoices-due',
        null,
        { branchId: 1 }
    );
    
    // 4.8 Get overdue invoices
    await test(
        'Get Overdue Invoices',
        'GET',
        '/api/accounting/stats/overdue',
        null,
        { branchId: 1 }
    );
    
    // ============================================================
    // 5. EXPORT SERVICES (6 endpoints)
    // ============================================================
    console.log('\n📥 5. EXPORT SERVICES');
    console.log('-'.repeat(80));
    
    // 5.1 Export revenue Excel
    await test(
        'Export Revenue Excel',
        'GET',
        '/api/export/revenue/excel',
        null,
        { branchId: 1, period: '30D' },
        200 // May return file, not JSON
    );
    
    // 5.2 Export expense Excel
    await test(
        'Export Expense Excel',
        'GET',
        '/api/export/expense/excel',
        null,
        {
            branchId: 1,
            startDate: '2025-11-01',
            endDate: '2025-11-30'
        },
        200
    );
    
    // 5.3 Export invoices Excel
    await test(
        'Export Invoices Excel',
        'GET',
        '/api/export/invoices/excel',
        null,
        { branchId: 1, type: 'INCOME' },
        200
    );
    
    // 5.4 Export invoice PDF
    await test(
        'Export Invoice PDF',
        'GET',
        `/api/export/invoice/${invoiceId1}/pdf`,
        null,
        null,
        200
    );
    
    // 5.5 Export revenue CSV
    await test(
        'Export Revenue CSV',
        'GET',
        '/api/export/revenue/csv',
        null,
        { branchId: 1, period: '30D' },
        200
    );
    
    // 5.6 Export expense CSV
    await test(
        'Export Expense CSV',
        'GET',
        '/api/export/expense/csv',
        null,
        {
            branchId: 1,
            startDate: '2025-11-01',
            endDate: '2025-11-30'
        },
        200
    );
    
    // ============================================================
    // SUMMARY
    // ============================================================
    console.log('\n' + '='.repeat(80));
    console.log('📊 TEST SUMMARY');
    console.log('='.repeat(80));
    console.log(`✅ Passed: ${results.passed}`);
    console.log(`❌ Failed: ${results.failed}`);
    console.log(`📈 Success Rate: ${((results.passed / (results.passed + results.failed)) * 100).toFixed(2)}%`);
    
    if (results.errors.length > 0) {
        console.log('\n❌ ERRORS:');
        results.errors.forEach((err, index) => {
            console.log(`${index + 1}. ${err.name}: ${err.error}`);
        });
    }
    
    console.log('\n' + '='.repeat(80));
    console.log('✨ Test completed!');
    console.log('='.repeat(80));
}

// Run tests
runTests().catch(error => {
    console.error('\n💥 Fatal error:', error);
    process.exit(1);
});

