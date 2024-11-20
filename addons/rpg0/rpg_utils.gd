class_name RpgUtils extends Object

static func interpolate_formatted_string(str: String, obj: Object) -> String:
	var interpolated = str
	
	# Regex pattern to match {expression}, where expression can be a property or a method (with or without args)
	var regex = RegEx.new()
	regex.compile(r"\{([^{}]+)\}")
	
	var matches = regex.search_all(str)
	
	for m in matches:
		var placeholder = m.get_string()  # {expression}
		var expression = m.get_string(1)  # expression
		
		var exp = Expression.new()
		var error = exp.parse(expression)
		if error != OK:
			assert(false, "Invalid expression %s found when interpolating string %s" % [expression, str])
			return str
		var result = exp.execute([], obj)
		assert(!exp.has_execute_failed(), "Evaluation of expression %s failed when interpolating string %s" % [expression, str])
		interpolated = interpolated.replace(placeholder, str(result))
	
	return interpolated
