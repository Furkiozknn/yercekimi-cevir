extends Node
## Gelistirici araci: oyunu penceresiz sekilde surer, girdiyi kod uzerinden basar,
## belirli anlarda ekran goruntusu kaydeder. Pencere odagi gerekmez.
##
##   godot --path . res://tests/ekran.tscn -- <mod> <cikti_klasoru>
##     <mod> >= 0  : o bolumu oyna, oynanis kareleri cek
##     <mod> = -1  : menu + bolum sec ekranlari
##     <mod> = -2  : yayin paketi (yayin/ altina 4 ekran goruntusu + kapak 630x500)
##     <mod> = -3  : tur 2 ozellikleri (ok, inis gostergesi, hayalet, olum
##                   haritasi, yuksek kontrast, yardim modu, oda kamerasi)
##     <mod> = -4  : tur 3 ozellikleri (altin hayalet, platformlu inis gostergesi)
##     <mod> = -5  : tanitim kare dizisi (3 sn, 10 kare/sn) + GIF icin ham veri
##     <mod> = -6  : tur 4 (v0.5): dokunma alanlari sag el / solak, 19. bolumun
##                   yeni duzeni, gunun bolumu (menu, ters baslangic, kristal zorunlu)
##     <mod> = -7  : tur 5 (v0.6): tavan-HUD solmasi, gunluk hayalet yarisi,
##                   paylasim paneli, menude seri, kapi/kristal parilti kareleri
##
## Yakalanan kareler 1280x720 (pencere boyutu). Kapak bu kareden 630x500
## kirpilarak uretilir — itch.io kapak olcusu.

const OYUN := preload("res://scenes/oyun.tscn")
## Kapak, 1280x720 karesinin oyuncuyu ve zemini iceren bolgesinden kirpilir.
## Kamera 2x yakinlastirilarak cekilir: itch kapsulu listede 120x45'e kadar
## kuculuyor ve 1. turdaki genis kare orada tanimsiz bir koyu lekeye donuyordu.
const KAPAK_ALANI := Rect2i(325, 110, 630, 500)

var _klasor: String = "user://ekran"
var _sira: int = 0
var _oyun: Node2D


func _ready() -> void:
	var argumanlar := OS.get_cmdline_user_args()
	var mod := int(argumanlar[0]) if argumanlar.size() > 0 else 0
	if argumanlar.size() > 1:
		_klasor = argumanlar[1]
	DirAccess.make_dir_recursive_absolute(_klasor)

	# Arac ilerleme uydurur (_sahte_ilerleme) ve bazi modlar bolum bitirir, yani
	# Ayarlar.kaydet() cagrilir. Kullanicinin kayit.cfg'si bundan etkilenmesin:
	# baslarken yedekle, cikarken geri koy (tools/bot.gd de ayarlari geri veriyor).
	var kayit_vardi := FileAccess.file_exists(Ayarlar.KAYIT_YOLU)
	var kayit_yedek := FileAccess.get_file_as_bytes(Ayarlar.KAYIT_YOLU) if kayit_vardi else PackedByteArray()

	Ayarlar.sifirla()
	_varsayilan_gorunum()
	Ayarlar.acilan_bolum = Ayarlar.bolum_sayisi() - 1
	if mod == -1:
		await _menu_cek()
	elif mod == -2:
		await _yayin_cek()
	elif mod == -3:
		await _ozellik_cek()
	elif mod == -4:
		await _tur3_cek()
	elif mod == -5:
		await _tanitim_cek()
	elif mod == -6:
		await _tur4_cek()
	elif mod == -7:
		await _tur5_cek()
	else:
		await _oynanis_cek(mod)

	if kayit_vardi:
		var f := FileAccess.open(Ayarlar.KAYIT_YOLU, FileAccess.WRITE)
		if f != null:
			f.store_buffer(kayit_yedek)
			f.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Ayarlar.KAYIT_YOLU))
	get_tree().quit(0)


