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
	print("— Affetme: kojot cevirme —")
	await _kojot_testi()
	print("— Yeniden deneme suresi —")
	await _yeniden_deneme_testi()
	print("— Isabet kutulari —")
	await _isabet_testi()
	print("— Oda tabanli kamera —")
	await _kamera_testi()
	print("— Inis gostergesi —")
	await _inis_testi()
	print("— En az cevirme hedefi —")
	_en_az_testi()
	print("— Hayalet yaris —")
	await _hayalet_testi()
	print("— Yardim modu —")
	await _yardim_testi()
	print("— Olum haritasi —")
	await _olum_haritasi_testi()
	print("— Simge yazi tipi —")
	await _simge_testi()
	print("— Dokunmatik metinler —")
	await _dokunma_metni_testi()
	print("— Olculmus esikler (rota_verisi) —")
	_olcum_testi()
	print("— Altin hayalet —")
	await _altin_hayalet_testi()
	print("— Hareketli parcalar ve inis gostergesi —")
	await _hareketli_inis_testi()
	print("— Ayarlarin kaydi —")
	_ayar_kayit_testi()
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
		# Esikler bolum verisinden DEGIL olculmus rota_verisi.gd'den gelir
		# (bkz. Ayarlar.esik). Test de oradan okumali, yoksa iki kaynak olur.
		var v := Ayarlar.esik(i)
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


# --- tur 2: affetme, okunurluk, farklilastiranlar ----------------------------

## Cevirmeyi affet: yuzeyden yeni ayrildiysan cevirme hakkin CEVIR_KOJOT kadar surer.
func _kojot_testi() -> void:
	var b := Bolum.new()
	add_child(b)
	b.kur(Bolumler.BOLUMLER[0])
	var o: CharacterBody2D = OYUNCU.instantiate()
	add_child(o)
	o.girdi_acik = false
	o.hazirla(b.baslangic)
	for i in 30:
		await get_tree().physics_frame
	_dogrula(o.is_on_floor(), "kojot: oyuncu once zeminde")
	# Yuzeyden yeni ayrildi: hala cevirebilmeli.
	o.position.y -= 40.0
	for i in 2:
		await get_tree().physics_frame
	_dogrula(not o.is_on_floor(), "kojot: oyuncu havada")
	_dogrula(o.cevir(), "kojot suresi icinde havada cevirme KABUL edildi")

	# Ayni durum, ama kojot suresi dolduktan sonra: reddedilmeli.
	o.hazirla(b.baslangic)
	for i in 30:
		await get_tree().physics_frame
	o.position.y -= 40.0
	for i in 14:      # 14 kare = 0,23 sn > CEVIR_KOJOT (0,08)
		await get_tree().physics_frame
	_dogrula(not o.cevir(), "kojot suresi bitince havada cevirme REDDEDILDI")
	_dogrula(Ayarlar.CEVIR_KOJOT >= 0.07 and Ayarlar.CEVIR_TAMPONU >= 0.09,
		"kojot 0,08 + tampon 0,10 (%.2f / %.2f)" % [Ayarlar.CEVIR_KOJOT, Ayarlar.CEVIR_TAMPONU])
	o.queue_free()
	b.queue_free()
	await get_tree().process_frame


## Yeniden deneme 0,3 sn'nin ALTINDA olmali ve sahne yeniden YUKLENMEMELI.
func _yeniden_deneme_testi() -> void:
	Ayarlar.sifirla()
	Ayarlar.secilen_bolum = 12         # 64 sutunluk, hareketli parcali bolum
	var oyun: Node2D = OYUN.instantiate()
	add_child(oyun)
	await get_tree().physics_frame
	var o: CharacterBody2D = oyun.get_node("Dunya/Oyuncu")
	o.girdi_acik = false
	var bolum: Bolum = oyun.get_node("Dunya/Bolum")
	var kimlik := bolum.get_instance_id()
	# Hareketli parcayi yerinden oynat: yeniden denemede basa donmeli.
	var hareketli: Node2D = null
	for c in bolum.get_children():
		if c is AnimatableBody2D or (c is Area2D and c.name.begins_with("@")):
			hareketli = c
	o.position += Vector2(120.0, 0.0)
	for i in 30:
		await get_tree().physics_frame
	var basla := Time.get_ticks_msec()
	o.oldur()
	var tur := 0
	while not o.yasiyor and tur < 200:
		tur += 1
		await get_tree().process_frame
	var gecen := Time.get_ticks_msec() - basla
	_dogrula(o.yasiyor, "olumden sonra yeniden dogdu")
	_dogrula(gecen < 300, "yeniden deneme 0,3 sn'den kisa (%d ms)" % gecen)
	_dogrula(bolum.get_instance_id() == kimlik, "sahne yeniden YUKLENMEDI (ayni bolum dugumu)")
	if hareketli != null:
		_dogrula(is_instance_valid(hareketli), "hareketli parca ayni dugum olarak kaldi")
	oyun.queue_free()
	await get_tree().process_frame


