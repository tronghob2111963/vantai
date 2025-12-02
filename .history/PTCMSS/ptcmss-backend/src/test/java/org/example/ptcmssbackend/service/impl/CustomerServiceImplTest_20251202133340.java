package org.example.ptcmssbackend.service.impl;

import org.example.ptcmssbackend.BaseTest;
import org.example.ptcmssbackend.dto.request.Customer.CreateCustomerRequest;
import org.example.ptcmssbackend.dto.request.Customer.UpdateCustomerRequest;
import org.example.ptcmssbackend.dto.response.Customer.CustomerResponse;
import org.example.ptcmssbackend.entity.Customers;
import org.example.ptcmssbackend.exception.BadRequestException;
import org.example.ptcmssbackend.exception.ResourceNotFoundException;
import org.example.ptcmssbackend.repository.CustomerRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

class CustomerServiceImplTest extends BaseTest {

    @Mock
    private CustomerRepository customerRepository;

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
        testCustomer.setCompanyName("Cong ty ABC");
        testCustomer.setTaxCode("0123456789");
    }

    @Test
    void createCustomer_Success() {
        // Given
        CreateCustomerRequest request = new CreateCustomerRequest();
        request.setFullName("Nguyen Van A");
        request.setPhone("0901234567");
        request.setEmail("nguyenvana@gmail.com");
        request.setAddress("123 Nguyen Hue, Q1, HCM");
        request.setCompanyName("Cong ty ABC");
        request.setTaxCode("0123456789");

        when(customerRepository.existsByPhone("0901234567")).thenReturn(false);
        when(customerRepository.save(any(Customers.class))).thenReturn(testCustomer);

        // When
        CustomerResponse response = customerService.createCustomer(request);

        // Then
        assertNotNull(response);
        assertEquals("Nguyen Van A", response.getFullName());
        assertEquals("0901234567", response.getPhone());
        assertEquals("nguyenvana@gmail.com", response.getEmail());

        verify(customerRepository, times(1)).save(any(Customers.class));
        verify(customerRepository, times(1)).existsByPhone("0901234567");
    }

    @Test
    void createCustomer_DuplicatePhone_ThrowsException() {
        // Given
        CreateCustomerRequest request = new CreateCustomerRequest();
        request.setPhone("0901234567");

        when(customerRepository.existsByPhone("0901234567")).thenReturn(true);

        // When & Then
        BadRequestException exception = assertThrows(BadRequestException.class, () -> {
            customerService.createCustomer(request);
        });

        assertTrue(exception.getMessage().contains("already exists"));
        verify(customerRepository, never()).save(any());
    }

    @Test
    void updateCustomer_Success() {
        // Given
        UpdateCustomerRequest request = new UpdateCustomerRequest();
        request.setFullName("Nguyen Van A Updated");
        request.setEmail("updated@gmail.com");

        when(customerRepository.findById(1)).thenReturn(Optional.of(testCustomer));
        when(customerRepository.save(any(Customers.class))).thenReturn(testCustomer);

        // When
        CustomerResponse response = customerService.updateCustomer(1, request);

        // Then
        assertNotNull(response);
        verify(customerRepository, times(1)).save(any(Customers.class));
    }

    @Test
    void updateCustomer_NotFound_ThrowsException() {
        // Given
        UpdateCustomerRequest request = new UpdateCustomerRequest();
        when(customerRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
            customerService.updateCustomer(999, request);
        });

        assertTrue(exception.getMessage().contains("Customer not found"));
    }

    @Test
    void deleteCustomer_Success() {
        // Given
        when(customerRepository.findById(1)).thenReturn(Optional.of(testCustomer));

        // When
        customerService.deleteCustomer(1);

        // Then
        verify(customerRepository, times(1)).delete(testCustomer);
    }

    @Test
    void getCustomerById_Success() {
        // Given
        when(customerRepository.findById(1)).thenReturn(Optional.of(testCustomer));

        // When
        CustomerResponse response = customerService.getCustomerById(1);

        // Then
        assertNotNull(response);
        assertEquals(1, response.getCustomerId());
        assertEquals("Nguyen Van A", response.getFullName());
        assertEquals("0901234567", response.getPhone());
    }

    @Test
    void getCustomerById_NotFound_ThrowsException() {
        // Given
        when(customerRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
            customerService.getCustomerById(999);
        });

        assertTrue(exception.getMessage().contains("Customer not found"));
    }

    @Test
    void searchCustomerByPhone_Success() {
        // Given
        when(customerRepository.findByPhone("0901234567")).thenReturn(Optional.of(testCustomer));

        // When
        CustomerResponse response = customerService.searchCustomerByPhone("0901234567");

        // Then
        assertNotNull(response);
        assertEquals("0901234567", response.getPhone());
    }

    @Test
    void searchCustomerByPhone_NotFound_ThrowsException() {
        // Given
        when(customerRepository.findByPhone("0999999999")).thenReturn(Optional.empty());

        // When & Then
        ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
            customerService.searchCustomerByPhone("0999999999");
        });

        assertTrue(exception.getMessage().contains("Customer not found"));
    }
}
