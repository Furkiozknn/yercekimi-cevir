extends Node2D
class_name Bolum
## ASCII haritayi (Bolumler.BOLUMLER) calisma aninda gecerli bir bolume cevirir:
## carpisma govdeleri + pixel art cizim. Sabit parcalar _draw ile tek seferde
## cizilir; hareketli parcalar, kapi, kristal ve kontrol noktasi kendi
## dugumleriyle gelir (kapi ve kristal parildar).

signal olum_temasi
signal kapiya_varildi
signal kristal_alindi
signal kontrol_alindi(konum: Vector2)

const A := preload("res://scripts/ayarlar.gd")
const H: int = A.HUCRE

const T_KARO := preload("res://assets/sprites/karo.png")
const T_KARO_UST := preload("res://assets/sprites/karo_ust.png")
const T_DIKEN := preload("res://assets/sprites/diken.png")
const T_KAPI := preload("res://assets/sprites/kapi.png")
const T_PLATFORM := preload("res://assets/sprites/platform.png")
const T_GEZGIN := preload("res://assets/sprites/gezgin.png")
const T_KRISTAL := preload("res://assets/sprites/kristal_parilti.png")   ## 4 kare; HUD simgesi ayri (kristal.png)
const T_KONTROL := preload("res://assets/sprites/kontrol.png")

## Parilti: kapi ve kristal 4 kareli sayfa (tools/uret_sprite.py), ikisi de
## tek sayacla ilerler. Bot ve testler kareye bakmaz; kare yalniz gorseldir.
const PARILTI_KARE: int = 4
const PARILTI_ARALIGI: float = 0.15   ## kare basina sn (0,6 sn'de tam tur)

var harita: Array = []                        ## ASCII satirlar (inis tahmini + olum haritasi okur)
var baslangic: Vector2 = Vector2.ZERO
var genislik_px: int = 0
var yukseklik_px: int = 0
var kapi_sayisi: int = 0
var kristal_konumu: Vector2 = Vector2.ZERO
var kontrol_konumu: Vector2 = Vector2.ZERO   ## ZERO = bu bolumde kontrol noktasi yok

var _blok_kutulari: Array[Rect2] = []
var _ust_hucreler: Array[Vector2] = []
var _alt_hucreler: Array[Vector2] = []
var _dikenler: Array = []                     ## [Vector2 konum, bool yukari]
var _kapi_gorselleri: Array[Sprite2D] = []    ## parildayan kapi(lar)
var _hareketliler: Array[Dictionary] = []
var _kristal: Area2D = null
var _kristal_gorsel: Sprite2D = null
var _kontrol: Area2D = null
var _kontrol_gorsel: Sprite2D = null
var _zaman: float = 0.0

## Bolum kurulurken oyuncu hala onceki bolumun konumundadir. Alanlar hemen dinlerse
## fizik sunucusu bu bayat ortusmeyi yeni kapiya/dikene sayiyor ve bolum atlaniyordu.
## Bu yuzden alanlar ilk fizik karesinden sonra acilir.
var _alan_gecikmesi: int = 2


func _ready() -> void:
	# Doseme karosu draw_texture_rect(..., tile=true) ile cizilir; tekrar kapaliysa
	# karodan tek bir gerilmis kopya cikar.
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED


func kur(veri: Dictionary) -> void:
	harita = veri["harita"]
	var satir_sayisi := harita.size()
	var sutun_sayisi: int = String(harita[0]).length()
	yukseklik_px = satir_sayisi * H
	genislik_px = sutun_sayisi * H

	var kati := StaticBody2D.new()
	kati.name = "Kati"
	add_child(kati)
	var dikenler := Area2D.new()
	dikenler.name = "Dikenler"
	dikenler.monitoring = false
	dikenler.body_entered.connect(_govde_girdi.bind(true))
	add_child(dikenler)
	var kapi := Area2D.new()
	kapi.name = "Kapi"
	kapi.monitoring = false
	kapi.body_entered.connect(_govde_girdi.bind(false))
	add_child(kapi)

	for r in satir_sayisi:
		var s: String = harita[r]
		var c := 0
		while c < sutun_sayisi:
			var ch := s[c]
			match ch:
				"#":
					var bas := c
					while c < sutun_sayisi and s[c] == "#":
						c += 1
					var kutu := Rect2(bas * H, r * H, (c - bas) * H, H)
					_blok_kutulari.append(kutu)
					_kutu_ekle(kati, kutu)
					continue
				"^", "v":
					# Isabet kutusu gorselden kucuk: yanlarda 4 px, ucta 8 px bos.
					# (Diken 16x16 bir ucgen; ucuna degmek olduremez, govdesi olurur.)
					var yukari := ch == "^"
					var x := c * H
					var y := r * H
					_dikenler.append([Vector2(x, y), yukari])
					_kutu_ekle(dikenler, Rect2(x + 4, (y + 8) if yukari else float(y), 8, 8))
				"S":
					baslangic = Vector2(c * H + H * 0.5, (r + 1) * H - Ayarlar.GOVDE.y * 0.5 - 1.0)
				"K":
					# Kapi tam hucre genisliginde ve 3 hucre boyunda: gorsel ile
					# carpisma ayni, boylece yukaridan gelen oyuncu da kapiyi bulur.
					var kk := Rect2(c * H, r * H - 32, H, 48)
					_kutu_ekle(kapi, kk)
					var kg := Sprite2D.new()
					kg.texture = T_KAPI
					kg.hframes = PARILTI_KARE
					kg.position = kk.get_center()
					add_child(kg)
					_kapi_gorselleri.append(kg)
					kapi_sayisi += 1
				"C":
					kristal_konumu = Vector2(c * H + H * 0.5, r * H + H * 0.5)
				"P":
					kontrol_konumu = Vector2(c * H + H * 0.5, (r + 1) * H - 12.0)
				"-", "*":
					var bas2 := c
					while c < sutun_sayisi and s[c] == ch:
						c += 1
					_hareketli_ekle(ch, r, bas2, c - 1)
					continue
			c += 1

	# Yuruyus yuzeyleri: ustunde (ya da altinda) blok olmayan hucreler uyari seritli
	# karo ile cizilir — cevirme oyununda iki yuzey de yuruyus yuzeyi.
	for r in satir_sayisi:
		var s: String = harita[r]
		for c in sutun_sayisi:
			if s[c] != "#":
				continue
			# Haritanin dis kenari (ust satirin ustu, alt satirin alti) gorunmez:
			# oraya serit cizmek yuruyus yuzeyini yanlis tarafa koyuyor.
			if r > 0 and String(harita[r - 1])[c] != "#":
				_ust_hucreler.append(Vector2(c * H, r * H))
			if r < satir_sayisi - 1 and String(harita[r + 1])[c] != "#":
				_alt_hucreler.append(Vector2(c * H, r * H))

	if kristal_konumu != Vector2.ZERO:
		_kristal_ekle()
	if kontrol_konumu != Vector2.ZERO:
		_kontrol_ekle()
	queue_redraw()


func _kutu_ekle(ebeveyn: Node, kutu: Rect2) -> void:
	var sekil := CollisionShape2D.new()
	var dikdortgen := RectangleShape2D.new()
	dikdortgen.size = kutu.size
	sekil.shape = dikdortgen
	sekil.position = kutu.position + kutu.size * 0.5
	ebeveyn.add_child(sekil)


func _alan_kur(ad: String, konum: Vector2, kutu: Vector2, doku: Texture2D, kare_sayisi: int) -> Area2D:
	var a := Area2D.new()
	a.name = ad
	a.monitoring = false
	a.position = konum
	var gorsel := Sprite2D.new()
	gorsel.name = "Gorsel"
	gorsel.texture = doku
	gorsel.hframes = kare_sayisi
	a.add_child(gorsel)
	_kutu_ekle(a, Rect2(-kutu * 0.5, kutu))
	add_child(a)
	return a