## Oldurucu seylerin isabet kutusu gorselinden kucuk olmali (diken 16x16,
## gezgin diken 24x10). Basilan platformda boyle bir pay YOK — kutu gorselle ayni.
func _isabet_testi() -> void:
	var pay: int = Ayarlar.DIKEN_PAY
	_dogrula(pay >= 2 and pay <= 3, "diken payi 2-3 px (%d)" % pay)
	# Sabit diken: 40. bolumde degil, dikenli 4. bolumde
	var b := Bolum.new()
	add_child(b)
	b.kur(Bolumler.BOLUMLER[3])
	await get_tree().physics_frame
	var dikenler: Area2D = b.get_node("Dikenler")
	_dogrula(dikenler.get_child_count() > 0, "sabit diken kutulari kuruldu")
	var en_dar := 999.0
	for c in dikenler.get_children():
		var sekil: RectangleShape2D = (c as CollisionShape2D).shape
		en_dar = minf(en_dar, minf(16.0 - sekil.size.x, 16.0 - sekil.size.y) * 0.5)
	_dogrula(en_dar >= float(pay), "sabit diken kutusu gorselden >= %d px icerde (%.1f)" % [pay, en_dar])
	b.queue_free()
	await get_tree().process_frame

	# Gezgin diken: 11. bolumde var
	var g := Bolum.new()
	add_child(g)
	g.kur(Bolumler.BOLUMLER[10])
	await get_tree().physics_frame
	var bulundu := false
	for c in g.get_children():
		if not (c is Area2D) or c.name in ["Dikenler", "Kapi", "Kristal", "Kontrol"]:
			continue
		var sekil2: RectangleShape2D = (c.get_child(0) as CollisionShape2D).shape
		bulundu = true
		_dogrula(is_equal_approx(sekil2.size.x, 24.0 - pay * 2) and is_equal_approx(sekil2.size.y, 10.0 - pay * 2),
			"gezgin diken kutusu gorselden %d px icerde (%s)" % [pay, sekil2.size])
	_dogrula(bulundu, "gezgin diken bulundu")
	g.queue_free()
	await get_tree().process_frame


## Oda tabanli kamera: kamera oda icinde SABIT durur, oda degisince atlar ve
## hicbir zaman bolumun disini gostermez.
func _kamera_testi() -> void:
	Ayarlar.sifirla()
	Ayarlar.acilan_bolum = 12
	Ayarlar.secilen_bolum = 12         # 64 sutun = 1024 px = 2 oda
	var oyun: Node2D = OYUN.instantiate()
	add_child(oyun)
	await get_tree().physics_frame
	var o: CharacterBody2D = oyun.get_node("Dunya/Oyuncu")
	o.girdi_acik = false
	var kam: Camera2D = oyun.get_node("Dunya/Kamera")
	var bolum: Bolum = oyun.get_node("Dunya/Bolum")
	_dogrula(bolum.genislik_px == 1024, "13. bolum 1024 px genis (%d)" % bolum.genislik_px)

	o.position.x = 100.0
	oyun._kamera_guncelle(true)
	var ilk: float = kam.position.x
	_dogrula(is_equal_approx(ilk, 320.0), "ilk oda ortalandi (%.0f)" % ilk)
	o.position.x = 600.0
	oyun._kamera_guncelle(false)
	_dogrula(is_equal_approx(kam.position.x, ilk), "ayni odada kamera KIMILDAMADI (%.0f)" % kam.position.x)
	o.position.x = 700.0
	oyun._kamera_guncelle(true)
	_dogrula(kam.position.x > ilk, "sonraki odaya gecildi (%.0f)" % kam.position.x)
	_dogrula(kam.position.x + 320.0 <= 1024.0 + 0.5, "kamera bolumun sagini asmadi")
	_dogrula(kam.position.x - 320.0 >= -0.5, "kamera bolumun solunu asmadi")
	_dogrula(is_equal_approx(kam.position.y, bolum.yukseklik_px * 0.5), "kamera dikeyde bolumu ortaladi")
	oyun.queue_free()
	await get_tree().process_frame


