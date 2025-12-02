package org.example.ptcmssbackend.service.impl;

import org.example.ptcmssbackend.BaseTest;
import org.example.ptcmssbackend.entity.*;
import org.example.ptcmssbackend.enums.NotificationPriority;
import org.example.ptcmssbackend.enums.NotificationType;
import org.example.ptcmssbackend.repository.NotificationRepository;
import org.example.ptcmssbackend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.time.Instant;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class NotificationServiceImplTest extends BaseTest {

    @Mock
    private NotificationRepository notificationRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private NotificationServiceImpl notificationService;

    private Users testUser;
    private Notifications testNotification;

    @BeforeEach
    @Override
    public void setUp() {
        super.setUp();

        testUser = new Users();
        testUser.setId(1);
        testUser.setUsername("staff");
        testUser.setFullName("Staff User");

        testNotification = new Notifications();
        testNotification.setId(1);
        testNotification.setRecipient(testUser);
        testNotification.setNotificationType(NotificationType.BOOKING_CONFIRMED);
        testNotification.setPriority(NotificationPriority.NORMAL);
        testNotification.setTitle("Booking Confirmed");
        testNotification.setMessage("Your booking has been confirmed");
        testNotification.setIsRead(false);
        testNotification.setCreatedAt(Instant.now());
    }

    @Test
    void createNotification_Success() {
        // Given
        when(userRepository.findById(1)).thenReturn(Optional.of(testUser));
        when(notificationRepository.save(any(Notifications.class))).thenReturn(testNotification);

        // When
        Notifications result = notificationService.createNotification(
            1,
            NotificationType.BOOKING_CONFIRMED,
            "Booking Confirmed",
            "Your booking has been confirmed",
            NotificationPriority.NORMAL
        );

        // Then
        assertNotNull(result);
        assertEquals("Booking Confirmed", result.getTitle());
        assertFalse(result.getIsRead());

        verify(notificationRepository, times(1)).save(any(Notifications.class));
    }

    @Test
    void markAsRead_Success() {
        // Given
        when(notificationRepository.findById(1)).thenReturn(Optional.of(testNotification));
        when(notificationRepository.save(any(Notifications.class))).thenReturn(testNotification);

        // When
        notificationService.markAsRead(1);

        // Then
        verify(notificationRepository, times(1)).save(argThat(notification -> 
            notification.getIsRead()
        ));
    }

    @Test
    void markAllAsRead_Success() {
        // Given
        when(userRepository.findById(1)).thenReturn(Optional.of(testUser));

        // When
        notificationService.markAllAsRead(1);

        // Then
        verify(notificationRepository, times(1)).markAllAsReadForUser(1);
    }

    @Test
    void deleteNotification_Success() {
        // Given
        when(notificationRepository.findById(1)).thenReturn(Optional.of(testNotification));

        // When
        notificationService.deleteNotification(1);

        // Then
        verify(notificationRepository, times(1)).delete(testNotification);
    }

    @Test
    void sendBookingConfirmationNotification_Success() {
        // Given
        Bookings booking = new Bookings();
        booking.setId(1);
        booking.setBookingCode("BK20251202001");

        Users createdBy = new Users();
        createdBy.setId(1);
        booking.setCreatedBy(createdBy);

        when(userRepository.findById(1)).thenReturn(Optional.of(testUser));
        when(notificationRepository.save(any(Notifications.class))).thenReturn(testNotification);

        // When
        notificationService.sendBookingConfirmationNotification(booking);

        // Then
        verify(notificationRepository, times(1)).save(argThat(notification -> 
            notification.getNotificationType() == NotificationType.BOOKING_CONFIRMED &&
            notification.getRecipient().getId() == 1
        ));
    }

    @Test
    void sendPaymentConfirmationNotification_Success() {
        // Given
        PaymentHistory payment = new PaymentHistory();
        payment.setId(1);

        Invoices invoice = new Invoices();
        invoice.setInvoiceNumber("INV20251202001");

        Customers customer = new Customers();
        customer.setFullName("Nguyen Van A");
        invoice.setCustomer(customer);

        payment.setInvoice(invoice);

        Users createdBy = new Users();
        createdBy.setId(1);
        payment.setCreatedBy(createdBy);

        when(userRepository.findById(1)).thenReturn(Optional.of(testUser));
        when(notificationRepository.save(any(Notifications.class))).thenReturn(testNotification);

        // When
        notificationService.sendPaymentConfirmationNotification(payment);

        // Then
        verify(notificationRepository, times(1)).save(argThat(notification -> 
            notification.getNotificationType() == NotificationType.PAYMENT_CONFIRMED
        ));
    }
}
