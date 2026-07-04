class_name Worker
extends Resource

enum Type { ADULT, RETIREE, CHILD }

var worker_name: String
var type: Worker.Type
var is_male: bool
var production: int
var lifetime: float
var inheritance: int
var age: float = 0.0

static func create(w_name: String, w_type: Worker.Type, w_is_male: bool) -> Worker:
	var w = Worker.new()
	w.worker_name = w_name
	w.type = w_type
	w.is_male = w_is_male
	match w_type:
		Worker.Type.ADULT:
			w.production = 2
			w.lifetime = 60.0
			w.inheritance = 30
		Worker.Type.RETIREE:
			w.production = 1
			w.lifetime = 30.0
			w.inheritance = 50
		Worker.Type.CHILD:
			w.production = 3
			w.lifetime = 20.0
			w.inheritance = 10
	return w
