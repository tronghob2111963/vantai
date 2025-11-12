package org.example.ptcmssbackend.repository;

import org.example.ptcmssbackend.entity.TripVehicles;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TripVehicleRepository extends JpaRepository<TripVehicles, Integer> {
    
    /**
     * Lấy danh sách trips của một vehicle
     */
    @Query("SELECT tv FROM TripVehicles tv " +
           "JOIN FETCH tv.trip t " +
           "JOIN FETCH t.booking b " +
           "WHERE tv.vehicle.id = :vehicleId " +
           "ORDER BY t.startTime DESC")
    List<TripVehicles> findAllByVehicleId(@Param("vehicleId") Integer vehicleId);
    
    // Tìm TripVehicles theo tripId
    @Query("SELECT tv FROM TripVehicles tv JOIN FETCH tv.vehicle JOIN FETCH tv.trip WHERE tv.trip.id = :tripId")
    List<TripVehicles> findByTripId(@Param("tripId") Integer tripId);
}