func _kristal_ekle() -> void:
	_kristal = _alan_kur("Kristal", kristal_konumu, Vector2(12, 12), T_KRISTAL, PARILTI_KARE)
	_kristal_gorsel = _kristal.get_node("Gorsel")
	_kristal.body_entered.connect(func(govde: Node) -> void:
		if govde.is_in_group("oyuncu") and _kristal.visible:
			_kristal.hide()
			# sinyal islenirken monitoring degistirilemez
			_kristal.set_deferred("monitoring", false)
			kristal_alindi.emit())


func _kontrol_ekle() -> void:
	_kontrol = _alan_kur("Kontrol", kontrol_konumu, Vector2(12, 20), T_KONTROL, 2)
	_kontrol_gorsel = _kontrol.get_node("Gorsel")
	_kontrol.body_entered.connect(func(govde: Node) -> void:
		if govde.is_in_group("oyuncu") and _kontrol_gorsel.frame == 0:
			_kontrol_gorsel.frame = 1
			kontrol_alindi.emit(kontrol_konumu + Vector2(0.0, 12.0 - Ayarlar.GOVDE.y * 0.5 - 1.0)))


func _hareketli_ekle(tip: String, r: int, c1: int, c2: int) -> void:
	var sol := c1 * H
	var sag := (c2 + 1) * H
	var y := r * H + H * 0.5
	var genislik := Ayarlar.PLATFORM_GENISLIGI if tip == "-" else 24.0
	var yukseklik := 10.0
	# Platform BASILAN bir yuzey: carpisma gorselle ayni olmali.
	# Gezgin diken OLDUREN bir sey: isabet kutusu gorselden her yonden
	# DIKEN_PAY kadar kucuk, yoksa disine degmek olduruyor.
	var pay: float = 0.0 if tip == "-" else float(Ayarlar.DIKEN_PAY)
	var dugum: Node2D
	if tip == "-":
		var p := AnimatableBody2D.new()
		p.sync_to_physics = true
		dugum = p
	else:
		var a := Area2D.new()
		a.body_entered.connect(_govde_girdi.bind(true))
		dugum = a
	dugum.position = Vector2(sol + genislik * 0.5, y)
	_kutu_ekle(dugum, Rect2(-genislik * 0.5 + pay, -yukseklik * 0.5 + pay,
		genislik - pay * 2.0, yukseklik - pay * 2.0))
	var gorsel := Sprite2D.new()
	gorsel.texture = T_PLATFORM if tip == "-" else T_GEZGIN
	if tip != "-" and Ayarlar.yuksek_kontrast:
		gorsel.modulate = Color(1.35, 1.10, 1.10)
	dugum.add_child(gorsel)
	add_child(dugum)
	_hareketliler.append({
		"dugum": dugum,
		"min_x": sol + genislik * 0.5,
		"max_x": sag - genislik * 0.5,
		"yon": 1.0,
		"hiz": Ayarlar.PLATFORM_HIZI if tip == "-" else Ayarlar.GEZGIN_DIKEN_HIZI,
		# Asagidaki iki alan inis gostergesi ve bot icin: parcanin ne oldugu
		# (basilabilir mi, olduruyor mu) ve carpisma kutusunun yari olcusu.
		"kati": tip == "-",
		"yari": Vector2(genislik * 0.5 - pay, yukseklik * 0.5 - pay),
	})


func _physics_process(delta: float) -> void:
	if _alan_gecikmesi > 0:
		_alan_gecikmesi -= 1
		if _alan_gecikmesi == 0:
			for ad in ["Dikenler", "Kapi", "Kristal", "Kontrol"]:
				var alan: Area2D = get_node_or_null(ad)
				if alan != null:
					alan.monitoring = true
	for h in _hareketliler:
		var d: Node2D = h["dugum"]
		var x: float = d.position.x + h["yon"] * h["hiz"] * delta
		if x <= h["min_x"]:
			x = h["min_x"]
			h["yon"] = 1.0
		elif x >= h["max_x"]:
			x = h["max_x"]
			h["yon"] = -1.0
		d.position.x = x


