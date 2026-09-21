extends Node2D
## Bolum dongusu: yukle -> oyna -> ol/bitir -> sonraki.
## Kontrol noktasi, kristal, madalya, hayalet yaris, olum haritasi, inis
## gostergesi, yardim modu, duraklatma ve bitis ekrani da burada.

enum { OYNA, OLDU, TAMAM, BITTI, HAYALET }   ## HAYALET: gunluk hayalet yarisi kaybedildi, bolum bastan

const TAMAM_BEKLEME: float = 1.00   ## bolum bitisinde sonraki boluma gecmeden once
const TAMAM_HARITA: float = 2.40    ## olum haritasi varsa: okumaya yetecek kadar
const HAYALET_BEKLEME: float = 1.00 ## "hayalet kazandi" mesaji bu kadar kalir, sonra bolum bastan
const GECIS_SURESI: float = 0.22
const A := preload("res://scripts/ayarlar.gd")
const ODA: float = float(A.ODA_GENISLIGI)

var bolum_i: int = 0
var sure: float = 0.0
var olum: int = 0
var cevirme: int = 0          ## bu bolumdeki cevirme sayisi (ikinci hedef)
var toplam_sure: float = 0.0
var toplam_olum: int = 0

var _durum: int = OYNA
var _zaman: float = 0.0
var _bolum: Bolum = null
var _dogus: Vector2 = Vector2.ZERO
var _sarsinti: float = 0.0
var _arka_tween: Tween = null
var _gecis: bool = false   ## bolum gecisi surerken _sonraki() tekrar cagrilmasin

# Oda tabanli kamera
var _oda: int = -1
var _oda_tween: Tween = null

# Hayalet yaris
var _yol: PackedVector2Array = PackedVector2Array()   ## bu kosunun kaydi
var _kare: int = 0
var _hayalet_yol: PackedVector2Array = PackedVector2Array()
var _altin_yol: PackedVector2Array = PackedVector2Array()   ## botun olculmus altin kosusu

# Olum haritasi
var _olum_yerleri: Array[Vector2] = []
var _bekleme: float = TAMAM_BEKLEME   ## bu bolum bitisinde beklenecek sure

# Gunluk bolum (Ayarlar.gunluk_mod): kristal bu yuklemede alindi mi?
# Ana oyunda kristal Ayarlar'a yazilir; gunluk modda YAZILMAZ, yalniz
# "kristal zorunlu" degistiricisinin kapisini acar.
var _kristal_alindi: bool = false
var _gunluk_ek: String = ""   ## gunluk bitis paneline eklenen satir (rekor / yardim modu)

@onready var _dunya: Node2D = $Dunya
@onready var _oyuncu: CharacterBody2D = $Dunya/Oyuncu
@onready var _kamera: Camera2D = $Dunya/Kamera
@onready var _hayalet: Sprite2D = $Dunya/Hayalet
@onready var _altin: Sprite2D = $Dunya/AltinHayalet
@onready var _inis: Sprite2D = $Dunya/Inis
@onready var _toz: CPUParticles2D = $Dunya/Toz
@onready var _olum_parca: CPUParticles2D = $Dunya/Olum
@onready var _toplama: CPUParticles2D = $Dunya/Toplama
@onready var _arka_katlar: Array[CanvasItem] = [$Arka/Kat0, $Arka/Kat1, $Arka/Kat2]
## Ust HUD iki grup: serit arkasi + uzerindeki yazilar. Grup olarak
## soldurulur (bkz. _hud_solma); kristal simgesinin kendi alfasi bozulmaz
## cunku modulate cocuklara carpilarak iner.
@onready var _hud_gruplari: Array[Control] = [$Arayuz/HudSol, $Arayuz/HudSag]
@onready var _ad: Label = $Arayuz/HudSol/Ad
@onready var _sayac: Label = $Arayuz/HudSag/Sayac
@onready var _hedef: Label = $Arayuz/HudSag/Hedef
@onready var _ipucu: Label = $Arayuz/Ipucu
@onready var _mesaj: Label = $Arayuz/Mesaj
@onready var _yardim_rozet: Label = $Arayuz/Yardim
@onready var _kristal_ikon: TextureRect = $Arayuz/HudSol/KristalIkon
@onready var _kristal_yazi: Label = $Arayuz/HudSol/KristalYazi
@onready var _olum_haritasi: Panel = $Arayuz/OlumHaritasi
@onready var _harita_alan: Control = $Arayuz/OlumHaritasi/Alan
@onready var _duraklat: Panel = $Arayuz/Duraklat
@onready var _bitis: Panel = $Arayuz/Bitis
@onready var _bitis_metin: Label = $Arayuz/Bitis/Kutu/Metin
@onready var _kopyala_dugme: Button = $Arayuz/Bitis/Kutu/Kopyala
@onready var _dokunmatik: Control = $Arayuz/Dokunmatik
@onready var _karartma: ColorRect = $Gecis/Karartma
@onready var _kilit_hud: Control = $Arayuz/Kilit          ## "ÇEVİRME KİLİTLİ" rozeti (seritlerin arasinda)
@onready var _tabela: Panel = $Arayuz/Tabela
@onready var _tabela_metin: Label = $Arayuz/Tabela/Metin

var _tabela_kalan: float = 0.0
var _kilit_tween: Tween = null