## Ekran goruntusu OYUNUN VARSAYILAN halini gostermeli. Ayarlar user://
## kayit.cfg'den geliyor ve bu makinede tools/bot.gd ile testler orayi
## degistirip kaydedebiliyor; oyle bir turda yayin goruntuleri oyun hissi
## kapali cekildi (cevirme izi, parcaciklar, sarsinti yok). Modlar bunun
## ustune kendi istedigini kurar.
func _varsayilan_gorunum() -> void:
	Ayarlar.oyun_hissi = true
	Ayarlar.inis_gostergesi = true
	Ayarlar.yercekimi_oku = true
	Ayarlar.altin_hayalet = true
	Ayarlar.yuksek_kontrast = false
	Ayarlar.yardim_acik = false
	Ayarlar.yardim_olumsuz = false
	Ayarlar.yardim_hiz = 1.0


func _bekle(sn: float) -> void:
	await get_tree().create_timer(sn).timeout


func _cek(ad: String, alan: Rect2i = Rect2i()) -> void:
	await RenderingServer.frame_post_draw
	var gorsel := get_viewport().get_texture().get_image()
	if alan.size.x > 0:
		gorsel = gorsel.get_region(alan)
	_sira += 1
	var yol := "%s/%02d-%s.png" % [_klasor, _sira, ad]
	var hata := gorsel.save_png(yol)
	print("ekran: %s  %dx%d  -> %d" % [yol, gorsel.get_width(), gorsel.get_height(), hata])


## Bolum Sec ekrani dolu gorunsun diye sahte ilerleme (diske YAZILMAZ).
func _sahte_ilerleme() -> void:
	for i in Ayarlar.bolum_sayisi():
		if i % 3 != 2:
			Ayarlar.kristal[i] = true
		Ayarlar.en_iyi[i] = float(Ayarlar.bolum(i)["gumus"]) - 0.4 - i * 0.05
		Ayarlar.madalya[i] = 3 if i % 4 == 0 else (2 if i % 4 != 3 else 1)


func _oyunu_ac(bolum: int) -> void:
	Ayarlar.secilen_bolum = bolum
	_oyun = OYUN.instantiate()
	add_child(_oyun)
	await _bekle(0.6)


func _oynanis_cek(bolum: int) -> void:
	await _oyunu_ac(bolum)
	await _cek("basla")
	Input.action_press("move_right")
	await _bekle(1.1)
	await _cek("yuruyor")
	Input.action_press("cevir")
	await _bekle(0.05)
	Input.action_release("cevir")
	await _bekle(0.2)
	await _cek("cevirdi")
	await _bekle(0.9)
	await _cek("tavanda")
	Input.action_release("move_right")
	await _bekle(0.4)
	await _cek("son")


## mod -1: menu ve bolum sec.
func _menu_cek() -> void:
	_sahte_ilerleme()
	var menu: Control = load("res://scenes/menu.tscn").instantiate()
	add_child(menu)
	await _bekle(0.5)
	await _cek("menu")
	menu.queue_free()
	await _bekle(0.3)
	var sec: Control = load("res://scenes/bolum_sec.tscn").instantiate()
	add_child(sec)
	await _bekle(0.5)
	await _cek("bolum-sec")
	sec.queue_free()
	await _bekle(0.3)
	var ayar: Control = load("res://scenes/ayarlar_ekrani.tscn").instantiate()
	add_child(ayar)
	await _bekle(0.5)
	await _cek("ayarlar")


## mod -2: itch.io icin 4 ekran goruntusu + kapak.
## Bolum secimi kasitli: 16. bolum (yogun diken deseni) zeminde kosarken
## olumcul degil, 3. bolum ise cevirme + tavan yurusu icin guvenli.
func _yayin_cek() -> void:
	_sahte_ilerleme()
	var menu: Control = load("res://scenes/menu.tscn").instantiate()
	add_child(menu)
	await _bekle(0.6)
	await _cek("menu")
	menu.queue_free()
	await _bekle(0.3)

	await _oyunu_ac(15)                       # 16 — Kilcik
	Input.action_press("move_right")
	await _bekle(0.9)
	await _cek("oynanis")

	# Kapak: HUD kapanir, kamera 2x yakinlasir, arka plan aydinlanir, buyuk
	# baslik konur, 630x500 kirpilir. Hepsi yalniz bu kare icin — oyunun
	# calisma ayarlari degismez.
	Input.action_release("move_right")
	_oyun.get_node("Arayuz").visible = false
	var kam: Camera2D = _oyun.get_node("Dunya/Kamera")
	var oyuncu: CharacterBody2D = _oyun.get_node("Dunya/Oyuncu")
	kam.zoom = Vector2(2.0, 2.0)
	kam.limit_left = -10000
	kam.limit_right = 10000
	kam.limit_top = -10000
	kam.limit_bottom = 10000
	kam.position = Vector2(oyuncu.position.x + 34.0, oyuncu.position.y - 30.0)
	for kat in ["Kat0", "Kat1", "Kat2"]:
		_oyun.get_node("Arka/" + kat).modulate = Color(1.9, 1.9, 2.2)
	var yazi := _kapak_yazisi()
	add_child(yazi)
	await _bekle(0.3)
	await _cek("kapak-630x500", KAPAK_ALANI)
	await _kapak_kucult()
	yazi.queue_free()
	_oyun.queue_free()
	await _bekle(0.3)

	await _oyunu_ac(2)                        # 3 — Tavan Yolu
	Input.action_press("move_right")
	await _bekle(0.85)
	Input.action_press("cevir")
	await _bekle(0.05)
	Input.action_release("cevir")
	await _bekle(0.2)
	await _cek("cevirme")
	await _bekle(0.9)
	await _cek("tavan")
	Input.action_release("move_right")


