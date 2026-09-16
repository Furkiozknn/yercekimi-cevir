extends Control
## Ayarlar ekrani. Iki sutun: solda ses/goruntu, sagda yardim modu ve dokunmatik.
## Her degisiklik aninda uygulanir ve user://kayit.cfg icine yazilir.


func _ready() -> void:
	Ayarlar.zaman_sifirla()
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
	$Geri.grab_focus()


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
	get_tree().change_scene_to_file(Ayarlar.donus_sahnesi)