## Inis gostergesi: cevirme tusuna basilsa oyuncu nereye duserdi?
func _inis_testi() -> void:
	Ayarlar.sifirla()
	Ayarlar.secilen_bolum = 0
	var oyun: Node2D = OYUN.instantiate()
	add_child(oyun)
	await get_tree().physics_frame
	var o: CharacterBody2D = oyun.get_node("Dunya/Oyuncu")
	o.girdi_acik = false
	for i in 20:
		await get_tree().physics_frame
	_dogrula(o.is_on_floor(), "inis testi: oyuncu zeminde")
	var t: Dictionary = oyun._inis_tahmini()
	_dogrula(bool(t["var"]), "inis noktasi bulundu")
	_dogrula(float(t["yon"]) == -1.0, "cevirince yercekimi yukari doner")
	_dogrula(float(t["konum"].y) < 40.0, "inis noktasi tavanda (y=%.0f)" % float(t["konum"].y))
	_dogrula(not bool(t["tehlike"]), "1. bolumde inis yolunda diken yok")
	# 5. bolum: tavanda diken var, ustune cevirmek tehlikeli olmali
	oyun.bolum_yukle(4)
	await get_tree().physics_frame
	var b: Bolum = oyun.get_node("Dunya/Bolum")
	var diken_sutun := -1
	var tavan: String = b.harita[1]
	for c in tavan.length():
		if tavan[c] == "v":
			diken_sutun = c
			break
	_dogrula(diken_sutun > 0, "5. bolumde tavan dikeni var")
	o.position.x = diken_sutun * Ayarlar.HUCRE + 8.0
	for i in 12:
		await get_tree().physics_frame
	var t2: Dictionary = oyun._inis_tahmini()
	_dogrula(bool(t2["var"]) and bool(t2["tehlike"]), "diken altinda cevirme TEHLIKELI isaretlendi")
	oyun.queue_free()
	await get_tree().process_frame


## Ikinci hedef: her bolumun "en az cevirme" sayisi ve rekor tutulmasi.
func _en_az_testi() -> void:
	Ayarlar.sifirla()
	for i in Ayarlar.bolum_sayisi():
		var h := Ayarlar.en_az_hedef(i)
		_dogrula(h >= 0 and h % 2 == 0, "bolum %d: en az cevirme cift ve >= 0 (%d)" % [i + 1, h])
		_dogrula(Ayarlar.en_az_al(i) == -1, "bolum %d: baslangicta cevirme rekoru yok" % (i + 1))
	_dogrula(Ayarlar.en_az_hedef(0) == 0, "1. bolum cevirmesiz bitirilebilir")
	_dogrula(Ayarlar.en_az_hedef(1) == 2, "2. bolum en az 2 cevirme (%d)" % Ayarlar.en_az_hedef(1))
	Ayarlar.bolum_bitti(1, 9.0, 6)
	_dogrula(Ayarlar.en_az_al(1) == 6, "cevirme rekoru kaydedildi (%d)" % Ayarlar.en_az_al(1))
	Ayarlar.bolum_bitti(1, 9.0, 9)
	_dogrula(Ayarlar.en_az_al(1) == 6, "daha KOTU cevirme rekoru ezmedi (%d)" % Ayarlar.en_az_al(1))
	var sonuc: Dictionary = Ayarlar.bolum_bitti(1, 9.0, 3)
	_dogrula(Ayarlar.en_az_al(1) == 3 and bool(sonuc["az_rekor"]), "daha IYI cevirme rekoru yazildi")


## Hayalet yaris: en iyi kosunun kaydi diske yazilir ve geri okunur.
func _hayalet_testi() -> void:
	Ayarlar.sifirla()
	var yol := PackedVector2Array([Vector2(1, 2), Vector2(3, 4), Vector2(5, 6)])
	Ayarlar.hayalet_kaydet(7, yol)
	var geri := Ayarlar.hayalet_yukle(7)
	_dogrula(geri.size() == 3 and geri[2] == Vector2(5, 6), "hayalet kaydedildi ve okundu (%d nokta)" % geri.size())
	_dogrula(Ayarlar.hayalet_yukle(19).is_empty(), "kaydi olmayan bolumde hayalet yok")
	# Yardim modunda hayalet kaydedilmez (adil olmayan kosu kayit olmaz).
	var onceki := Ayarlar.yardim_acik
	Ayarlar.yardim_acik = true
	Ayarlar.hayalet_kaydet(18, yol)
	_dogrula(Ayarlar.hayalet_yukle(18).is_empty(), "yardim modunda hayalet KAYDEDILMEDI")
	Ayarlar.yardim_acik = onceki

	# Oyun sahnesinde hayalet gercekten kosuyor mu?
	Ayarlar.secilen_bolum = 7
	# 2 saniyelik kayit: testin kac kare surdugune bagli kalmasin.
	var uzun := PackedVector2Array()
	for i in 60:
		uzun.append(Vector2(60.0 + i, 300.0))
	Ayarlar.hayalet_kaydet(7, uzun)
	var oyun: Node2D = OYUN.instantiate()
	add_child(oyun)
	await get_tree().physics_frame
	oyun.get_node("Dunya/Oyuncu").girdi_acik = false
	var h: Sprite2D = oyun.get_node("Dunya/Hayalet")
	for i in 4:
		await get_tree().process_frame
	_dogrula(h.visible, "hayalet ekranda")
	_dogrula(absf(h.global_position.y - 300.0) < 1.0 and h.global_position.x >= 59.0,
		"hayalet kayittaki yolu izliyor (%s)" % h.global_position)
	oyun.queue_free()
	await get_tree().process_frame


