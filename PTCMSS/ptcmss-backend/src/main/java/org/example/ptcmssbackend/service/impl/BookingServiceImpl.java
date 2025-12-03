package org.example.ptcmssbackend.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.ptcmssbackend.dto.request.Booking.CreateBookingRequest;
import org.example.ptcmssbackend.dto.request.Booking.CreatePaymentRequest;
import org.example.ptcmssbackend.dto.request.Booking.TripRequest;
import org.example.ptcmssbackend.dto.request.Booking.UpdateBookingRequest;
import org.example.ptcmssbackend.dto.request.Booking.VehicleDetailRequest;
import org.example.ptcmssbackend.dto.request.Booking.AssignRequest;
import org.example.ptcmssbackend.dto.request.Booking.CheckAvailabilityRequest;
import org.example.ptcmssbackend.dto.response.Booking.*;
import org.example.ptcmssbackend.dto.response.common.PageResponse;
import org.example.ptcmssbackend.entity.*;
import org.example.ptcmssbackend.enums.*;
import org.example.ptcmssbackend.repository.*;
import org.example.ptcmssbackend.service.BookingService;
import org.example.ptcmssbackend.service.CustomerService;
import org.example.ptcmssbackend.service.SystemSettingService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class BookingServiceImpl implements BookingService {

    private final BookingRepository bookingRepository;
    private final CustomerService customerService;
    private final BranchesRepository branchesRepository;
    private final EmployeeRepository employeeRepository;
    private final HireTypesRepository hireTypesRepository;
    private final VehicleCategoryPricingRepository vehicleCategoryRepository;
    private final TripRepository tripRepository;
    private final BookingVehicleDetailsRepository bookingVehicleDetailsRepository;
    private final TripDriverRepository tripDriverRepository;
    private final SystemSettingService systemSettingService;
    private final TripVehicleRepository tripVehicleRepository;
    private final InvoiceRepository invoiceRepository;
    private final DriverRepository driverRepository;
    private final VehicleRepository vehicleRepository;
    private final org.example.ptcmssbackend.service.WebSocketNotificationService webSocketNotificationService;
    
    @Override
    @Transactional
    public BookingResponse create(CreateBookingRequest request, Integer consultantEmployeeId) {
        log.info("[BookingService] Creating new booking for consultant: {}", consultantEmployeeId);
        
        // 1. Tìm hoặc tạo customer
        Customers customer = customerService.findOrCreateCustomer(
                request.getCustomer(),
                consultantEmployeeId != null ? consultantEmployeeId : null
        );
        
        // 2. Load consultant trước để lấy branch
        Employees consultant = consultantEmployeeId != null
                ? employeeRepository.findById(consultantEmployeeId).orElse(null)
                : null;
        
        // 3. Xác định branch: ưu tiên branch của consultant, nếu không có thì lấy từ request
        Branches branch;
        if (consultant != null && consultant.getBranch() != null) {
            // Consultant có branch → dùng branch của consultant
            branch = consultant.getBranch();
            log.info("[BookingService] Using consultant's branch: {} ({})", branch.getBranchName(), branch.getId());
        } else if (request.getBranchId() != null) {
            // Không có consultant hoặc consultant không có branch → dùng từ request (Admin tạo)
            branch = branchesRepository.findById(request.getBranchId())
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy chi nhánh: " + request.getBranchId()));
        } else {
            throw new RuntimeException("Không xác định được chi nhánh cho đơn hàng");
        }
        
        // Check branch status - không cho tạo booking nếu chi nhánh không hoạt động
        if (branch.getStatus() != BranchStatus.ACTIVE) {
            throw new RuntimeException("Chi nhánh '" + branch.getBranchName() + "' đã ngưng hoạt động, không thể tạo đơn hàng mới");
        }
        
        HireTypes hireType = request.getHireTypeId() != null
                ? hireTypesRepository.findById(request.getHireTypeId()).orElse(null)
                : null;
        
        // 3. Tính giá tự động nếu chưa có
        BigDecimal estimatedCost = request.getEstimatedCost();
        if (estimatedCost == null && request.getDistance() != null) {
            List<Integer> categoryIds = request.getVehicles().stream()
                    .map(VehicleDetailRequest::getVehicleCategoryId)
                    .collect(Collectors.toList());
            List<Integer> quantities = request.getVehicles().stream()
                    .map(VehicleDetailRequest::getQuantity)
                    .collect(Collectors.toList());
            // Lấy startTime và endTime từ trips để check chuyến trong ngày
            Instant startTime = null;
            Instant endTime = null;
            if (request.getTrips() != null && !request.getTrips().isEmpty()) {
                TripRequest firstTrip = request.getTrips().get(0);
                startTime = firstTrip.getStartTime();
                endTime = firstTrip.getEndTime();
            }
            
            estimatedCost = calculatePrice(
                    categoryIds,
                    quantities,
                    request.getDistance(),
                    request.getUseHighway(),
                    request.getHireTypeId(),
                    request.getIsHoliday(),
                    request.getIsWeekend(),
                    startTime,
                    endTime
            );
        }
        
        // 4. Tính totalCost (estimatedCost - discountAmount)
        BigDecimal discountAmount = request.getDiscountAmount() != null
                ? request.getDiscountAmount()
                : BigDecimal.ZERO;
        BigDecimal totalCost = estimatedCost != null
                ? estimatedCost.subtract(discountAmount)
                : BigDecimal.ZERO;
        
        // 5. Tạo booking
        Bookings booking = new Bookings();
        booking.setCustomer(customer);
        booking.setBranch(branch);
        booking.setConsultant(consultant);
        booking.setHireType(hireType);
        booking.setUseHighway(request.getUseHighway() != null ? request.getUseHighway() : false);
        booking.setEstimatedCost(estimatedCost);
        booking.setTotalCost(totalCost);
        
        // Tính tiền cọc tự động nếu chưa có
        BigDecimal depositAmount = request.getDepositAmount();
        if (depositAmount == null && totalCost.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal defaultDepositPercent = getSystemSettingDecimal("DEFAULT_DEPOSIT_PERCENT", new BigDecimal("0.50"));
            depositAmount = totalCost.multiply(defaultDepositPercent).setScale(2, RoundingMode.HALF_UP);
        }
        booking.setDepositAmount(depositAmount != null ? depositAmount : BigDecimal.ZERO);
        
        booking.setStatus(parseBookingStatus(request.getStatus()));
        booking.setNote(request.getNote());
        
        // Lưu các field mới
        if (request.getIsHoliday() != null) {
            booking.setIsHoliday(request.getIsHoliday());
        }
        if (request.getIsWeekend() != null) {
            booking.setIsWeekend(request.getIsWeekend());
        }

        booking = bookingRepository.save(booking);
        log.info("[BookingService] Created booking: {}", booking.getId());

        // Send WebSocket notification for new booking
        try {
            String customerName = customer.getFullName() != null ? customer.getFullName() : "Khách hàng";
            String bookingCode = "ORD-" + booking.getId();

            webSocketNotificationService.sendGlobalNotification(
                    "Đơn hàng mới",
                    String.format("Đơn %s - %s (%.0f km)",
                            bookingCode,
                            customerName,
                            request.getDistance() != null ? request.getDistance() : 0),
                    "INFO"
            );

            webSocketNotificationService.sendBookingUpdate(
                    booking.getId(),
                    "CREATED",
                    String.format("Đơn hàng %s đã được tạo thành công", bookingCode)
            );
        } catch (Exception e) {
            log.warn("Failed to send WebSocket notification for new booking", e);
        }

        // 6. Tạo trips
        // Tính tổng số xe cần thiết
        int totalVehicleCount = 0;
        if (request.getVehicles() != null && !request.getVehicles().isEmpty()) {
            totalVehicleCount = request.getVehicles().stream()
                    .mapToInt(v -> v.getQuantity() != null ? v.getQuantity() : 1)
                    .sum();
        }
        
        // VALIDATION: Kiểm tra số lượng tài xế rảnh trước khi tạo booking
        // Nếu booking có nhiều trips (nhiều xe), cần đảm bảo có đủ tài xế rảnh
        if (totalVehicleCount > 0 && request.getTrips() != null && !request.getTrips().isEmpty()) {
            // Tính số trips sẽ được tạo (có thể nhiều hơn số trips trong request nếu quantity > 1)
            int expectedTripsCount = Math.max(request.getTrips().size(), totalVehicleCount);
            
            // Kiểm tra số lượng tài xế rảnh cho tất cả trips
            Set<Integer> availableDriverIds = new java.util.HashSet<>();
            
            for (TripRequest tripReq : request.getTrips()) {
                if (tripReq.getStartTime() != null && tripReq.getEndTime() != null) {
                    Instant tripStart = tripReq.getStartTime();
                    Instant tripEnd = tripReq.getEndTime();
                    LocalDate tripDate = tripStart.atZone(ZoneId.systemDefault()).toLocalDate();
                    
                    // Lấy tất cả tài xế trong branch
                    List<Drivers> branchDrivers = driverRepository.findByBranchId(branch.getId());
                    
                    for (Drivers driver : branchDrivers) {
                        // Check các điều kiện để tài xế được coi là "rảnh"
                        boolean isAvailable = true;
                        
                        // 1. Check nghỉ phép (nếu có DriverDayOffRepository)
                        // Skip check này nếu không có repository
                        
                        // 2. Check bằng lái hết hạn
                        if (driver.getLicenseExpiry() != null && driver.getLicenseExpiry().isBefore(tripDate)) {
                            isAvailable = false;
                        }
                        
                        // 3. Check trùng giờ với trips khác
                        List<TripDrivers> driverTrips = tripDriverRepository.findAllByDriverId(driver.getId());
                        boolean hasOverlap = driverTrips.stream().anyMatch(td -> {
                            Trips t = td.getTrip();
                            if (t.getStatus() == TripStatus.CANCELLED || t.getStatus() == TripStatus.COMPLETED) {
                                return false;
                            }
                            Instant s1 = t.getStartTime();
                            Instant e1 = t.getEndTime();
                            if (s1 == null || e1 == null) return false;
                            return s1.isBefore(tripEnd) && tripStart.isBefore(e1);
                        });
                        
                        if (hasOverlap) {
                            isAvailable = false;
                        }
                        
                        if (isAvailable) {
                            availableDriverIds.add(driver.getId());
                        }
                    }
                }
            }
            
            // Nếu số tài xế rảnh < số trips cần → reject booking
            if (availableDriverIds.size() < expectedTripsCount) {
                throw new RuntimeException(String.format(
                        "Không đủ tài xế rảnh để tạo đơn hàng. " +
                        "Yêu cầu: %d tài xế cho %d chuyến, nhưng chỉ có %d tài xế rảnh trong khoảng thời gian này. " +
                        "Vui lòng chọn thời gian khác hoặc giảm số lượng xe.",
                        expectedTripsCount, expectedTripsCount, availableDriverIds.size()
                ));
            }
            
            log.info("[Booking] Driver availability check passed: {} drivers available for {} trips", 
                    availableDriverIds.size(), expectedTripsCount);
        }
        
        // Nếu có trips trong request, tạo trips theo request
        // Nếu không có trips nhưng có vehicles với quantity > 1, tự động tạo nhiều trips
        if (request.getTrips() != null && !request.getTrips().isEmpty()) {
            // Validate trips: endTime phải > startTime
            for (TripRequest tripReq : request.getTrips()) {
                if (tripReq.getStartTime() != null && tripReq.getEndTime() != null) {
                    if (!tripReq.getEndTime().isAfter(tripReq.getStartTime())) {
                        throw new RuntimeException("Thời gian về phải sau thời gian đi");
                    }
                }
            }
            
            // Tạo trips từ request
            for (TripRequest tripReq : request.getTrips()) {
                Trips trip = new Trips();
                trip.setBooking(booking);
                trip.setUseHighway(tripReq.getUseHighway() != null ? tripReq.getUseHighway() : booking.getUseHighway());
                trip.setStartTime(tripReq.getStartTime());
                // Set endTime nếu có (đã validate ở trên)
                trip.setEndTime(tripReq.getEndTime());
                trip.setStartLocation(tripReq.getStartLocation());
                trip.setEndLocation(tripReq.getEndLocation());
                if (tripReq.getDistance() != null && tripReq.getDistance() > 0) {
                    trip.setDistance(BigDecimal.valueOf(tripReq.getDistance()));
                }
                trip.setStatus(TripStatus.SCHEDULED);
                tripRepository.save(trip);
            }
            
            // Nếu số trips trong request < tổng số xe, tạo thêm trips
            int existingTripsCount = request.getTrips().size();
            if (existingTripsCount < totalVehicleCount) {
                TripRequest baseTrip = request.getTrips().get(0); // Dùng trip đầu tiên làm template
                for (int i = existingTripsCount; i < totalVehicleCount; i++) {
                    Trips trip = new Trips();
                    trip.setBooking(booking);
                    trip.setUseHighway(baseTrip.getUseHighway() != null ? baseTrip.getUseHighway() : booking.getUseHighway());
                    trip.setStartTime(baseTrip.getStartTime());
                    trip.setStartLocation(baseTrip.getStartLocation());
                    trip.setEndLocation(baseTrip.getEndLocation());
                    if (baseTrip.getDistance() != null && baseTrip.getDistance() > 0) {
                        trip.setDistance(BigDecimal.valueOf(baseTrip.getDistance()));
                    }
                    trip.setStatus(TripStatus.SCHEDULED);
                    tripRepository.save(trip);
                    log.info("[Booking] Auto-created additional trip {} for booking {} (vehicle {}/{})", 
                            trip.getId(), booking.getId(), i + 1, totalVehicleCount);
                }
            }
        } else if (totalVehicleCount > 0) {
            // Không có trips trong request nhưng có vehicles -> tạo trips tự động
            // Lấy thông tin từ distance và vehicles để tạo trips
            for (int i = 0; i < totalVehicleCount; i++) {
                Trips trip = new Trips();
                trip.setBooking(booking);
                trip.setUseHighway(booking.getUseHighway());
                // Sử dụng distance từ request nếu có
                if (request.getDistance() != null && request.getDistance() > 0) {
                    trip.setDistance(BigDecimal.valueOf(request.getDistance()));
                }
                trip.setStatus(TripStatus.SCHEDULED);
                // Note: startTime, startLocation, endLocation sẽ được set sau khi có thông tin từ frontend
                tripRepository.save(trip);
                log.info("[Booking] Auto-created trip {} for booking {} (vehicle {}/{})", 
                        trip.getId(), booking.getId(), i + 1, totalVehicleCount);
            }
        }

        // 7. Tạo booking vehicle details
        if (request.getVehicles() != null && !request.getVehicles().isEmpty()) {
            for (VehicleDetailRequest vehicleReq : request.getVehicles()) {
                BookingVehicleDetails details = new BookingVehicleDetails();
                BookingVehicleDetailsId id = new BookingVehicleDetailsId();
                id.setBookingId(booking.getId());
                id.setVehicleCategoryId(vehicleReq.getVehicleCategoryId());
                details.setId(id);
                details.setBooking(booking);
                VehicleCategoryPricing category = vehicleCategoryRepository.findById(vehicleReq.getVehicleCategoryId())
                        .orElseThrow(() -> new RuntimeException("Không tìm thấy loại xe: " + vehicleReq.getVehicleCategoryId()));
                details.setVehicleCategory(category);
                details.setQuantity(vehicleReq.getQuantity());
                bookingVehicleDetailsRepository.save(details);
            }
        }
        
        return toResponse(booking);
    }
    
    @Override
    @Transactional
    public BookingResponse update(Integer bookingId, UpdateBookingRequest request) {
        log.info("[BookingService] Updating booking: {}", bookingId);
        
        Bookings booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng: " + bookingId));
        
        // Chỉ cho phép update khi status là DRAFT, PENDING hoặc CONFIRMED
        if (booking.getStatus() != BookingStatus.DRAFT && 
            booking.getStatus() != BookingStatus.PENDING && 
            booking.getStatus() != BookingStatus.CONFIRMED) {
            throw new RuntimeException("Không thể cập nhật đơn hàng với trạng thái: " + booking.getStatus());
        }
        
        // Validation: Kiểm tra loại thay đổi và thời gian cho phép
        boolean isMajorChange = isMajorModification(booking, request);
        validateModificationTime(booking, isMajorChange);

        BookingStatus oldStatus = booking.getStatus();
        
        // Update customer nếu có
        if (request.getCustomer() != null) {
            Customers customer = customerService.findOrCreateCustomer(
                    request.getCustomer(),
                    booking.getConsultant() != null ? booking.getConsultant().getEmployeeId() : null
            );
            booking.setCustomer(customer);
        }
        
        // Update branch
        if (request.getBranchId() != null) {
            Branches branch = branchesRepository.findById(request.getBranchId())
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy chi nhánh: " + request.getBranchId()));
            booking.setBranch(branch);
        }
        
        // Update hire type
        if (request.getHireTypeId() != null) {
            HireTypes hireType = hireTypesRepository.findById(request.getHireTypeId()).orElse(null);
            booking.setHireType(hireType);
        }
        
        // Update useHighway
        if (request.getUseHighway() != null) {
            booking.setUseHighway(request.getUseHighway());
        }
        
        // Tính lại giá nếu có distance mới
        if (request.getDistance() != null && request.getVehicles() != null) {
            List<Integer> categoryIds = request.getVehicles().stream()
                    .map(VehicleDetailRequest::getVehicleCategoryId)
                    .collect(Collectors.toList());
            List<Integer> quantities = request.getVehicles().stream()
                    .map(VehicleDetailRequest::getQuantity)
                    .collect(Collectors.toList());
            // Lấy startTime và endTime từ trips để check chuyến trong ngày
            Instant startTime = null;
            Instant endTime = null;
            if (request.getTrips() != null && !request.getTrips().isEmpty()) {
                TripRequest firstTrip = request.getTrips().get(0);
                startTime = firstTrip.getStartTime();
                endTime = firstTrip.getEndTime();
            } else {
                // Nếu không có trips trong request, lấy từ trips hiện tại của booking
                List<Trips> existingTrips = tripRepository.findByBooking_Id(booking.getId());
                if (existingTrips != null && !existingTrips.isEmpty()) {
                    startTime = existingTrips.get(0).getStartTime();
                    endTime = existingTrips.get(0).getEndTime();
                }
            }
            
            BigDecimal estimatedCost = calculatePrice(
                    categoryIds,
                    quantities,
                    request.getDistance(),
                    request.getUseHighway() != null ? request.getUseHighway() : booking.getUseHighway(),
                    request.getHireTypeId() != null ? request.getHireTypeId() : (booking.getHireType() != null ? booking.getHireType().getId() : null),
                    request.getIsHoliday() != null ? request.getIsHoliday() : (booking.getIsHoliday() != null ? booking.getIsHoliday() : false),
                    request.getIsWeekend() != null ? request.getIsWeekend() : (booking.getIsWeekend() != null ? booking.getIsWeekend() : false),
                    startTime,
                    endTime
            );
            booking.setEstimatedCost(estimatedCost);
        } else if (request.getEstimatedCost() != null) {
            booking.setEstimatedCost(request.getEstimatedCost());
        }
        
        // Update các flag ngày lễ/cuối tuần
        if (request.getIsHoliday() != null) {
            booking.setIsHoliday(request.getIsHoliday());
        }
        if (request.getIsWeekend() != null) {
            booking.setIsWeekend(request.getIsWeekend());
        }
        
        // Update discount và totalCost
        BigDecimal discountAmount = request.getDiscountAmount() != null
                ? request.getDiscountAmount()
                : BigDecimal.ZERO;
        BigDecimal totalCost = booking.getEstimatedCost() != null
                ? booking.getEstimatedCost().subtract(discountAmount)
                : BigDecimal.ZERO;
        booking.setTotalCost(totalCost);


        if (request.getDepositAmount() != null) {
            booking.setDepositAmount(request.getDepositAmount());
        }

        if (request.getStatus() != null) {
            booking.setStatus(parseBookingStatus(request.getStatus()));
        }
        
        if (request.getNote() != null) {
            booking.setNote(request.getNote());
        }
        
        booking = bookingRepository.save(booking);

        // Send WebSocket notification for booking update
        try {
            String customerName = booking.getCustomer() != null ? booking.getCustomer().getFullName() : "Khách hàng";
            String bookingCode = "ORD-" + bookingId;
            BookingStatus newStatus = booking.getStatus();

            if (oldStatus != newStatus) {
                // Status changed
                webSocketNotificationService.sendGlobalNotification(
                        "Cập nhật trạng thái đơn hàng",
                        String.format("Đơn %s - %s: %s → %s",
                                bookingCode,
                                customerName,
                                oldStatus.name(),
                                newStatus.name()),
                        "INFO"
                );

                webSocketNotificationService.sendBookingUpdate(
                        bookingId,
                        newStatus.name(),
                        String.format("Trạng thái đơn hàng đã được cập nhật thành %s", newStatus.name())
                );
            } else {
                // General update
                webSocketNotificationService.sendBookingUpdate(
                        bookingId,
                        "UPDATED",
                        String.format("Đơn hàng %s đã được cập nhật", bookingCode)
                );
            }
        } catch (Exception e) {
            log.warn("Failed to send WebSocket notification for booking update", e);
        }

        // Update trips (xóa cũ, tạo mới)
        if (request.getTrips() != null) {
            // Xóa trips cũ (dọn phụ thuộc trước để tránh lỗi FK)
            List<Trips> oldTrips = tripRepository.findByBooking_Id(bookingId);
            for (Trips old : oldTrips) {
                // xóa trực tiếp theo tripId để đảm bảo xóa FK trước
                try {
                    tripDriverRepository.deleteByTrip_Id(old.getId());
                } catch (Exception ignore) {
                    List<TripDrivers> tds = tripDriverRepository.findByTripId(old.getId());
                    if (!tds.isEmpty()) tripDriverRepository.deleteAll(tds);
                }
                try {
                    tripVehicleRepository.deleteByTrip_Id(old.getId());
                } catch (Exception ignore) {
                    List<TripVehicles> tvs = tripVehicleRepository.findByTripId(old.getId());
                    if (!tvs.isEmpty()) tripVehicleRepository.deleteAll(tvs);
                }
            }
            // sau khi dọn phụ thuộc mới xóa trips
            if (!oldTrips.isEmpty()) {
                tripRepository.deleteAll(oldTrips);
            }
            
            // Tạo trips mới
            for (TripRequest tripReq : request.getTrips()) {
                Trips trip = new Trips();
                trip.setBooking(booking);
                trip.setUseHighway(tripReq.getUseHighway() != null ? tripReq.getUseHighway() : booking.getUseHighway());
                trip.setStartTime(tripReq.getStartTime());
                trip.setEndTime(tripReq.getEndTime());
                trip.setStartLocation(tripReq.getStartLocation());
                trip.setEndLocation(tripReq.getEndLocation());
                if (tripReq.getDistance() != null && tripReq.getDistance() > 0) {
                    trip.setDistance(BigDecimal.valueOf(tripReq.getDistance()));
                }
                trip.setStatus(TripStatus.SCHEDULED);
                tripRepository.save(trip);
            }
        }
        
        // Update vehicle details (xóa cũ, tạo mới)
        if (request.getVehicles() != null) {
            bookingVehicleDetailsRepository.deleteByBooking_Id(bookingId);
            
            for (VehicleDetailRequest vehicleReq : request.getVehicles()) {
                BookingVehicleDetails details = new BookingVehicleDetails();
                BookingVehicleDetailsId id = new BookingVehicleDetailsId();
                id.setBookingId(booking.getId());
                id.setVehicleCategoryId(vehicleReq.getVehicleCategoryId());
                details.setId(id);
                details.setBooking(booking);
                VehicleCategoryPricing category = vehicleCategoryRepository.findById(vehicleReq.getVehicleCategoryId())
                        .orElseThrow(() -> new RuntimeException("Không tìm thấy loại xe: " + vehicleReq.getVehicleCategoryId()));
                details.setVehicleCategory(category);
                details.setQuantity(vehicleReq.getQuantity());
                bookingVehicleDetailsRepository.save(details);
            }
        }
        
        return toResponse(booking);
    }
    
    @Override
    public BookingResponse getById(Integer bookingId) {
        Bookings booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng: " + bookingId));
        return toResponse(booking);
    }
    
    @Override
    public PageResponse<?> getAll(
            String status,
            Integer branchId,
            Integer consultantId,
            Instant startDate,
            Instant endDate,
            String keyword,
            int page,
            int size,
            String sortBy
    ) {
        int pageNo = page > 0 ? page - 1 : 0;
        List<Sort.Order> sorts = new ArrayList<>();
        
        if (StringUtils.hasLength(sortBy)) {
            java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("(\\w+?)(:)(.*)");
            java.util.regex.Matcher matcher = pattern.matcher(sortBy);
            if (matcher.find()) {
                if (matcher.group(3).equalsIgnoreCase("asc")) {
                    sorts.add(new Sort.Order(Sort.Direction.ASC, matcher.group(1)));
                } else {
                    sorts.add(new Sort.Order(Sort.Direction.DESC, matcher.group(1)));
                }
            }
        } else {
            sorts.add(new Sort.Order(Sort.Direction.DESC, "id"));
        }
        
        Pageable pageable = PageRequest.of(pageNo, size, Sort.by(sorts));
        BookingStatus statusEnum = status != null && !status.isBlank()
                ? parseBookingStatus(status)
                : null;
        
        Page<Bookings> bookingPage = bookingRepository.filterBookings(
                statusEnum, branchId, consultantId, startDate, endDate, keyword, pageable
        );
        
        List<BookingListResponse> items = bookingPage.getContent().stream()
                .map(this::toListResponse)
                .collect(Collectors.toList());
        
        return PageResponse.builder()
                .pageNo(pageNo + 1)
                .pageSize(size)
                .totalElements(bookingPage.getTotalElements())
                .totalPages(bookingPage.getTotalPages())
                .items(items)
                .build();
    }
    
    @Override
    @Transactional
    public void delete(Integer bookingId) {
        Bookings booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng: " + bookingId));
        
        // Validation: Chỉ cho phép hủy trước khi khởi hành
        validateCanCancelOrModify(booking, "hủy");
        
        // Tính % mất cọc dựa trên thời gian hủy
        BigDecimal depositLossAmount = calculateDepositLoss(booking);
        
        booking.setStatus(BookingStatus.CANCELLED);
        bookingRepository.save(booking);
        
        // Ghi nhận mất cọc nếu có
        if (depositLossAmount != null && depositLossAmount.compareTo(BigDecimal.ZERO) > 0) {
            try {
                // Tạo invoice để ghi nhận mất cọc
                Invoices depositLossInvoice = new Invoices();
                depositLossInvoice.setBooking(booking);
                depositLossInvoice.setBranch(booking.getBranch());
                depositLossInvoice.setCustomer(booking.getCustomer());
                depositLossInvoice.setType(org.example.ptcmssbackend.enums.InvoiceType.INCOME);
                depositLossInvoice.setIsDeposit(false); // Không phải tiền cọc, mà là tiền mất do hủy
                depositLossInvoice.setAmount(depositLossAmount);
                depositLossInvoice.setPaymentStatus(org.example.ptcmssbackend.enums.PaymentStatus.PAID);
                depositLossInvoice.setStatus(org.example.ptcmssbackend.enums.InvoiceStatus.ACTIVE);
                depositLossInvoice.setNote(String.format("Tiền mất cọc do hủy đơn (%.0f%% tiền cọc)", 
                        depositLossAmount.divide(booking.getDepositAmount() != null && booking.getDepositAmount().compareTo(BigDecimal.ZERO) > 0 
                                ? booking.getDepositAmount() 
                                : BigDecimal.ONE, 2, RoundingMode.HALF_UP)
                        .multiply(BigDecimal.valueOf(100)).doubleValue()));
                invoiceRepository.save(depositLossInvoice);
                
                log.info("[Booking] Deposit loss recorded: {} VNĐ for booking {}", depositLossAmount, bookingId);
            } catch (Exception e) {
                log.warn("Failed to record deposit loss invoice", e);
            }
        }

        // Send WebSocket notification for cancellation
        try {
            String customerName = booking.getCustomer() != null ? booking.getCustomer().getFullName() : "Khách hàng";
            String bookingCode = "ORD-" + bookingId;
            String message = depositLossAmount != null && depositLossAmount.compareTo(BigDecimal.ZERO) > 0
                    ? String.format("Đơn %s - %s đã bị hủy. Mất cọc: %,.0f VNĐ", bookingCode, customerName, depositLossAmount)
                    : String.format("Đơn %s - %s đã bị hủy", bookingCode, customerName);

            webSocketNotificationService.sendGlobalNotification(
                    "Đơn hàng bị hủy",
                    message,
                    "WARNING"
            );

            webSocketNotificationService.sendBookingUpdate(
                    bookingId,
                    "CANCELLED",
                    "Đơn hàng đã bị hủy"
            );
        } catch (Exception e) {
            log.warn("Failed to send WebSocket notification for booking cancellation", e);
        }
    }
    
    /**
     * Tính số tiền mất cọc khi hủy đơn dựa trên thời gian hủy
     * - Hủy < 24h trước khởi hành: Mất 100% tiền cọc
     * - Hủy < 48h trước khởi hành: Mất 30% tiền cọc
     * - Hủy >= 48h trước khởi hành: Không mất cọc (hoàn lại)
     */
    private BigDecimal calculateDepositLoss(Bookings booking) {
        if (booking.getDepositAmount() == null || booking.getDepositAmount().compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO; // Không có tiền cọc
        }
        
        // Lấy thời gian khởi hành từ trips
        List<Trips> trips = tripRepository.findByBooking_Id(booking.getId());
        if (trips == null || trips.isEmpty()) {
            log.warn("[Booking] No trips found for booking {}, cannot calculate deposit loss", booking.getId());
            return BigDecimal.ZERO; // Không có trip, không tính mất cọc
        }
        
        // Lấy thời gian khởi hành sớm nhất
        Instant earliestStartTime = trips.stream()
                .map(Trips::getStartTime)
                .filter(java.util.Objects::nonNull)
                .min(Instant::compareTo)
                .orElse(null);
        
        if (earliestStartTime == null) {
            log.warn("[Booking] No start time found for booking {}, cannot calculate deposit loss", booking.getId());
            return BigDecimal.ZERO;
        }
        
        // Tính số giờ từ bây giờ đến khởi hành
        Instant now = Instant.now();
        long hoursUntilStart = java.time.Duration.between(now, earliestStartTime).toHours();
        
        // Lấy cấu hình từ SystemSettings
        int fullLossHours = getSystemSettingInt("CANCELLATION_FULL_DEPOSIT_LOSS_HOURS", 24);
        int partialLossHours = getSystemSettingInt("CANCELLATION_PARTIAL_DEPOSIT_LOSS_HOURS", 48);
        BigDecimal partialLossPercent = getSystemSettingDecimal("CANCELLATION_PARTIAL_DEPOSIT_PERCENT", new BigDecimal("0.30"));
        
        BigDecimal depositAmount = booking.getDepositAmount();
        
        if (hoursUntilStart < 0) {
            // Đã quá thời gian khởi hành, mất 100%
            log.info("[Booking] Cancellation after start time, full deposit loss: {} VNĐ", depositAmount);
            return depositAmount;
        } else if (hoursUntilStart < fullLossHours) {
            // Hủy < 24h trước khởi hành: Mất 100%
            log.info("[Booking] Cancellation < {} hours before start, full deposit loss: {} VNĐ", fullLossHours, depositAmount);
            return depositAmount;
        } else if (hoursUntilStart < partialLossHours) {
            // Hủy < 48h trước khởi hành: Mất 30%
            BigDecimal lossAmount = depositAmount.multiply(partialLossPercent).setScale(2, RoundingMode.HALF_UP);
            log.info("[Booking] Cancellation < {} hours before start, partial deposit loss ({}%): {} VNĐ", 
                    partialLossHours, partialLossPercent.multiply(BigDecimal.valueOf(100)), lossAmount);
            return lossAmount;
        } else {
            // Hủy >= 48h trước khởi hành: Không mất cọc
            log.info("[Booking] Cancellation >= {} hours before start, no deposit loss", partialLossHours);
            return BigDecimal.ZERO;
        }
    }
    
    @Override
    public BigDecimal calculatePrice(
            List<Integer> vehicleCategoryIds,
            List<Integer> quantities,
            Double distance,
            Boolean useHighway
    ) {
        // Gọi overloaded method với các tham số mặc định
        return calculatePrice(
                vehicleCategoryIds,
                quantities,
                distance,
                useHighway,
                null, // hireTypeId - sẽ được xác định từ booking
                false, // isHoliday
                false, // isWeekend
                null, // startTime
                null // endTime
        );
    }

    /**
     * Tính giá với logic mới theo yêu cầu:
     * 
     * 1. TÍNH THEO CHIỀU:
     *    a. Một chiều: CT = Số_km × PricePerKm + baseFee
     *    b. Hai chiều (cùng ngày): CT = Số_km × PricePerKm × 1.5 + baseFee
     *    c. Hai chiều (khác ngày): CT = Số_km × PricePerKm × 2.0 + baseFee
     * 
     * 2. TÍNH THEO NGÀY:
     *    a. Trong tỉnh / nội thành (TP): CT = sameDayFixedPrice + baseFee
     *    b. Liên tỉnh – 1 ngày: CT = Số_km × PricePerKm × 1.5 + sameDayFixedPrice + baseFee
     *    c. Nhiều ngày: CT = Số_km × PricePerKm × 1.5 + sameDayFixedPrice × Số_ngày + baseFee
     */
    public BigDecimal calculatePrice(
            List<Integer> vehicleCategoryIds,
            List<Integer> quantities,
            Double distance,
            Boolean useHighway,
            Integer hireTypeId,
            Boolean isHoliday,
            Boolean isWeekend,
            Instant startTime,
            Instant endTime
    ) {
        if (vehicleCategoryIds == null || vehicleCategoryIds.isEmpty()) {
            return BigDecimal.ZERO;
        }
        
        // Lấy cấu hình từ SystemSettings
        BigDecimal holidaySurchargeRate = getSystemSettingDecimal("HOLIDAY_SURCHARGE_RATE", new BigDecimal("0.25"));
        BigDecimal weekendSurchargeRate = getSystemSettingDecimal("WEEKEND_SURCHARGE_RATE", new BigDecimal("0.20"));
        BigDecimal roundTripMultiplier = getSystemSettingDecimal("ROUND_TRIP_MULTIPLIER", new BigDecimal("1.5"));
        int interProvinceDistanceKm = getSystemSettingInt("INTER_PROVINCE_DISTANCE_KM", 100);
        
        // Tính số ngày
        int numberOfDays = calculateNumberOfDays(startTime, endTime);
        
        // Kiểm tra chuyến trong ngày
        boolean isSameDayTrip = isSameDayTrip(startTime, endTime);
        
        // Kiểm tra liên tỉnh (dựa trên khoảng cách > ngưỡng cấu hình, mặc định 100km)
        boolean isInterProvince = distance != null && distance > interProvinceDistanceKm;
        
        // Xác định loại thuê
        String hireTypeCode = null;
        if (hireTypeId != null) {
            HireTypes hireType = hireTypesRepository.findById(hireTypeId).orElse(null);
            if (hireType != null) {
                hireTypeCode = hireType.getCode();
            }
        }
        
        // Auto-detect hình thức thuê nếu không có hireType
        // Nếu numberOfDays >= 1 và chưa có hireType → mặc định là DAILY
        if (hireTypeCode == null && numberOfDays >= 1) {
            // Check nếu là chuyến trong ngày với khoảng cách ngắn → có thể là ONE_WAY hoặc ROUND_TRIP
            if (isSameDayTrip && distance != null && distance <= interProvinceDistanceKm) {
                // Để logic bên dưới xử lý (isSameDayTrip case)
            } else if (numberOfDays > 1) {
                hireTypeCode = "MULTI_DAY";
                log.debug("[Price] Auto-detected hireType: MULTI_DAY (days={})", numberOfDays);
            } else {
                hireTypeCode = "DAILY";
                log.debug("[Price] Auto-detected hireType: DAILY (days={})", numberOfDays);
            }
        }
        
        // Tính hệ số phụ phí ngày lễ/cuối tuần
        BigDecimal surchargeRate = BigDecimal.ZERO;
        if (isHoliday != null && isHoliday) {
            surchargeRate = surchargeRate.add(holidaySurchargeRate);
        }
        if (isWeekend != null && isWeekend) {
            surchargeRate = surchargeRate.add(weekendSurchargeRate);
        }
        
        BigDecimal totalPrice = BigDecimal.ZERO;
        
        for (int i = 0; i < vehicleCategoryIds.size(); i++) {
            Integer categoryId = vehicleCategoryIds.get(i);
            Integer quantity = i < quantities.size() ? quantities.get(i) : 1;
            
            VehicleCategoryPricing category = vehicleCategoryRepository.findById(categoryId)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy loại xe: " + categoryId));
            
            if (category.getStatus() != VehicleCategoryStatus.ACTIVE) {
                continue;
            }
            
            BigDecimal pricePerKm = category.getPricePerKm() != null ? category.getPricePerKm() : BigDecimal.ZERO;
            BigDecimal baseFee = category.getBaseFare() != null ? category.getBaseFare() : BigDecimal.ZERO;
            BigDecimal highwayFee = category.getHighwayFee() != null ? category.getHighwayFee() : BigDecimal.ZERO;
            BigDecimal sameDayFixedPrice = category.getSameDayFixedPrice() != null ? category.getSameDayFixedPrice() : BigDecimal.ZERO;
            
            BigDecimal basePrice = BigDecimal.ZERO;
            
            // Áp dụng công thức tính giá theo hình thức thuê
            if ("DAILY".equals(hireTypeCode)) {
                // THUÊ THEO NGÀY: sameDayFixedPrice × số_ngày + baseFee (không tính km)
                int days = Math.max(1, numberOfDays);
                BigDecimal dailyCost = sameDayFixedPrice.multiply(BigDecimal.valueOf(days));
                basePrice = dailyCost.add(baseFee);
                log.debug("[Price] DAILY: days={}, dailyRate={}, baseFee={}, total={}", 
                        days, sameDayFixedPrice, baseFee, basePrice);
                
            } else if ("MULTI_DAY".equals(hireTypeCode) && numberOfDays > 1) {
                // THUÊ NHIỀU NGÀY (đi xa): km × PricePerKm × 1.5 + sameDayFixedPrice × số_ngày + baseFee
                BigDecimal kmCost = BigDecimal.ZERO;
                if (distance != null && distance > 0 && pricePerKm.compareTo(BigDecimal.ZERO) > 0) {
                    kmCost = pricePerKm
                            .multiply(BigDecimal.valueOf(distance))
                            .multiply(roundTripMultiplier);
                }
                BigDecimal dailyCost = sameDayFixedPrice.multiply(BigDecimal.valueOf(numberOfDays));
                basePrice = kmCost.add(dailyCost).add(baseFee);
                log.debug("[Price] MULTI_DAY: km={}, days={}, kmCost={}, dailyCost={}, baseFee={}, total={}", 
                        distance, numberOfDays, kmCost, dailyCost, baseFee, basePrice);
                
            } else if ("ONE_WAY".equals(hireTypeCode)) {
                // MỘT CHIỀU: km × PricePerKm + baseFee
                BigDecimal kmCost = BigDecimal.ZERO;
                if (distance != null && distance > 0 && pricePerKm.compareTo(BigDecimal.ZERO) > 0) {
                    kmCost = pricePerKm.multiply(BigDecimal.valueOf(distance));
                }
                basePrice = kmCost.add(baseFee);
                log.debug("[Price] ONE_WAY: km={}, kmCost={}, baseFee={}, total={}", 
                        distance, kmCost, baseFee, basePrice);
                
            } else if ("ROUND_TRIP".equals(hireTypeCode)) {
                // KHỨ HỒI: 
                // - Cùng ngày: km × PricePerKm × 1.5 + baseFee
                // - Khác ngày: km × PricePerKm × 2 + baseFee
                BigDecimal multiplier = isSameDayTrip ? roundTripMultiplier : new BigDecimal("2.0");
                BigDecimal kmCost = BigDecimal.ZERO;
                if (distance != null && distance > 0 && pricePerKm.compareTo(BigDecimal.ZERO) > 0) {
                    kmCost = pricePerKm.multiply(BigDecimal.valueOf(distance)).multiply(multiplier);
                }
                basePrice = kmCost.add(baseFee);
                log.debug("[Price] ROUND_TRIP: km={}, isSameDay={}, kmCost={}, multiplier={}, baseFee={}, total={}", 
                        distance, isSameDayTrip, kmCost, multiplier, baseFee, basePrice);
                
            } else if (isSameDayTrip && sameDayFixedPrice.compareTo(BigDecimal.ZERO) > 0) {
                // CHUYẾN TRONG NGÀY (không có hireType cụ thể)
                if (isInterProvince) {
                    // Liên tỉnh 1 ngày: km × PricePerKm × 1.5 + sameDayFixedPrice + baseFee
                    BigDecimal kmCost = BigDecimal.ZERO;
                    if (distance != null && distance > 0 && pricePerKm.compareTo(BigDecimal.ZERO) > 0) {
                        kmCost = pricePerKm
                                .multiply(BigDecimal.valueOf(distance))
                                .multiply(roundTripMultiplier);
                    }
                    basePrice = kmCost.add(sameDayFixedPrice).add(baseFee);
                    log.debug("[Price] INTER_PROVINCE_SAME_DAY: km={}, kmCost={}, sameDayPrice={}, baseFee={}, total={}", 
                            distance, kmCost, sameDayFixedPrice, baseFee, basePrice);
                } else {
                    // Trong tỉnh / nội thành: sameDayFixedPrice + baseFee
                    basePrice = sameDayFixedPrice.add(baseFee);
                    log.debug("[Price] SAME_DAY_LOCAL: sameDayPrice={}, baseFee={}, total={}", 
                            sameDayFixedPrice, baseFee, basePrice);
                }
                
            } else {
                // MẶC ĐỊNH: Tính theo km × 1.5 + baseFee
                BigDecimal kmCost = BigDecimal.ZERO;
                if (distance != null && distance > 0 && pricePerKm.compareTo(BigDecimal.ZERO) > 0) {
                    kmCost = pricePerKm.multiply(BigDecimal.valueOf(distance)).multiply(roundTripMultiplier);
                }
                basePrice = kmCost.add(baseFee);
                log.debug("[Price] DEFAULT: km={}, kmCost={}, baseFee={}, total={}", 
                        distance, kmCost, baseFee, basePrice);
            }
            
            // Phụ phí cao tốc
            if (useHighway != null && useHighway && highwayFee.compareTo(BigDecimal.ZERO) > 0) {
                basePrice = basePrice.add(highwayFee);
            }
            
            // Phụ phí xe hạng sang
            if (category.getIsPremium() != null && category.getIsPremium()) {
                BigDecimal premiumSurcharge = category.getPremiumSurcharge() != null 
                        ? category.getPremiumSurcharge() 
                        : new BigDecimal("1000000");
                basePrice = basePrice.add(premiumSurcharge);
            }
            
            // Phụ phí ngày lễ/cuối tuần
            if (surchargeRate.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal surcharge = basePrice.multiply(surchargeRate);
                basePrice = basePrice.add(surcharge);
            }
            
            // Nhân với số lượng xe
            BigDecimal priceForThisCategory = basePrice.multiply(BigDecimal.valueOf(quantity));
            totalPrice = totalPrice.add(priceForThisCategory);
        }
        
        return totalPrice.setScale(2, RoundingMode.HALF_UP);
    }
    
    /**
     * Helper method: Tính số ngày giữa startTime và endTime
     */
    private int calculateNumberOfDays(Instant startTime, Instant endTime) {
        if (startTime == null || endTime == null) {
            return 1;
        }
        
        try {
            java.time.ZonedDateTime startZoned = startTime.atZone(java.time.ZoneId.systemDefault());
            java.time.ZonedDateTime endZoned = endTime.atZone(java.time.ZoneId.systemDefault());
            
            long daysBetween = java.time.temporal.ChronoUnit.DAYS.between(
                    startZoned.toLocalDate(), 
                    endZoned.toLocalDate()
            );
            
            // Tối thiểu 1 ngày
            return Math.max(1, (int) daysBetween + 1);
        } catch (Exception e) {
            log.warn("Error calculating number of days: {}", e.getMessage());
            return 1;
        }
    }
    
    /**
     * Helper method: Lấy giá trị decimal từ SystemSettings
     */
    private BigDecimal getSystemSettingDecimal(String key, BigDecimal defaultValue) {
        try {
            var setting = systemSettingService.getByKey(key);
            if (setting != null && setting.getSettingValue() != null) {
                return new BigDecimal(setting.getSettingValue());
            }
        } catch (Exception e) {
            log.warn("Cannot get system setting {}: {}", key, e.getMessage());
        }
        return defaultValue;
    }
    
    /**
     * Helper method: Kiểm tra xem có phải chuyến trong ngày không
     * Chuyến trong ngày: Khởi hành từ 6h sáng, về 7-8h tối (hoặc đến 10-11h đêm cùng ngày)
     */
    private boolean isSameDayTrip(Instant startTime, Instant endTime) {
        if (startTime == null || endTime == null) {
            return false;
        }
        
        try {
            // Lấy cấu hình từ SystemSettings
            int startHour = getSystemSettingInt("SAME_DAY_TRIP_START_HOUR", 6);
            int endHour = getSystemSettingInt("SAME_DAY_TRIP_END_HOUR", 23);
            
            java.time.ZonedDateTime startZoned = startTime.atZone(java.time.ZoneId.systemDefault());
            java.time.ZonedDateTime endZoned = endTime.atZone(java.time.ZoneId.systemDefault());
            
            // Check cùng ngày
            if (!startZoned.toLocalDate().equals(endZoned.toLocalDate())) {
                return false;
            }
            
            // Check giờ khởi hành >= 6h sáng
            int startHourOfDay = startZoned.getHour();
            if (startHourOfDay < startHour) {
                return false;
            }
            
            // Check giờ về <= 11h đêm (23h)
            int endHourOfDay = endZoned.getHour();
            if (endHourOfDay > endHour) {
                return false;
            }
            
            return true;
        } catch (Exception e) {
            log.warn("Error checking same day trip: {}", e.getMessage());
            return false;
        }
    }
    
    /**
     * Helper method: Lấy giá trị int từ SystemSettings
     */
    private int getSystemSettingInt(String key, int defaultValue) {
        try {
            var setting = systemSettingService.getByKey(key);
            if (setting != null && setting.getSettingValue() != null) {
                return Integer.parseInt(setting.getSettingValue());
            }
        } catch (Exception e) {
            log.warn("Cannot get system setting {}: {}", key, e.getMessage());
        }
        return defaultValue;
    }
    
    /**
     * Kiểm tra xem request có phải là thay đổi lớn không
     * Thay đổi lớn: điểm đón/trả, hành trình, số ngày, loại xe
     * Thay đổi nhỏ: thông tin khách hàng, ghi chú, trạng thái
     */
    private boolean isMajorModification(Bookings booking, UpdateBookingRequest request) {
        // Thay đổi trips (điểm đón, điểm trả, thời gian) = thay đổi lớn
        if (request.getTrips() != null && !request.getTrips().isEmpty()) {
            List<Trips> existingTrips = tripRepository.findByBooking_Id(booking.getId());
            
            // Số lượng trips khác nhau
            if (existingTrips.size() != request.getTrips().size()) {
                log.info("[Booking] Major change detected: trip count changed");
                return true;
            }
            
            // Check từng trip xem có thay đổi điểm đón/trả không
            for (int i = 0; i < request.getTrips().size(); i++) {
                TripRequest tripReq = request.getTrips().get(i);
                if (i < existingTrips.size()) {
                    Trips existingTrip = existingTrips.get(i);
                    
                    // Check điểm đón
                    if (tripReq.getStartLocation() != null && 
                        !tripReq.getStartLocation().equals(existingTrip.getStartLocation())) {
                        log.info("[Booking] Major change detected: pickup location changed");
                        return true;
                    }
                    
                    // Check điểm trả
                    if (tripReq.getEndLocation() != null && 
                        !tripReq.getEndLocation().equals(existingTrip.getEndLocation())) {
                        log.info("[Booking] Major change detected: dropoff location changed");
                        return true;
                    }
                    
                    // Check ngày/giờ khởi hành thay đổi > 2 giờ
                    if (tripReq.getStartTime() != null && existingTrip.getStartTime() != null) {
                        long hoursDiff = Math.abs(java.time.Duration.between(
                                tripReq.getStartTime(), existingTrip.getStartTime()).toHours());
                        if (hoursDiff > 2) {
                            log.info("[Booking] Major change detected: start time changed by {} hours", hoursDiff);
                            return true;
                        }
                    }
                }
            }
        }
        
        // Thay đổi loại xe = thay đổi lớn
        if (request.getVehicles() != null && !request.getVehicles().isEmpty()) {
            List<BookingVehicleDetails> existingVehicles = bookingVehicleDetailsRepository.findByBookingId(booking.getId());
            
            // Số lượng loại xe khác nhau
            if (existingVehicles.size() != request.getVehicles().size()) {
                log.info("[Booking] Major change detected: vehicle count changed");
                return true;
            }
            
            // Check từng loại xe
            for (int i = 0; i < request.getVehicles().size(); i++) {
                VehicleDetailRequest vReq = request.getVehicles().get(i);
                if (i < existingVehicles.size()) {
                    BookingVehicleDetails existingV = existingVehicles.get(i);
                    
                    // Loại xe khác
                    if (!vReq.getVehicleCategoryId().equals(existingV.getVehicleCategory().getId())) {
                        log.info("[Booking] Major change detected: vehicle category changed");
                        return true;
                    }
                    
                    // Số lượng xe khác
                    if (!vReq.getQuantity().equals(existingV.getQuantity())) {
                        log.info("[Booking] Major change detected: vehicle quantity changed");
                        return true;
                    }
                }
            }
        }
        
        // Không có thay đổi lớn
        return false;
    }
    
    /**
     * Validation thời gian cho phép sửa đổi
     * - Thay đổi nhỏ: >= 24h trước khởi hành
     * - Thay đổi lớn: >= 72h trước khởi hành
     */
    private void validateModificationTime(Bookings booking, boolean isMajorChange) {
        List<Trips> trips = tripRepository.findByBooking_Id(booking.getId());
        if (trips == null || trips.isEmpty()) {
            return; // Chưa có trip, cho phép sửa
        }
        
        Instant earliestStartTime = trips.stream()
                .map(Trips::getStartTime)
                .filter(java.util.Objects::nonNull)
                .min(Instant::compareTo)
                .orElse(null);
        
        if (earliestStartTime == null) {
            return;
        }
        
        Instant now = Instant.now();
        
        // Check đã khởi hành chưa
        if (now.isAfter(earliestStartTime)) {
            throw new RuntimeException("Không thể sửa đổi đơn hàng sau khi đã khởi hành");
        }
        
        // Check có trip đang diễn ra không
        boolean hasInProgressTrip = trips.stream()
                .anyMatch(t -> t.getStatus() == TripStatus.ONGOING);
        if (hasInProgressTrip) {
            throw new RuntimeException("Không thể sửa đổi đơn hàng khi có chuyến đang diễn ra");
        }
        
        long hoursUntilStart = java.time.Duration.between(now, earliestStartTime).toHours();
        
        if (isMajorChange) {
            // Thay đổi lớn: >= 72h
            int minHours = getSystemSettingInt("BOOKING_MAJOR_MODIFICATION_MIN_HOURS", 72);
            if (hoursUntilStart < minHours) {
                throw new RuntimeException(
                        String.format("Thay đổi lớn (điểm đón/trả, hành trình, loại xe) phải thực hiện trước %d giờ khởi hành. " +
                                "Còn %d giờ trước khi khởi hành.", minHours, hoursUntilStart)
                );
            }
        } else {
            // Thay đổi nhỏ: >= 24h
            int minHours = getSystemSettingInt("BOOKING_MINOR_MODIFICATION_MIN_HOURS", 24);
            if (hoursUntilStart < minHours) {
                throw new RuntimeException(
                        String.format("Sửa đổi đơn hàng phải thực hiện trước %d giờ khởi hành. " +
                                "Còn %d giờ trước khi khởi hành.", minHours, hoursUntilStart)
                );
            }
        }
        
        log.info("[Booking] Modification allowed: isMajorChange={}, hoursUntilStart={}", isMajorChange, hoursUntilStart);
    }
    
    /**
     * Validation: Kiểm tra xem có thể hủy booking không
     * - Chỉ cho phép trước khi khởi hành
     * - Hủy: được phép nhưng có phạt cọc theo quy định
     * (Dùng cho delete/cancel, không dùng cho update)
     */
    private void validateCanCancelOrModify(Bookings booking, String action) {
        // Lấy thời gian khởi hành từ trips
        List<Trips> trips = tripRepository.findByBooking_Id(booking.getId());
        if (trips == null || trips.isEmpty()) {
            // Không có trip, cho phép hủy
            return;
        }
        
        // Lấy thời gian khởi hành sớm nhất
        Instant earliestStartTime = trips.stream()
                .map(Trips::getStartTime)
                .filter(java.util.Objects::nonNull)
                .min(Instant::compareTo)
                .orElse(null);
        
        if (earliestStartTime == null) {
            // Không có thời gian khởi hành, cho phép
            return;
        }
        
        // Check xem đã khởi hành chưa
        Instant now = Instant.now();
        if (now.isAfter(earliestStartTime)) {
            throw new RuntimeException(
                    String.format("Không thể %s đơn hàng sau khi đã khởi hành. Thời gian khởi hành: %s", 
                            action, earliestStartTime.toString())
            );
        }
        
        // Check xem có trip nào đang IN_PROGRESS không
        boolean hasInProgressTrip = trips.stream()
                .anyMatch(t -> t.getStatus() == TripStatus.ONGOING);
        
        if (hasInProgressTrip) {
            throw new RuntimeException(
                    String.format("Không thể %s đơn hàng khi có chuyến đang diễn ra", action)
            );
        }
    }
    
    @Override
    public ConsultantDashboardResponse getConsultantDashboard(Integer consultantEmployeeId, Integer branchId) {
        // Lấy danh sách bookings theo status
        List<Bookings> pendingBookings = bookingRepository.findPendingBookings(branchId, consultantEmployeeId);
        List<Bookings> sentQuotations = bookingRepository.filterBookings(
                BookingStatus.QUOTATION_SENT, branchId, consultantEmployeeId, null, null, null, Pageable.unpaged()
        ).getContent();
        List<Bookings> confirmedBookings = bookingRepository.findConfirmedBookings(branchId, consultantEmployeeId);
        
        // Đếm số lượng
        Long totalPendingCount = bookingRepository.countByStatus(BookingStatus.PENDING, branchId, consultantEmployeeId);
        Long totalSentCount = bookingRepository.countByStatus(BookingStatus.QUOTATION_SENT, branchId, consultantEmployeeId);
        Long totalConfirmedCount = bookingRepository.countByStatus(BookingStatus.CONFIRMED, branchId, consultantEmployeeId);
        
        // Tính doanh số trong tháng
        YearMonth currentMonth = YearMonth.now();
        LocalDate monthStart = currentMonth.atDay(1);
        LocalDate monthEnd = currentMonth.atEndOfMonth();
        Instant startInstant = monthStart.atStartOfDay(ZoneId.systemDefault()).toInstant();
        Instant endInstant = monthEnd.atTime(23, 59, 59).atZone(ZoneId.systemDefault()).toInstant();
        
        Page<Bookings> monthlyBookings = bookingRepository.filterBookings(
                BookingStatus.COMPLETED,
                branchId,
                consultantEmployeeId,
                startInstant,
                endInstant,
                null,
                Pageable.unpaged()
        );
        
        BigDecimal monthlyRevenue = monthlyBookings.getContent().stream()
                .map(b -> b.getTotalCost() != null ? b.getTotalCost() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        // Tính tỷ lệ chuyển đổi
        Long totalBookings = bookingRepository.countByStatus(null, branchId, consultantEmployeeId);
        Double conversionRate = totalBookings > 0
                ? (double) totalConfirmedCount / totalBookings * 100
                : 0.0;
        
        // Thống kê theo tháng (3 tháng gần nhất)
        List<ConsultantDashboardResponse.MonthlyStatistic> monthlyStatistics = new ArrayList<>();
        for (int i = 2; i >= 0; i--) {
            YearMonth month = currentMonth.minusMonths(i);
            LocalDate mStart = month.atDay(1);
            LocalDate mEnd = month.atEndOfMonth();
            Instant mStartInstant = mStart.atStartOfDay(ZoneId.systemDefault()).toInstant();
            Instant mEndInstant = mEnd.atTime(23, 59, 59).atZone(ZoneId.systemDefault()).toInstant();
            
            Page<Bookings> monthBookings = bookingRepository.filterBookings(
                    null, branchId, consultantEmployeeId, mStartInstant, mEndInstant, null, Pageable.unpaged()
            );
            
            Long monthTotal = (long) monthBookings.getContent().size();
            Long monthConfirmed = monthBookings.getContent().stream()
                    .filter(b -> b.getStatus() == BookingStatus.CONFIRMED || b.getStatus() == BookingStatus.COMPLETED)
                    .count();
            BigDecimal monthRevenue = monthBookings.getContent().stream()
                    .map(b -> b.getTotalCost() != null ? b.getTotalCost() : BigDecimal.ZERO)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            Double monthConversionRate = monthTotal > 0 ? (double) monthConfirmed / monthTotal * 100 : 0.0;
            
            monthlyStatistics.add(ConsultantDashboardResponse.MonthlyStatistic.builder()
                    .month(month.toString())
                    .totalBookings(monthTotal)
                    .confirmedBookings(monthConfirmed)
                    .revenue(monthRevenue)
                    .conversionRate(monthConversionRate)
                    .build());
        }
        
        return ConsultantDashboardResponse.builder()
                .pendingBookings(pendingBookings.stream().map(this::toListResponse).collect(Collectors.toList()))
                .sentQuotations(sentQuotations.stream().map(this::toListResponse).collect(Collectors.toList()))
                .confirmedBookings(confirmedBookings.stream().map(this::toListResponse).collect(Collectors.toList()))
                .totalPendingCount(totalPendingCount)
                .totalSentCount(totalSentCount)
                .totalConfirmedCount(totalConfirmedCount)
                .monthlyRevenue(monthlyRevenue)
                .conversionRate(conversionRate)
                .monthlyStatistics(monthlyStatistics)
                .build();
    }
    
    @Override
    public List<BookingListResponse> getBookingList(String status, Integer branchId, Integer consultantId) {
        BookingStatus statusEnum = status != null && !status.isBlank()
                ? parseBookingStatus(status)
                : null;
        
        Page<Bookings> bookings = bookingRepository.filterBookings(
                statusEnum, branchId, consultantId, null, null, null, Pageable.unpaged()
        );
        
        return bookings.getContent().stream()
                .map(this::toListResponse)
                .collect(Collectors.toList());
    }
    
    // Helper methods
    private BookingStatus parseBookingStatus(String status) {
        if (status == null || status.isBlank()) {
            return BookingStatus.PENDING;
        }
        try {
            String s = status.trim().toUpperCase().replace('-', '_').replace(' ', '_');
            if ("INPROGRESS".equals(s)) s = "IN_PROGRESS";
            return BookingStatus.valueOf(s);
        } catch (IllegalArgumentException e) {
            return BookingStatus.PENDING;
        }
    }

    @Override
    @Transactional
    public BookingResponse addPayment(Integer bookingId, CreatePaymentRequest request, Integer employeeId) {
        Bookings booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng: " + bookingId));

        // Tìm invoice UNPAID với cùng số tiền và isDeposit để cập nhật thay vì tạo mới
        List<Invoices> existingInvoices = invoiceRepository.findByBooking_IdOrderByCreatedAtDesc(bookingId);
        Invoices matchingUnpaidInvoice = existingInvoices.stream()
                .filter(inv -> inv.getPaymentStatus() == org.example.ptcmssbackend.enums.PaymentStatus.UNPAID
                        && inv.getAmount() != null 
                        && inv.getAmount().compareTo(request.getAmount()) == 0
                        && inv.getIsDeposit() != null 
                        && inv.getIsDeposit().equals(Boolean.TRUE.equals(request.getDeposit())))
                .findFirst()
                .orElse(null);

        Invoices inv;
        if (matchingUnpaidInvoice != null) {
            // Cập nhật invoice UNPAID thành PAID
            inv = matchingUnpaidInvoice;
            inv.setPaymentStatus(org.example.ptcmssbackend.enums.PaymentStatus.PAID);
            if (request.getNote() != null && !request.getNote().isEmpty()) {
                inv.setNote(request.getNote());
            }
            if (employeeId != null) {
                inv.setCreatedBy(employeeRepository.findById(employeeId).orElse(null));
            }
        } else {
            // Tạo invoice mới nếu không tìm thấy invoice UNPAID phù hợp
            inv = new Invoices();
            inv.setBooking(booking);
            inv.setBranch(booking.getBranch());
            inv.setCustomer(booking.getCustomer());
            inv.setType(org.example.ptcmssbackend.enums.InvoiceType.INCOME);
            inv.setIsDeposit(Boolean.TRUE.equals(request.getDeposit()));
            inv.setAmount(request.getAmount());
            inv.setPaymentStatus(org.example.ptcmssbackend.enums.PaymentStatus.PAID);
            inv.setStatus(org.example.ptcmssbackend.enums.InvoiceStatus.ACTIVE);
            inv.setNote(request.getNote());
            if (employeeId != null) {
                inv.setCreatedBy(employeeRepository.findById(employeeId).orElse(null));
            }
        }
        invoiceRepository.save(inv);

        // return updated booking response with new totals
        return getById(bookingId);
    }

    @Override
    @Transactional
    public BookingResponse assign(Integer bookingId, AssignRequest request) {
        Bookings booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng: " + bookingId));

        List<Trips> trips = tripRepository.findByBooking_Id(bookingId);
        List<Integer> targetTripIds = (request.getTripIds() != null && !request.getTripIds().isEmpty())
                ? request.getTripIds()
                : trips.stream().map(Trips::getId).collect(Collectors.toList());

        // Assign driver if provided
        if (request.getDriverId() != null) {
            Drivers driver = driverRepository.findById(request.getDriverId())
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy tài xế: " + request.getDriverId()));
            
            // VALIDATION: Kiểm tra tài xế này đã được gán cho trip khác trong cùng booking chưa
            // (ngoài các trips đang được gán trong request này)
            List<Trips> allBookingTrips = tripRepository.findByBooking_Id(bookingId);
            Set<Integer> targetTripIdsSet = new java.util.HashSet<>(targetTripIds);
            
            for (Trips otherTrip : allBookingTrips) {
                // Bỏ qua các trips đang được gán trong request này
                if (targetTripIdsSet.contains(otherTrip.getId())) {
                    continue;
                }
                
                // Kiểm tra xem trip khác đã có tài xế này chưa
                List<TripDrivers> otherTripDrivers = tripDriverRepository.findByTripId(otherTrip.getId());
                boolean driverAlreadyAssigned = otherTripDrivers.stream()
                        .anyMatch(td -> td.getDriver() != null && td.getDriver().getId().equals(driver.getId()));
                
                if (driverAlreadyAssigned) {
                    throw new RuntimeException(String.format(
                            "Tài xế %s đã được gán cho chuyến khác trong cùng đơn hàng (Trip #%d). " +
                            "Mỗi chuyến trong cùng đơn hàng phải có tài xế khác nhau.",
                            driver.getEmployee() != null && driver.getEmployee().getUser() != null
                                    ? driver.getEmployee().getUser().getFullName()
                                    : "ID " + driver.getId(),
                            otherTrip.getId()
                    ));
                }
            }
            
            // Nếu gán cho nhiều trips cùng lúc, cũng cần đảm bảo không trùng nhau
            if (targetTripIds.size() > 1) {
                log.warn("[Booking] Assigning same driver {} to {} trips. This is allowed but may not be desired.", 
                        driver.getId(), targetTripIds.size());
            }
            
            for (Integer tid : targetTripIds) {
                List<TripDrivers> olds = tripDriverRepository.findByTripId(tid);
                if (!olds.isEmpty()) tripDriverRepository.deleteAll(olds);

                TripDrivers td = new TripDrivers();
                TripDriverId id = new TripDriverId();
                id.setTripId(tid);
                id.setDriverId(driver.getId());
                td.setId(id);
                Trips trip = trips.stream().filter(t -> t.getId().equals(tid)).findFirst().orElseThrow();
                td.setTrip(trip);
                td.setDriver(driver);
                td.setDriverRole("Main Driver");
                td.setNote(request.getNote());
                tripDriverRepository.save(td);
                
                // Update trip status to ASSIGNED
                if (trip.getStatus() == TripStatus.SCHEDULED) {
                    trip.setStatus(TripStatus.ASSIGNED);
                    tripRepository.save(trip);
                }
            }
        }

        // Assign vehicle if provided
        if (request.getVehicleId() != null) {
            Vehicles primaryVehicle = vehicleRepository.findById(request.getVehicleId())
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy xe: " + request.getVehicleId()));
            
            // Lấy thông tin về loại xe cần cho từng trip từ BookingVehicleDetails
            List<BookingVehicleDetails> bookingVehicles = bookingVehicleDetailsRepository.findByBookingId(booking.getId());
            
            // Tạo danh sách categoryId cho từng trip (theo thứ tự)
            List<Integer> requiredCategoryIds = new ArrayList<>();
            for (BookingVehicleDetails bvd : bookingVehicles) {
                Integer categoryId = bvd.getVehicleCategory() != null ? bvd.getVehicleCategory().getId() : null;
                int quantity = bvd.getQuantity() != null ? bvd.getQuantity() : 1;
                for (int q = 0; q < quantity; q++) {
                    requiredCategoryIds.add(categoryId);
                }
            }
            
            // Nếu gán cho nhiều trips, cần tìm thêm xe cho các trips còn lại
            List<Vehicles> assignedVehicles = new ArrayList<>();
            assignedVehicles.add(primaryVehicle); // Xe đầu tiên
            
            // Tìm thêm xe cho các trips còn lại (nếu có nhiều trips)
            if (targetTripIds.size() > 1) {
                Integer branchId = booking.getBranch() != null ? booking.getBranch().getId() : null;
                
                // Tìm xe cho từng trip còn lại (từ trip thứ 2 trở đi)
                for (int tripIdx = 1; tripIdx < targetTripIds.size(); tripIdx++) {
                    // Lấy categoryId cần cho trip này (nếu có)
                    Integer requiredCategoryId = tripIdx < requiredCategoryIds.size() 
                            ? requiredCategoryIds.get(tripIdx) 
                            : (primaryVehicle.getCategory() != null ? primaryVehicle.getCategory().getId() : null);
                    
                    // Tìm các xe cùng loại (nếu có yêu cầu), cùng branch, available
                    List<Vehicles> availableVehicles = vehicleRepository.filterVehicles(
                            requiredCategoryId, 
                            branchId, 
                            org.example.ptcmssbackend.enums.VehicleStatus.AVAILABLE
                    );
                    
                    // Loại bỏ các xe đã được gán
                    Set<Integer> alreadyAssignedIds = assignedVehicles.stream()
                            .map(Vehicles::getId)
                            .collect(java.util.stream.Collectors.toSet());
                    availableVehicles = availableVehicles.stream()
                            .filter(v -> !alreadyAssignedIds.contains(v.getId()))
                            .collect(java.util.stream.Collectors.toList());
                    
                    // Kiểm tra từng xe có bận không trong thời gian của trip này
                    final Integer currentTripId = targetTripIds.get(tripIdx);
                    Trips currentTrip = trips.stream()
                            .filter(t -> t.getId().equals(currentTripId))
                            .findFirst()
                            .orElse(null);
                    
                    Vehicles selectedVehicle = null;
                    if (currentTrip != null && currentTrip.getStartTime() != null) {
                        Instant tripEndTime = currentTrip.getEndTime() != null 
                                ? currentTrip.getEndTime() 
                                : currentTrip.getStartTime().plusSeconds(3600);
                        
                        for (Vehicles v : availableVehicles) {
                            // Kiểm tra overlap
                            List<org.example.ptcmssbackend.entity.TripVehicles> overlaps = 
                                    tripVehicleRepository.findOverlapsForVehicle(
                                            v.getId(), 
                                            currentTrip.getStartTime(), 
                                            tripEndTime
                                    );
                            
                            // Loại bỏ các overlaps với trips đã bị cancel hoặc chính trip này
                            boolean hasConflict = overlaps.stream().anyMatch(tv -> {
                                Trips overlapTrip = tv.getTrip();
                                return overlapTrip.getStatus() != TripStatus.CANCELLED
                                        && !targetTripIds.contains(overlapTrip.getId());
                            });
                            
                            if (!hasConflict) {
                                selectedVehicle = v;
                                break; // Tìm được xe phù hợp
                            }
                        }
                    } else {
                        // Nếu không có thời gian, lấy xe đầu tiên available
                        if (!availableVehicles.isEmpty()) {
                            selectedVehicle = availableVehicles.get(0);
                        }
                    }
                    
                    if (selectedVehicle != null) {
                        assignedVehicles.add(selectedVehicle);
                        log.info("[Booking] Found vehicle {} (category: {}) for trip {}", 
                                selectedVehicle.getLicensePlate(), 
                                selectedVehicle.getCategory() != null ? selectedVehicle.getCategory().getCategoryName() : "N/A",
                                targetTripIds.get(tripIdx));
                    } else {
                        // Không tìm được xe phù hợp, dùng xe chính (fallback)
                        log.warn("[Booking] No suitable vehicle found for trip {}. Will use primary vehicle.", 
                                targetTripIds.get(tripIdx));
                        assignedVehicles.add(primaryVehicle);
                    }
                }
                
                // Nếu không đủ xe, log warning
                if (assignedVehicles.size() < targetTripIds.size()) {
                    log.warn("[Booking] Not enough vehicles available. Need {} vehicles, found {}. Will reuse primary vehicle for remaining trips.", 
                            targetTripIds.size(), assignedVehicles.size());
                }
            }
            
            // Gán xe cho từng trip
            for (int i = 0; i < targetTripIds.size(); i++) {
                Integer tid = targetTripIds.get(i);
                Vehicles vehicleToAssign = i < assignedVehicles.size() 
                        ? assignedVehicles.get(i) 
                        : primaryVehicle; // Fallback: dùng xe chính nếu không đủ
                
                List<TripVehicles> olds = tripVehicleRepository.findByTripId(tid);

                // Nếu đã gán đúng vehicle này rồi -> cập nhật note/assignedAt (idempotent)
                TripVehicles same = null;
                for (TripVehicles tvOld : olds) {
                    if (tvOld.getVehicle() != null && tvOld.getVehicle().getId().equals(vehicleToAssign.getId())) {
                        same = tvOld;
                        break;
                    }
                }

                if (same != null) {
                    same.setAssignedAt(java.time.Instant.now());
                    same.setNote(request.getNote());
                    tripVehicleRepository.save(same);
                    // Xoá các mapping khác nếu tồn tại (đảm bảo chỉ còn 1)
                    for (TripVehicles tvOld : olds) {
                        if (!tvOld.getId().equals(same.getId())) {
                            tripVehicleRepository.delete(tvOld);
                        }
                    }
                    tripVehicleRepository.flush();
                } else {
                    // Chưa có -> xoá tất cả cũ rồi tạo mới
                    if (!olds.isEmpty()) {
                        tripVehicleRepository.deleteAll(olds);
                        tripVehicleRepository.flush();
                    }
                    TripVehicles tv = new TripVehicles();
                    Trips trip = trips.stream().filter(t -> t.getId().equals(tid)).findFirst().orElseThrow();
                    tv.setTrip(trip);
                    tv.setVehicle(vehicleToAssign);
                    tv.setAssignedAt(java.time.Instant.now());
                    tv.setNote(request.getNote() != null ? request.getNote() : 
                            (targetTripIds.size() > 1 ? String.format("Xe %d/%d", i + 1, targetTripIds.size()) : null));
                    tripVehicleRepository.save(tv);
                    
                    log.info("[Booking] Assigned vehicle {} to trip {} ({}/{})", 
                            vehicleToAssign.getLicensePlate(), tid, i + 1, targetTripIds.size());
                    
                    // Update trip status to ASSIGNED
                    if (trip.getStatus() == TripStatus.SCHEDULED) {
                        trip.setStatus(TripStatus.ASSIGNED);
                        tripRepository.save(trip);
                    }
                }
            }
        }
        
        // Update trip status to ASSIGNED when both driver and vehicle are assigned
        for (Integer tid : targetTripIds) {
            Trips trip = trips.stream().filter(t -> t.getId().equals(tid)).findFirst().orElseThrow();
            List<TripDrivers> tripDrivers = tripDriverRepository.findByTripId(tid);
            List<TripVehicles> tripVehicles = tripVehicleRepository.findByTripId(tid);
            
            // Set ASSIGNED if both driver and vehicle are assigned
            if (!tripDrivers.isEmpty() && !tripVehicles.isEmpty()) {
                trip.setStatus(TripStatus.ASSIGNED);
                tripRepository.save(trip);
            }
        }
        
        // Update booking status to CONFIRMED if all trips are assigned
        List<Trips> allTrips = tripRepository.findByBooking_Id(bookingId);
        boolean allTripsAssigned = allTrips.stream().allMatch(trip -> {
            List<TripDrivers> tds = tripDriverRepository.findByTripId(trip.getId());
            List<TripVehicles> tvs = tripVehicleRepository.findByTripId(trip.getId());
            return !tds.isEmpty() && !tvs.isEmpty();
        });
        
        if (allTripsAssigned && !allTrips.isEmpty()) {
            if (booking.getStatus() == BookingStatus.PENDING || booking.getStatus() == BookingStatus.QUOTATION_SENT) {
                booking.setStatus(BookingStatus.CONFIRMED);
                bookingRepository.save(booking);
                log.info("[Booking] Updated booking {} status to CONFIRMED after assigning all trips", bookingId);
            }
        }

        // Send notification to driver when assigned
        if (request.getDriverId() != null) {
            try {
                Drivers driver = driverRepository.findById(request.getDriverId()).orElse(null);
                if (driver != null && driver.getEmployee() != null && driver.getEmployee().getUser() != null) {
                    Integer userId = driver.getEmployee().getUser().getId();
                    String bookingCode = "ORD-" + booking.getId();
                    String customerName = booking.getCustomer() != null ? booking.getCustomer().getFullName() : "Khách hàng";
                    
                    webSocketNotificationService.sendUserNotification(
                            userId,
                            "Chuyến mới được gán",
                            String.format("Bạn được gán %d chuyến cho đơn %s - %s",
                                    targetTripIds.size(),
                                    bookingCode,
                                    customerName),
                            "INFO"
                    );
                    log.info("[Booking] Sent notification to driver {} for assigned trips", request.getDriverId());
                }
            } catch (Exception e) {
                log.warn("[Booking] Failed to send notification to driver: {}", e.getMessage());
            }
        }

        return getById(bookingId);
    }

    @Override
    public org.example.ptcmssbackend.dto.response.Booking.CheckAvailabilityResponse checkAvailability(CheckAvailabilityRequest request) {
        Integer branchId = request.getBranchId();
        Integer categoryId = request.getCategoryId();
        java.time.Instant start = request.getStartTime();
        java.time.Instant end = request.getEndTime();
        int needed = request.getQuantity() != null ? request.getQuantity() : 1;

        // Total candidates available by branch/category/status
        java.util.List<Vehicles> candidates = vehicleRepository.filterVehicles(categoryId, branchId, VehicleStatus.AVAILABLE);
        int total = candidates != null ? candidates.size() : 0;

        // Busy vehicles in window (đã gán TripVehicles)
        java.util.List<Integer> busyIds = tripVehicleRepository.findBusyVehicleIds(branchId, categoryId, start, end);
        int busy = busyIds != null ? busyIds.size() : 0;

        // Reserved quantity by bookings đã cọc nhưng CHƯA gán xe
        java.util.List<BookingStatus> reservedStatuses = java.util.Arrays.asList(
                BookingStatus.PENDING,
                BookingStatus.CONFIRMED,
                BookingStatus.INPROGRESS
        );
        Integer reservedQty = bookingVehicleDetailsRepository.countReservedQuantityWithoutAssignedVehicles(
                branchId,
                categoryId,
                start,
                end,
                reservedStatuses
        );
        int reserved = reservedQty != null ? reservedQty : 0;

        int available = Math.max(0, total - busy - reserved);
        boolean ok = available >= needed;

        // Nếu không đủ xe -> tính suggestions
        List<org.example.ptcmssbackend.dto.response.Booking.CheckAvailabilityResponse.AlternativeCategory> alternativeCategories = null;
        List<org.example.ptcmssbackend.dto.response.Booking.CheckAvailabilityResponse.NextAvailableSlot> nextAvailableSlots = null;
        
        if (!ok) {
            // 1. Tìm loại xe thay thế có sẵn tại thời điểm yêu cầu
            alternativeCategories = findAlternativeCategories(branchId, categoryId, start, end, needed);
            
            // 2. Tìm thời gian rảnh tiếp theo của loại xe được yêu cầu
            nextAvailableSlots = findNextAvailableSlots(branchId, categoryId, start, needed, candidates);
        }

        return org.example.ptcmssbackend.dto.response.Booking.CheckAvailabilityResponse.builder()
                .ok(ok)
                .availableCount(available)
                .needed(needed)
                .totalCandidates(total)
                // busyCount: đã gán xe (busy) + đã được giữ chỗ bằng booking nhưng chưa gán xe (reserved)
                .busyCount(busy + reserved)
                .alternativeCategories(alternativeCategories)
                .nextAvailableSlots(nextAvailableSlots)
                .build();
    }
    
    /**
     * Tìm các loại xe thay thế có sẵn tại thời điểm yêu cầu
     */
    private List<org.example.ptcmssbackend.dto.response.Booking.CheckAvailabilityResponse.AlternativeCategory> findAlternativeCategories(
            Integer branchId, Integer excludeCategoryId, Instant start, Instant end, int needed) {
        
        List<org.example.ptcmssbackend.dto.response.Booking.CheckAvailabilityResponse.AlternativeCategory> alternatives = new ArrayList<>();
        
        // Lấy tất cả loại xe active
        List<VehicleCategoryPricing> allCategories = vehicleCategoryRepository.findAll().stream()
                .filter(c -> c.getStatus() == VehicleCategoryStatus.ACTIVE)
                .filter(c -> !c.getId().equals(excludeCategoryId))
                .collect(Collectors.toList());
        
        for (VehicleCategoryPricing category : allCategories) {
            // Đếm xe available cho loại này
            List<Vehicles> catVehicles = vehicleRepository.filterVehicles(category.getId(), branchId, VehicleStatus.AVAILABLE);
            int totalInCategory = catVehicles != null ? catVehicles.size() : 0;
            
            // Đếm xe busy trong khoảng thời gian
            List<Integer> busyInCategory = tripVehicleRepository.findBusyVehicleIds(branchId, category.getId(), start, end);
            int busyCount = busyInCategory != null ? busyInCategory.size() : 0;
            
            int availableInCategory = Math.max(0, totalInCategory - busyCount);
            
            // Chỉ suggest nếu có đủ xe
            if (availableInCategory >= needed) {
                alternatives.add(org.example.ptcmssbackend.dto.response.Booking.CheckAvailabilityResponse.AlternativeCategory.builder()
                        .categoryId(category.getId())
                        .categoryName(category.getCategoryName())
                        .seats(category.getSeats())
                        .availableCount(availableInCategory)
                        .pricePerKm(category.getPricePerKm())
                        .estimatedPrice(null) // Có thể tính nếu biết distance
                        .build());
            }
        }
        
        // Sắp xếp theo số ghế tăng dần (ưu tiên xe gần với yêu cầu)
        alternatives.sort((a, b) -> {
            if (a.getSeats() == null) return 1;
            if (b.getSeats() == null) return -1;
            return a.getSeats().compareTo(b.getSeats());
        });
        
        return alternatives.isEmpty() ? null : alternatives;
    }
    
    /**
     * Tìm thời gian rảnh tiếp theo của loại xe được yêu cầu
     */
    private List<org.example.ptcmssbackend.dto.response.Booking.CheckAvailabilityResponse.NextAvailableSlot> findNextAvailableSlots(
            Integer branchId, Integer categoryId, Instant requestedStart, int needed, List<Vehicles> candidates) {
        
        if (candidates == null || candidates.isEmpty()) {
            return null;
        }
        
        List<org.example.ptcmssbackend.dto.response.Booking.CheckAvailabilityResponse.NextAvailableSlot> slots = new ArrayList<>();
        
        // Tìm thời gian kết thúc của các trip đang chạy cho mỗi xe
        for (Vehicles vehicle : candidates) {
            // Lấy trip đang SCHEDULED hoặc ONGOING có thời gian gần nhất sau requestedStart
            List<TripVehicles> upcomingTrips = tripVehicleRepository.findAllByVehicleId(vehicle.getId());
            
            // Lọc các trip trong tương lai gần (trong 24h) có overlap với requestedStart
            Instant searchEnd = requestedStart.plus(java.time.Duration.ofHours(24));
            
            Instant earliestAvailable = null;
            Instant availableUntil = null;
            
            for (TripVehicles tv : upcomingTrips) {
                Trips trip = tv.getTrip();
                if (trip == null || trip.getStatus() == null) continue;
                
                // Chỉ xét SCHEDULED, ASSIGNED hoặc ONGOING
                if (trip.getStatus() != TripStatus.SCHEDULED && 
                    trip.getStatus() != TripStatus.ASSIGNED &&
                    trip.getStatus() != TripStatus.ONGOING) {
                    continue;
                }
                
                Instant tripStart = trip.getStartTime();
                Instant tripEnd = trip.getEndTime();
                
                if (tripStart == null || tripEnd == null) continue;
                
                // Nếu trip này đang block thời gian yêu cầu
                if (tripStart.isBefore(searchEnd) && tripEnd.isAfter(requestedStart)) {
                    // Xe sẽ rảnh sau khi trip này kết thúc
                    if (earliestAvailable == null || tripEnd.isAfter(earliestAvailable)) {
                        earliestAvailable = tripEnd;
                    }
                }
                
                // Tìm trip tiếp theo sau earliestAvailable để biết availableUntil
                if (earliestAvailable != null && tripStart.isAfter(earliestAvailable)) {
                    if (availableUntil == null || tripStart.isBefore(availableUntil)) {
                        availableUntil = tripStart;
                    }
                }
            }
            
            // Nếu tìm được thời gian rảnh
            if (earliestAvailable != null) {
                slots.add(org.example.ptcmssbackend.dto.response.Booking.CheckAvailabilityResponse.NextAvailableSlot.builder()
                        .vehicleId(vehicle.getId())
                        .vehicleLicensePlate(vehicle.getLicensePlate())
                        .availableFrom(earliestAvailable)
                        .availableUntil(availableUntil)
                        .availableCount(1)
                        .build());
            }
        }
        
        // Sắp xếp theo thời gian rảnh sớm nhất
        slots.sort((a, b) -> {
            if (a.getAvailableFrom() == null) return 1;
            if (b.getAvailableFrom() == null) return -1;
            return a.getAvailableFrom().compareTo(b.getAvailableFrom());
        });
        
        // Gộp các slot cùng thời gian và chỉ trả về top 5
        List<org.example.ptcmssbackend.dto.response.Booking.CheckAvailabilityResponse.NextAvailableSlot> result = new ArrayList<>();
        for (var slot : slots) {
            // Kiểm tra xem đã có slot với thời gian tương tự chưa (trong vòng 30 phút)
            boolean merged = false;
            for (var existing : result) {
                if (existing.getAvailableFrom() != null && slot.getAvailableFrom() != null) {
                    long diffMinutes = java.time.Duration.between(existing.getAvailableFrom(), slot.getAvailableFrom()).abs().toMinutes();
                    if (diffMinutes <= 30) {
                        existing.setAvailableCount(existing.getAvailableCount() + 1);
                        merged = true;
                        break;
                    }
                }
            }
            if (!merged && result.size() < 5) {
                result.add(slot);
            }
        }
        
        return result.isEmpty() ? null : result;
    }
    
    private BookingResponse toResponse(Bookings booking) {
        // Load trips
        List<Trips> trips = tripRepository.findByBooking_Id(booking.getId());
        
        // Load vehicle details
        List<BookingVehicleDetails> vehicleDetails = bookingVehicleDetailsRepository.findByBookingId(booking.getId());
        
        // Load trip drivers và vehicles (nếu đã gán)
        List<TripResponse> tripResponses = trips.stream().map(trip -> {
            // Tìm driver và vehicle cho trip này
            Integer driverId = null;
            String driverName = null;
            Integer vehicleId = null;
            String vehicleLicensePlate = null;
            
            String driverPhone = null;
            
            // Tìm driver và vehicle từ TripDrivers và TripVehicles
            List<TripDrivers> tripDrivers = tripDriverRepository.findByTripId(trip.getId());
            if (!tripDrivers.isEmpty()) {
                TripDrivers td = tripDrivers.get(0); // Lấy driver đầu tiên
                driverId = td.getDriver().getId();
                if (td.getDriver().getEmployee() != null && td.getDriver().getEmployee().getUser() != null) {
                    driverName = td.getDriver().getEmployee().getUser().getFullName();
                    driverPhone = td.getDriver().getEmployee().getUser().getPhone();
                }
            }
            
            List<TripVehicles> tripVehicles = tripVehicleRepository.findByTripId(trip.getId());
            if (!tripVehicles.isEmpty()) {
                TripVehicles tv = tripVehicles.get(0); // Lấy vehicle đầu tiên
                vehicleId = tv.getVehicle().getId();
                vehicleLicensePlate = tv.getVehicle().getLicensePlate();
            }
            
            return TripResponse.builder()
                    .id(trip.getId())
                    .bookingId(booking.getId())
                    .startTime(trip.getStartTime())
                    .endTime(trip.getEndTime())
                    .startLocation(trip.getStartLocation())
                    .endLocation(trip.getEndLocation())
                    .distance(trip.getDistance() != null ? trip.getDistance().doubleValue() : null)
                    .useHighway(trip.getUseHighway())
                    .status(trip.getStatus() != null ? trip.getStatus().name() : null)
                    .driverId(driverId)
                    .driverName(driverName)
                    .driverPhone(driverPhone)
                    .vehicleId(vehicleId)
                    .vehicleLicensePlate(vehicleLicensePlate)
                    .build();
        }).collect(Collectors.toList());
        
        // Tính paidAmount từ payment_history đã CONFIRMED
        BigDecimal paidAmount = invoiceRepository.calculateConfirmedPaidAmountByBookingId(booking.getId());
        if (paidAmount == null) paidAmount = BigDecimal.ZERO;
        BigDecimal remainingAmount = booking.getTotalCost() != null
                ? booking.getTotalCost().subtract(paidAmount)
                : BigDecimal.ZERO;
        if (remainingAmount.compareTo(BigDecimal.ZERO) < 0) {
            remainingAmount = BigDecimal.ZERO;
        }
        
        return BookingResponse.builder()
                .id(booking.getId())
                .customer(customerService.toResponse(booking.getCustomer()))
                .branchId(booking.getBranch().getId())
                .branchName(booking.getBranch().getBranchName())
                .consultantId(booking.getConsultant() != null ? booking.getConsultant().getEmployeeId() : null)
                .consultantName(booking.getConsultant() != null && booking.getConsultant().getUser() != null
                        ? booking.getConsultant().getUser().getFullName() : null)
                .hireTypeId(booking.getHireType() != null ? booking.getHireType().getId() : null)
                .hireTypeName(booking.getHireType() != null ? booking.getHireType().getName() : null)
                .useHighway(booking.getUseHighway())
                .bookingDate(booking.getBookingDate())
                .estimatedCost(booking.getEstimatedCost())
                .discountAmount(booking.getEstimatedCost() != null && booking.getTotalCost() != null
                        ? booking.getEstimatedCost().subtract(booking.getTotalCost())
                        : BigDecimal.ZERO)
                .totalCost(booking.getTotalCost())
                .depositAmount(booking.getDepositAmount())
                .status(booking.getStatus() != null ? booking.getStatus().name() : null)
                .note(booking.getNote())
                .createdAt(booking.getCreatedAt())
                .updatedAt(booking.getUpdatedAt())
                .trips(tripResponses)
                .vehicles(vehicleDetails.stream().map(vd -> VehicleDetailResponse.builder()
                        .vehicleCategoryId(vd.getVehicleCategory().getId())
                        .categoryName(vd.getVehicleCategory().getCategoryName())
                        .quantity(vd.getQuantity())
                        .capacity(vd.getVehicleCategory().getSeats()) // Lấy số chỗ từ VehicleCategory
                        .build()).collect(Collectors.toList()))
                .paidAmount(paidAmount)
                .remainingAmount(remainingAmount)
                .build();
    }
    
    private BookingListResponse toListResponse(Bookings booking) {
        // Tạo route summary từ trips
        List<Trips> trips = tripRepository.findByBooking_Id(booking.getId());
        
        String routeSummary = trips.isEmpty() ? "Chưa có lịch trình" : 
                trips.stream()
                        .map(t -> (t.getStartLocation() != null ? t.getStartLocation() : "?") + 
                                  " → " + 
                                  (t.getEndLocation() != null ? t.getEndLocation() : "?"))
                        .collect(Collectors.joining(", "));
        
        Instant startDate = trips.stream()
                .map(Trips::getStartTime)
                .filter(java.util.Objects::nonNull)
                .min(Instant::compareTo)
                .orElse(null);
        
        // Tính paidAmount từ payment_history đã CONFIRMED
        BigDecimal paidAmount = invoiceRepository.calculateConfirmedPaidAmountByBookingId(booking.getId());
        if (paidAmount == null) paidAmount = BigDecimal.ZERO;
        
        // Check if booking has *any* trip assigned (at least one trip có đủ driver + vehicle)
        // Business view cho điều phối: chỉ cần đã gán chuyến nào cho đơn là coi là "Đã gắn chuyến".
        boolean isAssigned = !trips.isEmpty() && trips.stream().anyMatch(trip -> {
            List<TripDrivers> drivers = tripDriverRepository.findByTripId(trip.getId());
            List<TripVehicles> vehicles = tripVehicleRepository.findByTripId(trip.getId());
            return !drivers.isEmpty() && !vehicles.isEmpty();
        });
        
        return BookingListResponse.builder()
                .id(booking.getId())
                .customerName(booking.getCustomer().getFullName())
                .customerPhone(booking.getCustomer().getPhone())
                .routeSummary(routeSummary)
                .startDate(startDate)
                .totalCost(booking.getTotalCost())
                .depositAmount(booking.getDepositAmount())
                .paidAmount(paidAmount)
                .status(booking.getStatus() != null ? booking.getStatus().name() : null)
                .isAssigned(isAssigned)
                .createdAt(booking.getCreatedAt())
                .consultantId(booking.getConsultant() != null ? booking.getConsultant().getEmployeeId() : null)
                .consultantName(booking.getConsultant() != null && booking.getConsultant().getUser() != null
                        ? booking.getConsultant().getUser().getFullName() : null)
                .branchId(booking.getBranch() != null ? booking.getBranch().getId() : null)
                .branchName(booking.getBranch() != null ? booking.getBranch().getBranchName() : null)
                .build();
    }
}

