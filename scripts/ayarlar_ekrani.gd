extends Control
## Ayarlar ekrani. Iki sutun: solda ses/goruntu, sagda yardim modu ve dokunmatik.
## Her degisiklik aninda uygulanir ve user://kayit.cfg icine yazilir.


func _ready() -> void:
	RenderingServer.set_default_clear_color(Tema.PANEL)
	Ayarlar.zaman_sifirla()
	_dil_yaz()
	(_dugum("Dil") as Button).pressed.connect(_dil_degistir)
	_kaydirici("Muzik", Ayarlar.muzik_ses, func(v: float) -> void:
		Ayarlar.muzik_ses = v)
	_kaydirici("Efekt", Ayarlar.efekt_ses, func(v: float) -> void:
		Ayarlar.efekt_ses = v
		Ses.cal(&"menu"))
	_anahtar("MuzikAcik", Ayarlar.muzik_acik, func(a: bool) -> void:
		Ayarlar.muzik_acik = a)
	_anahtar("EfektAcik", Ayarlar.efekt_acik, func(a: bool) -> void:
		Ayarlar.efekt_acik = a
		if a:
			Ses.cal(&"menu"))
	_anahtar("TamEkran", Ayarlar.tam_ekran, func(a: bool) -> void:
		Ayarlar.tam_ekran = a
		Ayarlar.ekran_uygula())
	_anahtar("OyunHissi", Ayarlar.oyun_hissi, func(a: bool) -> void:
		Ayarlar.oyun_hissi = a)
	_anahtar("YuksekKontrast", Ayarlar.yuksek_kontrast, func(a: bool) -> void:
		Ayarlar.yuksek_kontrast = a)
	_anahtar("YercekimiOku", Ayarlar.yercekimi_oku, func(a: bool) -> void:
		Ayarlar.yercekimi_oku = a)
	_anahtar("InisGostergesi", Ayarlar.inis_gostergesi, func(a: bool) -> void:
		Ayarlar.inis_gostergesi = a)

	_anahtar("AltinHayalet", Ayarlar.altin_hayalet, func(a: bool) -> void:
		Ayarlar.altin_hayalet = a)

	_anahtar("YardimAcik", Ayarlar.yardim_acik, func(a: bool) -> void:
		Ayarlar.yardim_acik = a
		_yardim_goster())
	_kaydirici("YardimHiz", Ayarlar.yardim_hiz, func(v: float) -> void:
		Ayarlar.yardim_hiz = v
		_yardim_goster())
	_anahtar("YardimOlumsuz", Ayarlar.yardim_olumsuz, func(a: bool) -> void:
		Ayarlar.yardim_olumsuz = a)
	_anahtar("Solak", Ayarlar.solak, func(a: bool) -> void:
		Ayarlar.solak = a)
	_kaydirici("Opaklik", Ayarlar.dokunmatik_opaklik, func(v: float) -> void:
		Ayarlar.dokunmatik_opaklik = v
		_yardim_goster())
	_anahtar("Titresim", Ayarlar.titresim, func(a: bool) -> void:
		Ayarlar.titresim = a
		if a and DisplayServer.is_touchscreen_available():
			Input.vibrate_handheld(30))
	_yardim_goster()

	if OS.has_feature("web"):
		# Tarayicida tam ekrani oyun degil kullanici acar.
		for ad in ["TamEkranYazi", "TamEkranBosluk", "TamEkran"]:
			_dugum(ad).hide()

	$Geri.pressed.connect(_geri)
	# Key remapping: desktop only (a phone has no keyboard to remap).
	if not Ayarlar.dokunmatik_mi():
		_tus_atama_kur()
	UI.dugmeleri_bagla(self)
	$Geri.grab_focus()
	if Ayarlar.oyun_hissi:
		UI.sirayla_gir([$Baslik, $Kutu, $Not, $Geri])


func _dugum(ad: String) -> Node:
	var d := find_child(ad, true, false)
	assert(d != null, "Ayar dugumu yok: %s" % ad)
	return d