## itch kapagi listede kuculuyor: sayfa 630x500, tarama listesi ~315x250,
## en kucuk kapsul 120x45. Kapak o boyutta da bir sey anlatmali, bu yuzden
## kucultmeler burada UYGULANIYOR ve gozle denetleniyor (2. turda bu makinede
## olcekleyici yok diye atlanmisti; Image.resize zaten motorun icinde).
##
## 120x45 iki kez yaziliyor: Lanczos "iyi" olceklemeyi, bilinear ise
## tarayicinin buyuk kucultmelerde yaptigi daha kaba isi temsil ediyor.
## Karari KOTU olan belirler.
func _kapak_kucult() -> void:
	var kaynak := "%s/%02d-kapak-630x500.png" % [_klasor, _sira]
	var g := Image.load_from_file(kaynak)
	if g == null:
		printerr("kapak okunamadi: %s" % kaynak)
		return
	for ol in [[315, 250, Image.INTERPOLATE_LANCZOS, ""],
			[120, 45, Image.INTERPOLATE_LANCZOS, ""],
			[120, 45, Image.INTERPOLATE_BILINEAR, "-bilinear"]]:
		var k := g.duplicate() as Image
		k.resize(int(ol[0]), int(ol[1]), int(ol[2]))
		_sira += 1
		var yol := "%s/%02d-kapak-%dx%d%s.png" % [_klasor, _sira, int(ol[0]), int(ol[1]), String(ol[3])]
		print("ekran: %s  %dx%d  -> %d" % [yol, int(ol[0]), int(ol[1]), k.save_png(yol)])


