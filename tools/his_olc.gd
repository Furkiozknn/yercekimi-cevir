extends Node
## Cevirme girdi gecikmesi olcumu: tus basisindan `cevirdi` sinyaline (yani
## yercekimi isaretinin gercekten donmesine) gecen sure. Gercek zamanli kosar
## (--fixed-fps YOK): fizik 60 Hz oldugu icin beklenen dagilim 0-16,7 ms'dir.
##   godot --headless --path . res://tools/his_olc.tscn -- [deneme_sayisi]
## Her denemede basis, fizik adimina gore rastgele bir fazda yapilir. Sonuc
## docs/TASARIM.md'de: ortalama, %95, en yuksek.

const OYUNCU := preload("res://scenes/oyuncu.tscn")

var _t0: int = 0
var _olculer: Array[float] = []


func _ready() -> void:
	var n := 60
	var arg := OS.get_cmdline_user_args()
	if arg.size() > 0:
		n = int(arg[0])
	_kos(n)


func _kos(n: int) -> void:
	var b := Bolum.new()
	add_child(b)
	b.kur(Bolumler.BOLUMLER[0])
	var o: CharacterBody2D = OYUNCU.instantiate()
	add_child(o)
	o.girdi_acik = true
	o.hazirla(b.baslangic)
	o.cevirdi.connect(func(_y: float) -> void:
		if _t0 > 0:
			_olculer.append(float(Time.get_ticks_usec() - _t0) / 1000.0)
			_t0 = 0)
	await get_tree().create_timer(0.5).timeout
	var i := 0
	while i < n:
		# yuzeye oturana kadar bekle
		var bekle := 0
		while not o.is_on_floor() and bekle < 200:
			await get_tree().physics_frame
			bekle += 1
		await get_tree().create_timer(0.05 + randf() * 0.0167).timeout    # rastgele faz
		_t0 = Time.get_ticks_usec()
		# Gercek klavye gibi: olay dugumlere _input ile ulasir (action_press ulastirmaz).
		var ev := InputEventAction.new()
		ev.action = &"cevir"
		ev.pressed = true
		Input.parse_input_event(ev)
		var kalan := 0
		while _t0 > 0 and kalan < 60:
			await get_tree().process_frame
			kalan += 1
		var birak := InputEventAction.new()
		birak.action = &"cevir"
		birak.pressed = false
		Input.parse_input_event(birak)
		await get_tree().create_timer(0.35).timeout
		i += 1
	_olculer.sort()
	var top := 0.0
	for x in _olculer:
		top += x
	print("HIS_OLCUM deneme=%d ort_ms=%.1f p95_ms=%.1f en_yuksek_ms=%.1f en_dusuk_ms=%.1f" % [
		_olculer.size(), top / maxf(_olculer.size(), 1.0),
		_olculer[int(_olculer.size() * 0.95)], _olculer[_olculer.size() - 1], _olculer[0]])
	get_tree().quit(0)