func _ready() -> void:
	Ayarlar.zaman_uygula()
	_oyuncu.oldu.connect(_olum_oldu)
	_oyuncu.cevirdi.connect(_cevirdi)
	_oyuncu.kondu.connect(_kondu)
	_oyuncu.kilit_denendi.connect(_kilit_reddi)
	$Arayuz/Duraklat/Kutu/Devam.pressed.connect(_devam)
	$Arayuz/Duraklat/Kutu/Bastan.pressed.connect(_bastan)
	$Arayuz/Duraklat/Kutu/Atla.pressed.connect(_atla)
	$Arayuz/Duraklat/Kutu/Ayar.pressed.connect(_ayarlara)
	$Arayuz/Duraklat/Kutu/Menu.pressed.connect(_menuye)
	$Arayuz/Bitis/Kutu/Menu.pressed.connect(_menuye)
	_kopyala_dugme.pressed.connect(_kopyala)
	_dokunmatik_kur()
	Ayarlar.dokunmatik_degisti.connect(_dokunmatik_acildi)
	_hayalet.modulate = Ayarlar.HAYALET_RENGI
	_altin.modulate = Ayarlar.ALTIN_HAYALET_RENGI
	bolum_yukle(Ayarlar.secilen_bolum)
	_karartma.color.a = 1.0
	_karart(false)


# --- dokunmatik ---------------------------------------------------------------

## Gorunmez genis alanlar: parmak kucuk bir dugme aramaz, ekranin yarisi dugmedir.
## Solak secenegi taraflari degistirir; opaklik yalniz ipucu harflerini etkiler.
func _dokunmatik_kur() -> void:
	_dokunmatik.visible = Ayarlar.dokunmatik_mi()
	_dokunmatik.modulate.a = Ayarlar.dokunmatik_opaklik
	var ust := 40.0                       # ust seritteki arayuzu kapatma
	var yuk := 360.0 - ust
	var hareket_x := 320.0 if Ayarlar.solak else 0.0
	var cevir_x := 0.0 if Ayarlar.solak else 320.0
	_alan("Sol", Rect2(hareket_x, ust, 160.0, yuk), "move_left")
	_alan("Sag", Rect2(hareket_x + 160.0, ust, 160.0, yuk), "move_right")
	_alan("Cevir", Rect2(cevir_x, ust, 320.0, yuk), "cevir")


func _alan(dugme_adi: String, kutu: Rect2, eylem: String) -> void:
	var d: Button = _dokunmatik.get_node(dugme_adi)
	d.set_anchors_preset(Control.PRESET_TOP_LEFT)
	d.offset_left = kutu.position.x
	d.offset_top = kutu.position.y
	d.offset_right = kutu.end.x
	d.offset_bottom = kutu.end.y
	for durum in ["normal", "hover", "pressed", "focus", "disabled"]:
		d.add_theme_stylebox_override(durum, StyleBoxEmpty.new())
	# _dokunmatik_kur() dokunus algilaninca ikinci kez calisabilir: iki kez baglama.
	if d.button_down.get_connections().is_empty():
		d.button_down.connect(func() -> void: Input.action_press(eylem))
		d.button_up.connect(func() -> void: Input.action_release(eylem))


## Oyun acikken dokunus algilandi: alanlari goster, ipucunu dokunmaya cevir.
func _dokunmatik_acildi() -> void:
	_dokunmatik_kur()
	_ipucu.text = Ayarlar.kontrol_metni(String(Ayarlar.bolum(bolum_i)["ipucu"]))


func _titret() -> void:
	if Ayarlar.titresim and DisplayServer.is_touchscreen_available():
		Input.vibrate_handheld(30)


# --- bolum dongusu ------------------------------------------------------------

