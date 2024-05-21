<?php include '_dotenv.php'; ?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CNV - Project A</title>
    <!-- Load Bootstrap 5.3 CSS from a local copy -->
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/site.css">
</head>
<body class="d-flex flex-column">
    <?php include 'partials/navbar.php'; ?>

    <!-- Begin page content -->
    <main class="flex-shrink-0">
        <div class="container">
            <h1 class="mt-5">WebSockets Example</h1>

            <div class="container py-4">
                <div class="alert alert-warning alert-dismissible fade show" role="alert" id="statusDiv">
                    Connecting to the WebSockets server...
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                
                <!-- Container for displaying messages -->
                <div class="notifications" id="notificationDiv"></div>

                <!-- Form to send messages -->
                <form id="messageForm">
                    <div class="mb-3 d-flex">
                        <input type="text" id="messageInput" class="form-control me-2" placeholder="Enter a message">
                        <button type="submit" class="btn btn-primary">Send</button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <?php include 'partials/footer.php'; ?>

    <!-- Load Bootstrap 5.3 JS from a local copy -->
    <script src="js/bootstrap.bundle.min.js"></script>
    <!-- Load WebSocket script -->
    <script>
        const ws_uri = "<?php echo 'ws://' . $ws_host . ':' . $ws_port; ?>";
    </script>
    <script src="js/websockets.js" defer></script>
</body>
</html>
