extends Control
## Bolum Sec: acilmis bolumler tiklanabilir; her hucrede en iyi sure, kazanilan
## madalya ve kristal durumu gorunur.

const T_MADALYA := preload("res://assets/sprites/madalya.png")
const T_KRISTAL := preload("res://assets/sprites/kristal.png")


func _ready() -> void:
	var izgara: GridContainer = $Kutu/Izgara
	for i in Ayarlar.bolum_sayisi():
		izgara.add_child(_hucre(i))
	$Geri.pressed.connect(func() -> void:
		Ses.cal(&"menu")
		get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	$Ozet.text = "Kristal %d / %d     Madalya %d / %d" % [
		Ayarlar.kristal_sayisi(), Ayarlar.bolum_sayisi(),
		_madalyali_bolum(), Ayarlar.bolum_sayisi()]
	Ses.muzik(&"menu")


func _madalyali_bolum() -> int:
	var n := 0
	for i in Ayarlar.bolum_sayisi():
		if Ayarlar.madalya_al(i) > 0:
			n += 1
	return n


func _hucre(i: int) -> Button:
	var acik := Ayarlar.acik_mi(i)
	var dugme := Button.new()
	dugme.custom_minimum_size = Vector2(84, 52)
	dugme.disabled = not acik

	var kutu := VBoxContainer.new()
	kutu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	kutu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kutu.add_theme_constant_override("separation", 0)
	dugme.add_child(kutu)

	var no := Label.new()
	no.text = str(i + 1)
	no.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	no.add_theme_font_size_override("font_size", 14)
	no.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kutu.add_child(no)

	var sure := Label.new()
	sure.text = Ayarlar.en_iyi_metin(i) if acik else "kilitli"
	sure.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sure.add_theme_font_size_override("font_size", 9)
	sure.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kutu.add_child(sure)

	var simgeler := HBoxContainer.new()
	simgeler.alignment = BoxContainer.ALIGNMENT_CENTER
	simgeler.mouse_filter = Control.MOUSE_FILTER_IGNORE
	simgeler.add_theme_constant_override("separation", 4)
	kutu.add_child(simgeler)

	var m := Ayarlar.madalya_al(i)
	var madalya := TextureRect.new()
	madalya.custom_minimum_size = Vector2(12, 12)
	madalya.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if m > 0:
		var atlas := AtlasTexture.new()
		atlas.atlas = T_MADALYA
		atlas.region = Rect2((3 - m) * 12, 0, 12, 12)   # 3 altin=0, 2 gumus=12, 1 bronz=24
		madalya.texture = atlas
	else:
		madalya.modulate.a = 0.0
	simgeler.add_child(madalya)

	var kristal := TextureRect.new()
	kristal.custom_minimum_size = Vector2(12, 12)
	kristal.texture = T_KRISTAL
	kristal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kristal.modulate.a = 1.0 if Ayarlar.kristal_var(i) else 0.18
	simgeler.add_child(kristal)

	if acik:
		dugme.pressed.connect(func() -> void:
			Ses.cal(&"menu")
			Ayarlar.secilen_bolum = i
			get_tree().change_scene_to_file("res://scenes/oyun.tscn"))
	return dugme