func bolum_yukle(i: int) -> void:
	bolum_i = clampi(i, 0, Ayarlar.bolum_sayisi() - 1)
	Ses.muzik(Ses.bolum_parcasi(bolum_i))   # grup degismediyse parca kesilmez
	if _bolum != null:
		# adi hemen birak: yeni bolum de "Bolum" adiyla eklenebilsin
		_bolum.name = "EskiBolum"
		_bolum.set_physics_process(false)
		_bolum.queue_free()
	_bolum = Bolum.new()
	_bolum.name = "Bolum"
	_dunya.add_child(_bolum)
	_dunya.move_child(_bolum, 0)
	var veri: Dictionary = Ayarlar.bolum(bolum_i)
	_bolum.kur(veri)
	_bolum.olum_temasi.connect(_diken_temasi)
	_bolum.kapiya_varildi.connect(_kapi)
	_bolum.kristal_alindi.connect(_kristal)
	_bolum.kontrol_alindi.connect(_kontrol)
	_kristal_alindi = false
	if Ayarlar.kristal_var(bolum_i) and not Ayarlar.gunluk_mod:
		_bolum.kristali_gizle()      # gunluk modda kristal her gun yeniden orada

	_kamera.limit_left = 0
	_kamera.limit_right = maxi(_bolum.genislik_px, Ayarlar.ODA_GENISLIGI)
	var ust := int((_bolum.yukseklik_px - Ayarlar.ODA_YUKSEKLIGI) / 2.0)
	_kamera.limit_top = ust
	_kamera.limit_bottom = ust + Ayarlar.ODA_YUKSEKLIGI

	sure = 0.0
	olum = 0
	cevirme = 0
	_gecis = false
	_dogus = _bolum.baslangic
	_yol = PackedVector2Array()
	_kare = 0
	_olum_yerleri.clear()
	_olum_haritasi.visible = false
	_hayalet_yol = Ayarlar.hayalet_yukle(bolum_i)
	_hayalet.modulate = _hayalet_rengi()
	_hayalet.visible = false
	_altin_yol = Ayarlar.altin_hayalet_yolu(bolum_i)
	_altin.visible = false
	if Ayarlar.gunluk_mod:
		# Hayaletler normal baslangicin kaydi; ters baslangicta yalan soylerler.
		# Hayalet yarisi degistiricisinde altin hayalet RAKIPTIR: ayar kapali
		# olsa da kosar, kapi yalniz ondan once varilinca sayilir.
		_hayalet_yol = PackedVector2Array()
		_altin_yol = AltinHayalet.yol(bolum_i) if Ayarlar.gunluk_degistirici() == 2 else PackedVector2Array()
	_ad.text = String(veri["ad"])
	if Ayarlar.gunluk_mod:
		_ad.text += "   GÜNÜN BÖLÜMÜ · " + Ayarlar.gunluk_degistirici_adi()
	_ipucu.text = Ayarlar.kontrol_metni(String(veri["ipucu"]))
	_yardim_rozet.visible = Ayarlar.yardim_acik
	$Arayuz/YardimArka.visible = Ayarlar.yardim_acik
	if Ayarlar.yardim_acik:
		_yardim_rozet.text = "Yardım modu · hız %d%%%s" % [
			roundi(Ayarlar.yardim_hiz * 100.0),
			"  · dikenler itiyor" if Ayarlar.yardim_olumsuz else ""]
	_hedef_guncelle()
	_kristal_guncelle()
	_arka_ton(1.0, true)
	yeniden_basla()
	_oda = -1
	_kamera_guncelle(true)
	_tabela_goster()


## Bolum basi tabelasi: yalniz bolum yuklenince (yeniden dogusta degil).
## TABELA_SURESI sonra ya da ilk girdiyle kapanir; sayac bu sirada durmaz.
func _tabela_goster() -> void:
	_tabela_metin.text = Ayarlar.tabela_metni(bolum_i)
	_tabela_kalan = Ayarlar.TABELA_SURESI
	_tabela.visible = true


func _tabela_isle(delta: float) -> void:
	if not _tabela.visible:
		return
	_tabela_kalan -= delta
	if _tabela_kalan <= 0.0 or Input.is_action_just_pressed("cevir") \
			or Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		_tabela.visible = false


func _hayalet_rengi() -> Color:
	## Hayalet, o bolumun en iyi kosusudur; rengi o kosunun madalyasi.
	var m := Ayarlar.madalya_al(bolum_i)
	if m <= 0:
		return Ayarlar.HAYALET_RENGI
	var c: Color = Ayarlar.MADALYA_RENK[m]
	return Color(c.r, c.g, c.b, Ayarlar.HAYALET_RENGI.a)


func yeniden_basla() -> void:
	_bolum.sifirla()
	var yon := _baslangic_yonu()
	_oyuncu.hazirla(_dogus, yon)
	_kamera.reset_smoothing()
	_mesaj.text = ""
	_durum = OYNA
	_zaman = 0.0
	_kilit_hud.visible = false
	_arka_ton(yon, true)
	_kamera_guncelle(true)


## Gunluk "ters baslangic": yalniz bolum basinda ters dogarsin; kontrol
## noktasindan dogus normaldir (nokta zeminde duruyor).
func _baslangic_yonu() -> float:
	if Ayarlar.gunluk_mod and Ayarlar.gunluk_degistirici() == 0 and _dogus == _bolum.baslangic:
		return -1.0
	return 1.0


func _hedef_guncelle() -> void:
	if Ayarlar.gunluk_mod:
		_hedef.text = "Günün bölümü · en iyi %s · ana ilerlemeye yazmaz" % Ayarlar.gunluk_en_iyi_metin()
		return
	var az := Ayarlar.en_az_al(bolum_i)
	var e := Ayarlar.esik(bolum_i)
	_hedef.text = "● %.2f ● %.2f ● %.2f sn · en az ⟳ %d · en iyi %s%s" % [
		e["altin"], e["gumus"], e["bronz"], Ayarlar.en_az_hedef(bolum_i),
		Ayarlar.en_iyi_metin(bolum_i), (" / ⟳ %d" % az) if az >= 0 else ""]


func _kristal_guncelle() -> void:
	if Ayarlar.gunluk_mod:
		_kristal_ikon.modulate.a = 1.0 if _kristal_alindi else 0.28
		var d := Ayarlar.gunluk_degistirici()
		_kristal_yazi.text = ("kristal alındı" if _kristal_alindi else
			("kristal ZORUNLU — kapı onsuz açılmaz" if d == 1 else
			("HAYALET YARIŞI — altın hayaleti geç" if d == 2 else "kristal")))
		return
	var var_mi := Ayarlar.kristal_var(bolum_i)
	_kristal_ikon.modulate.a = 1.0 if var_mi else 0.28
	_kristal_yazi.text = "%d / %d kristal" % [Ayarlar.kristal_sayisi(), Ayarlar.bolum_sayisi()]


# --- kare dongusu -------------------------------------------------------------

