extends CanvasLayer
## Sahne gecisi (autoload "Gecis"): tam ekran renk bandi soldan girer (~260 ms),
## sahne degisir, bant saga cikar (~200 ms). Stil rehberi: turuncu-kirmizi ya da murekkep.
## Oyun hissi kapaliyken (erisilebilirlik) gecis animasyonsuz ve aninda.

const ORTME := 0.26
const ACMA := 0.20
const GENISLIK := 660.0

var _bant: ColorRect
var _mesgul: bool = false
var _ipucu: Label
var _dikey_kart: Panel
var _ipucu_sayac: float = 0.0


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_bant = ColorRect.new()
	_bant.color = Tema.DIKEN
	_bant.size = Vector2(GENISLIK, 380.0)
	_bant.position = Vector2(-GENISLIK, -10.0)
	_bant.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bant.visible = false
	add_child(_bant)
	# Dikey telefon: oyun 16:9'a kilitli (oda kamerasi), yatay tutmak gerekir.
	# Pencere dikeye donunce 4 sn'lik bir ipucu cikar (denetim: mobil).
	_ipucu = Label.new()
	_ipucu.theme_type_variation = &"Baslik2"
	_ipucu.add_theme_font_size_override("font_size", 26)
	_ipucu.add_theme_color_override("font_color", Tema.MUREKKEP)
	_ipucu.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ipucu.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ipucu.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ipucu.position = Vector2(60.0, 120.0)
	_ipucu.size = Vector2(520.0, 120.0)
	_ipucu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var kart := Panel.new()
	kart.theme_type_variation = &"Kagit"
	kart.position = Vector2(40.0, 110.0)
	kart.size = Vector2(560.0, 140.0)
	kart.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dikey_kart = kart
	kart.visible = false
	add_child(kart)
	kart.add_child(_ipucu)
	_ipucu.position = Vector2(20.0, 10.0)
	_ipucu.size = Vector2(520.0, 120.0)
	get_tree().root.size_changed.connect(_boyut_degisti)
	_boyut_degisti.call_deferred()


func mesgul_mu() -> bool:
	return _mesgul


## Sahneyi bantla degistirir. Bant sirasinda ikinci cagri yok sayilir (cift tik).
func git(yol: String, renk: Color = Tema.DIKEN) -> void:
	if _mesgul:
		return
	_mesgul = true
	if not Ayarlar.oyun_hissi:
		get_tree().change_scene_to_file(yol)
		_mesgul = false
		return
	_bant.color = renk
	_bant.position.x = -GENISLIK
	_bant.visible = true
	var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(_bant, "position:x", -10.0, ORTME)
	await t.finished
	get_tree().change_scene_to_file(yol)
	await get_tree().process_frame
	await get_tree().process_frame
	var t2 := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	t2.tween_property(_bant, "position:x", GENISLIK, ACMA)
	await t2.finished
	_bant.visible = false
	_mesgul = false


## Pencere dikeyse (telefon) "yatay tut" ipucu; yataya donunce kaybolur.
func _boyut_degisti() -> void:
	var boyut := get_tree().root.size
	var dikey: bool = boyut.y > boyut.x
	_ipucu.text = tr("Cihazını yatay çevir")
	_dikey_kart.visible = dikey
	_ipucu_sayac = 4.0 if dikey else 0.0


func _process(delta: float) -> void:
	if _ipucu_sayac > 0.0:
		_ipucu_sayac -= delta
		if _ipucu_sayac <= 0.0:
			_dikey_kart.visible = false
