extends Control
## Ayarlar ekrani: muzik/efekt ses duzeyi ve ac-kapa, tam ekran, oyun hissi.
## Her degisiklik aninda uygulanir ve user://kayit.cfg icine yazilir.

@onready var _izgara: GridContainer = $Kutu/Izgara


func _ready() -> void:
	_kaydirici("Muzik", Ayarlar.muzik_ses, func(v: float) -> void:
		Ayarlar.muzik_ses = v)
	_kaydirici("Efekt", Ayarlar.efekt_ses, func(v: float) -> void:
		Ayarlar.efekt_ses = v
		Ses.cal(&"menu"))
	_anahtar("MuzikAcik", Ayarlar.muzik_acik, func(a: bool) -> void:
		Ayarlar.muzik_acik = a)
	_anahtar("EfektAcik", Ayarlar.efekt_acik, func(a: bool) -> void:
		Ayarlar.efekt_acik = a
		if a:
			Ses.cal(&"menu"))
	_anahtar("TamEkran", Ayarlar.tam_ekran, func(a: bool) -> void:
		Ayarlar.tam_ekran = a
		Ayarlar.ekran_uygula())
	_anahtar("OyunHissi", Ayarlar.oyun_hissi, func(a: bool) -> void:
		Ayarlar.oyun_hissi = a)

	if OS.has_feature("web"):
		# Tarayicida tam ekrani oyun degil kullanici acar.
		$Kutu/Izgara/TamEkranYazi.hide()
		$Kutu/Izgara/TamEkranBosluk.hide()
		$Kutu/Izgara/TamEkran.hide()

	$Geri.pressed.connect(_geri)
	$Geri.grab_focus()


func _kaydirici(ad: String, deger: float, uygula: Callable) -> void:
	var k: HSlider = _izgara.get_node(ad)
	k.value = deger
	k.value_changed.connect(func(v: float) -> void:
		uygula.call(v)
		Ayarlar.ses_uygula()
		Ayarlar.kaydet())


func _anahtar(ad: String, deger: bool, uygula: Callable) -> void:
	var d: CheckButton = _izgara.get_node(ad)
	d.button_pressed = deger
	d.toggled.connect(func(a: bool) -> void:
		uygula.call(a)
		Ayarlar.ses_uygula()
		Ayarlar.kaydet())


func _geri() -> void:
	Ses.cal(&"menu")
	get_tree().change_scene_to_file(Ayarlar.donus_sahnesi)
