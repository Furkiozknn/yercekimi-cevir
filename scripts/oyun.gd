extends Node2D
## Bolum dongusu: yukle -> oyna -> ol/bitir -> sonraki. Duraklatma ve bitis ekrani da burada.

enum { OYNA, OLDU, TAMAM, BITTI }

const OLUM_BEKLEME: float = 0.30   ## olunce bu kadar sonra otomatik yeniden dene
const TAMAM_BEKLEME: float = 1.00

var bolum_i: int = 0
var sure: float = 0.0
var olum: int = 0
var toplam_sure: float = 0.0
var toplam_olum: int = 0

var _durum: int = OYNA
var _zaman: float = 0.0
var _bolum: Bolum = null

@onready var _dunya: Node2D = $Dunya
@onready var _oyuncu: CharacterBody2D = $Dunya/Oyuncu
@onready var _kamera: Camera2D = $Dunya/Oyuncu/Kamera
@onready var _ad: Label = $Arayuz/Ad
@onready var _sayac: Label = $Arayuz/Sayac
@onready var _ipucu: Label = $Arayuz/Ipucu
@onready var _mesaj: Label = $Arayuz/Mesaj
@onready var _duraklat: Panel = $Arayuz/Duraklat
@onready var _bitis: Panel = $Arayuz/Bitis
@onready var _bitis_metin: Label = $Arayuz/Bitis/Kutu/Metin
@onready var _dokunmatik: Control = $Arayuz/Dokunmatik


func _ready() -> void:
	_oyuncu.oldu.connect(_olum_oldu)
	$Arayuz/Duraklat/Kutu/Devam.pressed.connect(_devam)
	$Arayuz/Duraklat/Kutu/Menu.pressed.connect(_menuye)
	$Arayuz/Bitis/Kutu/Menu.pressed.connect(_menuye)
	_dokunmatik.visible = DisplayServer.is_touchscreen_available()
	_dokunmatik_bagla("Sol", "move_left")
	_dokunmatik_bagla("Sag", "move_right")
	_dokunmatik_bagla("Cevir", "cevir")
	bolum_yukle(Ayarlar.secilen_bolum)


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
	var veri: Dictionary = Bolumler.BOLUMLER[bolum_i]
	_bolum.kur(veri)
	_bolum.olum_temasi.connect(_diken_temasi)
	_bolum.kapiya_varildi.connect(_kapi)

	_kamera.limit_left = 0
	_kamera.limit_right = maxi(_bolum.genislik_px, 640)
	var ust := int((_bolum.yukseklik_px - 360) / 2.0)
	_kamera.limit_top = ust
	_kamera.limit_bottom = ust + 360

	sure = 0.0
	olum = 0
	_ad.text = String(veri["ad"])
	_ipucu.text = String(veri["ipucu"])
	yeniden_basla()


func yeniden_basla() -> void:
	_bolum.sifirla()
	_oyuncu.hazirla(_bolum.baslangic)
	_kamera.reset_smoothing()
	_mesaj.text = ""
	_durum = OYNA
	_zaman = 0.0


func _process(delta: float) -> void:
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
			if _zaman >= TAMAM_BEKLEME:
				_sonraki()
	_sayac.text = "Süre %.2f   Ölüm %d   En iyi %s" % [sure, olum, Ayarlar.en_iyi_metin(bolum_i)]


func _olum_oldu() -> void:
	if _durum != OYNA:
		return
	olum += 1
	toplam_olum += 1
	_durum = OLDU
	_zaman = 0.0
	_mesaj.text = "ÖLDÜN"


func _diken_temasi() -> void:
	if _durum == OYNA:
		_oyuncu.oldur()


func _kapi() -> void:
	if _durum != OYNA:
		return
	_durum = TAMAM
	_zaman = 0.0
	toplam_sure += sure
	var rekor := Ayarlar.bolum_bitti(bolum_i, sure)
	_mesaj.text = "BÖLÜM TAMAM — %.2f sn%s" % [sure, "  YENİ REKOR!" if rekor else ""]
	_oyuncu.set_physics_process(false)


func _sonraki() -> void:
	if bolum_i + 1 < Ayarlar.bolum_sayisi():
		bolum_yukle(bolum_i + 1)
	else:
		_durum = BITTI
		_mesaj.text = ""
		_oyuncu.visible = false
		_bitis_metin.text = "Tüm bölümler bitti!\n\nToplam süre: %.2f sn\nToplam ölüm: %d" \
			% [toplam_sure, toplam_olum]
		_bitis.visible = true


func _unhandled_input(olay: InputEvent) -> void:
	if olay.is_action_pressed("duraklat") and _durum != BITTI:
		if get_tree().paused:
			_devam()
		else:
			get_tree().paused = true
			_duraklat.visible = true


func _devam() -> void:
	get_tree().paused = false
	_duraklat.visible = false


func _menuye() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
