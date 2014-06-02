debug = (x) ->
	alert x
	console.log x
pass = undefined
RGBToHex = (rgb) ->
	hex = [
		rgb.r.toString 16
		rgb.g.toString 16
		rgb.b.toString 16
	]
	for val, i in hex
		if val.length == 1
			hex[i] = "0#{val}"
	hex.join ''
