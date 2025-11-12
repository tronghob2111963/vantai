package org.example.ptcmssbackend.enums;

public enum BookingStatus {
    PENDING,
    CONFIRMED,
    // Support both legacy DB value "INPROGRESS" and the canonical "IN_PROGRESS"
    INPROGRESS,
    COMPLETED,
    CANCELLED
}