func _physics_process(_delta: float) -> void:
	if _durum != OYNA or get_tree().paused:
		return
	_kilit_guncelle()
	# Hayalet kaydi: her HAYALET_ARALIGI fizik karesinde bir konum.
	_kare += 1
	if _kare % Ayarlar.HAYALET_ARALIGI == 0 and _yol.size() < Ayarlar.HAYALET_EN_FAZLA:
		_yol.append(_oyuncu.global_position)


func _process(delta: float) -> void:
	_sarsinti_isle(delta)
	_hud_solma(delta)
	if get_tree().paused:
		return
	_tabela_isle(delta)
	_zaman += delta
	match _durum:
		OYNA:
			sure += delta
			if _bolum.disarida(_oyuncu.global_position):
				if Ayarlar.yardim_acik and Ayarlar.yardim_olumsuz:
					_oyuncu.hazirla(_dogus)   # olum sayilmaz, kosu surer
				else:
					_oyuncu.oldur()
			_kamera_guncelle(false)
			_hayalet_isle()
			_inis_isle()
			if _durum == OYNA and _hayalet_yarisi() and _hayalet_bitti():
				_hayalet_kazandi()
		OLDU:
			if _zaman >= Ayarlar.OLUM_BEKLEME:
				yeniden_basla()
		TAMAM:
			if _zaman >= _bekleme and not _gecis:
				_gecis = true
				_sonraki()
		HAYALET:
			if _zaman >= HAYALET_BEKLEME:
				bolum_yukle(bolum_i)      # sure, olum ve hayalet birlikte basa doner
	_sayac.text = "Süre %.2f   Ölüm %d   ⟳ %d" % [sure, olum, cevirme]


## Cevirme yasagi bolgesi: oyuncunun govdesi bolge dikdortgenine degiyorsa
## oyuncu.kilitli acilir (cevir() reddeder), rozet gorunur; ilk giriste
## "kilit" sesi. Ebeveyn cocuktan once islendigi icin oyuncunun ayni
## karedeki cevir() cagrisi bu degeri gorur.
func _kilit_guncelle() -> void:
	var govde := Rect2(_oyuncu.global_position - Ayarlar.GOVDE * 0.5, Ayarlar.GOVDE)
	var k: bool = _oyuncu.yasiyor and _bolum.yasak_icinde(govde)
	if k and not _oyuncu.kilitli:
		Ses.cal(&"kilit")
	_oyuncu.kilitli = k
	_kilit_hud.visible = k


## Bolgede cevirme istendi: ses + rozet sarsilir (tus okundu ama reddedildi).
func _kilit_reddi() -> void:
	Ses.cal(&"kilit")
	if not Ayarlar.oyun_hissi:
		return
	if _kilit_tween != null and _kilit_tween.is_valid():
		_kilit_tween.kill()
	_kilit_hud.position.x = 0.0
	_kilit_tween = create_tween()
	for dx in [4.0, -4.0, 2.0, 0.0]:
		_kilit_tween.tween_property(_kilit_hud, "position:x", dx, 0.04)


## Tavanda yuruyen oyuncu (ya da hayalet) ust HUD seritlerinin arkasinda
## kaliyordu (x < 232 ve x > 398). Bir sey seridin dikdortgenine girince o
## grup (serit + yazilari) Ayarlar.HUD_SOLUK'a iner, cikinca geri gelir.
## Girdiye dokunmaz: seritler zaten fare olaylarini yok sayiyor.
func _hud_solma(delta: float) -> void:
	var donusum := get_viewport().get_canvas_transform()
	var kutular: Array[Rect2] = []
	var gorunenler: Array[Node2D] = [_oyuncu, _hayalet, _altin]
	for d in gorunenler:
		if d.visible:
			kutular.append(Rect2(donusum * d.global_position - Vector2(8.0, 12.0), Vector2(16.0, 24.0)))
	var adim: float = delta * (1.0 - Ayarlar.HUD_SOLUK) / Ayarlar.HUD_SOLMA_SURESI
	for grup in _hud_gruplari:
		var serit: Rect2 = (grup.get_node("Arka") as Control).get_rect()
		var hedef := 1.0
		for k in kutular:
			if serit.intersects(k):
				hedef = Ayarlar.HUD_SOLUK
		grup.modulate.a = move_toward(grup.modulate.a, hedef, adim)


## Oda tabanli kamera: kamera oyuncuyu izlemez, 640 px'lik odalar arasinda atlar.
## Boylece bir odadaki tehlikenin tamami hep ekranda — turun en sik sikayeti olan
## "ekran disindan gelen olum" ortadan kalkar.
func _kamera_guncelle(aninda: bool) -> void:
	var g: float = float(maxi(_bolum.genislik_px, Ayarlar.ODA_GENISLIGI))
	var son_oda: int = int(ceil(g / ODA)) - 1
	var oda: int = clampi(int(floor(_oyuncu.global_position.x / ODA)), 0, son_oda)
	if oda == _oda and not aninda:
		return
	_oda = oda
	var hedef := Vector2(
		clampf(oda * ODA + ODA * 0.5, ODA * 0.5, g - ODA * 0.5),
		_bolum.yukseklik_px * 0.5)
	if _oda_tween != null and _oda_tween.is_valid():
		_oda_tween.kill()
	if aninda:
		_kamera.position = hedef
		return
	_oda_tween = create_tween()
	_oda_tween.tween_property(_kamera, "position", hedef, Ayarlar.ODA_GECISI) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