func _process(delta: float) -> void:
	_zaman += delta
	var kare := int(_zaman / PARILTI_ARALIGI) % PARILTI_KARE
	for g in _kapi_gorselleri:
		g.frame = kare
	if _kristal != null and _kristal.visible:
		_kristal_gorsel.frame = kare
		_kristal.position.y = kristal_konumu.y + sin(_zaman * 3.0) * 1.5


func _govde_girdi(govde: Node, olumcul: bool) -> void:
	if not govde.is_in_group("oyuncu"):
		return
	if olumcul:
		olum_temasi.emit()
	else:
		kapiya_varildi.emit()


## Yuksek kontrast: zemin koyulasir, tehlike parlar. Renk korlugune karsi
## tek basina yeterli degil (diken ucgen ve dis cizgili), ama dusuk kontrastli
## ekranlarda tehlikeyi zeminden ayiran sey bu.
func _draw() -> void:
	var kontrast := Ayarlar.yuksek_kontrast
	var zemin_ton: Color = Color(0.62, 0.66, 0.78) if kontrast else Color.WHITE
	var tehlike_ton: Color = Color(1.35, 1.10, 1.10) if kontrast else Color.WHITE
	for k in _blok_kutulari:
		draw_texture_rect(T_KARO, k, true, zemin_ton)
	for p in _ust_hucreler:
		draw_texture_rect(T_KARO_UST, Rect2(p, Vector2(H, H)), false, zemin_ton)
	for p in _alt_hucreler:
		# dikey ayna: negatif yukseklik
		draw_texture_rect(T_KARO_UST, Rect2(p.x, p.y + H, H, -H), false, zemin_ton)
	for d in _dikenler:
		var p: Vector2 = d[0]
		if d[1]:
			draw_texture_rect(T_DIKEN, Rect2(p, Vector2(H, H)), false, tehlike_ton)
		else:
			draw_texture_rect(T_DIKEN, Rect2(p.x, p.y + H, H, -H), false, tehlike_ton)


## Kristali gizler (onceki oturumda toplandiysa bolum kurulurken cagrilir).
func kristali_gizle() -> void:
	if _kristal != null:
		_kristal.hide()
		_kristal.monitoring = false


## Bolum basina donunce hareketli parcalar da basa donsun (yeniden deneme adil olsun).
## Toplanan kristal ve etkinlesen kontrol noktasi geri gelmez.
func sifirla() -> void:
	for h in _hareketliler:
		var d: Node2D = h["dugum"]
		d.position.x = h["min_x"]
		h["yon"] = 1.0


## --- Hareketli parcalar: zaman farkindali sorgular --------------------------
##
## Inis gostergesi ve bot "simdi cevirirsem nereye inerim" diye soruyor; cevap
## ~0,9 saniye SONRASI icin. O sure icinde platform 42 px, gezgin diken 56 px
## yol aliyor. Bu yuzden sorgular bir t (saniye) alir ve parcayi o kadar
## ilerletir; t = 0 su anki konumdur.

## Parcanin t saniye sonraki x konumu. Gidip gelen hareket ucgen dalgadir:
## konumu [0, 2*acikl) araligina acip geri katliyoruz — kare kare benzetmeye
## gerek yok, kapali cozum var.
func _ileri_x(h: Dictionary, t: float) -> float:
	var mn: float = h["min_x"]
	var mx: float = h["max_x"]
	var acikl: float = mx - mn
	if acikl <= 0.0 or t <= 0.0:
		return float((h["dugum"] as Node2D).position.x)
	var x: float = float((h["dugum"] as Node2D).position.x)
	var faz: float = (x - mn) if float(h["yon"]) >= 0.0 else (2.0 * acikl - (x - mn))
	faz = fposmod(faz + float(h["hiz"]) * t, 2.0 * acikl)
	return mn + (faz if faz <= acikl else 2.0 * acikl - faz)