## mod -3: tur 2'de eklenen her seyin gozle denetlenmesi.
func _ozellik_cek() -> void:
	_sahte_ilerleme()
	var yedek := [Ayarlar.yuksek_kontrast, Ayarlar.yardim_acik, Ayarlar.yardim_olumsuz]
	Ayarlar.yuksek_kontrast = false
	Ayarlar.yardim_acik = false

	# 1) Yercekimi oku + yeni HUD (sure / olum / cevirme + ikinci hedef)
	await _oyunu_ac(12)                       # 13 — Uzun Yol, 64 sutun = 2 oda
	Input.action_press("move_right")
	await _bekle(0.35)                        # 8. sutundaki diken bandina girmeden dur
	Input.action_release("move_right")
	await _bekle(0.25)
	await _cek("ok-ve-hud")

	# 2) Inis gostergesi: cevirme tusu BASILI tutulurken karsi yuzeydeki nokta
	Input.action_press("cevir")
	await _bekle(0.35)
	await _cek("inis-gostergesi")
	Input.action_release("cevir")
	await _bekle(1.0)

	# 3) Oda kamerasi: ikinci odaya gecis
	var oyuncu: CharacterBody2D = _oyun.get_node("Dunya/Oyuncu")
	oyuncu.position.x = 700.0
	await _bekle(0.5)
	await _cek("oda-2")
	Input.action_release("move_right")
	_oyun.queue_free()
	await _bekle(0.3)

	# 4) Yuksek kontrast: ayni bolum, tehlike parliyor, arka plan geri cekiliyor
	Ayarlar.yuksek_kontrast = true
	await _oyunu_ac(15)                       # 16 — Kilcik: en yogun diken deseni
	Input.action_press("move_right")
	await _bekle(0.8)
	await _cek("yuksek-kontrast")
	Input.action_release("move_right")
	_oyun.queue_free()
	Ayarlar.yuksek_kontrast = false
	await _bekle(0.3)

	# 5) Hayalet yaris: sahte bir "en iyi kosu" kaydi yaz, yaninda kossun
	var yol := PackedVector2Array()
	for i in 200:
		yol.append(Vector2(56.0 + i * 1.6, 328.0))
	Ayarlar.hayalet_kaydet(2, yol)
	await _oyunu_ac(2)
	Input.action_press("move_right")
	await _bekle(1.2)
	await _cek("hayalet")
	Input.action_release("move_right")

	# 6) Olum haritasi: iki kez ol, sonra kapiya var
	var o2: CharacterBody2D = _oyun.get_node("Dunya/Oyuncu")
	for tur in 3:
		o2.oldur()
		await _bekle(0.45)
	var kapi: Area2D = _oyun.get_node("Dunya/Bolum/Kapi")
	o2.position = kapi.get_child(0).global_position
	await _bekle(0.5)
	await _cek("olum-haritasi")
	_oyun.queue_free()
	await _bekle(0.4)

	# 7) Yardim modu: rozet + duraklatma menusundeki "Bolumu Atla"
	Ayarlar.yardim_acik = true
	Ayarlar.yardim_hiz = 0.6
	Ayarlar.yardim_olumsuz = true
	await _oyunu_ac(15)
	await _bekle(0.4)
	await _cek("yardim-rozeti")
	_oyun._duraklat.visible = true
	_oyun.get_node("Arayuz/Duraklat/Kutu/Atla").visible = true
	await _bekle(0.3)
	await _cek("yardim-duraklatma")
	_oyun.queue_free()
	await _bekle(0.3)

	# 8) Ayarlar ekrani (iki sutun)
	var ayar: Control = load("res://scenes/ayarlar_ekrani.tscn").instantiate()
	add_child(ayar)
	await _bekle(0.5)
	await _cek("ayarlar-iki-sutun")
	ayar.queue_free()

	Ayarlar.yuksek_kontrast = yedek[0]
	Ayarlar.yardim_acik = yedek[1]
	Ayarlar.yardim_olumsuz = yedek[2]
	Ayarlar.zaman_sifirla()


