extends Node2D
## Bolum dongusu: yukle -> oyna -> ol/bitir -> sonraki.
## Kontrol noktasi, kristal, madalya, duraklatma ve bitis ekrani da burada.

enum { OYNA, OLDU, TAMAM, BITTI }

const OLUM_BEKLEME: float = 0.30   ## olunce bu kadar sonra otomatik yeniden dene
const TAMAM_BEKLEME: float = 1.00
const GECIS_SURESI: float = 0.22

var bolum_i: int = 0
var sure: float = 0.0
var olum: int = 0
var toplam_sure: float = 0.0
var toplam_olum: int = 0
var toplam_kristal: int = 0

var _durum: int = OYNA
var _zaman: float = 0.0
var _bolum: Bolum = null
var _dogus: Vector2 = Vector2.ZERO
var _sarsinti: float = 0.0
var _arka_tween: Tween = null
var _gecis: bool = false   ## bolum gecisi surerken _sonraki() tekrar cagrilmasin

@onready var _dunya: Node2D = $Dunya
@onready var _oyuncu: CharacterBody2D = $Dunya/Oyuncu
@onready var _kamera: Camera2D = $Dunya/Oyuncu/Kamera
@onready var _toz: CPUParticles2D = $Dunya/Toz
@onready var _olum_parca: CPUParticles2D = $Dunya/Olum
@onready var _toplama: CPUParticles2D = $Dunya/Toplama
@onready var _arka_katlar: Array[CanvasItem] = [$Arka/Kat0, $Arka/Kat1, $Arka/Kat2]
@onready var _ad: Label = $Arayuz/Ad
@onready var _sayac: Label = $Arayuz/Sayac
@onready var _hedef: Label = $Arayuz/Hedef
@onready var _ipucu: Label = $Arayuz/Ipucu
@onready var _mesaj: Label = $Arayuz/Mesaj
@onready var _kristal_ikon: TextureRect = $Arayuz/KristalIkon
@onready var _kristal_yazi: Label = $Arayuz/KristalYazi
@onready var _duraklat: Panel = $Arayuz/Duraklat
@onready var _bitis: Panel = $Arayuz/Bitis
@onready var _bitis_metin: Label = $Arayuz/Bitis/Kutu/Metin
@onready var _dokunmatik: Control = $Arayuz/Dokunmatik
@onready var _karartma: ColorRect = $Gecis/Karartma


func _ready() -> void:
	_oyuncu.oldu.connect(_olum_oldu)
	_oyuncu.cevirdi.connect(_cevirdi)
	_oyuncu.kondu.connect(_kondu)
	$Arayuz/Duraklat/Kutu/Devam.pressed.connect(_devam)
	$Arayuz/Duraklat/Kutu/Bastan.pressed.connect(_bastan)
	$Arayuz/Duraklat/Kutu/Ayar.pressed.connect(_ayarlara)
	$Arayuz/Duraklat/Kutu/Menu.pressed.connect(_menuye)
	$Arayuz/Bitis/Kutu/Menu.pressed.connect(_menuye)
	_dokunmatik.visible = DisplayServer.is_touchscreen_available()
	_dokunmatik_bagla("Sol", "move_left")
	_dokunmatik_bagla("Sag", "move_right")
	_dokunmatik_bagla("Cevir", "cevir")
	Ses.muzik(&"oyun")
	bolum_yukle(Ayarlar.secilen_bolum)
	_karartma.color.a = 1.0
	_karart(false)


func _dokunmatik_bagla(dugme_adi: String, eylem: String) -> void:
	var d: Button = _dokunmatik.get_node(dugme_adi)
	d.button_down.connect(func() -> void: Input.action_press(eylem))
	d.button_up.connect(func() -> void: Input.action_release(eylem))


func bolum_yukle(i: int) -> void:
	bolum_i = clampi(i, 0, Ayarlar.bolum_sayisi() - 1)
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
	if Ayarlar.kristal_var(bolum_i):
		_bolum.kristali_gizle()

	_kamera.limit_left = 0
	_kamera.limit_right = maxi(_bolum.genislik_px, 640)
	var ust := int((_bolum.yukseklik_px - 360) / 2.0)
	_kamera.limit_top = ust
	_kamera.limit_bottom = ust + 360

	sure = 0.0
	olum = 0
	_gecis = false
	_dogus = _bolum.baslangic
	_ad.text = String(veri["ad"])
	_ipucu.text = String(veri["ipucu"])
	_hedef.text = "Hedef  ● %.1f  ● %.1f  ● %.1f sn" % [veri["altin"], veri["gumus"], veri["bronz"]]
	_kristal_guncelle()
	_arka_ton(1.0, true)
	yeniden_basla()


