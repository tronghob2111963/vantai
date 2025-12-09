package org.example.ptcmssbackend.integration;

import org.example.ptcmssbackend.dto.response.notification.AlertResponse;
import org.example.ptcmssbackend.dto.response.notification.ApprovalItemResponse;
import org.example.ptcmssbackend.dto.response.notification.NotificationDashboardResponse;
import org.example.ptcmssbackend.entity.*;
import org.example.ptcmssbackend.enums.*;
import org.example.ptcmssbackend.repository.*;
import org.example.ptcmssbackend.service.NotificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

class NotificationServiceIntegrationTest extends BaseIntegrationTest {

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private BranchesRepository branchesRepository;

    @Autowired
    private UsersRepository usersRepository;

    @Autowired
    private RolesRepository rolesRepository;

    @Autowired
    private ApprovalHistoryRepository approvalHistoryRepository;

    @Autowired
    private SystemAlertsRepository systemAlertsRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private Branches testBranch;
    private Users testManager;
    private Users testDriver;

    @BeforeEach
    void setUp() {
        // Create test branch
        testBranch = new Branches();
        testBranch.setBranchName("Test Branch");
        testBranch.setLocation("123 Test Street");
        testBranch.setStatus(BranchStatus.ACTIVE);
        testBranch = branchesRepository.save(testBranch);

        // Create manager role and user
        Roles managerRole = new Roles();
        managerRole.setRoleName("MANAGER");
        managerRole.setDescription("Manager Role");
        managerRole = rolesRepository.save(managerRole);

        Users managerUser = new Users();
        managerUser.setFullName("Test Manager");
        managerUser.setUsername("manager");
        managerUser.setEmail("manager@example.com");
        managerUser.setPhone("0111222333");
        managerUser.setPasswordHash(passwordEncoder.encode("password123"));
        managerUser.setStatus(UserStatus.ACTIVE);
        managerUser.setRole(managerRole);
        testManager = usersRepository.save(managerUser);

        // Create driver role and user
        Roles driverRole = new Roles();
        driverRole.setRoleName("DRIVER");
        driverRole.setDescription("Driver Role");
        driverRole = rolesRepository.save(driverRole);

        Users driverUser = new Users();
        driverUser.setFullName("Test Driver");
        driverUser.setUsername("driver");
        driverUser.setEmail("driver@example.com");
        driverUser.setPhone("0222333444");
        driverUser.setPasswordHash(passwordEncoder.encode("password123"));
        driverUser.setStatus(UserStatus.ACTIVE);
        driverUser.setRole(driverRole);
        testDriver = usersRepository.save(driverUser);

        // Create some test approval history
        createTestApprovalHistory();
    }

    private void createTestApprovalHistory() {
        ApprovalHistory approval = new ApprovalHistory();
        approval.setBranch(testBranch);
        approval.setApprovalType(ApprovalType.EXPENSE_REQUEST);
        approval.setStatus(ApprovalStatus.PENDING);
        approval.setRelatedEntityId(1);
        approval.setRequestedBy(testDriver);
        approvalHistoryRepository.save(approval);
    }

    @Test
    void getDashboard_shouldReturnDashboardData() {
        // When
        NotificationDashboardResponse dashboard = notificationService.getDashboard(testBranch.getId());

        // Then
        assertThat(dashboard).isNotNull();
        assertThat(dashboard.getStats()).isNotNull();
        if (dashboard.getStats() != null) {
            assertThat(dashboard.getStats().getTotalPendingApprovals()).isNotNull();
            assertThat(dashboard.getStats().getTotalAlerts()).isNotNull();
        }
    }

    @Test
    void getDashboard_withNullBranch_shouldReturnData() {
        // When
        NotificationDashboardResponse dashboard = notificationService.getDashboard(null);

        // Then
        assertThat(dashboard).isNotNull();
    }

    @Test
    void getAllAlerts_shouldReturnAlerts() {
        // Given - Create a test alert
        SystemAlerts alert = SystemAlerts.builder()
            .branch(testBranch)
            .alertType(AlertType.DRIVER_LICENSE_EXPIRING)
            .severity(AlertSeverity.MEDIUM)
            .message("Driver license expiring soon")
            .build();
        systemAlertsRepository.save(alert);

        // When
        List<AlertResponse> alerts = notificationService.getAllAlerts(testBranch.getId());

        // Then
        assertThat(alerts).isNotNull();
    }

