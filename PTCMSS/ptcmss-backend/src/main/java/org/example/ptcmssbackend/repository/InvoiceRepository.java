package org.example.ptcmssbackend.repository;

import org.example.ptcmssbackend.entity.Invoices;
import org.example.ptcmssbackend.enums.InvoiceType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoices, Integer> {
    
    /**
     * Lấy danh sách expenses (chi phí) của một vehicle
     * Thông qua: Vehicle -> TripVehicles -> Trips -> Bookings -> Invoices
     * Hoặc: Vehicle -> TripVehicles -> Trips -> Invoices (nếu invoice có bookingId)
     * Lưu ý: Chỉ lấy invoices có bookingId và booking đó có trips được gán cho vehicle
     */
    @Query("SELECT i FROM Invoices i " +
           "WHERE i.type = :type " +
           "AND i.booking IS NOT NULL " +
           "AND i.booking.id IN (" +
           "  SELECT t.booking.id FROM TripVehicles tv " +
           "  JOIN tv.trip t " +
           "  WHERE tv.vehicle.id = :vehicleId" +
           ") " +
           "ORDER BY i.invoiceDate DESC")
    List<Invoices> findExpensesByVehicleId(@Param("vehicleId") Integer vehicleId, @Param("type") InvoiceType type);
    
    /**
     * Lấy danh sách expenses theo costType (fuel, toll, maintenance)
     */
    @Query("SELECT i FROM Invoices i " +
           "WHERE i.type = :type " +
           "AND i.costType = :costType " +
           "AND i.booking IS NOT NULL " +
           "AND i.booking.id IN (" +
           "  SELECT t.booking.id FROM TripVehicles tv " +
           "  JOIN tv.trip t " +
           "  WHERE tv.vehicle.id = :vehicleId" +
           ") " +
           "ORDER BY i.invoiceDate DESC")
    List<Invoices> findExpensesByVehicleIdAndCostType(
            @Param("vehicleId") Integer vehicleId, 
            @Param("type") InvoiceType type,
            @Param("costType") String costType);
}

