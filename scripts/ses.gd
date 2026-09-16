extends Node
## Tek durak ses. Efektler kucuk bir oynatici havuzundan calar (ust uste binebilsin),
## muzik tek oynaticida doner.
##
## Ses duzeyi burada DEGIL Ayarlar.ses_uygula() icinde, AudioServer veriyolunda
## ayarlanir: Godot'un web hedefinde AudioStreamPlayer.volume_db sessizce yok
## sayilabiliyor, veriyolu ise her zaman calisiyor.

const EFEKT := {
	&"cevir": preload("res://assets/audio/cevir.wav"),
	&"cevir_ters": preload("res://assets/audio/cevir_ters.wav"),
	&"kristal": preload("res://assets/audio/kristal.wav"),
	&"kontrol": preload("res://assets/audio/kontrol.wav"),
	&"olum": preload("res://assets/audio/olum.wav"),
	&"bolum_sonu": preload("res://assets/audio/bolum_sonu.wav"),
	&"madalya": preload("res://assets/audio/madalya.wav"),
	&"menu": preload("res://assets/audio/menu.wav"),
	&"inis": preload("res://assets/audio/inis.wav"),
}

const MUZIK := {
	&"menu": preload("res://assets/audio/muzik_menu.wav"),
	&"oyun": preload("res://assets/audio/muzik_oyun.wav"),
	&"bitis": preload("res://assets/audio/muzik_bitis.wav"),
}

const HAVUZ: int = 6

var _havuz: Array[AudioStreamPlayer] = []
var _sira: int = 0
var _muzik: AudioStreamPlayer
var _calan: StringName = &""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in HAVUZ:
		var p := AudioStreamPlayer.new()
		p.bus = &"Efekt"
		add_child(p)
		_havuz.append(p)
	_muzik = AudioStreamPlayer.new()
	_muzik.bus = &"Muzik"
	add_child(_muzik)
	# Ice aktarma ayarina guvenmeden dongu noktalarini burada kur: WAV 16 bit mono.
	for ad in MUZIK:
		if ad == &"bitis":
			continue
		var s: AudioStreamWAV = MUZIK[ad]
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		s.loop_begin = 0
		s.loop_end = s.data.size() / 2


## Cikmadan ONCE cagrilmali. Godot agaci alttan yukari sokuyor: Ses._exit_tree()
## calistiginda oynatici zaten agactan cikmis oluyor ve orada stop() etmek gec
## kaliyor ("resource still in use at exit"). Bu yuzden kapanis yollari (Cikis
## dugmesi, pencere kapatma, testler) once bunu cagirir.
func kapat() -> void:
	_muzik.stop()
	_muzik.stream = null
	_calan = &""
	for p in _havuz:
		p.stop()
		p.stream = null


func _notification(ne: int) -> void:
	if ne == NOTIFICATION_WM_CLOSE_REQUEST:
		kapat()


func cal(ad: StringName) -> void:
	if not EFEKT.has(ad):
		push_warning("Bilinmeyen efekt: %s" % ad)
		return
	var p := _havuz[_sira]
	_sira = (_sira + 1) % HAVUZ
	p.stream = EFEKT[ad]
	p.play()


func muzik(ad: StringName) -> void:
	if _calan == ad and _muzik.playing:
		return
	_calan = ad
	_muzik.stream = MUZIK[ad]
	_muzik.play()


func muzik_durdur() -> void:
	_calan = &""
	_muzik.stop()
