<?php
session_start();
require 'db.php';
$error = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = trim($_POST['username']);
    $password = $_POST['password'];

    $stmt = $conn->prepare("SELECT UserID, Username, PasswordHash FROM USERS WHERE Username = ?");
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows == 1) {
        $user = $result->fetch_assoc();
        if (password_verify($password, $user['PasswordHash'])) {
            // Correct password — start the session
            $_SESSION['user_id'] = $user['UserID'];
            $_SESSION['username'] = $user['Username'];
            header("Location: flights.php");
            exit();
        } else {
            $error = "Incorrect username or password.";
        }
    } else {
        $error = "Incorrect username or password.";
    }
    $stmt->close();
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Login - Airline Reservation</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 400px; margin: 60px auto; }
        input { width: 100%; padding: 8px; margin: 6px 0; box-sizing: border-box; }
        button { width: 100%; padding: 10px; background: #1D5B8A; color: white; border: none; cursor: pointer; }
        .error { color: red; }
    </style>
</head>
<body>
    <h2>Login</h2>
    <?php if ($error) echo "<p class='error'>$error</p>"; ?>

    <form method="POST">
        <label>Username</label>
        <input type="text" name="username" required>
        <label>Password</label>
        <input type="password" name="password" required>
        <button type="submit">Login</button>
    </form>
    <p>Don't have an account? <a href="register.php">Register</a></p>
</body>
</html>