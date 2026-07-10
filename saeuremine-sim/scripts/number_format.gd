class_name NumberFormat
extends RefCounted

# Formatiert große Zahlen mit Tausenderpunkten: 12345 -> "12.345"
static func with_dots(n: int) -> String:
	var s = str(abs(n))
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "." + result
	if n < 0:
		result = "-" + result
	return result