## Yardim modu kapaliyken hiz ve olumsuzluk satirlari soluklasir — gizlenmez ki
## nerede oldugu unutulmasin.
func _yardim_goster() -> void:
	var acik: bool = Ayarlar.yardim_acik
	for ad in ["HizYazi", "YardimHiz", "HizDeger", "ItYazi", "YardimOlumsuz"]:
		var d := _dugum(ad) as CanvasItem
		d.modulate.a = 1.0 if acik else 0.4
		if d is Control:
			(d as Control).mouse_filter = Control.MOUSE_FILTER_STOP if acik else Control.MOUSE_FILTER_IGNORE
	(_dugum("HizDeger") as Label).text = "%%%d" % roundi(Ayarlar.yardim_hiz * 100.0)
	(_dugum("OpakDeger") as Label).text = "%%%d" % roundi(Ayarlar.dokunmatik_opaklik * 100.0)


func _kaydirici(ad: String, deger: float, uygula: Callable) -> void:
	var k := _dugum(ad) as HSlider
	k.value = deger
	k.value_changed.connect(func(v: float) -> void:
		uygula.call(v)
		Ayarlar.ses_uygula()
		Ayarlar.kaydet())


func _anahtar(ad: String, deger: bool, uygula: Callable) -> void:
	var d := _dugum(ad) as CheckButton
	d.button_pressed = deger
	d.toggled.connect(func(a: bool) -> void:
		uygula.call(a)
		Ayarlar.ses_uygula()
		Ayarlar.kaydet())


func _geri() -> void:
	Ses.cal(&"menu")
	Gecis.git(Ayarlar.donus_sahnesi)


# --- Key remapping (Tuslar) ------------------------------------------------------

var _tus_panel: Control = null
var _tus_not: Label = null
var _tus_dugmeleri: Dictionary = {}   ## action -> Button
var _bekleyen := ""                   ## action waiting for a key press ("" = none)


## "Key bindings" button next to Back, and the overlay it opens. Built in code
## so the scene layout (two columns that already fill the screen) is untouched.
func _tus_atama_kur() -> void:
	var geri := $Geri as Button
	geri.offset_left = 326.0
	geri.offset_right = 446.0
	var ac := Button.new()
	ac.name = "TusAtama"
	ac.text = tr("Tuş atama")
	ac.offset_left = 194.0
	ac.offset_top = geri.offset_top
	ac.offset_right = 314.0
	ac.offset_bottom = geri.offset_bottom
	ac.pressed.connect(_tus_paneli_ac)
	add_child(ac)

	_tus_panel = Control.new()
	_tus_panel.name = "TusPaneli"
	_tus_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_tus_panel.visible = false
	add_child(_tus_panel)
	var arka := ColorRect.new()
	arka.color = Tema.PANEL
	arka.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_tus_panel.add_child(arka)
	var orta := CenterContainer.new()
	orta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_tus_panel.add_child(orta)
	var kutu := VBoxContainer.new()
	kutu.add_theme_constant_override("separation", 6)
	orta.add_child(kutu)
	var baslik := Label.new()
	baslik.text = tr("TUŞ ATAMA")
	baslik.theme_type_variation = &"Baslik2"
	baslik.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kutu.add_child(baslik)
	_tus_not = Label.new()
	_tus_not.name = "TusNot"
	_tus_not.add_theme_font_size_override("font_size", 9)
	_tus_not.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kutu.add_child(_tus_not)
	var izgara := GridContainer.new()
	izgara.columns = 2
	izgara.add_theme_constant_override("h_separation", 12)
	izgara.add_theme_constant_override("v_separation", 4)
	kutu.add_child(izgara)
	for eylem: String in Tuslar.EYLEMLER:
		var yazi := Label.new()
		yazi.text = tr(String(Tuslar.EYLEMLER[eylem]))
		yazi.custom_minimum_size = Vector2(150, 0)
		yazi.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		izgara.add_child(yazi)
		var d := Button.new()
		d.name = "Tus_" + eylem
		d.custom_minimum_size = Vector2(120, 24)
		d.theme_type_variation = &"Kucuk"
		d.pressed.connect(_tus_bekle.bind(eylem))
		izgara.add_child(d)
		_tus_dugmeleri[eylem] = d
	var alt := HBoxContainer.new()
	alt.alignment = BoxContainer.ALIGNMENT_CENTER
	alt.add_theme_constant_override("separation", 10)
	kutu.add_child(alt)
	var sifir := Button.new()
	sifir.name = "TusSifirla"
	sifir.text = tr("Varsayılana dön")
	sifir.custom_minimum_size = Vector2(140, 28)
	sifir.pressed.connect(func() -> void:
		Tuslar.sifirla()
		_bekleyen = ""
		_tuslari_yaz(tr("Varsayılan tuşlar geri geldi."))
		Ses.cal(&"menu"))
	alt.add_child(sifir)
	var kapat := Button.new()
	kapat.name = "TusGeri"
	kapat.text = tr("Geri")
	kapat.theme_type_variation = &"Birincil"
	kapat.custom_minimum_size = Vector2(120, 28)
	kapat.pressed.connect(_tus_paneli_kapat)
	alt.add_child(kapat)