## Yardim modu: hiz, olumsuzluk, bolum atlama; madalya YOK, kristal VAR.
func _yardim_testi() -> void:
	Ayarlar.sifirla()
	var yedek := [Ayarlar.yardim_acik, Ayarlar.yardim_hiz, Ayarlar.yardim_olumsuz]

	# Oyun hizi
	Ayarlar.yardim_acik = true
	Ayarlar.yardim_hiz = 0.5
	Ayarlar.zaman_uygula()
	_dogrula(is_equal_approx(Engine.time_scale, 0.5), "yardim modu oyunu yavaslatti (%.2f)" % Engine.time_scale)
	Ayarlar.zaman_sifirla()
	_dogrula(is_equal_approx(Engine.time_scale, 1.0), "menude hiz 1.0'a dondu")
	Ayarlar.yardim_hiz = 1.0

	# Madalya ve sure kaydi tutulmaz, bolum yine acilir
	var sonuc: Dictionary = Ayarlar.bolum_bitti(0, 0.5, 2)
	_dogrula(int(sonuc["madalya"]) == 0 and not bool(sonuc["rekor"]), "yardim modunda madalya/rekor verilmedi")
	_dogrula(bool(sonuc["yardim"]), "sonuc yardim modunu bildiriyor")
	_dogrula(not Ayarlar.en_iyi.has(0), "yardim modunda en iyi sure YAZILMADI")
	_dogrula(Ayarlar.en_az_al(0) == -1, "yardim modunda cevirme rekoru YAZILMADI")
	_dogrula(Ayarlar.acilan_bolum == 1, "yardim modunda da sonraki bolum acildi")
	Ayarlar.kristal_topla(0)
	_dogrula(Ayarlar.kristal_var(0), "yardim modunda kristal SAYILIYOR")

	# Bolum atlama
	Ayarlar.bolum_ac(1)
	_dogrula(Ayarlar.acilan_bolum == 2, "bolum atlama yolu acti (%d)" % Ayarlar.acilan_bolum)

	# Olumsuzluk: diken oldurmez, geri iter
	Ayarlar.yardim_olumsuz = true
	Ayarlar.sifirla()
	Ayarlar.acilan_bolum = 3
	Ayarlar.secilen_bolum = 3
	var oyun: Node2D = OYUN.instantiate()
	add_child(oyun)
	await get_tree().physics_frame
	var o: CharacterBody2D = oyun.get_node("Dunya/Oyuncu")
	o.girdi_acik = false
	var basla: Vector2 = o.position
	o.position = Vector2(16 * 14 + 8, basla.y)
	for i in 8:
		await get_tree().physics_frame
	_dogrula(o.yasiyor, "yardim modunda diken OLDURMEDI")
	_dogrula(oyun.olum == 0, "olum sayaci artmadi (%d)" % oyun.olum)
	oyun.queue_free()
	await get_tree().process_frame

	Ayarlar.yardim_acik = yedek[0]
	Ayarlar.yardim_hiz = yedek[1]
	Ayarlar.yardim_olumsuz = yedek[2]
	Ayarlar.zaman_sifirla()


## Olum haritasi: bolum bitince oldugun her nokta isaretlenir.
func _olum_haritasi_testi() -> void:
	Ayarlar.sifirla()
	Ayarlar.secilen_bolum = 0
	var oyun: Node2D = OYUN.instantiate()
	add_child(oyun)
	await get_tree().physics_frame
	var o: CharacterBody2D = oyun.get_node("Dunya/Oyuncu")
	o.girdi_acik = false
	var harita: Panel = oyun.get_node("Arayuz/OlumHaritasi")
	_dogrula(not harita.visible, "baslangicta olum haritasi kapali")
	for tur in 2:
		o.oldur()
		await get_tree().create_timer(0.4).timeout
	_dogrula(oyun.olum == 2, "iki kez olundu (%d)" % oyun.olum)
	var kapi: Area2D = oyun.get_node("Dunya/Bolum/Kapi")
	o.position = kapi.get_child(0).global_position
	for i in 6:
		await get_tree().physics_frame
	_dogrula(harita.visible, "bolum bitince olum haritasi acildi")
	var alan: Control = oyun.get_node("Arayuz/OlumHaritasi/Alan")
	var isaret := 0
	for c in alan.get_children():
		if c is Label and (c as Label).text == "×":
			isaret += 1
	_dogrula(isaret == 2, "her olum icin bir X isareti (%d)" % isaret)
	_dogrula(alan.get_child_count() > isaret, "haritanin plani da cizildi")
	oyun.queue_free()
	await get_tree().process_frame


