extends Control
## Bolum Sec: acilmis bolumler tiklanabilir, her birinde en iyi sure yazili.

func _ready() -> void:
	var izgara: GridContainer = $Kutu/Izgara
	for i in Ayarlar.bolum_sayisi():
		var acik := Ayarlar.acik_mi(i)
		var dugme := Button.new()
		dugme.custom_minimum_size = Vector2(82, 46)
		dugme.text = "%d\n%s" % [i + 1, Ayarlar.en_iyi_metin(i)] if acik else "%d\nkilitli" % (i + 1)
		dugme.disabled = not acik
		dugme.pressed.connect(func() -> void:
			Ayarlar.secilen_bolum = i
			get_tree().change_scene_to_file("res://scenes/oyun.tscn"))
		izgara.add_child(dugme)
	$Geri.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/menu.tscn"))