## kati=true  -> platform (basilabilir yuzey)
## kati=false -> gezen diken (oldurur)
##
## Oldurucu parcanin kutusu sorguda 4 px buyutulur: inis benzetmesi 1/60 sn
## adimlarla ilerliyor, en yuksek dusus hizinda adim 7,2 px, gezgin dikenin
## kutusu ise yalniz 4 px yuksek — buyutmezsek benzetme dikenin icinden
## gecip "temiz" diyebiliyor. Tehlikede comert olmak dogru yon.
func hareketli_kesisiyor(kutu: Rect2, kati: bool, t: float = 0.0) -> bool:
	for h in _hareketliler:
		if bool(h["kati"]) != kati:
			continue
		var yari: Vector2 = h["yari"]
		var merkez := Vector2(_ileri_x(h, t), (h["dugum"] as Node2D).position.y)
		var p := Rect2(merkez - yari, yari * 2.0)
		if not kati:
			p = p.grow(4.0)
		if p.intersects(kutu):
			return true
	return false


## Nokta sorgusu (inis benzetmesi ayak noktasini boyle soruyor).
func hareketli_nokta(nokta: Vector2, kati: bool, t: float = 0.0) -> bool:
	return hareketli_kesisiyor(Rect2(nokta - Vector2(0.5, 0.5), Vector2.ONE), kati, t)


## Verilen dunya noktasi kati bir karo mu? (inis gostergesi bunu kullanir)
func kati_mi(nokta: Vector2) -> bool:
	return _hucre(nokta) == "#"


## Verilen dikdortgen bir dikene DEGIYOR mu?
##
## Nokta sorgusu (olumcul_mu) yetmiyor: inis tahmini ayak noktasini izliyordu,
## cevirdikten sonra "ayak" bas oluyor ve govdenin geri kalani zemin dikeninin
## icinden gecerken tahmin "temiz" diyordu. Burada dikenin GERCEK isabet
## kutusu kullaniliyor (gorselden DIKEN_PAY kadar kucuk, bkz. kur()).
func olumcul_kutu(kutu: Rect2) -> bool:
	var c1 := int(floor(kutu.position.x / float(H)))
	var c2 := int(floor((kutu.end.x - 0.001) / float(H)))
	var r1 := int(floor(kutu.position.y / float(H)))
	var r2 := int(floor((kutu.end.y - 0.001) / float(H)))
	for r in range(maxi(r1, 0), mini(r2 + 1, harita.size())):
		var satir: String = harita[r]
		for c in range(maxi(c1, 0), mini(c2 + 1, satir.length())):
			var ch := satir[c]
			if ch != "^" and ch != "v":
				continue
			var y := float(r * H)
			var d := Rect2(float(c * H) + 4.0, (y + 8.0) if ch == "^" else y, 8.0, 8.0)
			if d.intersects(kutu):
				return true
	return false


## Verilen dunya noktasi diken karesi mi? (inis gostergesi uyariyi buradan alir)
func olumcul_mu(nokta: Vector2) -> bool:
	var ch := _hucre(nokta)
	return ch == "^" or ch == "v"


func _hucre(nokta: Vector2) -> String:
	var c := int(floor(nokta.x / float(H)))
	var r := int(floor(nokta.y / float(H)))
	if r < 0 or r >= harita.size():
		return "#"
	var satir: String = harita[r]
	if c < 0 or c >= satir.length():
		return "#"
	return satir[c]


## Ekran/bolum disina dusmek olumdur.
func disarida(nokta: Vector2) -> bool:
	return not Rect2(-48, -48, genislik_px + 96, yukseklik_px + 96).has_point(nokta)
