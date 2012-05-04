SELECT 	CONCAT("ID: ", r_id, "
Date/time: ", DATE_FORMAT(r_datetime, "%D %b %y, %r"), "
Value: ", r_value, "
") AS ""
	FROM critical_records
	ORDER BY r_datetime ASC;
