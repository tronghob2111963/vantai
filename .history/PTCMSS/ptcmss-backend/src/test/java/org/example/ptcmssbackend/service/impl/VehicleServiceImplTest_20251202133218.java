package org.example.ptcmssbackend.service.impl;

import org.example.ptcmssbackend.BaseTest;
import org.example.ptcmssbackend.dto.request.Vehicle.CreateVehicleRequest;
import org.example.ptcmssbackend.dto.request.Vehicle.UpdateVehicleRequest;
import org.example.ptcmssbackend.dto.response.Vehicle.VehicleResponse;
import org.example.ptcmssbackend.entity.Branches;
import org.example.ptcmssbackend.entity.VehicleCategories;
import org.example.ptcmssbackend.entity.Vehicles;
import org.example.ptcmssbackend.enums.VehicleStatus;
import org.example.ptcmssbackend.exception.ResourceNotFoundException;
import org.example.ptcmssbackend.repository.BranchRepository;
import org.example.ptcmssbackend.repository.VehicleCategoryRepository;
import org.example.ptcmssbackend.repository.VehicleRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class VehicleServiceImplTest extends BaseTest {

    @Mock
    private VehicleRepository vehicleRepository;

    @Mock
    private VehicleCategoryRepository categoryRepository;

    @Mock
    private BranchRepository branchRepository;

    @InjectMocks
    private VehicleServiceImpl vehicleService;

    private Vehicles testVehicle;
    private VehicleCategories testCategory;
    private Branches testBranch;

    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();

        testCategory = new VehicleCategories();
        testCategory.setId(1);
        testCategory.setCategoryName("Xe tải 5 tấn");

        testBranch = new Branches();
        testBranch.setId(1);
        testBranch.setBranchName("HCM Branch");

        testVehicle = new Vehicles();
        testVehicle.setId(1);
        testVehicle.setLicensePlate("51A-12345");
        testVehicle.setVehicleName("Xe tải Hino");
        testVehicle.setCategory(testCategory);
        testVehicle.setBranch(testBranch);
        testVehicle.setStatus(VehicleStatus.AVAILABLE);
        testVehicle.setInsuranceExpiryDate(LocalDate.now().plusMonths(6));
        testVehicle.setInspectionExpiryDate(LocalDate.now().plusMonths(3));
    }

    @Test
    void createVehicle_Success() {
        // Given
        CreateVehicleRequest request = new CreateVehicleRequest();
        request.setLicensePlate("51A-12345");
        request.setVehicleName("Xe tải Hino");
        request.setCategoryId(1);
        request.setBranchId(1);
        request.setInsuranceExpiryDate(LocalDate.now().plusMonths(6));
        request.setInspectionExpiryDate(LocalDate.now().plusMonths(3));

        when(categoryRepository.findById(1)).thenReturn(Optional.of(testCategory));
        when(branchRepository.findById(1)).thenReturn(Optional.of(testBranch));
        when(vehicleRepository.save(any(Vehicles.class))).thenReturn(testVehicle);

        // When
        VehicleResponse response = vehicleService.createVehicle(request);

        // Then
        assertNotNull(response);
        assertEquals("51A-12345", response.getLicensePlate());
        assertEquals("Xe tải Hino", response.getVehicleName());
        assertEquals(VehicleStatus.AVAILABLE.name(), response.getStatus());

        verify(vehicleRepository, times(1)).save(any(Vehicles.class));
    }

    @Test
    void createVehicle_CategoryNotFound_ThrowsException() {
        // Given
        CreateVehicleRequest request = new CreateVehicleRequest();
        request.setCategoryId(999);

        when(categoryRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
            vehicleService.createVehicle(request);
        });

        assertTrue(exception.getMessage().contains("Category not found"));
        verify(vehicleRepository, never()).save(any());
    }

    @Test
    void updateVehicle_Success() {
        // Given
        UpdateVehicleRequest request = new UpdateVehicleRequest();
        request.setVehicleName("Xe tải Hino 2024");
        request.setStatus(VehicleStatus.IN_USE);

        when(vehicleRepository.findById(1)).thenReturn(Optional.of(testVehicle));
        when(vehicleRepository.save(any(Vehicles.class))).thenReturn(testVehicle);

        // When
        VehicleResponse response = vehicleService.updateVehicle(1, request);

        // Then
        assertNotNull(response);
        verify(vehicleRepository, times(1)).save(any(Vehicles.class));
    }

    @Test
    void deleteVehicle_Success() {
        // Given
        when(vehicleRepository.findById(1)).thenReturn(Optional.of(testVehicle));

        // When
        vehicleService.deleteVehicle(1);

        // Then
        verify(vehicleRepository, times(1)).delete(testVehicle);
    }

    @Test
    void getVehicleById_Success() {
        // Given
        when(vehicleRepository.findById(1)).thenReturn(Optional.of(testVehicle));

        // When
        VehicleResponse response = vehicleService.getVehicleById(1);

        // Then
        assertNotNull(response);
        assertEquals(1, response.getVehicleId());
        assertEquals("51A-12345", response.getLicensePlate());
    }

    @Test
    void getVehicleById_NotFound_ThrowsException() {
        // Given
        when(vehicleRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
            vehicleService.getVehicleById(999);
        });

        assertTrue(exception.getMessage().contains("Vehicle not found"));
    }

    @Test
    void changeVehicleStatus_ToInUse_Success() {
        // Given
        when(vehicleRepository.findById(1)).thenReturn(Optional.of(testVehicle));
        when(vehicleRepository.save(any(Vehicles.class))).thenReturn(testVehicle);

        // When
        VehicleResponse response = vehicleService.changeVehicleStatus(1, VehicleStatus.IN_USE);

        // Then
        assertNotNull(response);
        verify(vehicleRepository, times(1)).save(argThat(vehicle -> 
            vehicle.getStatus() == VehicleStatus.IN_USE
        ));
    }

    @Test
    void changeVehicleStatus_ToMaintenance_Success() {
        // Given
        when(vehicleRepository.findById(1)).thenReturn(Optional.of(testVehicle));
        when(vehicleRepository.save(any(Vehicles.class))).thenReturn(testVehicle);

        // When
        VehicleResponse response = vehicleService.changeVehicleStatus(1, VehicleStatus.MAINTENANCE);

        // Then
        assertNotNull(response);
        verify(vehicleRepository, times(1)).save(argThat(vehicle -> 
            vehicle.getStatus() == VehicleStatus.MAINTENANCE
        ));
    }
}
