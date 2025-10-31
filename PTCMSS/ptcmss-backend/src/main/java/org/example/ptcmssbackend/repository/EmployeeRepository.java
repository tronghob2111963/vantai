package org.example.ptcmssbackend.repository;

import org.example.ptcmssbackend.entity.Employees;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EmployeeRepository extends JpaRepository<Employees, Integer> {

    // 🔹 Tìm nhân viên theo user_id (khi có mối quan hệ 1-1 với bảng users)
    @Query("SELECT e FROM Employees e WHERE e.user.id = :userId")
    Optional<Employees> findByUserId(Integer userId);

    // 🔹 Tìm danh sách nhân viên theo branch_id
    @Query("SELECT e FROM Employees e WHERE e.branch.id = :branchId")
    List<Employees> findByBranchId(Integer branchId);

    // 🔹 Tìm danh sách nhân viên theo role_id
    @Query("SELECT e FROM Employees e WHERE e.role.id = :roleId")
    List<Employees> findByRoleId(Integer roleId);

    // 🔹 Kiểm tra xem nhân viên có thuộc về user cụ thể hay không
    boolean existsByUser_Id(Integer userId);

    // 🔹 Tìm tất cả nhân viên đang hoạt động
    List<Employees> findByStatus(String status);
}
