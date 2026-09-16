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
	_bolum_testi()
	print("— Cevirme mantigi —")
	await _cevirme_testi()
	print("— Diken ve yeniden baslama —")
	await _diken_testi()
	print("— Kapi ve ilerleme —")
	await _kapi_testi()
	print("%d dogrulama, %d hata" % [_sayi, _hata])
	if _hata == 0:
		print("TESTLER GECTI")
	else:
		printerr("TESTLER KALDI")
	get_tree().quit(1 if _hata > 0 else 0)


func _dogrula(kosul: bool, ad: String) -> void:
	_sayi += 1
	if kosul:
		print("  [OK] ", ad)
	else:
		_hata += 1
		printerr("  [HATA] ", ad)


func _bolum_testi() -> void:
	_dogrula(Bolumler.BOLUMLER.size() >= 12, "en az 12 bolum var (%d)" % Bolumler.BOLUMLER.size())
	for i in Bolumler.BOLUMLER.size():
		var veri: Dictionary = Bolumler.BOLUMLER[i]
		var harita: Array = veri["harita"]
		var s := 0
		var k := 0
		var genislik: int = String(harita[0]).length()
		var duzgun := true
		for ham in harita:
			var satir: String = ham
			if satir.length() != genislik:
				duzgun = false
			s += satir.count("S")
			k += satir.count("K")
		var b := Bolum.new()
		add_child(b)
		b.kur(veri)
		var ad: String = "bolum %d" % (i + 1)
		_dogrula(duzgun, ad + ": tum satirlar esit genislikte")
		_dogrula(s == 1, ad + ": tam 1 baslangic (%d)" % s)
		_dogrula(k >= 1, ad + ": en az 1 kapi (%d)" % k)
		_dogrula(b.baslangic != Vector2.ZERO, ad + ": baslangic konumu kuruldu")
		_dogrula(b.kapi_sayisi == k, ad + ": kapi alani kuruldu")
		_dogrula(b.get_node("Kati").get_child_count() > 0, ad + ": kati govde kuruldu")
		b.queue_free()
		await get_tree().process_frame


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
	_dogrula(o.cevir(), "yuzeydeyken cevirme kabul edildi")
	_dogrula(o.yercekimi_yonu == -onceki, "yercekimi yonu ters dondu")
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
	Ayarlar.secilen_bolum = 2          # "3 — Diken": zeminde 14..22 sutunlarinda diken var
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
	_dogrula(Ayarlar.acilan_bolum == 1, "2. bolum acildi (%d)" % Ayarlar.acilan_bolum)
	await get_tree().create_timer(1.3).timeout
	_dogrula(oyun.bolum_i == 1, "sonraki boluma gecildi (%d)" % (oyun.bolum_i + 1))
	_dogrula(oyun.get_node("Dunya/Bolum") != null, "yeni bolum kuruldu")

	# kalan butun bolumleri kapiya isinlayarak bitir: zincir sonuna kadar yuruyor mu?
	var tur := 0
	while oyun.bolum_i < Ayarlar.bolum_sayisi() - 1 and tur < 20:
		tur += 1
		print("    ... bolum %d kapiya goturuluyor" % (oyun.bolum_i + 1))
		await _kapiya_dokun(oyun, o)
	var son: int = oyun.bolum_i
	await _kapiya_dokun(oyun, o)
	_dogrula(son == Ayarlar.bolum_sayisi() - 1, "son boluma kadar gelindi (%d)" % (son + 1))
	_dogrula(oyun.get_node("Arayuz/Bitis").visible, "bitis ekrani acildi")
	_dogrula(Ayarlar.acilan_bolum == Ayarlar.bolum_sayisi() - 1, "tum bolumler acildi")
	_dogrula(Ayarlar.en_iyi.size() == Ayarlar.bolum_sayisi(), "her bolumun en iyi suresi kaydedildi")
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
	await get_tree().create_timer(1.3).timeout
