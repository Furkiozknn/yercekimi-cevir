extends Control
## Ana menu.

func _ready() -> void:
	Ayarlar.zaman_sifirla()
	Ayarlar.dokunmatik_degisti.connect(_alt_basligi_yaz)
	_alt_basligi_yaz()
	$Kutu/Basla.pressed.connect(_basla)
	$Kutu/Sec.pressed.connect(func() -> void:
		Ses.cal(&"menu")
		get_tree().change_scene_to_file("res://scenes/bolum_sec.tscn"))
	$Kutu/Ayar.pressed.connect(func() -> void:
		Ses.cal(&"menu")
		Ayarlar.donus_sahnesi = "res://scenes/menu.tscn"
		get_tree().change_scene_to_file("res://scenes/ayarlar_ekrani.tscn"))
	# Once ses durdurulup motora bir karistirma turu birakilir; yoksa cikista
	# "resource still in use" hatasi basiyor.
	$Kutu/Cikis.pressed.connect(func() -> void:
		Ses.kapat()
		await get_tree().create_timer(0.12).timeout
		get_tree().quit())
	if OS.has_feature("web"):
		$Kutu/Cikis.hide()
	$Durum.text = "%d / %d kristal      Açık bölüm: %d / %d%s" % [
		Ayarlar.kristal_sayisi(), Ayarlar.bolum_sayisi(),
		Ayarlar.acilan_bolum + 1, Ayarlar.bolum_sayisi(),
		"      Yardım modu açık" if Ayarlar.yardim_acik else ""]
	$Kutu/Basla.grab_focus()
	Ses.muzik(&"menu")


## "Tek tus" yazisi dokunmatikte yalan; tablo uzerinden cevrilir.
func _alt_basligi_yaz() -> void:
	$AltBaslik.text = Ayarlar.kontrol_metni("Zıplama yok. Tek tuş: yerçekimini çevir.")


func _basla() -> void:
	Ses.cal(&"menu")
	Ayarlar.secilen_bolum = Ayarlar.acilan_bolum
	get_tree().change_scene_to_file("res://scenes/oyun.tscn")