func yeniden_basla() -> void:
	_bolum.sifirla()
	_oyuncu.hazirla(_dogus)
	_kamera.reset_smoothing()
	_mesaj.text = ""
	_durum = OYNA
	_zaman = 0.0
	_arka_ton(1.0, true)


func _kristal_guncelle() -> void:
	var var_mi := Ayarlar.kristal_var(bolum_i)
	_kristal_ikon.modulate.a = 1.0 if var_mi else 0.28
	_kristal_yazi.text = "%d / %d kristal" % [Ayarlar.kristal_sayisi(), Ayarlar.bolum_sayisi()]


func _process(delta: float) -> void:
	_sarsinti_isle(delta)
	if get_tree().paused:
		return
	_zaman += delta
	match _durum:
		OYNA:
			sure += delta
			if _bolum.disarida(_oyuncu.global_position):
				_oyuncu.oldur()
		OLDU:
			if _zaman >= OLUM_BEKLEME:
				yeniden_basla()
		TAMAM:
			if _zaman >= TAMAM_BEKLEME and not _gecis:
				_gecis = true
				_sonraki()
	_sayac.text = "Süre %.2f   Ölüm %d   En iyi %s" % [sure, olum, Ayarlar.en_iyi_metin(bolum_i)]


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
	Ses.cal((&"cevir" if yeni_yon < 0.0 else &"cevir_ters"))
	sars(Ayarlar.SARSINTI_CEVIR)
	_arka_ton(yeni_yon)


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
	_durum = OLDU
	_zaman = 0.0
	_mesaj.text = "ÖLDÜN"
	Ses.cal(&"olum")
	sars(Ayarlar.SARSINTI_OLUM)
	_parcacik(_olum_parca, _oyuncu.global_position)


func _diken_temasi() -> void:
	if _durum == OYNA:
		_oyuncu.oldur()


func _kristal() -> void:
	Ayarlar.kristal_topla(bolum_i)
	toplam_kristal += 1
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
	_durum = TAMAM
	_zaman = 0.0
	toplam_sure += sure
	var sonuc: Dictionary = Ayarlar.bolum_bitti(bolum_i, sure)
	var m: int = sonuc["madalya"]
	Ses.cal(&"bolum_sonu")
	if m > 0:
		Ses.cal(&"madalya")
	var ek := ""
	if bool(sonuc["rekor"]):
		ek += "  YENİ REKOR!"
	_mesaj.text = "BÖLÜM TAMAM — %.2f sn%s\n%s madalya" % [sure, ek, Ayarlar.MADALYA_AD[m]]
	_mesaj.add_theme_color_override("font_color", Ayarlar.MADALYA_RENK[m])
	_oyuncu.set_physics_process(false)


func _sonraki() -> void:
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
		var madalyalar := 0
		for i in Ayarlar.bolum_sayisi():
			if Ayarlar.madalya_al(i) > 0:
				madalyalar += 1
		_bitis_metin.text = ("Tüm %d bölüm bitti!\n\nToplam süre: %.2f sn\nToplam ölüm: %d\n"
			+ "Kristal: %d / %d\nMadalya kazanılan bölüm: %d / %d") % [
				Ayarlar.bolum_sayisi(), toplam_sure, toplam_olum,
				Ayarlar.kristal_sayisi(), Ayarlar.bolum_sayisi(),
				madalyalar, Ayarlar.bolum_sayisi()]
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
	_dogus = _bolum.baslangic
	sure = 0.0
	yeniden_basla()


func _ayarlara() -> void:
	Ses.cal(&"menu")
	get_tree().paused = false
	Ayarlar.secilen_bolum = bolum_i
	Ayarlar.donus_sahnesi = "res://scenes/oyun.tscn"
	get_tree().change_scene_to_file("res://scenes/ayarlar_ekrani.tscn")


func _menuye() -> void:
	Ses.cal(&"menu")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