## mod -4: tur 3'te eklenenler.
func _tur3_cek() -> void:
	_sahte_ilerleme()

	# 1) Altin hayalet + kendi hayaletin YAN YANA. Kendi hayaletin altin
	#    madalyali (yani o da altin renkte) — etiketler ayirt ediyor mu?
	# 1. bolum bilerek secildi: bot orada hic cevirmiyor, yani iki hayalet de
	# butun kosu boyunca ZEMINDE ve acikca gorunuyor. 3. bolumde bot daha ilk
	# saniyede tavana geciyordu ve hayaletler ust HUD seridinin arkasinda
	# kaliyordu (kayitta gorunur=true diyor ama karede yoklar).
	var bolum := 0
	var altin := AltinHayalet.yol(bolum)
	if altin.is_empty():
		push_warning("altin hayalet kaydi yok: once tools/bot.tscn calistir")
	var seninki := PackedVector2Array()
	for i in maxi(altin.size(), 120):
		var p: Vector2 = altin[mini(i, altin.size() - 1)] if not altin.is_empty() else Vector2(56.0 + i * 1.6, 328.0)
		seninki.append(p + Vector2(-26.0, 0.0))
	Ayarlar.madalya[bolum] = 3
	Ayarlar.hayalet_kaydet(bolum, seninki)
	await _oyunu_ac(bolum)
	Input.action_press("move_right")
	# 0,5 sn: iki hayalet de cevirme gecisinin ortasinda, yani HUD seridinin
	# altinda ve ayri ayri secilebilir durumda (1,3 sn'de ikisi de tavanda
	# olup ust seridin arkasina giriyordu).
	await _bekle(0.5)
	print("TANI hayalet: kendi=%d altin=%d  gorunur=%s/%s  konum=%s/%s  ayar=%s" % [
		_oyun._hayalet_yol.size(), _oyun._altin_yol.size(),
		_oyun._hayalet.visible, _oyun._altin.visible,
		_oyun._hayalet.global_position, _oyun._altin.global_position,
		Ayarlar.altin_hayalet])
	await _cek("altin-hayalet")
	Input.action_release("move_right")
	_oyun.queue_free()
	await _bekle(0.3)

	# 2) Inis gostergesi hareketli platformu goruyor mu? 8 — Asansor:
	#    10-20 sutunlari arasi zemin delik, platform o deligin uzerinde
	#    gidip geliyor. Tavandan cevirince gosterge PLATFORMU isaretlemeli.
	await _oyunu_ac(7)
	var o: CharacterBody2D = _oyun.get_node("Dunya/Oyuncu")
	var b: Bolum = _oyun.get_node("Dunya/Bolum")
	var plat: Node2D = null
	for c in b.get_children():
		if c is AnimatableBody2D:
			plat = c
	if plat != null:
		o.yercekimi_yonu = -1.0
		o.up_direction = Vector2.DOWN
		o.position = Vector2(plat.position.x, 16.0 + Ayarlar.GOVDE.y * 0.5)
		await _bekle(0.5)
		# Platform gidip geliyor ve tahmin ~0,9 sn SONRASINI soruyor; o sure
		# icinde platform ~43 px yol aliyor. Yani gostergenin platformu
		# isaretledigi yer platformun SU ANKI yeri degil. Dogru noktayi
		# aramak zorundayiz — ki bu zaten duzeltmenin ta kendisi: v0.3'te
		# boyle bir nokta hic yoktu, gosterge her yerde delige dusuyordu.
		var bulundu := false
		for adim in 40:
			o.position.x = plat.position.x - 80.0 + adim * 4.0
			await get_tree().physics_frame
			var tah: Dictionary = _oyun._inis_tahmini()
			if bool(tah["var"]) and float(tah["konum"].y) < 260.0:
				bulundu = true
				break
		if not bulundu:
			push_warning("inis gostergesi platformu isaretleyen nokta bulunamadi")
	# Cevirme tusuna BASMAK ayni anda cevirmeyi de yapar; gosterge gecis
	# boyunca inecegi noktayi isaretler. Platformlu bolumde isaretin
	# platformun ustunde durmasi bu turun duzeltmesidir.
	Input.action_press("cevir")
	await _bekle(0.22)
	print("TANI inis: gorunur=%s konum=%s  platform=%s  zemin y=336" % [
		_oyun._inis.visible, _oyun._inis.position, plat.position if plat != null else "yok"])
	await _cek("inis-platform")
	Input.action_release("cevir")
	_oyun.queue_free()
	await _bekle(0.3)


## mod -5: tanitim. Cevirme ani + inis gostergesi, tam 3 saniye.
## 60 Hz'de her 6. kare yakalanir -> 30 kare, 10 kare/sn.
## Cikti: <klasor>/kare_NN.png (640x360) ve <klasor>/kareler.raw
## (320x180 RGB8, hepsi arka arkaya) — tools/gif_yap.py bunu GIF'e ceviriyor.
func _tanitim_cek() -> void:
	const KARE: int = 30
	const ARALIK: int = 6
	Ayarlar.altin_hayalet = false        ## tanitimda tek oyuncu olsun
	# 4 — Diken: 14-22 sutunlarinda ZEMIN dikeni, tavan tertemiz. Tanitimin
	# anlatmasi gereken sey tam olarak bu: dikenin uzerinden gecmiyorsun,
	# tavana dusup ustunden yuruyorsun.
	await _oyunu_ac(3)
	_oyun.get_node("Arayuz/Ipucu").visible = false
	var ham := PackedByteArray()
	Input.action_press("move_right")
	for k in KARE:
		# Iki cevirme: 5. karede yukari (dikenlerin uzerine), 23. karede
		# geri asagi. Tus BIRKAC KARE BASILI tutulur, cunku inis gostergesi
		# yalniz basiliyken gorunur. Ikinci cevirmenin gostergesi ZEMINDE
		# cikiyor ve acikca goruluyor; birincisininki tavanda, HUD seridinin
		# arkasinda kaliyor.
		if k == 5 or k == 23:
			Input.action_press("cevir")
		if k == 11 or k == 29:
			Input.action_release("cevir")
		for f in ARALIK:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var g := get_viewport().get_texture().get_image()
		g.resize(640, 360, Image.INTERPOLATE_NEAREST)
		g.save_png("%s/kare_%02d.png" % [_klasor, k])
		var kucuk := g.duplicate() as Image
		kucuk.resize(320, 180, Image.INTERPOLATE_NEAREST)
		kucuk.convert(Image.FORMAT_RGB8)
		ham.append_array(kucuk.get_data())
	Input.action_release("move_right")
	var f := FileAccess.open("%s/kareler.raw" % _klasor, FileAccess.WRITE)
	f.store_buffer(ham)
	f.close()
	print("tanitim: %d kare, ham %d bayt (320x180 RGB8)" % [KARE, ham.size()])


