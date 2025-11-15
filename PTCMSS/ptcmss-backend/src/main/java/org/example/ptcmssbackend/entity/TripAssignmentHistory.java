package org.example.ptcmssbackend.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;


import java.time.Instant;

@Entity
@Table(name = "trip_assignment_history")
@Getter
@Setter
public class TripAssignmentHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tripId", nullable = false)
    private Trips trip;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "oldDriverId")
    private Drivers oldDriver;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "newDriverId")
    private Drivers newDriver;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "oldVehicleId")
    private Vehicles oldVehicle;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "newVehicleId")
    private Vehicles newVehicle;

    @Column(name = "actionType", nullable = false, length = 50)
    private String actionType;
    // ASSIGN, REASSIGN, UNASSIGN, ACCEPT, CANCEL

    @Column(name = "assignMethod", length = 20)
    private String assignMethod;
    // AUTO hoặc MANUAL

    @Column(name = "reason")
    private String reason;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "performedBy")
    private Users performedBy;

    @CreationTimestamp
    @Column(name = "createdAt", updatable = false)
    private Instant createdAt;
}