<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title></title>
</head>
<body>
	Hi
	<?php echo posix_getpwuid(posix_geteuid())['name']; ?>
</body>
</html>