extends CharacterBody2D
## Tek dikey eylem: CEVIR. Yercekimi isaretini ters cevirir, oyuncu tavana "duser".
## Ziplama yok. Cevirme yalniz bir yuzeye degerken calisir + kisa giris tamponu var.
##
## Okunurluk: cevirince kisa bir hayalet izi birakir, sprite esneyip sikisir ve
## "cevirdi" sinyaliyle sahneye sarsinti/ses/arka plan kaymasi haber verilir.

signal oldu
signal cevirdi(yeni_yon: float)
signal kondu

var yercekimi_yonu: float = 1.0   ## 1 = asagi ceker, -1 = yukari ceker
var yasiyor: bool = true
var girdi_acik: bool = true       ## testler kapatabilsin diye

var _tampon: float = 0.0
var _kojot: float = 0.0           ## yuzeyden ayrildiktan sonra kalan cevirme hakki
var _bakis: float = 1.0
var _iz_kalan: float = 0.0
var _iz_sayaci: float = 0.0
var _onceki_yerde: bool = true
var _ezilme: Tween = null

@onready var _gorsel: AnimatedSprite2D = $Gorsel
@onready var _ok: Node2D = $Ok


func _ready() -> void:
	add_to_group("oyuncu")
	up_direction = Vector2(0.0, -yercekimi_yonu)


## Bolum basina (ya da kontrol noktasina) dondurur. yon = -1: ters yercekimiyle
## dogar, tavana duser (gunluk bolumun "ters baslangic" degistiricisi).
func hazirla(konum: Vector2, yon: float = 1.0) -> void:
	position = konum
	velocity = Vector2.ZERO
	yercekimi_yonu = yon
	up_direction = Vector2(0.0, -yon)
	_tampon = 0.0
	_kojot = 0.0
	_bakis = 1.0
	_iz_kalan = 0.0
	_onceki_yerde = true
	yasiyor = true
	_gorsel.flip_v = yon < 0.0
	_gorsel.scale = Vector2.ONE
	_ok.scale.y = yon
	visible = true
	set_physics_process(true)


func oldur() -> void:
	if not yasiyor:
		return
	yasiyor = false
	velocity = Vector2.ZERO
	_iz_kalan = 0.0
	set_physics_process(false)
	oldu.emit()


## Yercekimini cevirir. Basarili olursa true doner.
##
## Affetme: yuzeyden yeni ayrilmis olmak cevirmeyi engellemez — CEVIR_KOJOT
## (0,08 sn) boyunca hak surer. Ustune CEVIR_TAMPONU (0,10 sn) erken basilan
## tusu saklar. Ikisi birlikte "bir kare gec bastim" olumunu ortadan kaldirir.
func cevir() -> bool:
	if not is_on_floor() and _kojot <= 0.0:
		return false
	_kojot = 0.0
	yercekimi_yonu = -yercekimi_yonu
	up_direction = Vector2(0.0, -yercekimi_yonu)
	velocity.y = Ayarlar.CEVIR_ITISI * yercekimi_yonu
	_tampon = 0.0
	_iz_kalan = Ayarlar.IZ_SURESI
	_iz_sayaci = 0.0
	_ezil(Vector2(0.72, 1.28))
	cevirdi.emit(yercekimi_yonu)
	return true


## Yardim modu (olumsuzluk): diken oldurmez, oyuncuyu geldigi yone geri iter.
func geri_it() -> void:
	var yon: float = -signf(velocity.x) if absf(velocity.x) > 1.0 else -_bakis
	velocity.x = yon * Ayarlar.HIZ * 1.2
	position.x += yon * 6.0
	_ezil(Vector2(1.25, 0.75))


func _physics_process(delta: float) -> void:
	if not yasiyor:
		return

	var yerde := is_on_floor()
	_kojot = Ayarlar.CEVIR_KOJOT if yerde else maxf(0.0, _kojot - delta)

	if yerde:
		# yuzeye hafifce yapisik kal (egimsiz haritada yeterli)
		velocity.y = Ayarlar.YERCEKIMI * yercekimi_yonu * delta * 3.0
	else:
		velocity.y += Ayarlar.YERCEKIMI * yercekimi_yonu * delta
		velocity.y = clampf(velocity.y, -Ayarlar.EN_YUKSEK_DUSUS, Ayarlar.EN_YUKSEK_DUSUS)

	if girdi_acik and Input.is_action_just_pressed("cevir"):
		_tampon = Ayarlar.CEVIR_TAMPONU
	else:
		_tampon = maxf(0.0, _tampon - delta)

	if _tampon > 0.0 and (yerde or _kojot > 0.0):
		if cevir():
			yerde = true

	var yon := 0.0
	if girdi_acik:
		yon = Input.get_axis("move_left", "move_right")
	var carpan := 1.0 if yerde else Ayarlar.HAVA_CARPANI
	if yon != 0.0:
		velocity.x = move_toward(velocity.x, yon * Ayarlar.HIZ, Ayarlar.IVME * delta * carpan)
	else:
		velocity.x = move_toward(velocity.x, 0.0, Ayarlar.SURTUNME * delta * carpan)

	move_and_slide()

	var simdi_yerde := is_on_floor()
	if simdi_yerde and not _onceki_yerde:
		_ezil(Vector2(1.28, 0.72))
		kondu.emit()
	_onceki_yerde = simdi_yerde

	_iz_isle(delta)

	if yon != 0.0:
		_bakis = yon
	_gorsel.flip_h = _bakis < 0.0
	_gorsel.flip_v = yercekimi_yonu < 0.0
	# Yercekimi yonu oku: durumu renkten degil BICIMDEN okunur kilar.
	_ok.visible = Ayarlar.yercekimi_oku
	_ok.scale.y = yercekimi_yonu

	var anim: StringName
	if simdi_yerde:
		anim = &"idle" if absf(velocity.x) < 5.0 else &"yuru"
	else:
		anim = &"zipla" if velocity.y * yercekimi_yonu < 0.0 else &"dus"
	if _gorsel.animation != anim:
		_gorsel.play(anim)


## Cevirme anini okunur kilan kisa hayalet izi.
func _iz_isle(delta: float) -> void:
	if _iz_kalan <= 0.0:
		return
	_iz_kalan -= delta
	if not Ayarlar.oyun_hissi:
		return
	_iz_sayaci -= delta
	if _iz_sayaci > 0.0:
		return
	_iz_sayaci = Ayarlar.IZ_ARALIGI
	var kareler: SpriteFrames = _gorsel.sprite_frames
	var hayalet := Sprite2D.new()
	hayalet.texture = kareler.get_frame_texture(_gorsel.animation, _gorsel.frame)
	hayalet.flip_h = _gorsel.flip_h
	hayalet.flip_v = _gorsel.flip_v
	hayalet.global_position = global_position
	hayalet.modulate = Ayarlar.IZ_RENGI
	hayalet.z_index = -1
	get_parent().add_child(hayalet)
	var t := hayalet.create_tween()
	t.tween_property(hayalet, "modulate:a", 0.0, 0.28)
	t.tween_callback(hayalet.queue_free)


func _ezil(olcek: Vector2) -> void:
	if not Ayarlar.oyun_hissi:
		return
	if _ezilme != null and _ezilme.is_valid():
		_ezilme.kill()
	_gorsel.scale = olcek
	_ezilme = create_tween()
	_ezilme.tween_property(_gorsel, "scale", Vector2.ONE, Ayarlar.EZILME_SURESI) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
