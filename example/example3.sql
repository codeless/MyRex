SELECT 	r_id AS "ID",
	DATE_FORMAT(r_datetime, "%D %b %y, %r") AS "Date/Time",
	r_value AS "Value",
	"äöüß" AS "Special Chars"
	FROM critical_records
	ORDER BY r_datetime ASC;