## Hayalet yaris. Iki hayalet olabilir ve karismamalari gerekir:
##   "sen"   = senin en iyi kosun, rengi o kosunun madalyasi
##   "altın" = botun OLCULMUS altin kosusu (tools/bot.gd), sabit altin renk
## Ikisi de etiketli — renk tek basina yetmez, cunku altin madalyan varsa
## kendi hayaletin de altin renkte olur.
func _hayalet_isle() -> void:
	var i := int(sure * 60.0 / float(Ayarlar.HAYALET_ARALIGI))
	_hayalet_koy(_hayalet, _hayalet_yol, i)
	_hayalet_koy(_altin, _altin_yol, i)


func _hayalet_koy(d: Sprite2D, yol: PackedVector2Array, i: int) -> void:
	d.visible = i >= 0 and i < yol.size()
	if d.visible:
		d.global_position = yol[i]


## Inis gostergesi: cevirme tusu BASILI tutulurken karsi yuzeyde nereye
## inecegini gosterir. Yesil/mavi = bos yuzey, kirmizi = yolda diken var.
func _inis_isle() -> void:
	if not Ayarlar.inis_gostergesi or not Input.is_action_pressed("cevir"):
		_inis.visible = false
		return
	var t := _inis_tahmini()
	_inis.visible = bool(t["var"])
	if not _inis.visible:
		return
	_inis.position = t["konum"]
	_inis.scale.y = t["yon"]
	_inis.modulate = Color(1.0, 0.35, 0.35) if bool(t["tehlike"]) else Color(0.35, 0.95, 1.0)


## Oyuncunun hareketini ileri sarar: yerdeyse once cevirir, sonra karsi yuzeye
## kadar adim adim duser.
##
## Hareketli platformlar ve gezen dikenler HESABA KATILIR ve her adimda o adimin
## zamanina gore ilerletilir (bkz. Bolum.hareketli_kesisiyor). v0.3'te tahmin
## yalniz sabit harita uzerinden yapiliyordu: platformlu bolumlerde gosterge
## platformu yok sayip altindaki zemini (ya da bolum disini) gosteriyordu.
func _inis_tahmini() -> Dictionary:
	var yok := {"var": false, "konum": Vector2.ZERO, "yon": 1.0, "tehlike": false, "sure": 0.0, "plat": {}}
	if _bolum == null or not _oyuncu.yasiyor:
		return yok
	var yon: float = _oyuncu.yercekimi_yonu
	var hiz: Vector2 = _oyuncu.velocity
	var k: Vector2 = _oyuncu.global_position
	if _oyuncu.is_on_floor():
		yon = -yon
		hiz.y = Ayarlar.CEVIR_ITISI * yon
	var girdi := Input.get_axis("move_left", "move_right")
	var d := 1.0 / 60.0
	var tehlike := false
	for adim in 200:
		hiz.y = clampf(hiz.y + Ayarlar.YERCEKIMI * yon * d,
			-Ayarlar.EN_YUKSEK_DUSUS, Ayarlar.EN_YUKSEK_DUSUS)
		var carpan := Ayarlar.HAVA_CARPANI
		if girdi != 0.0:
			hiz.x = move_toward(hiz.x, girdi * Ayarlar.HIZ, Ayarlar.IVME * d * carpan)
		else:
			hiz.x = move_toward(hiz.x, 0.0, Ayarlar.SURTUNME * d * carpan)
		k += hiz * d
		var ayak := k + Vector2(0.0, Ayarlar.GOVDE.y * 0.5 * yon)
		var t: float = float(adim + 1) * d
		# Tehlike GOVDE kutusuyla aranir, ayak noktasiyla degil: cevirdikten
		# sonra "ayak" yukari bakar ve govdenin alt yarisi zemin dikeninin
		# icinden gecerken tahmin "temiz" diyordu.
		var govde := Rect2(k - Ayarlar.GOVDE * 0.5, Ayarlar.GOVDE)
		if _bolum.olumcul_kutu(govde) or _bolum.hareketli_kesisiyor(govde, false, t):
			tehlike = true
		# Tek yonlu platform yalniz kendi yonunden tutar: '_' asagi dusene,
		# '~' yukari dusene. Ters yonden gelen ayak icinden gecer (bkz. Bolum).
		if _bolum.kati_mi(ayak) or _bolum.hareketli_nokta(ayak, true, t) or _bolum.tek_yonlu_nokta(ayak, yon):
			return {"var": true, "konum": Vector2(roundf(k.x), roundf(ayak.y)),
				"yon": yon, "tehlike": tehlike, "sure": t, "plat": _bolum.tek_yonlu_bul(ayak, yon)}
	return yok


# --- oyun hissi --------------------------------------------------------------

func sars(guc: float) -> void:
	if not Ayarlar.oyun_hissi:
		return
	_sarsinti = maxf(_sarsinti, guc)


func _sarsinti_isle(delta: float) -> void:
	if _sarsinti <= 0.0:
		if _kamera.offset != Vector2.ZERO:
			_kamera.offset = Vector2.ZERO
		return
	_sarsinti = move_toward(_sarsinti, 0.0, Ayarlar.SARSINTI_SONUM * delta)
	_kamera.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _sarsinti


func _parcacik(p: CPUParticles2D, konum: Vector2) -> void:
	if not Ayarlar.oyun_hissi:
		return
	p.global_position = konum
	p.restart()
	p.emitting = true


