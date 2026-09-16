extends Node2D
class_name Bolum
## ASCII haritayi (Bolumler.BOLUMLER) calisma aninda gecerli bir bolume cevirir:
## carpisma govdeleri + yer tutucu cizim. Cizim _draw ile tek seferde yapilir,
## hareketli parcalar kendi Polygon2D'leriyle gelir.

signal olum_temasi
signal kapiya_varildi

const A := preload("res://scripts/ayarlar.gd")
const H: int = A.HUCRE

var baslangic: Vector2 = Vector2.ZERO
var genislik_px: int = 0
var yukseklik_px: int = 0
var kapi_sayisi: int = 0

var _blok_kutulari: Array[Rect2] = []
var _ust_kenarlar: Array[Rect2] = []
var _diken_ucgenleri: Array[PackedVector2Array] = []
var _kapi_kutulari: Array[Rect2] = []
var _hareketliler: Array[Dictionary] = []

## Bolum kurulurken oyuncu hala onceki bolumun konumundadir. Alanlar hemen dinlerse
## fizik sunucusu bu bayat ortusmeyi yeni kapiya/dikene sayiyor ve bolum atlaniyordu.
## Bu yuzden alanlar ilk fizik karesinden sonra acilir.
var _alan_gecikmesi: int = 2


func kur(veri: Dictionary) -> void:
	var harita: Array = veri["harita"]
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
					var yukari := ch == "^"
					var x := c * H
					var y := r * H
					if yukari:
						_diken_ucgenleri.append(PackedVector2Array([
							Vector2(x, y + H), Vector2(x + H, y + H), Vector2(x + H * 0.5, y + 2)]))
						_kutu_ekle(dikenler, Rect2(x + 4, y + 8, 8, 8))
					else:
						_diken_ucgenleri.append(PackedVector2Array([
							Vector2(x, y), Vector2(x + H, y), Vector2(x + H * 0.5, y + H - 2)]))
						_kutu_ekle(dikenler, Rect2(x + 4, y, 8, 8))
				"S":
					baslangic = Vector2(c * H + H * 0.5, (r + 1) * H - Ayarlar.GOVDE.y * 0.5 - 1.0)
				"K":
					var kk := Rect2(c * H + 2, r * H - 24, 12, 40)
					_kapi_kutulari.append(kk)
					_kutu_ekle(kapi, kk)
					kapi_sayisi += 1
				"-", "*":
					var bas2 := c
					while c < sutun_sayisi and s[c] == ch:
						c += 1
					_hareketli_ekle(ch, r, bas2, c - 1)
					continue
			c += 1

	# ust kenar vurgusu: ustunde blok olmayan hucre siralari
	for r in satir_sayisi:
		var s: String = harita[r]
		var c := 0
		while c < sutun_sayisi:
			if s[c] != "#" or (r > 0 and String(harita[r - 1])[c] == "#"):
				c += 1
				continue
			var bas := c
			while c < sutun_sayisi and s[c] == "#" and (r == 0 or String(harita[r - 1])[c] != "#"):
				c += 1
			_ust_kenarlar.append(Rect2(bas * H, r * H, (c - bas) * H, 3))

	queue_redraw()


func _kutu_ekle(ebeveyn: Node, kutu: Rect2) -> void:
	var sekil := CollisionShape2D.new()
	var dikdortgen := RectangleShape2D.new()
	dikdortgen.size = kutu.size
	sekil.shape = dikdortgen
	sekil.position = kutu.position + kutu.size * 0.5
	ebeveyn.add_child(sekil)


func _hareketli_ekle(tip: String, r: int, c1: int, c2: int) -> void:
	var sol := c1 * H
	var sag := (c2 + 1) * H
	var y := r * H + H * 0.5
	var genislik := Ayarlar.PLATFORM_GENISLIGI if tip == "-" else 24.0
	var yukseklik := 10.0
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
	_kutu_ekle(dugum, Rect2(-genislik * 0.5, -yukseklik * 0.5, genislik, yukseklik))
	var gorsel := Polygon2D.new()
	gorsel.color = Ayarlar.RENK_PLATFORM if tip == "-" else Ayarlar.RENK_DIKEN
	gorsel.polygon = PackedVector2Array([
		Vector2(-genislik * 0.5, -yukseklik * 0.5), Vector2(genislik * 0.5, -yukseklik * 0.5),
		Vector2(genislik * 0.5, yukseklik * 0.5), Vector2(-genislik * 0.5, yukseklik * 0.5)])
	dugum.add_child(gorsel)
	add_child(dugum)
	_hareketliler.append({
		"dugum": dugum,
		"min_x": sol + genislik * 0.5,
		"max_x": sag - genislik * 0.5,
		"yon": 1.0,
		"hiz": Ayarlar.PLATFORM_HIZI if tip == "-" else Ayarlar.GEZGIN_DIKEN_HIZI,
	})


func _physics_process(delta: float) -> void:
	if _alan_gecikmesi > 0:
		_alan_gecikmesi -= 1
		if _alan_gecikmesi == 0:
			for ad in ["Dikenler", "Kapi"]:
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


func _govde_girdi(govde: Node, olumcul: bool) -> void:
	if not govde.is_in_group("oyuncu"):
		return
	if olumcul:
		olum_temasi.emit()
	else:
		kapiya_varildi.emit()


func _draw() -> void:
	draw_rect(Rect2(-64, -64, genislik_px + 128, yukseklik_px + 128), Ayarlar.RENK_ARKA)
	for k in _blok_kutulari:
		draw_rect(k, Ayarlar.RENK_BLOK)
	for k in _ust_kenarlar:
		draw_rect(k, Ayarlar.RENK_BLOK_UST)
	for u in _diken_ucgenleri:
		draw_colored_polygon(u, Ayarlar.RENK_DIKEN)
	for k in _kapi_kutulari:
		draw_rect(k, Ayarlar.RENK_KAPI)
		draw_rect(Rect2(k.position.x + 2, k.position.y + 2, k.size.x - 4, k.size.y - 4),
			Ayarlar.RENK_KAPI.darkened(0.35))


## Bolum basina donunce hareketli parcalar da basa donsun (yeniden deneme adil olsun).
func sifirla() -> void:
	for h in _hareketliler:
		var d: Node2D = h["dugum"]
		d.position.x = h["min_x"]
		h["yon"] = 1.0


## Ekran/bolum disina dusmek olumdur.
func disarida(nokta: Vector2) -> bool:
	return not Rect2(-48, -48, genislik_px + 96, yukseklik_px + 96).has_point(nokta)
