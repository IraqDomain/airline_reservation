
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


-- Database: airline_reservation

CREATE TABLE `aircraft` (
  `AircraftID` int(11) NOT NULL,
  `Model` varchar(50) NOT NULL,
  `Manufacturer` varchar(50) NOT NULL,
  `SeatingCapacity` int(11) NOT NULL,
  `MaintenanceStatus` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- table `aircraft`
--

INSERT INTO `aircraft` (`AircraftID`, `Model`, `Manufacturer`, `SeatingCapacity`, `MaintenanceStatus`) VALUES
(1, 'Boeing 777-300ER', 'Boeing', 396, 'Active'),
(2, 'Airbus A350-900', 'Airbus', 325, 'Active'),
(3, 'Boeing 787-9', 'Boeing', 290, 'Under Maintenance'),
(4, 'Airbus A320neo', 'Airbus', 180, 'Active');



-- table `airport`


CREATE TABLE `airport` (
  `AirportID` int(11) NOT NULL,
  `AirportName` varchar(100) NOT NULL,
  `City` varchar(50) NOT NULL,
  `Country` varchar(50) NOT NULL,
  `AirportCode` char(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- table `airport`

INSERT INTO `airport` (`AirportID`, `AirportName`, `City`, `Country`, `AirportCode`) VALUES
(1, 'Hazrat Shahjalal International Airport', 'Dhaka', 'Bangladesh', 'DAC'),
(2, 'John F Kennedy International Airport', 'New York', 'USA', 'JFK'),
(3, 'Heathrow Airport', 'London', 'UK', 'LHR'),
(4, 'Dubai International Airport', 'Dubai', 'UAE', 'DXB'),
(5, 'Changi Airport', 'Singapore', 'Singapore', 'SIN');


--table `booking`


CREATE TABLE `booking` (
  `BookingID` int(11) NOT NULL,
  `PassengerID` int(11) NOT NULL,
  `FlightID` int(11) NOT NULL,
  `BookingDate` date NOT NULL,
  `SeatNumber` varchar(5) NOT NULL,
  `TravelClass` varchar(15) NOT NULL,
  `BookingStatus` varchar(20) NOT NULL DEFAULT 'Confirmed'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- table `booking`


INSERT INTO `booking` (`BookingID`, `PassengerID`, `FlightID`, `BookingDate`, `SeatNumber`, `TravelClass`, `BookingStatus`) VALUES
(1, 1, 1, '2026-08-01', '12A', 'Economy', 'Confirmed'),
(2, 2, 1, '2026-08-01', '12B', 'Economy', 'Confirmed'),
(3, 3, 2, '2026-08-02', '2A', 'Business', 'Confirmed'),
(4, 4, 3, '2026-08-03', '15C', 'Economy', 'Confirmed'),
(5, 5, 4, '2026-08-04', '3A', 'Business', 'Confirmed'),
(6, 6, 4, '2026-08-04', '20D', 'Economy', 'Confirmed'),
(7, 7, 5, '2026-08-05', '8B', 'Economy', 'Cancelled'),
(8, 8, 6, '2026-08-06', '1A', 'Business', 'Confirmed'),
(9, 3, 1, '2026-08-07', '14C', 'Economy', 'Confirmed'),
(10, 3, 1, '2026-08-07', '16D', 'Economy', 'Confirmed');


-- Triggers `booking`

DELIMITER $$
CREATE TRIGGER `after_booking_delete` AFTER DELETE ON `booking` FOR EACH ROW BEGIN
    INSERT INTO BOOKING_LOG (BookingID, PassengerID, FlightID, BookingDate, SeatNumber, TravelClass, BookingStatus, DeletedAt)
    VALUES (OLD.BookingID, OLD.PassengerID, OLD.FlightID, OLD.BookingDate, OLD.SeatNumber, OLD.TravelClass, OLD.BookingStatus, NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_booking_insert` BEFORE INSERT ON `booking` FOR EACH ROW BEGIN
    DECLARE seat_taken INT;
    SELECT COUNT(*) INTO seat_taken
    FROM BOOKING
    WHERE FlightID = NEW.FlightID
      AND SeatNumber = NEW.SeatNumber
      AND BookingStatus <> 'Cancelled';

    IF seat_taken > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seat already booked for this flight.';
    END IF;
END
$$
DELIMITER ;




-- table `booking_log`


CREATE TABLE `booking_log` (
  `LogID` int(11) NOT NULL,
  `BookingID` int(11) DEFAULT NULL,
  `PassengerID` int(11) DEFAULT NULL,
  `FlightID` int(11) DEFAULT NULL,
  `BookingDate` date DEFAULT NULL,
  `SeatNumber` varchar(5) DEFAULT NULL,
  `TravelClass` varchar(15) DEFAULT NULL,
  `BookingStatus` varchar(20) DEFAULT NULL,
  `DeletedAt` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;




-- table `crew`

CREATE TABLE `crew` (
  `CrewID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Position` varchar(30) NOT NULL,
  `LicenseNumber` varchar(20) NOT NULL,
  `EmploymentStatus` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- data for table `crew`


INSERT INTO `crew` (`CrewID`, `Name`, `Position`, `LicenseNumber`, `EmploymentStatus`) VALUES
(1, 'Karim Islam', 'Pilot', 'LIC1001', 'Active'),
(2, 'Nusrat Jahan', 'Co-Pilot', 'LIC1002', 'Active'),
(3, 'David Lee', 'Flight Attendant', 'LIC2001', 'Active'),
(4, 'Sara Khan', 'Flight Attendant', 'LIC2002', 'Active'),
(5, 'Tom Becker', 'Purser', 'LIC3001', 'Active');




--  table `flight`


CREATE TABLE `flight` (
  `FlightID` int(11) NOT NULL,
  `FlightNumber` varchar(10) NOT NULL,
  `DepartureAirportID` int(11) NOT NULL,
  `ArrivalAirportID` int(11) NOT NULL,
  `AircraftID` int(11) NOT NULL,
  `DepartureTime` datetime NOT NULL,
  `ArrivalTime` datetime NOT NULL,
  `FlightStatus` varchar(20) NOT NULL DEFAULT 'Scheduled'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


--  data for table `flight`

INSERT INTO `flight` (`FlightID`, `FlightNumber`, `DepartureAirportID`, `ArrivalAirportID`, `AircraftID`, `DepartureTime`, `ArrivalTime`, `FlightStatus`) VALUES
(1, 'BG147', 1, 4, 1, '2026-08-10 08:00:00', '2026-08-10 13:30:00', 'Scheduled'),
(2, 'BG201', 1, 3, 2, '2026-08-11 22:00:00', '2026-08-12 06:00:00', 'Scheduled'),
(3, 'EK586', 4, 1, 1, '2026-08-12 15:00:00', '2026-08-12 19:00:00', 'Scheduled'),
(4, 'SQ438', 5, 1, 4, '2026-08-13 08:00:00', '2026-08-13 14:00:00', 'Delayed'),
(5, 'BA204', 3, 2, 2, '2026-08-14 10:00:00', '2026-08-14 13:00:00', 'Scheduled'),
(6, 'BG150', 1, 4, 4, '2026-08-15 06:00:00', '2026-08-15 10:00:00', 'Cancelled');




-- table `flight_crew`


CREATE TABLE `flight_crew` (
  `FlightID` int(11) NOT NULL,
  `CrewID` int(11) NOT NULL,
  `RoleOnFlight` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- data for table `flight_crew`


INSERT INTO `flight_crew` (`FlightID`, `CrewID`, `RoleOnFlight`) VALUES
(1, 1, 'Pilot'),
(1, 2, 'Co-Pilot'),
(1, 3, 'Flight Attendant'),
(2, 1, 'Pilot'),
(2, 4, 'Flight Attendant'),
(3, 2, 'Pilot'),
(3, 5, 'Purser'),
(4, 1, 'Pilot'),
(4, 3, 'Flight Attendant'),
(5, 2, 'Pilot'),
(5, 4, 'Flight Attendant'),
(6, 1, 'Pilot');




-- table `passenger`


CREATE TABLE `passenger` (
  `PassengerID` int(11) NOT NULL,
  `FullName` varchar(100) NOT NULL,
  `PassportNumber` varchar(20) NOT NULL,
  `Nationality` varchar(50) NOT NULL,
  `PhoneNumber` varchar(15) DEFAULT NULL,
  `Email` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- data for table `passenger`


INSERT INTO `passenger` (`PassengerID`, `FullName`, `PassportNumber`, `Nationality`, `PhoneNumber`, `Email`) VALUES
(1, 'Abdur Rahman', 'BD1234567', 'Bangladeshi', '01711111111', 'abdur.rahman@example.com'),
(2, 'Fatima Noor', 'BD2233445', 'Bangladeshi', '01722222222', 'fatima.noor@example.com'),
(3, 'John Smith', 'US9988776', 'American', '12025550111', 'john.smith@example.com'),
(4, 'Rahman Ahmed Chowdhury', 'BD5544332', 'Bangladeshi', '01733333333', 'rahman.chowdhury@example.com'),
(5, 'Emily Clarke', 'GB1122334', 'British', '447911123456', 'emily.clarke@example.com'),
(6, 'Mohammed Al Farsi', 'AE7788990', 'Emirati', '971501234567', 'm.alfarsi@example.com'),
(7, 'Priya Sharma', 'IN6655443', 'Indian', '919876543210', 'priya.sharma@example.com'),
(8, 'Wei Chen', 'SG3344556', 'Singaporean', '6591234567', 'wei.chen@example.com');




--  table `payment`

CREATE TABLE `payment` (
  `PaymentID` int(11) NOT NULL,
  `BookingID` int(11) NOT NULL,
  `Amount` decimal(10,2) NOT NULL,
  `PaymentMethod` varchar(20) NOT NULL,
  `PaymentDate` date NOT NULL,
  `PaymentStatus` varchar(20) NOT NULL DEFAULT 'Pending',
  `Tax` decimal(10,2) DEFAULT 0.00,
  `Discount` decimal(10,2) DEFAULT 0.00,
  `Final_Amount` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- data for table `payment`

INSERT INTO `payment` (`PaymentID`, `BookingID`, `Amount`, `PaymentMethod`, `PaymentDate`, `PaymentStatus`, `Tax`, `Discount`, `Final_Amount`) VALUES
(1, 1, 450.00, 'Credit Card', '2026-08-01', 'Completed', 20.00, 10.00, 460.00),
(2, 2, 450.00, 'Debit Card', '2026-08-01', 'Completed', 15.00, 5.00, 460.00),
(3, 3, 1200.00, 'Credit Card', '2026-08-02', 'Completed', 0.00, 0.00, NULL),
(4, 4, 300.00, 'Cash', '2026-08-03', 'Completed', 0.00, 0.00, NULL),
(5, 5, 950.00, 'Credit Card', '2026-08-04', 'Completed', 0.00, 0.00, NULL),
(6, 6, 280.00, 'Credit Card', '2026-08-04', 'Completed', 0.00, 0.00, NULL),
(7, 7, 200.00, 'Credit Card', '2026-08-05', 'Refunded', 0.00, 0.00, NULL),
(8, 8, 1100.00, 'Bank Transfer', '2026-08-06', 'Completed', 0.00, 0.00, NULL);


-- Triggers `payment`

DELIMITER $$
CREATE TRIGGER `before_payment_update` BEFORE UPDATE ON `payment` FOR EACH ROW BEGIN
    SET NEW.Final_Amount = NEW.Amount + IFNULL(NEW.Tax, 0) - IFNULL(NEW.Discount, 0);
END
$$
DELIMITER ;




-- table `users`


CREATE TABLE `users` (
  `UserID` int(11) NOT NULL,
  `Username` varchar(50) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `PasswordHash` varchar(255) NOT NULL,
  `CreatedAt` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


--data for table `users`


INSERT INTO `users` (`UserID`, `Username`, `Email`, `PasswordHash`, `CreatedAt`) VALUES
(1, 'testuser', 'test1@gmail.com', '$2y$10$BrDLYVpCPJtIpH6jfjljde99tj4cFwtf5gLjgYfz5lfti3r/NenCq', '2026-08-04 15:36:34');


-- Indexes for  tables



-- Indexes for table `aircraft`

ALTER TABLE `aircraft`
  ADD PRIMARY KEY (`AircraftID`);

--
-- Indexes for table `airport`
--
ALTER TABLE `airport`
  ADD PRIMARY KEY (`AirportID`),
  ADD UNIQUE KEY `AirportCode` (`AirportCode`);

--
-- Indexes for table `booking`
--
ALTER TABLE `booking`
  ADD PRIMARY KEY (`BookingID`),
  ADD UNIQUE KEY `FlightID` (`FlightID`,`SeatNumber`),
  ADD KEY `PassengerID` (`PassengerID`);

--
-- Indexes for table `booking_log`
--
ALTER TABLE `booking_log`
  ADD PRIMARY KEY (`LogID`);

--
-- Indexes for table `crew`
--
ALTER TABLE `crew`
  ADD PRIMARY KEY (`CrewID`),
  ADD UNIQUE KEY `LicenseNumber` (`LicenseNumber`);

--
-- Indexes for table `flight`
--
ALTER TABLE `flight`
  ADD PRIMARY KEY (`FlightID`),
  ADD UNIQUE KEY `FlightNumber` (`FlightNumber`),
  ADD KEY `DepartureAirportID` (`DepartureAirportID`),
  ADD KEY `ArrivalAirportID` (`ArrivalAirportID`),
  ADD KEY `AircraftID` (`AircraftID`);

--
-- Indexes for table `flight_crew`
--
ALTER TABLE `flight_crew`
  ADD PRIMARY KEY (`FlightID`,`CrewID`),
  ADD KEY `CrewID` (`CrewID`);

--
-- Indexes for table `passenger`
--
ALTER TABLE `passenger`
  ADD PRIMARY KEY (`PassengerID`),
  ADD UNIQUE KEY `PassportNumber` (`PassportNumber`),
  ADD UNIQUE KEY `Email` (`Email`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`PaymentID`),
  ADD UNIQUE KEY `BookingID` (`BookingID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`UserID`),
  ADD UNIQUE KEY `Username` (`Username`),
  ADD UNIQUE KEY `Email` (`Email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `aircraft`
--
ALTER TABLE `aircraft`
  MODIFY `AircraftID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `airport`
--
ALTER TABLE `airport`
  MODIFY `AirportID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `booking`
--
ALTER TABLE `booking`
  MODIFY `BookingID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `booking_log`
--
ALTER TABLE `booking_log`
  MODIFY `LogID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crew`
--
ALTER TABLE `crew`
  MODIFY `CrewID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `flight`
--
ALTER TABLE `flight`
  MODIFY `FlightID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `passenger`
--
ALTER TABLE `passenger`
  MODIFY `PassengerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `payment`
--
ALTER TABLE `payment`
  MODIFY `PaymentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `booking`
--
ALTER TABLE `booking`
  ADD CONSTRAINT `booking_ibfk_1` FOREIGN KEY (`PassengerID`) REFERENCES `passenger` (`PassengerID`),
  ADD CONSTRAINT `booking_ibfk_2` FOREIGN KEY (`FlightID`) REFERENCES `flight` (`FlightID`);

--
-- Constraints for table `flight`
--
ALTER TABLE `flight`
  ADD CONSTRAINT `flight_ibfk_1` FOREIGN KEY (`DepartureAirportID`) REFERENCES `airport` (`AirportID`),
  ADD CONSTRAINT `flight_ibfk_2` FOREIGN KEY (`ArrivalAirportID`) REFERENCES `airport` (`AirportID`),
  ADD CONSTRAINT `flight_ibfk_3` FOREIGN KEY (`AircraftID`) REFERENCES `aircraft` (`AircraftID`);

--
-- Constraints for table `flight_crew`
--
ALTER TABLE `flight_crew`
  ADD CONSTRAINT `flight_crew_ibfk_1` FOREIGN KEY (`FlightID`) REFERENCES `flight` (`FlightID`),
  ADD CONSTRAINT `flight_crew_ibfk_2` FOREIGN KEY (`CrewID`) REFERENCES `crew` (`CrewID`);

--
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`BookingID`) REFERENCES `booking` (`BookingID`);
COMMIT;

