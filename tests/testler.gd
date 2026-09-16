extends Node
## Headless otomatik test. Calistirma:
##   godot --headless --path . res://tests/testler.tscn
## Cikis kodu 0 = gecti, 1 = kaldi.

const OYUNCU := preload("res://scenes/oyuncu.tscn")
const OYUN := preload("res://scenes/oyun.tscn")

var _hata: int = 0
var _sayi: int = 0


func _ready() -> void:
	await get_tree().process_frame
	print("— Bolum verisi —")
	await _bolum_testi()
	print("— Madalya esikleri —")
	_madalya_testi()
	print("— Ses ve veriyollari —")
	_ses_testi()
	print("— Cevirme mantigi —")
	await _cevirme_testi()
	print("— Diken ve yeniden baslama —")
	await _diken_testi()
	print("— Kristal —")
	await _kristal_testi()
	print("— Kontrol noktasi —")
	await _kontrol_testi()
	print("— Kapi, madalya ve ilerleme —")
	await _kapi_testi()
	print("%d dogrulama, %d hata" % [_sayi, _hata])
	if _hata == 0:
		print("TESTLER GECTI")
	else:
		printerr("TESTLER KALDI")
	# Motorun kapanis sirasi alttan yukari: muzik burada durdurulmazsa cikista
	# "resource still in use" hatasi basiliyor.
	Ses.kapat()
	await get_tree().create_timer(0.25).timeout
	get_tree().quit(1 if _hata > 0 else 0)


func _dogrula(kosul: bool, ad: String) -> void:
	_sayi += 1
	if kosul:
		print("  [OK] ", ad)
	else:
		_hata += 1
		printerr("  [HATA] ", ad)


func _bolum_testi() -> void:
	_dogrula(Bolumler.BOLUMLER.size() == 20, "20 bolum var (%d)" % Bolumler.BOLUMLER.size())
	for i in Bolumler.BOLUMLER.size():
		var veri: Dictionary = Bolumler.BOLUMLER[i]
		var harita: Array = veri["harita"]
		var s := 0
		var k := 0
		var kr := 0
		var kn := 0
		var genislik: int = String(harita[0]).length()
		var duzgun := true
		for ham in harita:
			var satir: String = ham
			if satir.length() != genislik:
				duzgun = false
			s += satir.count("S")
			k += satir.count("K")
			kr += satir.count("C")
			kn += satir.count("P")
		var b := Bolum.new()
		add_child(b)
		b.kur(veri)
		var ad: String = "bolum %d" % (i + 1)
		_dogrula(duzgun, ad + ": tum satirlar esit genislikte")
		_dogrula(s == 1, ad + ": tam 1 baslangic (%d)" % s)
		_dogrula(k >= 1, ad + ": en az 1 kapi (%d)" % k)
		_dogrula(kr == 1, ad + ": tam 1 kristal (%d)" % kr)
		_dogrula(kn <= 1, ad + ": en fazla 1 kontrol noktasi (%d)" % kn)
		_dogrula(b.baslangic != Vector2.ZERO, ad + ": baslangic konumu kuruldu")
		_dogrula(b.kapi_sayisi == k, ad + ": kapi alani kuruldu")
		_dogrula(b.kristal_konumu != Vector2.ZERO, ad + ": kristal alani kuruldu")
		_dogrula((b.kontrol_konumu != Vector2.ZERO) == (kn == 1),
			ad + ": kontrol noktasi haritayla uyumlu")
		_dogrula(b.get_node("Kati").get_child_count() > 0, ad + ": kati govde kuruldu")
		b.queue_free()
		await get_tree().process_frame
	# Uzun bolumlerin (64 sutun) hepsinde kontrol noktasi olmali.
	for i in Bolumler.BOLUMLER.size():
		var harita: Array = Bolumler.BOLUMLER[i]["harita"]
		if String(harita[0]).length() < 56:
			continue
		var var_mi := false
		for ham in harita:
			if String(ham).count("P") > 0:
				var_mi = true
		_dogrula(var_mi, "uzun bolum %d: kontrol noktasi var" % (i + 1))


func _madalya_testi() -> void:
	for i in Ayarlar.bolum_sayisi():
		var v := Ayarlar.bolum(i)
		var a: float = v["altin"]
		var g: float = v["gumus"]
		var br: float = v["bronz"]
		var ad := "bolum %d madalya" % (i + 1)
		_dogrula(a > 0.0 and a < g and g < br, ad + ": altin < gumus < bronz (%.1f/%.1f/%.1f)" % [a, g, br])
		_dogrula(Ayarlar.madalya_hesapla(i, a - 0.01) == 3, ad + ": altin esigi")
		_dogrula(Ayarlar.madalya_hesapla(i, g - 0.01) == 2, ad + ": gumus esigi")
		_dogrula(Ayarlar.madalya_hesapla(i, br - 0.01) == 1, ad + ": bronz esigi")
		_dogrula(Ayarlar.madalya_hesapla(i, br + 1.0) == 0, ad + ": madalyasiz")