## Yeni ayarlar kayit dosyasina gercekten yaziliyor ve geri okunuyor mu?
## Web yapisinda sistem yazi tipi yedegi yoktur: gomulu Open Sans'ta olmayan
## her simge kutu olarak cikar. Bu test web'deki durumu olcer (kur() cagrilmazsa
## ayni test kalir), cunku has_char sistem yazi tipine bakmaz.
func _simge_testi() -> void:
	_dogrula(ResourceLoader.exists(Simgeler.YOL), "simge yazi tipi projede var")
	_dogrula(Simgeler.eksikler("⟳●—") == "",
		"HUD simgeleri yazi tipinde var (eksik: '%s')" % Simgeler.eksikler("⟳●—"))

	# Test bos olmasin: yedek kaldirilinca eksik gercekten cikmali. Cikmiyorsa
	# bu test web'i degil masaustunu olcuyor demektir.
	var yedekler: Array[Font] = ThemeDB.fallback_font.fallbacks.duplicate()
	ThemeDB.fallback_font.fallbacks = []
	_dogrula(Simgeler.eksikler("⟳●") == "⟳●",
		"yedeksiz yazi tipinde simgeler GERCEKTEN eksik (web durumu olculuyor)")
	ThemeDB.fallback_font.fallbacks = yedekler

	# kur() birden cok kez cagrilabiliyor (menu + oyun sahnesi); yedek bir kez eklenmeli.
	var once: int = ThemeDB.fallback_font.fallbacks.size()
	Simgeler.kur()
	Simgeler.kur()
	_dogrula(ThemeDB.fallback_font.fallbacks.size() == once,
		"kur() tekrar cagrilinca yedek cogalmadi (%d)" % ThemeDB.fallback_font.fallbacks.size())

	# Asil guvence: gercekten ekrana basilan metinlerde eksik simge kalmasin.
	Ayarlar.sifirla()
	Ayarlar.secilen_bolum = 0
	var oyun: Node2D = OYUN.instantiate()
	add_child(oyun)
	await get_tree().physics_frame
	await get_tree().process_frame
	var metin := ""
	for ad in ["Ad", "Sayac", "Hedef", "Ipucu", "KristalYazi"]:
		metin += (oyun.get_node("Arayuz/" + ad) as Label).text
	_dogrula(Simgeler.eksikler(metin) == "",
		"HUD metinlerinde eksik simge yok (eksik: '%s')" % Simgeler.eksikler(metin))
	oyun.queue_free()
	await get_tree().process_frame


## Dokunmatik cihazda "A / D ile yürü" yalan. Metinler tablodan geciriliyor.
func _dokunma_metni_testi() -> void:
	var yedek := Ayarlar.dokunmatik_algilandi
	Ayarlar.dokunmatik_algilandi = false

	# Tablodaki her klavye terimi gercekten bir arayuz metninde geciyor mu?
	# Gecmiyorsa metin degismis, ceviri sessizce olu kalmis demektir.
	var tum := "Zıplama yok. Tek tuş: yerçekimini çevir."
	for i in Ayarlar.bolum_sayisi():
		tum += String(Ayarlar.bolum(i)["ipucu"])
	for c in Ayarlar.DOKUNMA_METNI:
		_dogrula(tum.contains(String(c[0])), "ceviri hedefi arayuzde duruyor: '%s'" % c[0])

	if not DisplayServer.is_touchscreen_available():
		_dogrula(Ayarlar.kontrol_metni(tum) == tum, "masaustunde metin degismiyor")

	Ayarlar.dokunmatik_algilandi = true
	_dogrula(Ayarlar.dokunmatik_mi(), "ekran dokunusu dokunmatik modu aciyor")
	var cevrilmis := Ayarlar.kontrol_metni(tum)
	for c in Ayarlar.DOKUNMA_METNI:
		_dogrula(not cevrilmis.contains(String(c[0])), "klavye terimi kalkti: '%s'" % c[0])
		_dogrula(cevrilmis.contains(String(c[1])), "dokunma karsiligi kondu: '%s'" % c[1])
	_dogrula(Simgeler.eksikler(cevrilmis) == "", "dokunma metinlerinde eksik simge yok")

	# Dokunus algilaninca oyun sahnesi alanlari acmali ve ipucunu degistirmeli.
	Ayarlar.sifirla()
	Ayarlar.dokunmatik_algilandi = false
	Ayarlar.secilen_bolum = 0
	var oyun: Node2D = OYUN.instantiate()
	add_child(oyun)
	await get_tree().physics_frame
	var ipucu: Label = oyun.get_node("Arayuz/Ipucu")
	var alanlar: Control = oyun.get_node("Arayuz/Dokunmatik")
	if not DisplayServer.is_touchscreen_available():
		_dogrula(not alanlar.visible, "masaustunde dokunma alanlari kapali")
		_dogrula(ipucu.text.contains("A / D"), "masaustunde klavye ipucu duruyor")
	Ayarlar.dokunmatik_algilandi = true
	Ayarlar.dokunmatik_degisti.emit()
	_dogrula(alanlar.visible, "dokunus algilaninca alanlar acildi")
	_dogrula(not ipucu.text.contains("A / D"), "ipucu dokunmaya cevrildi: '%s'" % ipucu.text)
	# Alanlar iki kez kurulunca dugme sinyali cogalmamali (tek dokunus = tek basma).
	var sol: Button = alanlar.get_node("Sol")
	_dogrula(sol.button_down.get_connections().size() == 1,
		"alan sinyali tek kez bagli (%d)" % sol.button_down.get_connections().size())
	oyun.queue_free()
	await get_tree().process_frame
	Ayarlar.dokunmatik_algilandi = yedek