## Ters yercekiminde arka plan soguga kayar — durum tek bakista okunur.
func _arka_ton(yon: float, aninda: bool = false) -> void:
	var hedef: Color = Ayarlar.ARKA_DUZ if yon > 0.0 else Ayarlar.ARKA_TERS
	if Ayarlar.yuksek_kontrast:
		# Yuksek kontrastta arka plan geri cekilir; oynanis katmani one cikar.
		hedef = hedef * 0.45
	if _arka_tween != null and _arka_tween.is_valid():
		_arka_tween.kill()
	if aninda or not Ayarlar.oyun_hissi:
		for k in _arka_katlar:
			k.modulate = hedef
		return
	_arka_tween = create_tween().set_parallel(true)
	for k in _arka_katlar:
		_arka_tween.tween_property(k, "modulate", hedef, Ayarlar.ARKA_GECIS)


func _karart(kapali: bool) -> void:
	var t := create_tween()
	t.tween_property(_karartma, "color:a", 1.0 if kapali else 0.0, GECIS_SURESI)


# --- olaylar -----------------------------------------------------------------

func _cevirdi(yeni_yon: float) -> void:
	cevirme += 1
	Ses.cal((&"cevir" if yeni_yon < 0.0 else &"cevir_ters"))
	sars(Ayarlar.SARSINTI_CEVIR)
	_arka_ton(yeni_yon)
	_titret()


func _kondu() -> void:
	if _durum != OYNA:
		return
	Ses.cal(&"inis")
	var yon: float = _oyuncu.yercekimi_yonu
	var ayak: float = _oyuncu.global_position.y + Ayarlar.GOVDE.y * 0.5 * yon
	# toz ayaktan ters yone sicrar, sonra yercekimi yonunde duser
	_toz.direction = Vector2(0.0, -yon)
	_toz.gravity = Vector2(0.0, absf(_toz.gravity.y) * yon)
	_parcacik(_toz, Vector2(_oyuncu.global_position.x, ayak))


func _olum_oldu() -> void:
	if _durum != OYNA:
		return
	olum += 1
	toplam_olum += 1
	_olum_yerleri.append(_oyuncu.global_position)
	_durum = OLDU
	_zaman = 0.0
	_mesaj.text = "ÖLDÜN"
	_inis.visible = false
	_kilit_hud.visible = false
	_tabela.visible = false
	Ses.cal(&"olum")
	sars(Ayarlar.SARSINTI_OLUM)
	_parcacik(_olum_parca, _oyuncu.global_position)
	_titret()


func _diken_temasi() -> void:
	if _durum != OYNA:
		return
	if Ayarlar.yardim_acik and Ayarlar.yardim_olumsuz:
		# Yardim modunda diken oldurmez, geri iter: bolum yine ogretir, cezalandirmaz.
		_oyuncu.geri_it()
		Ses.cal(&"inis")
		sars(Ayarlar.SARSINTI_CEVIR)
		return
	_oyuncu.oldur()


func _kristal() -> void:
	_kristal_alindi = true
	if not Ayarlar.gunluk_mod:
		Ayarlar.kristal_topla(bolum_i)
	Ses.cal(&"kristal")
	_parcacik(_toplama, _bolum.kristal_konumu)
	_kristal_guncelle()


func _kontrol(konum: Vector2) -> void:
	_dogus = konum
	Ses.cal(&"kontrol")
	_mesaj.text = "KONTROL NOKTASI"
	get_tree().create_timer(0.9).timeout.connect(func() -> void:
		if _durum == OYNA and _mesaj.text == "KONTROL NOKTASI":
			_mesaj.text = "")


func _kapi() -> void:
	if _durum != OYNA:
		return
	if _hayalet_yarisi() and _hayalet_bitti():
		_hayalet_kazandi()           # kapiya hayaletten SONRA varmak sayilmaz
		return
	if Ayarlar.gunluk_mod and Ayarlar.gunluk_degistirici() == 1 and not _kristal_alindi:
		# Kristal zorunlu: kapi kapali. Oyuncu kapidan cikip yeniden girince
		# body_entered yeniden tetiklenir, yani mesaj gerektiginde tekrar cikar.
		_mesaj.text = "KAPI KAPALI — ÖNCE KRİSTALİ AL"
		_mesaj.add_theme_color_override("font_color", Ayarlar.RENK_METIN)
		Ses.cal(&"menu")
		get_tree().create_timer(1.2).timeout.connect(func() -> void:
			if _durum == OYNA and _mesaj.text.begins_with("KAPI KAPALI"):
				_mesaj.text = "")
		return
	_durum = TAMAM
	_zaman = 0.0
	_inis.visible = false
	_hayalet.visible = false
	_altin.visible = false
	toplam_sure += sure
	Ses.cal(&"bolum_sonu")
	if Ayarlar.gunluk_mod:
		_gunluk_bitti()
	else:
		_ana_bitti()
	_hedef_guncelle()
	_olum_haritasi_goster()
	_bekleme = TAMAM_HARITA if _olum_haritasi.visible else TAMAM_BEKLEME
	_oyuncu.set_physics_process(false)


