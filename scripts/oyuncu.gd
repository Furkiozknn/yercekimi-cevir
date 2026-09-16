extends CharacterBody2D
## Tek dikey eylem: CEVIR. Yercekimi isaretini ters cevirir, oyuncu tavana "duser".
## Ziplama yok. Cevirme yalniz bir yuzeye degerken calisir + kisa giris tamponu var.

signal oldu

var yercekimi_yonu: float = 1.0   ## 1 = asagi ceker, -1 = yukari ceker
var yasiyor: bool = true
var girdi_acik: bool = true       ## testler kapatabilsin diye

var _tampon: float = 0.0
var _bakis: float = 1.0

@onready var _gorsel: AnimatedSprite2D = $Gorsel


func _ready() -> void:
	add_to_group("oyuncu")
	up_direction = Vector2(0.0, -yercekimi_yonu)


## Bolum basina dondurur.
func hazirla(konum: Vector2) -> void:
	position = konum
	velocity = Vector2.ZERO
	yercekimi_yonu = 1.0
	up_direction = Vector2.UP
	_tampon = 0.0
	_bakis = 1.0
	yasiyor = true
	_gorsel.flip_v = false
	visible = true
	set_physics_process(true)


func oldur() -> void:
	if not yasiyor:
		return
	yasiyor = false
	velocity = Vector2.ZERO
	set_physics_process(false)
	oldu.emit()


## Yercekimini cevirir. Havadayken calismaz; basarili olursa true doner.
func cevir() -> bool:
	if not is_on_floor():
		return false
	yercekimi_yonu = -yercekimi_yonu
	up_direction = Vector2(0.0, -yercekimi_yonu)
	velocity.y = Ayarlar.CEVIR_ITISI * yercekimi_yonu
	_tampon = 0.0
	return true


func _physics_process(delta: float) -> void:
	if not yasiyor:
		return

	var yerde := is_on_floor()

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

	if _tampon > 0.0 and yerde:
		cevir()
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

	if yon != 0.0:
		_bakis = yon
	_gorsel.flip_h = _bakis < 0.0
	_gorsel.flip_v = yercekimi_yonu < 0.0

	var anim: StringName
	if is_on_floor():
		anim = &"idle" if absf(velocity.x) < 5.0 else &"yuru"
	else:
		anim = &"zipla" if velocity.y * yercekimi_yonu < 0.0 else &"dus"
	if _gorsel.animation != anim:
		_gorsel.play(anim)
