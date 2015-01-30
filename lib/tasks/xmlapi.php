<?php
error_reporting(E_ALL);

$punkt 	= isset($_GET['point']) ? $_GET['point'] : "";
$krets 	= isset($_GET['start']) ? $_GET['start'] : "";

$krets 	= isset($_GET['krets']) ? $_GET['krets'] : $krets;


require_once("common.php");
require_once("functions/orthodrom.php");

$mysqli = new mysqli( DB_HOST, DB_USER, DB_PASS, DB_DBNAME);
if ($mysqli->connect_errno) {
	if ($mysqli->connect_errno == 1040)
	die('Database connect error: '. $mysqli->connect_error.
		"<br /><br />Databasen är överbelastad. Försök igen senare");
} 

//$mysqli->query("SET NAMES 'utf8'");

$out = "<?xml version='1.0' encoding='ISO-8859-1'?>";

$out .= "<PoD>";

if (isset($_GET['point'])) {
	$lat1 = "";
	$long1 ="";
	$query = "SELECT Punktnamn, Punktdefinition, Latitud, Longitud ";
	$query .= "FROM Punkter WHERE Punkt={$punkt}";
	if ($result = $mysqli->query($query)) {
		while($row = $result->fetch_row()) {
			$out .= "<punkt><nummer>{$punkt}</nummer>";
			$out .= "<namn>{$row[0]}</namn>";
			$out .= "<definition>". htmlspecialchars($row[1])."</definition>";
			$out .= "<lat>{$row[2]}</lat>";
			$out .= "<long>{$row[3]}</long>";
			$out .= "</punkt>";
			$lat1 = $row[2];
			$long1 = $row[3];
		}
		$result->close();
	}
	
	$out .= "<tillpunkter>";
	$query = "SELECT `ToPoint`,Punktnamn, `Latitud`,`Longitud`, `Distance` FROM ";
	$query .= "Punkter,`Distances` WHERE FromPoint={$punkt} and Punkt=ToPoint";
	if ($result = $mysqli->query($query)) {
		while($row = $result->fetch_row()) {
			$distans = is_null($row[4])?distance($lat1, $long1, $row[2], $row[3]):$row[4];
			$out .= "<punkt><nummer>{$row[0]}</nummer>";
			$out .= "<punktnamn>{$row[1]}</punktnamn>";
			$out .= "<distans>{$distans}</distans></punkt>";
		}
		$out .= "</tillpunkter>";
		$result->close();
	} else {
		echo $query;
	}
}

if (strlen($krets)>0) {
	$query = "SELECT Punkter.Punkt, Punktnamn FROM Punkter, Urval ";
	$query .= "WHERE Punkter.Punkt=Urval.Punkt AND Urval.Krets='{$krets}' and startpunkt=1";
	if ($result = $mysqli->query($query)) {
		//echo "Antal startpunkter: ".$result->num_rows."\n";
		$out .= "<startpunkter>";
		while ($row = $result->fetch_row()) {
			$out .= "<startpunkt><nummer>{$row[0]}</nummer><punktnamn>{$row[1]}</punktnamn></startpunkt>";
		}
		$out .= "</startpunkter>";
	} else {
		echo $query;
	}
}

$out .= "</PoD>";

$mysqli->close();

header("Content-type: text/xml");
echo $out;
?>