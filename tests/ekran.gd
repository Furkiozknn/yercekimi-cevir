extends Node
## Gelistirici araci: oyunu penceresiz sekilde surer, girdiyi kod uzerinden basar,
## belirli anlarda ekran goruntusu kaydeder. Pencere odagi gerekmez.
##
##   godot --path . res://tests/ekran.tscn -- <mod> <cikti_klasoru>
##     <mod> >= 0  : o bolumu oyna, oynanis kareleri cek
##     <mod> = -1  : menu + bolum sec ekranlari
##     <mod> = -2  : yayin paketi (yayin/ altina 4 ekran goruntusu + kapak 630x500)
##
## Yakalanan kareler 1280x720 (pencere boyutu). Kapak bu kareden 630x500
## kirpilarak uretilir — itch.io kapak olcusu.

const OYUN := preload("res://scenes/oyun.tscn")
## Kapak, 1280x720 karesinin oyuncuyu ve zemini iceren bolgesinden kirpilir.
const KAPAK_ALANI := Rect2i(120, 220, 630, 500)

var _klasor: String = "user://ekran"
var _sira: int = 0
var _oyun: Node2D


func _ready() -> void:
	var argumanlar := OS.get_cmdline_user_args()
	var mod := int(argumanlar[0]) if argumanlar.size() > 0 else 0
	if argumanlar.size() > 1:
		_klasor = argumanlar[1]
	DirAccess.make_dir_recursive_absolute(_klasor)

	Ayarlar.sifirla()
	Ayarlar.acilan_bolum = Ayarlar.bolum_sayisi() - 1
	if mod == -1:
		await _menu_cek()
	elif mod == -2:
		await _yayin_cek()
	else:
		await _oynanis_cek(mod)
	get_tree().quit(0)


func _bekle(sn: float) -> void:
	await get_tree().create_timer(sn).timeout


func _cek(ad: String, alan: Rect2i = Rect2i()) -> void:
	await RenderingServer.frame_post_draw
	var gorsel := get_viewport().get_texture().get_image()
	if alan.size.x > 0:
		gorsel = gorsel.get_region(alan)
	_sira += 1
	var yol := "%s/%02d-%s.png" % [_klasor, _sira, ad]
	var hata := gorsel.save_png(yol)
	print("ekran: %s  %dx%d  -> %d" % [yol, gorsel.get_width(), gorsel.get_height(), hata])


## Bolum Sec ekrani dolu gorunsun diye sahte ilerleme (diske YAZILMAZ).
func _sahte_ilerleme() -> void:
	for i in Ayarlar.bolum_sayisi():
		if i % 3 != 2:
			Ayarlar.kristal[i] = true
		Ayarlar.en_iyi[i] = float(Ayarlar.bolum(i)["gumus"]) - 0.4 - i * 0.05
		Ayarlar.madalya[i] = 3 if i % 4 == 0 else (2 if i % 4 != 3 else 1)


func _oyunu_ac(bolum: int) -> void:
	Ayarlar.secilen_bolum = bolum
	_oyun = OYUN.instantiate()
	add_child(_oyun)
	await _bekle(0.6)


func _oynanis_cek(bolum: int) -> void:
	await _oyunu_ac(bolum)
	await _cek("basla")
	Input.action_press("move_right")
	await _bekle(1.1)
	await _cek("yuruyor")
	Input.action_press("cevir")
	await _bekle(0.05)
	Input.action_release("cevir")
	await _bekle(0.2)
	await _cek("cevirdi")
	await _bekle(0.9)
	await _cek("tavanda")
	Input.action_release("move_right")
	await _bekle(0.4)
	await _cek("son")


## mod -1: menu ve bolum sec.
func _menu_cek() -> void:
	_sahte_ilerleme()
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
	sec.queue_free()
	await _bekle(0.3)
	var ayar: Control = load("res://scenes/ayarlar_ekrani.tscn").instantiate()
	add_child(ayar)
	await _bekle(0.5)
	await _cek("ayarlar")


## mod -2: itch.io icin 4 ekran goruntusu + kapak.
## Bolum secimi kasitli: 16. bolum (yogun diken deseni) zeminde kosarken
## olumcul degil, 3. bolum ise cevirme + tavan yurusu icin guvenli.
func _yayin_cek() -> void:
	_sahte_ilerleme()
	var menu: Control = load("res://scenes/menu.tscn").instantiate()
	add_child(menu)
	await _bekle(0.6)
	await _cek("menu")
	menu.queue_free()
	await _bekle(0.3)

	await _oyunu_ac(15)                       # 16 — Kilcik
	Input.action_press("move_right")
	await _bekle(0.9)
	await _cek("oynanis")

	# kapak: HUD kapatilir, buyuk baslik konur, 630x500 kirpilir
	_oyun.get_node("Arayuz").visible = false
	var yazi := _kapak_yazisi()
	add_child(yazi)
	await _bekle(0.25)
	await _cek("kapak-630x500", KAPAK_ALANI)
	Input.action_release("move_right")
	yazi.queue_free()
	_oyun.queue_free()
	await _bekle(0.3)

	await _oyunu_ac(2)                        # 3 — Tavan Yolu
	Input.action_press("move_right")
	await _bekle(0.85)
	Input.action_press("cevir")
	await _bekle(0.05)
	Input.action_release("cevir")
	await _bekle(0.2)
	await _cek("cevirme")
	await _bekle(0.9)
	await _cek("tavan")
	Input.action_release("move_right")


func _kapak_yazisi() -> CanvasLayer:
	var kat := CanvasLayer.new()
	kat.layer = 15
	var golge := ColorRect.new()
	golge.color = Color(0.02, 0.02, 0.05, 0.45)
	# Kirpma alani mantiksal x 60..375'e denk geliyor; yazi buraya sigmali.
	golge.offset_left = 66.0
	golge.offset_top = 123.0
	golge.offset_right = 370.0
	golge.offset_bottom = 207.0
	kat.add_child(golge)
	var baslik := Label.new()
	baslik.text = "YERÇEKİMİ\nÇEVİR"
	baslik.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	baslik.offset_left = 66.0
	baslik.offset_top = 125.0
	baslik.offset_right = 370.0
	baslik.offset_bottom = 205.0
	baslik.add_theme_font_size_override("font_size", 32)
	baslik.add_theme_color_override("font_color", Color(0.39, 0.78, 0.30))
	baslik.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	baslik.add_theme_constant_override("outline_size", 8)
	kat.add_child(baslik)
	return kat
