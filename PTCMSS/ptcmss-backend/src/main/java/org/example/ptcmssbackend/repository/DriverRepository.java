package org.example.ptcmssbackend.repository;

import org.example.ptcmssbackend.entity.Drivers;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DriverRepository extends JpaRepository<Drivers, Integer> {
    Optional<Drivers> findByEmployee_EmployeeId(Integer employeeId);
    boolean existsByLicenseNumber(String licenseNumber);


    @Query("""
        SELECT d FROM Drivers d
        WHERE d.employee.branch.id = :branchId
          AND d.status = 'ACTIVE'
    """)
    List<Drivers> findAvailableDrivers(Integer branchId);


    // Lấy tất cả driver của 1 chi nhánh
    @Query("SELECT d FROM Drivers d WHERE d.branch.id = :branchId")
    List<Drivers> findByBranchId(Integer branchId);
}
