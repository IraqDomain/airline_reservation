<?php
require 'db.php';
$error = "";
$success = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = trim($_POST['username']);
    $email = trim($_POST['email']);
    $password = $_POST['password'];

    // Check if username or email already exists
    $check = $conn->prepare("SELECT UserID FROM USERS WHERE Username = ? OR Email = ?");
    $check->bind_param("ss", $username, $email);
    $check->execute();
    $result = $check->get_result();

    if ($result->num_rows > 0) {
        $error = "Username or email already taken.";
    } else {
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        $stmt = $conn->prepare("INSERT INTO USERS (Username, Email, PasswordHash) VALUES (?, ?, ?)");
        $stmt->bind_param("sss", $username, $email, $hashedPassword);

        if ($stmt->execute()) {
            $success = "Account created! You can now log in.";
        } else {
            $error = "Something went wrong. Please try again.";
        }
        $stmt->close();
    }
    $check->close();
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Register - Airline Reservation</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 400px; margin: 60px auto; }
        input { width: 100%; padding: 8px; margin: 6px 0; box-sizing: border-box; }
        button { width: 100%; padding: 10px; background: #1D5B8A; color: white; border: none; cursor: pointer; }
        .error { color: red; }
        .success { color: green; }
    </style>
</head>
<body>
    <h2>Create an Account</h2>
    <?php if ($error) echo "<p class='error'>$error</p>"; ?>
    <?php if ($success) echo "<p class='success'>$success</p>"; ?>

    <form method="POST">
        <label>Username</label>
        <input type="text" name="username" required>
        <label>Email</label>
        <input type="email" name="email" required>
        <label>Password</label>
        <input type="password" name="password" required minlength="6">
        <button type="submit">Register</button>
    </form>
    <p>Already have an account? <a href="login.php">Log in</a></p>
</body>
</html>