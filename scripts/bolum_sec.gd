extends Control
## Bolum Sec: acilmis bolumler tiklanabilir; her hucrede en iyi sure, kazanilan
## madalya ve kristal durumu gorunur. "Sure Listesi" ayni 20 bolumu iki sutunlu
## bir listeye cevirir: ad, en iyi sure, madalya, altin hedefi (v0.7).

const T_MADALYA := preload("res://assets/sprites/madalya.png")
const T_KRISTAL := preload("res://assets/sprites/kristal.png")

var _liste_acik: bool = false


func _ready() -> void:
	Ayarlar.zaman_sifirla()
	var izgara: GridContainer = $Kutu/Izgara
	for i in Ayarlar.bolum_sayisi():
		izgara.add_child(_hucre(i))
	_liste_kur()
	$Geri.pressed.connect(func() -> void:
		Ses.cal(&"menu")
		get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	$Gorunum.pressed.connect(func() -> void:
		Ses.cal(&"menu")
		liste_goster(not _liste_acik))
	$Ozet.text = "Kristal %d / %d     Madalya %d / %d     En az çevirme %d / %d" % [
		Ayarlar.kristal_sayisi(), Ayarlar.bolum_sayisi(),
		Ayarlar.madalya_sayisi(), Ayarlar.bolum_sayisi(),
		_en_az_bolum(), Ayarlar.bolum_sayisi()]
	Ses.muzik(&"menu")


## Izgara <-> liste. Ikisi de ayni alani kullanir; dugme metni oteki gorunumu soyler.
func liste_goster(acik: bool) -> void:
	_liste_acik = acik
	$Kutu.visible = not acik
	$Liste.visible = acik
	$Gorunum.text = "Bölüm Izgarası" if acik else "Süre Listesi"


## 20 satir 640x360'a tek sutunda sigmaz (20 x 20 px = 400): iki sutun, 10'ar.
func _liste_kur() -> void:
	var sutunlar: Array = [$Liste/Sol, $Liste/Sag]
	var n := Ayarlar.bolum_sayisi()
	var yarim := int(ceil(n / 2.0))
	for i in n:
		(sutunlar[i / yarim] as Control).add_child(_satir(i))


## Bir liste satiri: "ad ..... en iyi [madalya] ● altin". Tiklaninca bolum acilir.
func _satir(i: int) -> Button:
	var acik := Ayarlar.acik_mi(i)
	var d := Button.new()
	d.name = "Satir%d" % (i + 1)
	d.custom_minimum_size = Vector2(0, 20)
	d.disabled = not acik
	d.flat = true
	var h := HBoxContainer.new()
	h.name = "Kutu"
	h.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_theme_constant_override("separation", 6)
	d.add_child(h)

	var ad := _yazi(String(Ayarlar.bolum(i)["ad"]), 0, HORIZONTAL_ALIGNMENT_LEFT)
	ad.name = "Ad"
	ad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ad.clip_text = true
	h.add_child(ad)

	var en_iyi := _yazi(Ayarlar.en_iyi_metin(i) if acik else "kilitli", 58, HORIZONTAL_ALIGNMENT_RIGHT)
	en_iyi.name = "EnIyi"
	if not acik:
		en_iyi.modulate.a = 0.5
	h.add_child(en_iyi)

	var m := Ayarlar.madalya_al(i)
	var madalya := TextureRect.new()
	madalya.name = "Madalya"
	madalya.custom_minimum_size = Vector2(12, 12)
	madalya.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	madalya.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if m > 0:
		madalya.texture = _madalya_dokusu(m)
	h.add_child(madalya)

	var altin := _yazi("● %.2f sn" % float(Ayarlar.esik(i)["altin"]), 64, HORIZONTAL_ALIGNMENT_RIGHT)
	altin.name = "Altin"
	altin.add_theme_color_override("font_color", Ayarlar.MADALYA_RENK[3])
	h.add_child(altin)

	if acik:
		d.pressed.connect(func() -> void:
			Ses.cal(&"menu")
			Ayarlar.secilen_bolum = i
			get_tree().change_scene_to_file("res://scenes/oyun.tscn"))
	return d


func _yazi(metin: String, genislik: float, hiza: int) -> Label:
	var l := Label.new()
	l.text = metin
	l.custom_minimum_size = Vector2(genislik, 0)
	l.horizontal_alignment = hiza
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 10)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


## 3 altin=0, 2 gumus=12, 1 bronz=24 (madalya.png 36x12, uc madalya yan yana).
func _madalya_dokusu(m: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = T_MADALYA
	atlas.region = Rect2((3 - m) * 12, 0, 12, 12)
	return atlas


## Hedefteki en az cevirmeyle (ya da daha aziyla) bitirilen bolum sayisi.
func _en_az_bolum() -> int:
	var n := 0
	for i in Ayarlar.bolum_sayisi():
		var az := Ayarlar.en_az_al(i)
		if az >= 0 and az <= Ayarlar.en_az_hedef(i):
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
	var az := Ayarlar.en_az_al(i)
	sure.text = Ayarlar.en_iyi_metin(i) if acik else "kilitli"
	if acik and az >= 0:
		sure.text += "  ⟳%d" % az
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
		madalya.texture = _madalya_dokusu(m)
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