## mod -6: tur 4'te (v0.5) eklenenler.
func _tur4_cek() -> void:
	_sahte_ilerleme()

	# 1) Dokunma alanlari ve ipucu: sag el, sonra solak. Ipucu metni tarafi
	#    soyler; alanlarin harfleri (< > CEVIR) alanla birlikte yer degistirir.
	Ayarlar.solak = false
	await _oyunu_ac(0)
	Ayarlar.dokunmatik_algilandi = true
	Ayarlar.dokunmatik_degisti.emit()
	_oyun.get_node("Arayuz/Dokunmatik").modulate.a = 0.9   # harfler karede secilsin
	await _bekle(0.4)
	await _cek("dokunma-sag-el")
	Ayarlar.solak = true
	_oyun._dokunmatik_acildi()
	_oyun.get_node("Arayuz/Dokunmatik").modulate.a = 0.9
	await _bekle(0.4)
	await _cek("dokunma-solak")
	Ayarlar.solak = false
	Ayarlar.dokunmatik_algilandi = false
	_oyun.queue_free()
	await _bekle(0.3)

	# 2) 19 — Firtina, yeni duzen: iki oda. Ilk odada oyuncu 32. sutunda gezgin
	#    dikenle burun buruna, tepesinde TEMIZ tavan (kacis yolu); ikinci odada
	#    tavan dikeni (42-47), platformlu delik (51-57) ve kapi.
	await _oyunu_ac(18)
	var o: CharacterBody2D = _oyun.get_node("Dunya/Oyuncu")
	o.position = Vector2(32.0 * 16.0 + 8.0, 336.0 - Ayarlar.GOVDE.y * 0.5)
	await _bekle(0.7)
	await _cek("firtina-oda-1")
	o.position = Vector2(41.0 * 16.0 + 8.0, 336.0 - Ayarlar.GOVDE.y * 0.5)
	o.yercekimi_yonu = 1.0
	o.up_direction = Vector2.UP
	await _bekle(0.7)
	await _cek("firtina-oda-2")
	_oyun.queue_free()
	await _bekle(0.3)

	# 3) Gunun bolumu: menu satiri + dugme, ters baslangic, kristal zorunlu.
	var t0 := 20260916
	while Ayarlar.gunluk_degistirici(t0) != 0:
		t0 += 1
	var t1 := 20260916
	while Ayarlar.gunluk_degistirici(t1) != 1:
		t1 += 1
	Ayarlar.tarih_zorla = t0
	Ayarlar.gunluk_tarih = t0
	Ayarlar.gunluk_en_iyi = 9.87           # menude "en iyi" dolu gorunsun (diske yazilmaz)
	var menu: Control = load("res://scenes/menu.tscn").instantiate()
	add_child(menu)
	await _bekle(0.5)
	await _cek("gunluk-menu")
	menu.queue_free()
	await _bekle(0.3)
	Ayarlar.gunluk_mod = true
	await _oyunu_ac(Ayarlar.gunluk_bolum())
	# 0,6 sn sonra oyuncu tavana dogru HAVADA (ucus ~0,85 sn): ok yukari, arka
	# plan soguk. Tavana konduktan sonra ust HUD seridinin arkasinda kaliyordu.
	await _cek("gunluk-ters-baslangic")
	_oyun.queue_free()
	await _bekle(0.3)
	Ayarlar.tarih_zorla = t1
	await _oyunu_ac(Ayarlar.gunluk_bolum())
	var o2: CharacterBody2D = _oyun.get_node("Dunya/Oyuncu")
	var kapi: Area2D = _oyun.get_node("Dunya/Bolum/Kapi")
	o2.position = kapi.get_child(0).global_position
	await _bekle(0.3)
	await _cek("gunluk-kristal-zorunlu")
	_oyun.queue_free()
	Ayarlar.gunluk_mod = false
	Ayarlar.tarih_zorla = 0
	Ayarlar.gunluk_en_iyi = 0.0
	Ayarlar.gunluk_tarih = 0
	await _bekle(0.3)