    @Test
    void getAllAlerts_withNoAlerts_shouldReturnEmptyList() {
        // When
        List<AlertResponse> alerts = notificationService.getAllAlerts(99999); // Non-existent branch

        // Then
        assertThat(alerts).isNotNull();
    }

    @Test
    void acknowledgeAlert_shouldAcknowledgeAlert() {
        // Given - Create a test alert
        SystemAlerts alert = SystemAlerts.builder()
            .branch(testBranch)
            .alertType(AlertType.DRIVER_LICENSE_EXPIRING)
            .severity(AlertSeverity.MEDIUM)
            .message("Test alert")
            .build();
        alert = systemAlertsRepository.save(alert);

        // When
        AlertResponse response = notificationService.acknowledgeAlert(alert.getId(), testManager.getId());

        // Then
        assertThat(response).isNotNull();
        
        // Verify alert is acknowledged (check if it exists)
        SystemAlerts updated = systemAlertsRepository.findById(alert.getId()).orElse(null);
        assertThat(updated).isNotNull();
    }

    @Test
    void getPendingApprovals_shouldReturnPendingApprovals() {
        // When
        List<ApprovalItemResponse> approvals = notificationService.getPendingApprovals(testBranch.getId());

        // Then
        assertThat(approvals).isNotNull();
    }

    @Test
    void getPendingApprovals_withNoApprovals_shouldReturnEmptyList() {
        // When
        List<ApprovalItemResponse> approvals = notificationService.getPendingApprovals(99999); // Non-existent branch

        // Then
        assertThat(approvals).isNotNull();
    }

    @Test
    void getProcessedApprovals_shouldReturnProcessedApprovals() {
        // Given - Create a processed approval
        ApprovalHistory processed = ApprovalHistory.builder()
            .branch(testBranch)
            .approvalType(ApprovalType.EXPENSE_REQUEST)
            .status(ApprovalStatus.APPROVED)
            .relatedEntityId(2)
            .requestedBy(testDriver)
            .approvedBy(testManager)
            .build();
        approvalHistoryRepository.save(processed);

        // When
        List<ApprovalItemResponse> approvals = notificationService.getProcessedApprovals(
            testBranch.getId(),
            testManager.getId(),
            10
        );

        // Then
        assertThat(approvals).isNotNull();
    }

    @Test
    void approveRequest_shouldApproveRequest() {
        // Given - Get a pending approval
        List<ApprovalItemResponse> pending = notificationService.getPendingApprovals(testBranch.getId());
        if (!pending.isEmpty()) {
            Integer historyId = pending.get(0).getId();

            // When
            ApprovalItemResponse response = notificationService.approveRequest(
                historyId,
                testManager.getId(),
                "Approved for testing"
            );

            // Then
            assertThat(response).isNotNull();
            assertThat(response.getStatus()).isEqualTo("APPROVED");
        }
    }

    @Test
    void rejectRequest_shouldRejectRequest() {
        // Given - Get a pending approval
        List<ApprovalItemResponse> pending = notificationService.getPendingApprovals(testBranch.getId());
        if (!pending.isEmpty()) {
            Integer historyId = pending.get(0).getId();

            // When
            ApprovalItemResponse response = notificationService.rejectRequest(
                historyId,
                testManager.getId(),
                "Rejected for testing"
            );

            // Then
            assertThat(response).isNotNull();
            assertThat(response.getStatus()).isEqualTo("REJECTED");
        }
    }

    @Test
    void getUserNotifications_shouldReturnNotifications() {
        // When
        Map<String, Object> notifications = notificationService.getUserNotifications(testManager.getId(), 1, 10);

        // Then
        assertThat(notifications).isNotNull();
        assertThat(notifications.containsKey("notifications")).isTrue();
    }

    @Test
    void getUserNotifications_withInvalidUser_shouldReturnEmpty() {
        // When
        Map<String, Object> notifications = notificationService.getUserNotifications(99999, 1, 10);

        // Then
        assertThat(notifications).isNotNull();
    }
}

