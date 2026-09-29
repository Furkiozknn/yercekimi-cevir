extends Control
## Ana menu: dev OYNA dugmesi, tek satir "nasil oynanir", ikincil dugmeler.
## Zemin #10101a + videodaki gibi egik uzun bloklar (uzerinde kirmizi dikenler).

const KAGIT := Color("f1ece2")
var _t: float = 0.0


func _ready() -> void:
	RenderingServer.set_default_clear_color(Tema.PANEL)
	Ayarlar.zaman_sifirla()
	Ayarlar.gunluk_mod = false          # menuye donen her yol gunluk modu kapatir
	Ayarlar.dokunmatik_degisti.connect(_yazilari_yaz)
	$Dekor.draw.connect(_dekor_ciz)
	$Kutu/Basla.pressed.connect(_basla)
	$Kutu/Ikinci/Gunluk.pressed.connect(_gunluk)
	$Kutu/Ikinci/Sec.pressed.connect(func() -> void:
		Ses.cal(&"menu")
		Gecis.git("res://scenes/bolum_sec.tscn"))
	$Kutu/Ikinci/Ayar.pressed.connect(func() -> void:
		Ses.cal(&"menu")
		Ayarlar.donus_sahnesi = "res://scenes/menu.tscn"
		Gecis.git("res://scenes/ayarlar_ekrani.tscn"))
	# Once ses durdurulup motora bir karistirma turu birakilir; yoksa cikista
	# "resource still in use" hatasi basiyor.
	$Kutu/Ikinci/Cikis.pressed.connect(func() -> void:
		Ses.kapat()
		await get_tree().create_timer(0.12).timeout
		get_tree().quit())
	if OS.has_feature("web"):
		$Kutu/Ikinci/Cikis.hide()
	$Dil.pressed.connect(_dil_degistir)
	_yazilari_yaz()
	UI.dugmeleri_bagla(self)
	$Kutu/Basla.grab_focus()
	Ses.muzik(&"menu")
	if Ayarlar.oyun_hissi:
		UI.sirayla_gir([$Ust, $Dil, $Baslik, $AltBaslik, $Kutu/Basla, $Kutu/Ikinci/Sec, $Kutu/Ikinci/Gunluk,
			$Kutu/Ikinci/Ayar, $Kutu/Ikinci/Cikis, $Gunluk, $KristalIkon, $Durum])


func _process(delta: float) -> void:
	# Egik bloklar yavas ve dogrusal kayar (bulaniklik/parlama yok).
	_t += delta
	$Dekor.position = Vector2(sin(_t * 0.25) * 24.0, 0.0)


## Dile bagli her metin: dil degisince ya da dokunma algilaninca yeniden yazilir.
func _yazilari_yaz() -> void:
	$Ust.text = Tema.buyuk(Ayarlar.kontrol_metni("Tek tuş · 20 oda"))
	$Dil.text = "TR" if Ayarlar.dil_etkin() == "en" else "EN"
	## "Tek tus" dokunmatikte yalan; tablo uzerinden cevrilir (Ayarlar.kontrol_metni).
	$AltBaslik.text = Ayarlar.kontrol_metni("A / D ile yürü · BOŞLUK yerçekimini çevirir")
	$Gunluk.text = tr("Günün bölümü: %s · en iyi %s · seri %d gün") % [
		tr_bolum_baslik(), Ayarlar.gunluk_en_iyi_metin(), Ayarlar.gunluk_seri_al()]
	$Durum.text = tr("%d / %d kristal · %d / %d madalya · açık bölüm %d / %d") % [
		Ayarlar.kristal_sayisi(), Ayarlar.bolum_sayisi(),
		Ayarlar.madalya_sayisi(), Ayarlar.bolum_sayisi(),
		Ayarlar.acilan_bolum + 1, Ayarlar.bolum_sayisi()]
	if Ayarlar.yardim_acik:
		$Durum.text += " · " + tr("yardım açık")
	$Durum.reset_size()
	var g: float = 14.0 + $Durum.size.x
	$KristalIkon.position.x = 320.0 - g * 0.5
	$Durum.position.x = 320.0 - g * 0.5 + 14.0


func tr_bolum_baslik() -> String:
	return "%s · %s" % [tr(String(Ayarlar.bolum(Ayarlar.gunluk_bolum())["ad"])), tr(Ayarlar.gunluk_degistirici_adi())]


## Videodaki gibi iki egik blok; ustlerinde kirmizi ucgen dikenler.
func _dekor_ciz() -> void:
	var blok := Color(KAGIT, 0.055)
	var diken := Color(Tema.DIKEN, 0.55)
	# Uzun blok 1: sol alttan sag uste hafif egim
	_egik(Vector2(-80.0, 380.0), Vector2(720.0, 332.0), 26.0, blok, diken)
	# Uzun blok 2: ustte, ters egim
	_egik(Vector2(-80.0, 60.0), Vector2(720.0, 0.0), 20.0, blok, diken)


func _egik(a: Vector2, b: Vector2, kalinlik: float, blok: Color, diken: Color) -> void:
	var yon := (b - a).normalized()
	var dik := Vector2(-yon.y, yon.x)
	var yari := dik * kalinlik * 0.5
	$Dekor.draw_colored_polygon(PackedVector2Array([a - yari, b - yari, b + yari, a + yari]), blok)
	# yukari bakan yuzey boyunca dikenler (blogun ust kenarindan disari)
	var n := int((b - a).length() / 44.0)
	for i in range(1, n):
		var p := a + (b - a) * (float(i) / float(n)) - yari
		$Dekor.draw_colored_polygon(PackedVector2Array([p - yon * 6.0, p + yon * 6.0, p - dik * 9.0]), diken)


func _dil_degistir() -> void:
	Ses.cal(&"menu")
	Ayarlar.dil = "tr" if Ayarlar.dil_etkin() == "en" else "en"
	Ayarlar.dil_uygula()
	Ayarlar.kaydet()
	get_tree().reload_current_scene()


func _basla() -> void:
	Ses.cal(&"menu")
	Ayarlar.secilen_bolum = Ayarlar.acilan_bolum
	Gecis.git("res://scenes/oyun.tscn")


## Gunun bolumu: tarihten secilen bolum + degistirici, ayri kayit yuvasi.
func _gunluk() -> void:
	Ses.cal(&"menu")
	Ayarlar.gunluk_mod = true
	Ayarlar.secilen_bolum = Ayarlar.gunluk_bolum()
	Gecis.git("res://scenes/oyun.tscn")