## mod -7: tur 5'te (v0.6) eklenenler.
func _tur5_cek() -> void:
	_sahte_ilerleme()

	# 1) Tavan-HUD solmasi: oyuncu tavanda once sol seridin, sonra sag seridin
	#    altinda. Serit (arka + yazilari) 0,15 sn'de alfa 0,25'e iniyor.
	await _oyunu_ac(2)                        # 3 — Tavan Yolu
	var o: CharacterBody2D = _oyun.get_node("Dunya/Oyuncu")
	o.yercekimi_yonu = -1.0
	o.up_direction = Vector2.DOWN
	o.position = Vector2(120.0, float(Ayarlar.HUCRE) + Ayarlar.GOVDE.y * 0.5)
	await _bekle(0.5)
	print("TANI hud sol: sol=%.2f sag=%.2f" % [_oyun._hud_gruplari[0].modulate.a, _oyun._hud_gruplari[1].modulate.a])
	await _cek("hud-solma-sol")
	o.position.x = 520.0
	await _bekle(0.5)
	print("TANI hud sag: sol=%.2f sag=%.2f" % [_oyun._hud_gruplari[0].modulate.a, _oyun._hud_gruplari[1].modulate.a])
	await _cek("hud-solma-sag")
	_oyun.queue_free()
	await _bekle(0.3)

	# 2) Gunluk hayalet yarisi: HUD satiri + altin hayalet rakip; sonra sure
	#    ileri sarilip "hayalet kazandi" ekrani.
	var t2 := 20260916
	while Ayarlar.gunluk_degistirici(t2) != 2:
		t2 += 1
	Ayarlar.tarih_zorla = t2
	Ayarlar.gunluk_mod = true
	await _oyunu_ac(Ayarlar.gunluk_bolum())
	Input.action_press("move_right")
	await _bekle(0.5)
	await _cek("gunluk-hayalet-yarisi")
	Input.action_release("move_right")
	_oyun.sure = 999.0
	await _bekle(0.3)
	await _cek("hayalet-kazandi")
	_oyun.queue_free()
	await _bekle(0.3)

	# 3) Gunluk bitis: paylasim paneli + kopyala dugmesi. Dun de bitirilmis
	#    olsun ki panelde "seri 3 gun" yazsin.
	var dun := Time.get_datetime_dict_from_unix_time(Time.get_unix_time_from_datetime_dict(
		{"year": t2 / 10000, "month": (t2 / 100) % 100, "day": t2 % 100}) - 86400)
	Ayarlar.gunluk_seri = 2
	Ayarlar.gunluk_seri_tarih = int(dun["year"]) * 10000 + int(dun["month"]) * 100 + int(dun["day"])
	await _oyunu_ac(Ayarlar.gunluk_bolum())
	var o3: CharacterBody2D = _oyun.get_node("Dunya/Oyuncu")
	var kapi: Area2D = _oyun.get_node("Dunya/Bolum/Kapi")
	o3.position = kapi.get_child(0).global_position
	await _bekle(1.5)
	print("TANI panel: %s" % _oyun.get_node("Arayuz/Bitis/Kutu/Metin").text.replace("\n", " | "))
	await _cek("gunluk-paylasim-paneli")
	_oyun.queue_free()
	await _bekle(0.3)

	# 4) Menu: gunun bolumu satirinda seri rozeti.
	var menu: Control = load("res://scenes/menu.tscn").instantiate()
	add_child(menu)
	await _bekle(0.5)
	await _cek("gunluk-seri-menu")
	menu.queue_free()
	Ayarlar.gunluk_mod = false
	Ayarlar.tarih_zorla = 0
	Ayarlar.sifirla()
	_varsayilan_gorunum()
	Ayarlar.acilan_bolum = Ayarlar.bolum_sayisi() - 1
	await _bekle(0.3)

	# 5) Parilti: kapi ve kristalin 4 karesi tek levhada (2x) + tam bir oyun karesi.
	await _oyunu_ac(0)
	await _parilti_levhasi()
	await _cek("parilti-oyun")
	_oyun.queue_free()
	await _bekle(0.3)


