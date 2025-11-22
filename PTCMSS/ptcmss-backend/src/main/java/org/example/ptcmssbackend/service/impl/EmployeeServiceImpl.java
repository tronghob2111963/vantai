package org.example.ptcmssbackend.service.impl;

import lombok.RequiredArgsConstructor;
import org.example.ptcmssbackend.entity.Employees;
import org.example.ptcmssbackend.entity.Users;
import org.example.ptcmssbackend.entity.Branches;
import org.example.ptcmssbackend.entity.Roles;
import org.example.ptcmssbackend.enums.EmployeeStatus;
import org.example.ptcmssbackend.repository.EmployeeRepository;
import org.example.ptcmssbackend.repository.UsersRepository;
import org.example.ptcmssbackend.repository.BranchesRepository;
import org.example.ptcmssbackend.repository.RolesRepository;
import org.example.ptcmssbackend.service.EmployeeService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class EmployeeServiceImpl implements EmployeeService {

    private final EmployeeRepository employeeRepository;
    private final UsersRepository usersRepository;
    private final BranchesRepository branchesRepository;
    private final RolesRepository rolesRepository;

    @Override
    public List<Employees> findAll() {
        return employeeRepository.findAll();
    }

    @Override
    public Employees findById(Integer id) {
        // Sử dụng findByIdWithDetails để eager load các relationships
        Optional<Employees> employeeOpt = employeeRepository.findByIdWithDetails(id);
        return employeeOpt.orElse(null);
    }

    @Override
    public Employees save(Employees employee) {
        return employeeRepository.save(employee);
    }

    @Override
    public void delete(Employees employee) {
        employeeRepository.delete(employee);
    }

    @Override
    public List<Employees> findByRoleName(String roleName) {
        return employeeRepository.findByRoleName(roleName);
    }

    @Override
    public List<Employees> findByBranchId(Integer branchId) {
        return employeeRepository.findByBranchId(branchId);
    }

    @Override
    @Transactional
    public Employees createEmployee(org.example.ptcmssbackend.dto.request.Employee.CreateEmployeeRequest request) {
        System.out.println("=== Creating Employee ===");
        System.out.println("Request: userId=" + request.getUserId() + ", branchId=" + request.getBranchId() + ", roleId=" + request.getRoleId());
        
        // Tìm User, Branch, Role từ ID
        Users user = usersRepository.findById(request.getUserId())
                .orElseThrow(() -> new RuntimeException("User not found with id: " + request.getUserId()));
        System.out.println("Found user: " + user.getId() + " - " + user.getFullName());
        
        Branches branch = branchesRepository.findById(request.getBranchId())
                .orElseThrow(() -> new RuntimeException("Branch not found with id: " + request.getBranchId()));
        System.out.println("Found branch: " + branch.getId() + " - " + branch.getBranchName());
        
        Roles role = rolesRepository.findById(request.getRoleId())
                .orElseThrow(() -> new RuntimeException("Role not found with id: " + request.getRoleId()));
        System.out.println("Found role: " + role.getId() + " - " + role.getRoleName());
        
        // Kiểm tra xem user đã là employee chưa
        if (employeeRepository.existsByUser_Id(request.getUserId())) {
            throw new RuntimeException("User is already an employee");
        }
        
        // Tạo Employee mới
        Employees employee = new Employees();
        employee.setUser(user);
        employee.setBranch(branch);
        employee.setRole(role);
        
        System.out.println("Employee before save - User: " + employee.getUser() + ", Branch: " + employee.getBranch() + ", Role: " + employee.getRole());
        
        // Set status
        if (request.getStatus() != null && !request.getStatus().isEmpty()) {
            employee.setStatus(EmployeeStatus.valueOf(request.getStatus().toUpperCase()));
        } else {
            employee.setStatus(EmployeeStatus.ACTIVE);
        }
        
        System.out.println("Saving employee...");
        Employees saved = employeeRepository.save(employee);
        System.out.println("Employee saved with ID: " + saved.getEmployeeId());
        
        return saved;
    }

    @Override
    @Transactional
    public Employees updateEmployee(Integer id, org.example.ptcmssbackend.dto.request.Employee.UpdateEmployeeRequest request) {
        System.out.println("=== Updating Employee ===");
        System.out.println("Employee ID: " + id + ", branchId=" + request.getBranchId() + ", roleId=" + request.getRoleId());
        
        // Tìm employee hiện tại với eager loading
        Employees employee = employeeRepository.findByIdWithDetails(id)
                .orElseThrow(() -> new RuntimeException("Employee not found with id: " + id));
        
        // Tìm Branch và Role mới
        Branches branch = branchesRepository.findById(request.getBranchId())
                .orElseThrow(() -> new RuntimeException("Branch not found with id: " + request.getBranchId()));
        System.out.println("Found branch: " + branch.getId() + " - " + branch.getBranchName());
        
        Roles role = rolesRepository.findById(request.getRoleId())
                .orElseThrow(() -> new RuntimeException("Role not found with id: " + request.getRoleId()));
        System.out.println("Found role: " + role.getId() + " - " + role.getRoleName());
        
        // Cập nhật thông tin
        employee.setBranch(branch);
        employee.setRole(role);
        
        // Cập nhật status nếu có
        if (request.getStatus() != null && !request.getStatus().isEmpty()) {
            employee.setStatus(EmployeeStatus.valueOf(request.getStatus().toUpperCase()));
        }
        
        System.out.println("Updating employee...");
        Employees updated = employeeRepository.save(employee);
        System.out.println("Employee updated successfully");
        
        return updated;
    }

}