## Gunun bolumu bitti: AYRI kayit yuvasi, madalya/hayalet/acilan bolum yok.
func _gunluk_bitti() -> void:
	var sonuc: Dictionary = Ayarlar.gunluk_bitti(sure)
	if bool(sonuc["rekor"]):
		Ses.cal(&"madalya")
	if bool(sonuc["yardim"]):
		_gunluk_ek = "Yardım modu açık: süre kaydı tutulmuyor."
	else:
		_gunluk_ek = "GÜNÜN REKORU!" if bool(sonuc["rekor"]) else ""
	_mesaj.text = "GÜNÜN BÖLÜMÜ TAMAM — %.2f sn · %d çevirme · seri %d gün%s" % [
		sure, cevirme, int(sonuc["seri"]), ("\n" + _gunluk_ek) if _gunluk_ek != "" else ""]
	_mesaj.add_theme_color_override("font_color",
		Ayarlar.MADALYA_RENK[3] if bool(sonuc["rekor"]) else Ayarlar.RENK_METIN)


## Gunun bolumu bitince menuye donmek yerine paylasim paneli. Panoya kopyalama
## bir DUGMEYE bagli: tarayici panoya yazmayi yalniz kullanici dokunusunda
## kabul ediyor, bitiste kendiliginden kopyalamak web'de sessizce basarisiz
## olurdu. Masaustunde de ayni yol — tek kod.
func _gunluk_panel() -> void:
	_durum = BITTI
	_mesaj.text = ""
	$Arayuz/Bitis/Kutu/Baslik.text = "GÜNÜN BÖLÜMÜ TAMAM"
	_bitis_metin.text = paylasim_metni() + (("\n\n" + _gunluk_ek) if _gunluk_ek != "" else "")
	_kopyala_dugme.text = "Paylaşım Metnini Kopyala"
	_kopyala_dugme.visible = true
	_bitis.visible = true
	_kopyala_dugme.grab_focus()


## Panoya kopyalanan metin: bolum, degistirici, sure, olum, cevirme, seri.
func paylasim_metni() -> String:
	return Ayarlar.gunluk_paylasim(sure, olum, cevirme)


func _kopyala() -> void:
	DisplayServer.clipboard_set(paylasim_metni())
	_kopyala_dugme.text = "Kopyalandı"
	Ses.cal(&"menu")


# --- gunluk hayalet yarisi ----------------------------------------------------

func _hayalet_yarisi() -> bool:
	return Ayarlar.gunluk_mod and Ayarlar.gunluk_degistirici() == 2 and not _altin_yol.is_empty()


## Altin hayaletin yolu bitti = hayalet kapiya vardi. Indeks formulu
## _hayalet_isle ile ayni: hayalet ekrandan kaybolunca kazanmistir.
func _hayalet_bitti() -> bool:
	return int(sure * 60.0 / float(Ayarlar.HAYALET_ARALIGI)) >= _altin_yol.size()


func _hayalet_kazandi() -> void:
	_durum = HAYALET
	_zaman = 0.0
	_inis.visible = false
	_mesaj.text = "HAYALET KAZANDI — baştan"
	_mesaj.add_theme_color_override("font_color", Ayarlar.MADALYA_RENK[3])
	Ses.cal(&"olum")
	sars(Ayarlar.SARSINTI_OLUM)
	_oyuncu.set_physics_process(false)


func _ana_bitti() -> void:
	var sonuc: Dictionary = Ayarlar.bolum_bitti(bolum_i, sure, cevirme)
	var m: int = sonuc["madalya"]
	if m > 0:
		Ses.cal(&"madalya")
	if bool(sonuc["rekor"]):
		Ayarlar.hayalet_kaydet(bolum_i, _yol)
	if bool(sonuc["yardim"]):
		_mesaj.text = ("BÖLÜM TAMAM — %.2f sn · %d çevirme\n"
			+ "Yardım modu açık: süre ve madalya kaydı tutulmuyor, kristaller sayılıyor.") % [sure, cevirme]
		_mesaj.add_theme_color_override("font_color", Ayarlar.RENK_METIN)
	else:
		var ek := ""
		if bool(sonuc["rekor"]):
			ek += "  YENİ REKOR!"
		if bool(sonuc["az_rekor"]):
			ek += "  EN AZ ÇEVİRME: %d" % cevirme
		_mesaj.text = "BÖLÜM TAMAM — %.2f sn%s\n%s madalya" % [sure, ek, Ayarlar.MADALYA_AD[m]]
		_mesaj.add_theme_color_override("font_color", Ayarlar.MADALYA_RENK[m])


