<?php
include '_dotenv.php';

// Function to handle file upload
function handleFileUpload($uploadDir)
{
    if (isset($_POST['submit'])) {
        // Check if the upload directory exists, otherwise create it
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir);
        }

        $fileName = basename($_FILES['image']['name']);
        $targetPath = $uploadDir . $fileName;
        $fileType = pathinfo($targetPath, PATHINFO_EXTENSION);

        // Check if the uploaded file is a JPG image
        if ($fileType === 'jpg' || $fileType === 'jpeg') {
            if (move_uploaded_file($_FILES['image']['tmp_name'], $targetPath)) {
                return '<div class="alert alert-success">Image uploaded successfully!</div>';
            } else {
                return '<div class="alert alert-danger">Sorry, there was an error uploading your file.</div>';
            }
        } else {
            return '<div class="alert alert-danger">Please upload a JPG image.</div>';
        }
    }
}

// Function to handle clear gallery button click
function handleClearGallery($imageDir)
{
    if (isset($_POST['clear'])) {
        // Validate the image directory path to prevent accidental deletion of system files
        if (strpos(realpath($imageDir), realpath(__DIR__)) === 0) {
            $images = glob($imageDir . '*.jpg');

            foreach ($images as $image) {
                unlink($image); // Delete each image file
            }

            return '<div class="alert alert-success">Gallery cleared successfully!</div>';
        } else {
            return '<div class="alert alert-danger">Invalid operation!</div>';
        }
    }
}

// Function to delete an individual image
function deleteImage($imagePath)
{
    if (isset($_POST['delete'])) {
        // Validate the image path to prevent accidental deletion of system files
        if (strpos(realpath($imagePath), realpath(__DIR__)) === 0) {
            unlink($imagePath); // Delete the image file
            return '<div class="alert alert-success">Image deleted successfully!</div>';
        } else {
            return '<div class="alert alert-danger">Invalid operation!</div>';
        }
    }
}

$imageDir = 'gallery/';
$uploadDir = 'gallery/';

// Call functions to handle file upload, delete image, and clear gallery
$uploadMessage = handleFileUpload($uploadDir);
$clearMessage = handleClearGallery($imageDir);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CNV - Project A</title>
    <!-- Load Bootstrap 5.3 CSS from a local copy -->
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <!-- Load custom CSS -->
    <link rel="stylesheet" href="css/site.css">
</head>
<body class="d-flex flex-column">
    <?php include 'partials/navbar.php'; ?>

    <!-- Begin page content -->
    <main class="flex-shrink-0">
        <div class="container mt-5">
            <h1 class="text-center">Image Upload</h1>

            <!-- Display upload, clear gallery, and delete image messages -->
            <?php echo $uploadMessage; ?>
            <?php echo $clearMessage; ?>
            <?php echo isset($_POST['delete']) ? deleteImage($_POST['delete']) : ''; ?>

            <div class="row">
                <div class="col-md-6">
                    <!-- Display file upload form -->
                    <form method="POST" enctype="multipart/form-data">
                        <div class="input-group mb-3">
                            <input type="file" class="form-control" name="image" accept=".jpg, .jpeg">
                            <button type="submit" class="btn btn-primary" name="submit">Upload</button>
                        </div>
                    </form>
                </div>
                <div class="col-md-6">
                    <!-- Display clear gallery button -->
                    <form method="POST">
                        <div class="form-group mt-md-4">
                            <button type="submit" class="btn btn-danger" name="clear">Clear Gallery</button>
                        </div>
                    </form>
                </div>
            </div>

            <hr>

            <!-- Display image gallery with delete buttons -->
            <div class="row">
                <?php
                $images = glob($imageDir . '*.jpg');
                foreach ($images as $image) {
                    echo '<div class="col-md-4 mb-3">';
                    echo '<img src="' . $image . '" class="img-fluid">';
                    echo '<form method="POST" class="mt-2">';
                    echo '<input type="hidden" name="delete" value="' . $image . '">';
                    echo '<button type="submit" class="btn btn-danger btn-sm">Delete</button>';
                    echo '</form>';
                    echo '</div>';
                }
                ?>
            </div>
        </div>
    </main>
    <?php include 'partials/footer.php'; ?>
    <!-- Load Bootstrap 5.3 JS from a local copy -->
    <script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>