## Kapinin ve kristalin 4 karesini, cizildikleri anda ekrandan kirpip yan yana
## 2x buyutulmus tek levhaya dizer. Kare numarasi cizimden SONRA okunur (o
## karede cizilen kare odur); 4'u de toplanana kadar doner.
func _parilti_levhasi() -> void:
	var b: Bolum = _oyun.get_node("Dunya/Bolum")
	var donusum := get_viewport().get_canvas_transform()
	var merkezler: Array[Vector2] = [
		donusum * (b._kapi_gorselleri[0] as Sprite2D).global_position,
		donusum * b.kristal_konumu]
	var yari := Vector2i(16, 32)            # dunya px; 1280x720 karede 2 kati
	var hucre := yari * 2 * 4               # levhada 4 kat buyutulmus (128x256)
	var levha := Image.create(8 * (hucre.x + 8) + 8, hucre.y + 16, false, Image.FORMAT_RGBA8)
	levha.fill(Color(0.75, 0.79, 0.86))
	var alinan := {}
	var deneme := 0
	while alinan.size() < 4 and deneme < 200:
		deneme += 1
		await RenderingServer.frame_post_draw
		var k: int = (b._kapi_gorselleri[0] as Sprite2D).frame
		if alinan.has(k):
			continue
		var g := get_viewport().get_texture().get_image()
		g.convert(Image.FORMAT_RGBA8)
		for m in 2:
			var c: Vector2i = Vector2i(merkezler[m] * 2.0)
			var parca := g.get_region(Rect2i(c - yari * 2, yari * 4))
			parca.resize(hucre.x, hucre.y, Image.INTERPOLATE_NEAREST)
			levha.blit_rect(parca, Rect2i(Vector2i.ZERO, hucre), Vector2i(8 + (m * 4 + k) * (hucre.x + 8), 8))
		alinan[k] = true
	_sira += 1
	var yol := "%s/%02d-parilti-kareler.png" % [_klasor, _sira]
	print("ekran: %s  %dx%d (kareler %s) -> %d" % [yol, levha.get_width(), levha.get_height(), str(alinan.keys()), levha.save_png(yol)])


## Kapak yazisi. Kirpma alani (325,110)-(955,610) mantiksal koordinatta
## x 162..477, y 55..305'e denk gelir; her sey bu dikdortgene sigar.
## 120x45'e kuculdugunde ayakta kalan iki sey: dolu koyu serit ve uzerindeki
## yuksek kontrastli iki satir.
func _kapak_yazisi() -> CanvasLayer:
	var kat := CanvasLayer.new()
	kat.layer = 15
	var serit := ColorRect.new()
	serit.color = Color(0.04, 0.04, 0.08, 0.92)
	serit.offset_left = 162.0
	serit.offset_top = 92.0
	serit.offset_right = 478.0
	serit.offset_bottom = 200.0
	kat.add_child(serit)
	var cizgi := ColorRect.new()          # ustte ince camgobegi kenar: kucukken bile secilir
	cizgi.color = Color(0.17, 0.91, 0.96, 1.0)
	cizgi.offset_left = 162.0
	cizgi.offset_top = 87.0
	cizgi.offset_right = 478.0
	cizgi.offset_bottom = 92.0
	kat.add_child(cizgi)
	var baslik := Label.new()
	baslik.text = "YERÇEKİMİ\nÇEVİR"
	baslik.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	baslik.offset_left = 162.0
	baslik.offset_top = 95.0
	baslik.offset_right = 478.0
	baslik.offset_bottom = 175.0
	baslik.add_theme_font_size_override("font_size", 34)
	baslik.add_theme_color_override("font_color", Color(0.99, 0.91, 0.38))
	baslik.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
	baslik.add_theme_constant_override("outline_size", 10)
	baslik.add_theme_constant_override("line_spacing", -4)
	kat.add_child(baslik)
	var alt := Label.new()
	alt.text = "TEK TUŞ · 20 BÖLÜM"
	alt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	alt.offset_left = 162.0
	alt.offset_top = 178.0
	alt.offset_right = 478.0
	alt.offset_bottom = 196.0
	alt.add_theme_font_size_override("font_size", 13)
	alt.add_theme_color_override("font_color", Color(0.17, 0.91, 0.96))
	alt.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
	alt.add_theme_constant_override("outline_size", 6)
	kat.add_child(alt)
	return kat