## Olum haritasi: bolumun kucultulmus plani ve oldugun her nokta X ile.
## Neden: tekrar tekrar ayni yerde olurken bunu fark etmek zor; harita
## "burada takiliyorsun" der ve ekran goruntusu olarak paylasilabilir.
func _olum_haritasi_goster() -> void:
	for c in _harita_alan.get_children():
		c.queue_free()
	if _olum_yerleri.is_empty():
		_olum_haritasi.visible = false
		return
	# Olcek hem genislige hem yukseklige sigsin: 40 ve 64 sutunluk bolumler ayni
	# yukseklikte cizilsin diye kucuk olan secilir.
	var olcek: float = minf(_harita_alan.size.x / float(maxi(_bolum.genislik_px, 1)),
		_harita_alan.size.y / float(maxi(_bolum.yukseklik_px, 1)))
	var kaydir := Vector2((_harita_alan.size.x - _bolum.genislik_px * olcek) * 0.5, 0.0)
	for satir_i in _bolum.harita.size():
		var satir: String = _bolum.harita[satir_i]
		var c := 0
		while c < satir.length():
			var ch := satir[c]
			if not (ch in ["#", "^", "v", "K", "_", "~", "="]):
				c += 1
				continue
			var bas := c
			while c < satir.length() and satir[c] == ch:
				c += 1
			var kutu := ColorRect.new()
			kutu.mouse_filter = Control.MOUSE_FILTER_IGNORE
			kutu.position = kaydir + Vector2(bas * Ayarlar.HUCRE * olcek, satir_i * Ayarlar.HUCRE * olcek)
			kutu.size = Vector2(maxf((c - bas) * Ayarlar.HUCRE * olcek, 1.0),
				maxf(Ayarlar.HUCRE * olcek, 1.0))
			match ch:
				"#": kutu.color = Color(0.29, 0.33, 0.46)
				"K": kutu.color = Color(0.39, 0.78, 0.30)
				"_", "~": kutu.color = Color(0.75, 0.79, 0.86)
				"=": kutu.color = Color(0.97, 0.46, 0.13, 0.6)
				_: kutu.color = Color(0.89, 0.23, 0.27)
			_harita_alan.add_child(kutu)
	for yer in _olum_yerleri:
		var x := Label.new()
		x.text = "×"
		x.add_theme_font_size_override("font_size", 12)
		x.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
		x.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08))
		x.add_theme_constant_override("outline_size", 3)
		x.mouse_filter = Control.MOUSE_FILTER_IGNORE
		x.position = kaydir + Vector2(yer.x * olcek - 4.0, yer.y * olcek - 8.0)
		_harita_alan.add_child(x)
	$Arayuz/OlumHaritasi/Baslik.text = "Bu bölümde %d kez öldün" % _olum_yerleri.size()
	_olum_haritasi.visible = true


func _sonraki() -> void:
	_olum_haritasi.visible = false
	if Ayarlar.gunluk_mod:
		_gunluk_panel()              # gunun bolumu tek bolumdur, zincir yok
		return
	if bolum_i + 1 < Ayarlar.bolum_sayisi():
		_mesaj.add_theme_color_override("font_color", Ayarlar.RENK_METIN)
		_karart(true)
		await get_tree().create_timer(GECIS_SURESI).timeout
		bolum_yukle(bolum_i + 1)
		_karart(false)
	else:
		_durum = BITTI
		_mesaj.text = ""
		_oyuncu.visible = false
		var madalyalar := Ayarlar.madalya_sayisi()
		var az := 0
		for i in Ayarlar.bolum_sayisi():
			if Ayarlar.en_az_al(i) >= 0 and Ayarlar.en_az_al(i) <= Ayarlar.en_az_hedef(i):
				az += 1
		_bitis_metin.text = ("Tüm %d bölüm bitti!\n\nToplam süre: %.2f sn\nToplam ölüm: %d\n"
			+ "Kristal: %d / %d\nMadalya kazanılan bölüm: %d / %d\n"
			+ "En az çevirmeyle biten bölüm: %d / %d") % [
				Ayarlar.bolum_sayisi(), toplam_sure, toplam_olum,
				Ayarlar.kristal_sayisi(), Ayarlar.bolum_sayisi(),
				madalyalar, Ayarlar.bolum_sayisi(), az, Ayarlar.bolum_sayisi()]
		_bitis.visible = true
		Ses.muzik(&"bitis")


# --- duraklatma ve gecisler ---------------------------------------------------

func _unhandled_input(olay: InputEvent) -> void:
	if olay.is_action_pressed("duraklat") and _durum != BITTI:
		if get_tree().paused:
			_devam()
		else:
			get_tree().paused = true
			_duraklat.visible = true
			$Arayuz/Duraklat/Kutu/Atla.visible = Ayarlar.yardim_acik and not Ayarlar.gunluk_mod
			$Arayuz/Duraklat/Kutu/Devam.grab_focus()
			Ses.cal(&"menu")


func _devam() -> void:
	Ses.cal(&"menu")
	get_tree().paused = false
	_duraklat.visible = false


func _bastan() -> void:
	Ses.cal(&"menu")
	get_tree().paused = false
	_duraklat.visible = false
	# Bolumu bastan kur: yalniz dogus noktasini geri almak yetmez, etkinlesmis
	# kontrol noktasi yanik kalir ve bir daha tetiklenmez.
	bolum_yukle(bolum_i)


## Yardim modu: bolum atlama. Sure/madalya vermez, yalniz yolu acar.
func _atla() -> void:
	Ses.cal(&"menu")
	get_tree().paused = false
	_duraklat.visible = false
	if bolum_i + 1 >= Ayarlar.bolum_sayisi() or Ayarlar.gunluk_mod:
		_menuye()
		return
	Ayarlar.bolum_ac(bolum_i)
	bolum_yukle(bolum_i + 1)


func _ayarlara() -> void:
	Ses.cal(&"menu")
	get_tree().paused = false
	Ayarlar.secilen_bolum = bolum_i
	Ayarlar.donus_sahnesi = "res://scenes/oyun.tscn"
	get_tree().change_scene_to_file("res://scenes/ayarlar_ekrani.tscn")


func _menuye() -> void:
	Ses.cal(&"menu")
	get_tree().paused = false
	Ayarlar.zaman_sifirla()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
