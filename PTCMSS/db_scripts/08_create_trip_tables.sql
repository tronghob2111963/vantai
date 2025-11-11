USE ptcmss_db;

CREATE TABLE IF NOT EXISTS Trips (
  tripId INT AUTO_INCREMENT PRIMARY KEY,
  bookingId INT NOT NULL,
  useHighway BOOLEAN NULL,
  startTime DATETIME NULL,
  endTime DATETIME NULL,
  startLocation VARCHAR(255),
  endLocation VARCHAR(255),
  incidentalCosts DECIMAL(10,2) DEFAULT 0,
  status ENUM('Scheduled','Ongoing','Completed','Cancelled') DEFAULT 'Scheduled',
  CONSTRAINT fk_trip_booking FOREIGN KEY (bookingId) REFERENCES Bookings(bookingId),
  CHECK ((startTime IS NULL OR endTime IS NULL) OR (startTime < endTime))
) ENGINE=InnoDB;

CREATE INDEX IX_Trips_BookingId ON Trips(bookingId);
CREATE INDEX IX_Trips_Status_Start ON Trips(status, startTime);

CREATE TABLE IF NOT EXISTS TripVehicles (
  tripVehicleId INT AUTO_INCREMENT PRIMARY KEY,
  tripId INT NOT NULL,
  vehicleId INT NOT NULL,
  assignedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  note VARCHAR(255),
  CONSTRAINT fk_tv_trip    FOREIGN KEY (tripId)   REFERENCES Trips(tripId),
  CONSTRAINT fk_tv_vehicle FOREIGN KEY (vehicleId) REFERENCES Vehicles(vehicleId),
  CONSTRAINT UQ_TripVehicles UNIQUE (tripId, vehicleId)
) ENGINE=InnoDB;

CREATE INDEX IX_TripVehicles_TripId ON TripVehicles(tripId);
CREATE INDEX IX_TripVehicles_Vehicle ON TripVehicles(vehicleId, tripId);

CREATE TABLE IF NOT EXISTS TripDrivers (
  tripId INT NOT NULL,
  driverId INT NOT NULL,
  driverRole VARCHAR(50) DEFAULT 'Main Driver',
  startTime DATETIME NULL,
  endTime DATETIME NULL,
  note VARCHAR(255),
  PRIMARY KEY (tripId, driverId),
  CONSTRAINT fk_td_trip   FOREIGN KEY (tripId)   REFERENCES Trips(tripId),
  CONSTRAINT fk_td_driver FOREIGN KEY (driverId) REFERENCES Drivers(driverId),
  CHECK ((startTime IS NULL OR endTime IS NULL) OR (startTime < endTime))
) ENGINE=InnoDB;

CREATE INDEX IX_TripDrivers_Driver ON TripDrivers(driverId, tripId);