## Esikler TEK YERDEN: tools/bot.gd'nin urettigi scripts/rota_verisi.gd.
func _olcum_testi() -> void:
	_dogrula(RotaVerisi.VERI.size() == Ayarlar.bolum_sayisi(),
		"rota verisi 20 bolum iceriyor (%d)" % RotaVerisi.VERI.size())
	var olculen := 0
	for i in Ayarlar.bolum_sayisi():
		var e := Ayarlar.esik(i)
		var v: Dictionary = RotaVerisi.VERI[i]
		var ad := "bolum %d olcum" % (i + 1)
		# Esik gercekten URETILEN dosyadan mi geliyor, yoksa geometri yedeginden mi?
		_dogrula(is_equal_approx(float(e["altin"]), float(v["altin"])),
			ad + ": esik uretilen dosyadan geliyor")
		_dogrula(float(e["altin"]) >= float(v["sure"]),
			ad + ": altin esigi botun kosusundan dusuk degil (%.2f >= %.2f)" % [
				float(e["altin"]), float(v["sure"])])
		_dogrula(float(e["altin"]) < float(e["gumus"]) and float(e["gumus"]) < float(e["bronz"]),
			ad + ": altin < gumus < bronz")
		# Olculen en az cevirme, geometri hedefinden DAHA COK olamaz: geometri
		# hedefi bilerek comert tarafta hatalidir, olcum onu ancak dusurur.
		_dogrula(Ayarlar.en_az_hedef(i) <= int(Ayarlar.bolum(i).get("cevirme", 0)),
			ad + ": olculen cevirme hedefi geometriyi asmiyor (%d <= %d)" % [
				Ayarlar.en_az_hedef(i), int(Ayarlar.bolum(i).get("cevirme", 0))])
		if not bool(v["tahmin"]):
			olculen += 1
			_dogrula(int(v["biten"]) >= 1 and int(v["kosu"]) >= 5,
				ad + ": en az 5 kosudan en az 1'i bitti (%d/%d)" % [int(v["biten"]), int(v["kosu"])])
	_dogrula(olculen == Ayarlar.bolum_sayisi(),
		"%d bolumun %d'i gercekten olculdu (tahmin degil)" % [Ayarlar.bolum_sayisi(), olculen])
	# Veri yoksa oyun yine calismali: sinir disi indis geometri yedegine duser.
	var yedek := Ayarlar.esik(9999)
	_dogrula(bool(yedek["tahmin"]), "veri disi indis geometri yedegine duser")


## Altin hayalet: botun olculmus kosusu ayri bir hedef olarak kosar ve
## oyuncunun kendi hayaletiyle KARISMAZ.
func _altin_hayalet_testi() -> void:
	Ayarlar.sifirla()
	var bolum := 2
	var yol := AltinHayalet.yol(bolum)
	_dogrula(yol.size() > 10, "altin hayalet yolu yuklendi (%d nokta)" % yol.size())
	_dogrula(yol[0].x < yol[yol.size() - 1].x, "altin hayalet soldan saga kosuyor")
	Ayarlar.altin_hayalet = true
	_dogrula(Ayarlar.altin_hayalet_yolu(bolum).size() == yol.size(), "ayar acikken hayalet geliyor")
	Ayarlar.altin_hayalet = false
	_dogrula(Ayarlar.altin_hayalet_yolu(bolum).is_empty(), "ayar kapaliyken hayalet GELMIYOR")
	Ayarlar.altin_hayalet = true

	# Oyuncunun kendi hayaleti de ALTIN madalyali olsun: renk tek basina
	# ayirt etmeye yetmemeli, etiket yetmeli.
	var kendi := PackedVector2Array()
	for i in 120:
		kendi.append(Vector2(56.0 + i * 1.5, 328.0))
	Ayarlar.hayalet_kaydet(bolum, kendi)
	Ayarlar.madalya[bolum] = 3
	Ayarlar.secilen_bolum = bolum
	var oyun: Node2D = OYUN.instantiate()
	add_child(oyun)
	await get_tree().physics_frame
	var o: CharacterBody2D = oyun.get_node("Dunya/Oyuncu")
	o.girdi_acik = false
	var h: Sprite2D = oyun.get_node("Dunya/Hayalet")
	var a: Sprite2D = oyun.get_node("Dunya/AltinHayalet")
	for i in 30:
		await get_tree().physics_frame
	_dogrula(h.visible and a.visible, "iki hayalet de ekranda")
	_dogrula(h.global_position != a.global_position, "iki hayalet ayri yerde")
	var eh: Label = h.get_node("Ad")
	var ea: Label = a.get_node("Ad")
	_dogrula(eh.text != ea.text, "hayalet etiketleri farkli (%s / %s)" % [eh.text, ea.text])
	_dogrula(eh.visible and ea.visible, "etiketler gorunur")
	_dogrula(a.modulate != h.modulate,
		"altin madalyali oyuncunun hayaleti bile altin hayaletten ayri renkte")
	oyun.queue_free()
	await get_tree().process_frame
	Ayarlar.sifirla()


