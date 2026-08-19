<?php
session_start();
require 'db.php';

// Block access if not logged in
if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit();
}

$error = "";
$success = "";

// ---- DELETE ----
if (isset($_GET['delete'])) {
    $id = (int)$_GET['delete'];
    $stmt = $conn->prepare("DELETE FROM FLIGHT WHERE FlightID = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $stmt->close();
    header("Location: flights.php");
    exit();
}

// ---- CREATE or UPDATE ----
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $flightNumber = trim($_POST['flight_number']);
    $departureAirport = (int)$_POST['departure_airport'];
    $arrivalAirport = (int)$_POST['arrival_airport'];
    $aircraftId = (int)$_POST['aircraft_id'];
    $departureTime = $_POST['departure_time'];
    $arrivalTime = $_POST['arrival_time'];
    $status = $_POST['status'];

    if ($departureAirport == $arrivalAirport) {
        $error = "Departure and arrival airport cannot be the same.";
    } else {
        if (!empty($_POST['flight_id'])) {
            // UPDATE existing flight
            $flightId = (int)$_POST['flight_id'];
            $stmt = $conn->prepare("UPDATE FLIGHT SET FlightNumber=?, DepartureAirportID=?, ArrivalAirportID=?, AircraftID=?, DepartureTime=?, ArrivalTime=?, FlightStatus=? WHERE FlightID=?");
            $stmt->bind_param("siiisssi", $flightNumber, $departureAirport, $arrivalAirport, $aircraftId, $departureTime, $arrivalTime, $status, $flightId);
            $stmt->execute();
            $stmt->close();
            $success = "Flight updated successfully.";
        } else {
            // CREATE new flight
            $stmt = $conn->prepare("INSERT INTO FLIGHT (FlightNumber, DepartureAirportID, ArrivalAirportID, AircraftID, DepartureTime, ArrivalTime, FlightStatus) VALUES (?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("siiisss", $flightNumber, $departureAirport, $arrivalAirport, $aircraftId, $departureTime, $arrivalTime, $status);
            $stmt->execute();
            $stmt->close();
            $success = "Flight added successfully.";
        }
    }
}

// ---- Data for the edit form (if editing) ----
$editFlight = null;
if (isset($_GET['edit'])) {
    $id = (int)$_GET['edit'];
    $stmt = $conn->prepare("SELECT * FROM FLIGHT WHERE FlightID = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $editFlight = $stmt->get_result()->fetch_assoc();
    $stmt->close();
}

// ---- READ: all flights, joined with airport/aircraft names for readability ----
$flights = $conn->query("
    SELECT F.FlightID, F.FlightNumber, DEP.AirportName AS DepName, ARR.AirportName AS ArrName,
           A.Model, F.DepartureTime, F.ArrivalTime, F.FlightStatus
    FROM FLIGHT F
    JOIN AIRPORT DEP ON F.DepartureAirportID = DEP.AirportID
    JOIN AIRPORT ARR ON F.ArrivalAirportID = ARR.AirportID
    JOIN AIRCRAFT A ON F.AircraftID = A.AircraftID
    ORDER BY F.FlightID
");

// Dropdown data
$airports = $conn->query("SELECT AirportID, AirportName FROM AIRPORT ORDER BY AirportName");
$aircraftList = $conn->query("SELECT AircraftID, Model FROM AIRCRAFT ORDER BY Model");
?>
<!DOCTYPE html>
<html>
<head>
    <title>Flight Management</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 950px; margin: 30px auto; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: left; font-size: 14px; }
        th { background: #1D5B8A; color: white; }
        form.flight-form input, form.flight-form select { padding: 6px; margin: 4px 0; width: 100%; box-sizing: border-box; }
        form.flight-form { border: 1px solid #ccc; padding: 15px; border-radius: 6px; background: #f7f7f7; }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
        button { padding: 8px 14px; background: #1D5B8A; color: white; border: none; cursor: pointer; margin-top: 8px; }
        .error { color: red; } .success { color: green; }
        a.action { margin-right: 8px; }
        .topbar { display: flex; justify-content: space-between; align-items: center; }
    </style>
</head>
<body>
    <div class="topbar">
        <h2>Flight Management</h2>
        <div>Logged in as <b><?php echo htmlspecialchars($_SESSION['username']); ?></b> | <a href="logout.php">Logout</a></div>
    </div>

    <?php if ($error) echo "<p class='error'>$error</p>"; ?>
    <?php if ($success) echo "<p class='success'>$success</p>"; ?>

    <h3><?php echo $editFlight ? "Edit Flight" : "Add New Flight"; ?></h3>
    <form class="flight-form" method="POST">
        <?php if ($editFlight): ?>
            <input type="hidden" name="flight_id" value="<?php echo $editFlight['FlightID']; ?>">
        <?php endif; ?>
        <div class="grid">
            <div>
                <label>Flight Number</label>
                <input type="text" name="flight_number" required
                       value="<?php echo $editFlight ? htmlspecialchars($editFlight['FlightNumber']) : ''; ?>">
            </div>
            <div>
                <label>Status</label>
                <select name="status">
                    <?php foreach (['Scheduled','Delayed','Cancelled','Departed','Arrived'] as $st): ?>
                        <option value="<?php echo $st; ?>" <?php echo ($editFlight && $editFlight['FlightStatus']==$st) ? 'selected' : ''; ?>><?php echo $st; ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div>
                <label>Departure Airport</label>
                <select name="departure_airport" required>
                    <?php $airports->data_seek(0); while ($a = $airports->fetch_assoc()): ?>
                        <option value="<?php echo $a['AirportID']; ?>" <?php echo ($editFlight && $editFlight['DepartureAirportID']==$a['AirportID']) ? 'selected' : ''; ?>>
                            <?php echo htmlspecialchars($a['AirportName']); ?>
                        </option>
                    <?php endwhile; ?>
                </select>
            </div>
            <div>
                <label>Arrival Airport</label>
                <select name="arrival_airport" required>
                    <?php $airports->data_seek(0); while ($a = $airports->fetch_assoc()): ?>
                        <option value="<?php echo $a['AirportID']; ?>" <?php echo ($editFlight && $editFlight['ArrivalAirportID']==$a['AirportID']) ? 'selected' : ''; ?>>
                            <?php echo htmlspecialchars($a['AirportName']); ?>
                        </option>
                    <?php endwhile; ?>
                </select>
            </div>
            <div>
                <label>Aircraft</label>
                <select name="aircraft_id" required>
                    <?php $aircraftList->data_seek(0); while ($a = $aircraftList->fetch_assoc()): ?>
                        <option value="<?php echo $a['AircraftID']; ?>" <?php echo ($editFlight && $editFlight['AircraftID']==$a['AircraftID']) ? 'selected' : ''; ?>>
                            <?php echo htmlspecialchars($a['Model']); ?>
                        </option>
                    <?php endwhile; ?>
                </select>
            </div>
            <div></div>
            <div>
                <label>Departure Time</label>
                <input type="datetime-local" name="departure_time" required
                       value="<?php echo $editFlight ? date('Y-m-d\TH:i', strtotime($editFlight['DepartureTime'])) : ''; ?>">
            </div>
            <div>
                <label>Arrival Time</label>
                <input type="datetime-local" name="arrival_time" required
                       value="<?php echo $editFlight ? date('Y-m-d\TH:i', strtotime($editFlight['ArrivalTime'])) : ''; ?>">
            </div>
        </div>
        <button type="submit"><?php echo $editFlight ? "Update Flight" : "Add Flight"; ?></button>
        <?php if ($editFlight): ?> <a href="flights.php">Cancel</a> <?php endif; ?>
    </form>

    <h3>All Flights</h3>
    <table>
        <tr>
            <th>Flight #</th><th>From</th><th>To</th><th>Aircraft</th>
            <th>Departure</th><th>Arrival</th><th>Status</th><th>Actions</th>
        </tr>
        <?php while ($f = $flights->fetch_assoc()): ?>
        <tr>
            <td><?php echo htmlspecialchars($f['FlightNumber']); ?></td>
            <td><?php echo htmlspecialchars($f['DepName']); ?></td>
            <td><?php echo htmlspecialchars($f['ArrName']); ?></td>
            <td><?php echo htmlspecialchars($f['Model']); ?></td>
            <td><?php echo $f['DepartureTime']; ?></td>
            <td><?php echo $f['ArrivalTime']; ?></td>
            <td><?php echo htmlspecialchars($f['FlightStatus']); ?></td>
            <td>
                <a class="action" href="flights.php?edit=<?php echo $f['FlightID']; ?>">Edit</a>
                <a class="action" href="flights.php?delete=<?php echo $f['FlightID']; ?>" onclick="return confirm('Delete this flight?');">Delete</a>
            </td>
        </tr>
        <?php endwhile; ?>
    </table>
</body>
</html>