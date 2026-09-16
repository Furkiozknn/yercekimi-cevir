extends Node
## Gelistirici araci: oyunu penceresiz sekilde surer, girdiyi kod uzerinden basar,
## belirli anlarda ekran goruntusu kaydeder. Pencere odagi gerekmez.
##   godot --path . res://tests/ekran.tscn -- <bolum_indeksi> <cikti_klasoru>

const OYUN := preload("res://scenes/oyun.tscn")

var _klasor: String = "user://ekran"
var _sira: int = 0
var _oyun: Node2D


func _ready() -> void:
	var argumanlar := OS.get_cmdline_user_args()
	var bolum := int(argumanlar[0]) if argumanlar.size() > 0 else 0
	if argumanlar.size() > 1:
		_klasor = argumanlar[1]
	DirAccess.make_dir_recursive_absolute(_klasor)

	Ayarlar.sifirla()
	Ayarlar.acilan_bolum = Ayarlar.bolum_sayisi() - 1
	if bolum < 0:
		await _menu_cek()
		get_tree().quit(0)
		return
	Ayarlar.secilen_bolum = bolum
	_oyun = OYUN.instantiate()
	add_child(_oyun)

	await _bekle(0.6)
	await _cek("basla")
	Input.action_press("move_right")
	await _bekle(1.1)
	await _cek("yuruyor")
	Input.action_press("cevir")
	await _bekle(0.05)
	Input.action_release("cevir")
	await _bekle(0.35)
	await _cek("cevirdi")
	await _bekle(0.8)
	await _cek("tavanda")
	Input.action_release("move_right")
	await _bekle(0.4)
	await _cek("son")
	get_tree().quit(0)


func _bekle(sn: float) -> void:
	await get_tree().create_timer(sn).timeout


func _cek(ad: String) -> void:
	await RenderingServer.frame_post_draw
	var gorsel := get_viewport().get_texture().get_image()
	_sira += 1
	var yol := "%s/%02d-%s.png" % [_klasor, _sira, ad]
	var hata := gorsel.save_png(yol)
	print("ekran: ", yol, " -> ", hata)


## bolum indeksi -1 verilirse menu ve bolum sec ekranlari cekilir.
func _menu_cek() -> void:
	Ayarlar.acilan_bolum = 5
	var menu: Control = load("res://scenes/menu.tscn").instantiate()
	add_child(menu)
	await _bekle(0.5)
	await _cek("menu")
	menu.queue_free()
	await _bekle(0.3)
	var sec: Control = load("res://scenes/bolum_sec.tscn").instantiate()
	add_child(sec)
	await _bekle(0.5)
	await _cek("bolum-sec")