func _ses_testi() -> void:
	_dogrula(AudioServer.get_bus_index("Muzik") > 0, "Muzik veriyolu var")
	_dogrula(AudioServer.get_bus_index("Efekt") > 0, "Efekt veriyolu var")
	for ad in ["cevir", "cevir_ters", "kristal", "kontrol", "olum", "bolum_sonu",
			"madalya", "menu", "inis"]:
		_dogrula(Ses.EFEKT.has(StringName(ad)), "efekt yuklendi: %s" % ad)
	for ad in ["menu", "oyun"]:
		var s: AudioStreamWAV = Ses.MUZIK[StringName(ad)]
		_dogrula(s.loop_mode == AudioStreamWAV.LOOP_FORWARD, "muzik donguye ayarli: %s" % ad)
		_dogrula(s.loop_end > 0, "muzik dongu sonu kurulu: %s" % ad)
	# Ses kapatildiginda veriyolu gercekten susuyor mu?
	var onceki := Ayarlar.efekt_acik
	Ayarlar.efekt_acik = false
	Ayarlar.ses_uygula()
	_dogrula(AudioServer.is_bus_mute(AudioServer.get_bus_index("Efekt")), "efekt kapatilinca veriyolu susuyor")
	Ayarlar.efekt_acik = onceki
	Ayarlar.ses_uygula()
	_dogrula(not AudioServer.is_bus_mute(AudioServer.get_bus_index("Efekt")), "efekt acilinca veriyolu aciliyor")


func _cevirme_testi() -> void:
	var b := Bolum.new()
	add_child(b)
	b.kur(Bolumler.BOLUMLER[0])
	var o: CharacterBody2D = OYUNCU.instantiate()
	add_child(o)
	o.girdi_acik = false
	o.hazirla(b.baslangic)
	for i in 30:
		await get_tree().physics_frame
	_dogrula(o.is_on_floor(), "oyuncu zemine oturdu")
	var onceki: float = o.yercekimi_yonu
	var yakalanan := [0.0]
	o.cevirdi.connect(func(y: float) -> void: yakalanan[0] = y)
	_dogrula(o.cevir(), "yuzeydeyken cevirme kabul edildi")
	_dogrula(o.yercekimi_yonu == -onceki, "yercekimi yonu ters dondu")
	_dogrula(yakalanan[0] == o.yercekimi_yonu, "cevirdi sinyali yeni yonu tasidi")
	_dogrula(o.up_direction == Vector2.DOWN, "up_direction asagi dondu")
	for i in 6:
		await get_tree().physics_frame
	_dogrula(not o.is_on_floor(), "cevirdikten sonra oyuncu havada")
	var havadaki: float = o.yercekimi_yonu
	_dogrula(not o.cevir(), "havada cevirme reddedildi")
	_dogrula(o.yercekimi_yonu == havadaki, "havada yercekimi degismedi")
	for i in 90:
		await get_tree().physics_frame
	_dogrula(o.is_on_floor(), "ters yercekimi oyuncuyu tavana indirdi")
	_dogrula(o.position.y < b.baslangic.y - 100.0, "oyuncu haritanin ust yarisinda")
	o.queue_free()
	b.queue_free()
	await get_tree().process_frame


func _diken_testi() -> void:
	Ayarlar.sifirla()
	Ayarlar.secilen_bolum = 3          # "4 — Diken": zeminde 14..22 sutunlarinda diken var
	var oyun: Node2D = OYUN.instantiate()
	add_child(oyun)
	await get_tree().physics_frame
	var o: CharacterBody2D = oyun.get_node("Dunya/Oyuncu")
	o.girdi_acik = false
	var baslangic: Vector2 = o.position
	_dogrula(oyun.olum == 0, "baslangicta olum yok")
	o.position = Vector2(16 * 14 + 8, baslangic.y)   # ilk dikenin uzerine isinla
	for i in 6:
		await get_tree().physics_frame
	_dogrula(oyun.olum == 1, "diken temasi olum sayaci artirdi (%d)" % oyun.olum)
	_dogrula(not o.yasiyor, "oyuncu oldu")
	await get_tree().create_timer(0.6).timeout
	_dogrula(o.yasiyor, "oyuncu otomatik yeniden dogdu")
	_dogrula(o.position.distance_to(baslangic) < 4.0, "bolum basina dondu")
	_dogrula(o.yercekimi_yonu == 1.0, "yercekimi de basa dondu")
	oyun.queue_free()
	await get_tree().process_frame


