<?php  

  // From a travelog website that enabled users to upload photos. This page processed the uploaded images, saved them on the server and updated the database with a record of the image.

  // Check cookie against session variable for basic security authentication

  $value = $_COOKIE['traveLog'];
  $check = $_SESSION['secureCheck'];
  
  if($value==$check) {
  
  setcookie("travel", $value, time()+3600);  // resets the timeout
  
  // Upload file from the form

	$uploadDir = '/home/jjwtoad/public_html/travelog/images/' . $_SESSION['userImgFolder'];
	$uploadFile = $uploadDir . $_FILES['userfile']['name'];
	$im = $_FILES['userfile']['name'];
	if (move_uploaded_file($_FILES['userfile']['tmp_name'], $uploadFile))
	{
		$status = "File is valid, and was successfully uploaded.";
	}
	else
	{
		$status = "Possible file upload attack! Error... File may be too large.";
	}
		
	$imname = $_FILES['userfile']['name'];
	$imdim = $uploadDir . $im;

	$imgname = $uploadDir . $name;

	$im = imagecreatefromjpeg($imdim);
	$mywidth = imagesx($im) ; 
	$myheight = imagesy($im) ;
	
	$thumb_width = 50; // width for the thumbnail image... here 50 pixel 
	$thumb_height = ($thumb_width * $myheight) / $mywidth ; // get the appropriate height
	$large_width = 800; // width for the large image... here 800 pixel 
	$large_height = ($large_width * $myheight) / $mywidth ; // get the appropriate height
	
	$canvas = ImageCreatetruecolor($large_width,$large_height); // creation of a canvas ready for the large image
	imagecopyresized($canvas,$im,0,0,0,0,$large_width,$large_height,$mywidth,$myheight); // thumb is now created on the white canvas
	ImageJPEG($thumb, $imgname."_large.jpg"); // gives the MIME type to the file (jpeg) and adds _large.jpg to the file name.
	
	$canvas = ImageCreatetruecolor($thumb_width,$thumb_height); // creation of a canvas ready for the thumbnail
	imagecopyresized($canvas,$im,0,0,0,0,$thumb_width,$thumb_height,$mywidth,$myheight); // thumb is now created on the white canvas
	ImageJPEG($thumb, $imgname."_thumb.jpg"); // gives the MIME type to the file (jpeg) and adds _thumb.jpg to the file name.
	
	ImageDestroy ($im);  // destroy the original uploaded file
	ImageDestroy ($canvas);  // destroy the canvas file
	
	$file = '/home/jjwtoad/public_html/travelog/images/'.$imname;
	if(isset($file)){  
		unlink($file);  
	} else { redirect("upload_failed.php");  // uploaded file failed to be unlinked properly } 
	
	// Save information about the image file to the images table in the mySQL database
		
	  $db = mysql_connect("localhost",$_SESSION['dbUser'],$_SESSION['dbPass']) or die("Connection Failure to Database");
	
	  mysql_select_db("jjwtoad_diary",$db) or die ($db . " Database not found.");	
		
	  $sql = "INSERT INTO images(userID,filename,imgtext,width,height,location,date) VALUES ('$id','$name','$imgtext','$new_width','$new_height','$imglocation','$imgdate')"; 
	  $result=mysql_query($sql);
	  	  
?>

<?php  include("header.php");  // page header including all HTML code ?>

<div class="mainPage"> 

	<p class="msgAlert">Upload successful ... you may now upload another image if you wish.</p>
    
	<?php  include("uploadForm.php");  // upload form to allow user to upload another image to their diary ?>

</div>
<div class="imageGallery"> 

	<?php  include("imageGallery.php");  // page header including all HTML code  ?>
    
</div>
	  
<?php  include("footer.php");  // page footer including all HTML code ?>

<?php } else { redirect("expired.php"); }  // redirects user to expired page if the basic authentication is not passed ?>