## Inis gostergesi hareketli platformu goruyor mu? (v0.3'te gormuyordu)
func _hareketli_inis_testi() -> void:
	Ayarlar.sifirla()
	Ayarlar.secilen_bolum = 7           # 8 — Asansor: 10-20 sutunlari delik, ustunde platform
	var oyun: Node2D = OYUN.instantiate()
	add_child(oyun)
	await get_tree().physics_frame
	var o: CharacterBody2D = oyun.get_node("Dunya/Oyuncu")
	var b: Bolum = oyun.get_node("Dunya/Bolum")
	o.girdi_acik = false
	var plat: Node2D = null
	for c in b.get_children():
		if c is AnimatableBody2D:
			plat = c
	_dogrula(plat != null, "8. bolumde hareketli platform var")

	# --- zaman farkindaligi: ayni kutu, ileri sarilmis zamanda bos olmali ---
	var kutu := Rect2(plat.position - Vector2(6, 6), Vector2(12, 12))
	_dogrula(b.hareketli_kesisiyor(kutu, true, 0.0), "platform su an bu kutuda")
	var bosaldi := false
	var t := 0.0
	while t < 5.0:
		if not b.hareketli_kesisiyor(kutu, true, t):
			bosaldi = true
			break
		t += 0.1
	_dogrula(bosaldi, "ileri sarilan zamanda platform kutudan cikiyor (t=%.1f sn)" % t)

	# --- inis tahmini: tavandan cevirince platformun UZERINE inmeli ---
	# Delik oldugu icin platform sayilmazsa tahmin ya bolum disina duser ya da
	# haritanin alt sinirini gosterir; ikisi de y > 300 demektir.
	o.yercekimi_yonu = -1.0
	o.up_direction = Vector2.DOWN
	o.position = Vector2(plat.position.x, float(Ayarlar.HUCRE) + Ayarlar.GOVDE.y * 0.5)
	for i in 12:
		await get_tree().physics_frame
	o.position.x = plat.position.x
	_dogrula(o.is_on_floor(), "oyuncu tavana yapisti")
	var t1: Dictionary = oyun._inis_tahmini()
	_dogrula(bool(t1["var"]), "platform ustunde inis noktasi bulundu")
	_dogrula(float(t1["konum"].y) < 260.0,
		"inis noktasi PLATFORMDA, delikten asagida degil (y=%.0f)" % float(t1["konum"].y))

	# Kontrol: PLATFORMSUZ bir delik ustunde ayni tahmin yuksek bir nokta
	# bulmamali — yoksa test platformu degil "delikte bir sey var" sanisini
	# olcuyor olurdu. (Platformu kenara itmek ise ise yaramaz: _ileri_x
	# konumu kendi araligina geri katliyor.)
	oyun.bolum_yukle(1)                 # 2 — Cevir: 15-26 delik, platform YOK
	await get_tree().physics_frame
	var b2: Bolum = oyun.get_node("Dunya/Bolum")
	var delik := String(b2.harita[b2.harita.size() - 1]).find(".")
	_dogrula(delik > 0, "2. bolumde platformsuz delik var (sutun %d)" % delik)
	o.yercekimi_yonu = -1.0
	o.up_direction = Vector2.DOWN
	o.position = Vector2(delik * Ayarlar.HUCRE + 8.0, float(Ayarlar.HUCRE) + Ayarlar.GOVDE.y * 0.5)
	for i in 12:
		await get_tree().physics_frame
	o.position.x = delik * Ayarlar.HUCRE + 8.0
	var t2: Dictionary = oyun._inis_tahmini()
	_dogrula(not bool(t2["var"]) or float(t2["konum"].y) > 300.0,
		"platformsuz delikte inis noktasi yukarida DEGIL (y=%.0f)" % float(t2["konum"].y))

	# --- govde kutusuyla diken sorgusu ---
	var d := Bolum.new()
	add_child(d)
	d.kur(Bolumler.BOLUMLER[3])         # 4 — Diken: 14-22 sutunlarinda zemin dikeni
	var satir: String = d.harita[d.harita.size() - 2]
	var sutun := satir.find("^")
	_dogrula(sutun > 0, "4. bolumde zemin dikeni var (sutun %d)" % sutun)
	# Oyuncu o sutunda zeminde dururken: merkez y = zemin ustu - govde/2
	var zemin_ust := float(d.harita.size() - 1) * float(Ayarlar.HUCRE)
	var merkez := Vector2(sutun * Ayarlar.HUCRE + 8.0, zemin_ust - Ayarlar.GOVDE.y * 0.5)
	var uzerinde := Rect2(merkez - Ayarlar.GOVDE * 0.5, Ayarlar.GOVDE)
	_dogrula(d.olumcul_kutu(uzerinde), "dikenin uzerindeki govde kutusu olumcul")
	var yukarida := Rect2(merkez - Ayarlar.GOVDE * 0.5 - Vector2(0.0, 24.0), Ayarlar.GOVDE)
	_dogrula(not d.olumcul_kutu(yukarida), "dikenin 24 px ustundeki govde kutusu olumcul DEGIL")
	# Asil bulgu: inis tahmini tek bir "ayak" noktasi ornekliyordu ve cevirme
	# sonrasi o nokta BAS oluyor (govde yaricapi kadar yukarida). Ayni yerde
	# bas noktasi tertemiz, govde ise dikenin icinde.
	var bas := merkez - Vector2(0.0, Ayarlar.GOVDE.y * 0.5)
	_dogrula(not d.olumcul_mu(bas),
		"cevirme sonrasi orneklenen bas noktasi ayni yerde TEMIZ diyor")
	_dogrula(d.olumcul_kutu(uzerinde) and not d.olumcul_mu(bas),
		"govde sorgusu nokta sorgusunun kacirdigi carpismayi yakaliyor")
	d.queue_free()
	oyun.queue_free()
	await get_tree().process_frame
	Ayarlar.sifirla()