func _tus_paneli_ac() -> void:
	Ses.cal(&"menu")
	_bekleyen = ""
	_tuslari_yaz("")
	_tus_panel.visible = true
	(_tus_dugmeleri["cevir"] as Button).grab_focus()


func _tus_paneli_kapat() -> void:
	Ses.cal(&"menu")
	_bekleyen = ""
	_tus_panel.visible = false
	(find_child("TusAtama", true, false) as Button).grab_focus()


func _tus_bekle(eylem: String) -> void:
	_bekleyen = eylem
	Ses.cal(&"menu")
	_tuslari_yaz("")


## Button texts = current key of each action; the waiting one says so.
func _tuslari_yaz(not_metni: String) -> void:
	for eylem: String in _tus_dugmeleri:
		var d := _tus_dugmeleri[eylem] as Button
		d.text = tr("bir tuşa bas...") if eylem == _bekleyen else Tuslar.tus_adi(eylem)
	_tus_not.text = not_metni if not_metni != "" else tr("Düğmeye bas, sonra yeni tuşa bas · Esc: vazgeç · gamepad değişmez")


## While an action waits, the next key press is the new binding (Esc cancels).
func _input(olay: InputEvent) -> void:
	if _bekleyen == "" or not (olay is InputEventKey):
		return
	var k := olay as InputEventKey
	if not k.pressed or k.echo:
		return
	get_viewport().set_input_as_handled()
	tus_yakala(int(k.physical_keycode) if k.physical_keycode != 0 else int(k.keycode))


## Applies a captured key to the waiting action (also the test entry point).
func tus_yakala(kod: int) -> void:
	var eylem := _bekleyen
	_bekleyen = ""
	if eylem == "":
		return
	if kod == KEY_ESCAPE:
		_tuslari_yaz(tr("Vazgeçildi."))
		return
	if Tuslar.ata(eylem, kod):
		Ses.cal(&"kontrol")
		_tuslari_yaz("")
	else:
		_tuslari_yaz(tr("Bu tuş atanamadı: bir eylem tuşsuz kalırdı."))


## Dil dugmesi: etkin dilin adini gosterir; basinca digerine gecer, kaydeder ve
## sahneyi yeniden kurar (sahne metinleri tr() ile yeniden cevrilir).
func _dil_yaz() -> void:
	(_dugum("Dil") as Button).text = "English" if Ayarlar.dil_etkin() == "en" else "Türkçe"


func _dil_degistir() -> void:
	Ses.cal(&"menu")
	Gecis.ara(&"glitch", 0, func() -> void:       # dil degisimi: glitch ortusunun altinda yeni metin
		Ayarlar.dil = "tr" if Ayarlar.dil_etkin() == "en" else "en"
		Ayarlar.dil_uygula()
		Ayarlar.kaydet()
		get_tree().reload_current_scene())
