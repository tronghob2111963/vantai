package org.example.ptcmssbackend.repository;

import org.example.ptcmssbackend.entity.TripDriverId;
import org.example.ptcmssbackend.entity.TripDrivers;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TripDriversRepository extends JpaRepository<TripDrivers, TripDriverId> {
    
    List<TripDrivers> findByTrip_Id(Integer tripId);
    
    @Query("SELECT td FROM TripDrivers td WHERE td.trip.id = :tripId AND td.driverRole = 'Main Driver' ORDER BY td.id ASC")
    List<TripDrivers> findMainDriversByTripId(@Param("tripId") Integer tripId);
    
    @Query(value = "SELECT td.* FROM trip_drivers td WHERE td.trip_id = :tripId AND td.driver_role = 'Main Driver' ORDER BY td.id ASC LIMIT 1", nativeQuery = true)
    TripDrivers findFirstMainDriverByTripId(@Param("tripId") Integer tripId);
    
    List<TripDrivers> findByDriver_Id(Integer driverId);
}