func _ayar_kayit_testi() -> void:
	var yedek := {
		"kontrast": Ayarlar.yuksek_kontrast, "ok": Ayarlar.yercekimi_oku,
		"inis": Ayarlar.inis_gostergesi, "solak": Ayarlar.solak,
		"opak": Ayarlar.dokunmatik_opaklik, "titresim": Ayarlar.titresim,
		"yardim": Ayarlar.yardim_acik, "hiz": Ayarlar.yardim_hiz,
		"olumsuz": Ayarlar.yardim_olumsuz,
	}
	yedek["altin_h"] = Ayarlar.altin_hayalet
	Ayarlar.altin_hayalet = false
	Ayarlar.yuksek_kontrast = true
	Ayarlar.yercekimi_oku = false
	Ayarlar.inis_gostergesi = false
	Ayarlar.solak = true
	Ayarlar.dokunmatik_opaklik = 0.8
	Ayarlar.titresim = false
	Ayarlar.yardim_acik = true
	Ayarlar.yardim_hiz = 0.6
	Ayarlar.yardim_olumsuz = true
	Ayarlar.kaydet()
	# Bellegi bozup dosyadan geri okuyalim
	Ayarlar.yuksek_kontrast = false
	Ayarlar.yardim_hiz = 1.0
	Ayarlar.solak = false
	Ayarlar.yukle()
	_dogrula(not Ayarlar.altin_hayalet, "altin hayalet ayari kaydedildi")
	_dogrula(Ayarlar.yuksek_kontrast, "yuksek kontrast kaydedildi")
	_dogrula(not Ayarlar.yercekimi_oku, "yercekimi oku kaydedildi")
	_dogrula(not Ayarlar.inis_gostergesi, "inis gostergesi kaydedildi")
	_dogrula(Ayarlar.solak, "solak dokunmatik kaydedildi")
	_dogrula(is_equal_approx(Ayarlar.dokunmatik_opaklik, 0.8), "dugme opakligi kaydedildi")
	_dogrula(not Ayarlar.titresim, "titresim kaydedildi")
	_dogrula(Ayarlar.yardim_acik, "yardim modu kaydedildi")
	_dogrula(is_equal_approx(Ayarlar.yardim_hiz, 0.6), "yardim hizi kaydedildi (%.2f)" % Ayarlar.yardim_hiz)
	_dogrula(Ayarlar.yardim_olumsuz, "olumsuzluk kaydedildi")
	# Eski hale dondur
	Ayarlar.altin_hayalet = bool(yedek["altin_h"])
	Ayarlar.yuksek_kontrast = yedek["kontrast"]
	Ayarlar.yercekimi_oku = yedek["ok"]
	Ayarlar.inis_gostergesi = yedek["inis"]
	Ayarlar.solak = yedek["solak"]
	Ayarlar.dokunmatik_opaklik = yedek["opak"]
	Ayarlar.titresim = yedek["titresim"]
	Ayarlar.yardim_acik = yedek["yardim"]
	Ayarlar.yardim_hiz = yedek["hiz"]
	Ayarlar.yardim_olumsuz = yedek["olumsuz"]
	Ayarlar.kaydet()
	Ayarlar.zaman_sifirla()