func _kristal_testi() -> void:
	Ayarlar.sifirla()
	Ayarlar.secilen_bolum = 0
	var oyun: Node2D = OYUN.instantiate()
	add_child(oyun)
	await get_tree().physics_frame
	var o: CharacterBody2D = oyun.get_node("Dunya/Oyuncu")
	o.girdi_acik = false
	var bolum: Bolum = oyun.get_node("Dunya/Bolum")
	_dogrula(not Ayarlar.kristal_var(0), "baslangicta kristal yok")
	o.position = bolum.kristal_konumu
	for i in 6:
		await get_tree().physics_frame
	_dogrula(Ayarlar.kristal_var(0), "kristal toplandi ve kaydedildi")
	_dogrula(Ayarlar.kristal_sayisi() == 1, "kristal sayaci 1 (%d)" % Ayarlar.kristal_sayisi())
	_dogrula(not bolum.get_node("Kristal").visible, "toplanan kristal gorunmuyor")
	# Olup yeniden dogunca kristal geri gelmemeli.
	o.position = bolum.baslangic
	oyun.yeniden_basla()
	await get_tree().physics_frame
	_dogrula(not bolum.get_node("Kristal").visible, "yeniden dogunca kristal geri gelmedi")
	oyun.queue_free()
	await get_tree().process_frame


func _kontrol_testi() -> void:
	Ayarlar.sifirla()
	var hedef := -1
	for i in Ayarlar.bolum_sayisi():
		for ham in Ayarlar.bolum(i)["harita"]:
			if String(ham).count("P") > 0:
				hedef = i
				break
		if hedef >= 0:
			break
	_dogrula(hedef >= 0, "kontrol noktasi olan bir bolum bulundu")
	if hedef < 0:
		return
	Ayarlar.acilan_bolum = hedef
	Ayarlar.secilen_bolum = hedef
	var oyun: Node2D = OYUN.instantiate()
	add_child(oyun)
	await get_tree().physics_frame
	var o: CharacterBody2D = oyun.get_node("Dunya/Oyuncu")
	o.girdi_acik = false
	var bolum: Bolum = oyun.get_node("Dunya/Bolum")
	var baslangic: Vector2 = bolum.baslangic
	o.position = bolum.kontrol_konumu
	for i in 6:
		await get_tree().physics_frame
	_dogrula(bolum.get_node("Kontrol/Gorsel").frame == 1, "kontrol noktasi etkinlesti")
	o.oldur()
	await get_tree().create_timer(0.6).timeout
	_dogrula(o.position.distance_to(baslangic) > 32.0, "olunce bolum basina DONMEDI")
	_dogrula(absf(o.position.x - bolum.kontrol_konumu.x) < 4.0, "kontrol noktasinda dogdu")
	oyun.queue_free()
	await get_tree().process_frame


func _kapi_testi() -> void:
	Ayarlar.sifirla()
	Ayarlar.secilen_bolum = 0
	var oyun: Node2D = OYUN.instantiate()
	add_child(oyun)
	await get_tree().physics_frame
	var o: CharacterBody2D = oyun.get_node("Dunya/Oyuncu")
	o.girdi_acik = false
	_dogrula(oyun.bolum_i == 0, "1. bolumde basladi")
	var kapi: Area2D = oyun.get_node("Dunya/Bolum/Kapi")
	o.position = kapi.get_child(0).global_position
	for i in 6:
		await get_tree().physics_frame
	_dogrula(Ayarlar.en_iyi.has(0), "kapiya varinca en iyi sure kaydedildi")
	_dogrula(Ayarlar.madalya_al(0) == 3, "hizli bitis altin madalya verdi (%d)" % Ayarlar.madalya_al(0))
	_dogrula(Ayarlar.acilan_bolum == 1, "2. bolum acildi (%d)" % Ayarlar.acilan_bolum)
	await get_tree().create_timer(1.6).timeout
	_dogrula(oyun.bolum_i == 1, "sonraki boluma gecildi (%d)" % (oyun.bolum_i + 1))
	_dogrula(oyun.get_node("Dunya/Bolum") != null, "yeni bolum kuruldu")

	# kalan butun bolumleri kapiya isinlayarak bitir: zincir sonuna kadar yuruyor mu?
	var tur := 0
	while oyun.bolum_i < Ayarlar.bolum_sayisi() - 1 and tur < 30:
		tur += 1
		await _kapiya_dokun(oyun, o)
	var son: int = oyun.bolum_i
	await _kapiya_dokun(oyun, o)
	_dogrula(son == Ayarlar.bolum_sayisi() - 1, "son boluma kadar gelindi (%d)" % (son + 1))
	_dogrula(oyun.get_node("Arayuz/Bitis").visible, "bitis ekrani acildi")
	_dogrula(Ayarlar.acilan_bolum == Ayarlar.bolum_sayisi() - 1, "tum bolumler acildi")
	_dogrula(Ayarlar.en_iyi.size() == Ayarlar.bolum_sayisi(), "her bolumun en iyi suresi kaydedildi")
	_dogrula(Ayarlar.madalya.size() == Ayarlar.bolum_sayisi(), "her bolumden madalya kazanildi")
	oyun.queue_free()
	await get_tree().process_frame


func _kapiya_dokun(oyun: Node2D, o: CharacterBody2D) -> void:
	var kapi: Area2D = oyun.get_node_or_null("Dunya/Bolum/Kapi")
	if kapi == null:
		_dogrula(false, "bolum %d: kapi dugumu bulunamadi" % (oyun.bolum_i + 1))
		return
	o.position = kapi.get_child(0).global_position
	for i in 6:
		await get_tree().physics_frame
	await get_tree().create_timer(1.6).timeout
