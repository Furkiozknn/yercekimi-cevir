extends Control
## Ana menu.

func _ready() -> void:
	$Kutu/Basla.pressed.connect(_basla)
	$Kutu/Sec.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/bolum_sec.tscn"))
	$Kutu/Cikis.pressed.connect(func() -> void: get_tree().quit())
	if OS.has_feature("web"):
		$Kutu/Cikis.hide()
	$Durum.text = "Açık bölüm: %d / %d" % [Ayarlar.acilan_bolum + 1, Ayarlar.bolum_sayisi()]
	$Kutu/Basla.grab_focus()


func _basla() -> void:
	Ayarlar.secilen_bolum = Ayarlar.acilan_bolum
	get_tree().change_scene_to_file("res://scenes/oyun.tscn")
