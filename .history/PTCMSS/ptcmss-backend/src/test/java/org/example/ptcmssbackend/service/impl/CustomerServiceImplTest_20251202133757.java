package org.example.ptcmssbackend.service.impl;

import org.example.ptcmssbackend.BaseTest;
import org.example.ptcmssbackend.dto.request.Booking.CustomerRequest;
import org.example.ptcmssbackend.dto.response.Booking.CustomerResponse;
import org.example.ptcmssbackend.entity.Customers;
import org.example.ptcmssbackend.enums.CustomerStatus;
import org.example.ptcmssbackend.repository.CustomerRepository;
import org.example.ptcmssbackend.repository.EmployeeRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.time.Instant;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

class CustomerServiceImplTest extends BaseTest {

    @Mock
    private CustomerRepository customerRepository;

    @Mock
    private EmployeeRepository employeeRepository;

    @InjectMocks
    private CustomerServiceImpl customerService;

    private Customers testCustomer;

    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();

        testCustomer = new Customers();
        testCustomer.setId(1);
        testCustomer.setFullName("Nguyen Van A");
        testCustomer.setPhone("0901234567");
        testCustomer.setEmail("nguyenvana@gmail.com");
        testCustomer.setAddress("123 Nguyen Hue, Q1, HCM");
        testCustomer.setNote("Test customer");
        testCustomer.setStatus(CustomerStatus.ACTIVE);
    }

    @Test
    void findOrCreateCustomer_NewCustomer_Success() {
        // Given
        CustomerRequest request = new CustomerRequest();
        request.setFullName("Nguyen Van A");
        request.setPhone("0901234567");
        request.setEmail("nguyenvana@gmail.com");

        when(customerRepository.findByPhoneIgnoreCase("0901234567")).thenReturn(Optional.empty());
        when(customerRepository.save(any(Customers.class))).thenReturn(testCustomer);

        // When
        Customers result = customerService.findOrCreateCustomer(request, 1);

        // Then
        assertNotNull(result);
        verify(customerRepository, times(1)).save(any(Customers.class));
    }

    @Test
    void findOrCreateCustomer_ExistingCustomer_ReturnsExisting() {
        // Given
        CustomerRequest request = new CustomerRequest();
        request.setPhone("0901234567");

        when(customerRepository.findByPhoneIgnoreCase("0901234567")).thenReturn(Optional.of(testCustomer));

        // When
        Customers result = customerService.findOrCreateCustomer(request, 1);

        // Then
        assertNotNull(result);
        assertEquals("0901234567", result.getPhone());
        verify(customerRepository, never()).save(any());
    }

    @Test
    void getCustomerById_Success() {
        // Given
        when(customerRepository.findById(1)).thenReturn(Optional.of(testCustomer));

        // When
        CustomerResponse result = customerService.getCustomerById(1);

        // Then
        assertNotNull(result);
        assertEquals(1, result.getCustomerId());
        assertEquals("Nguyen Van A", result.getFullName());
    }

    @Test
    void getCustomerById_NotFound_ThrowsException() {
        // Given
        when(customerRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(RuntimeException.class, () -> {
            customerService.getCustomerById(999);
        });
    }
}
