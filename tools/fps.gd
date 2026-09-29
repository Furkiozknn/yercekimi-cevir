extends SceneTree
## Olcum araci: oyun sahnesini gercek render ile calistirir, kare suresini olcer.
##   godot --path . -s res://tools/fps.gd -- <bolum_indeksi> <kare_sayisi>
## Vsync kapali, 90 kare isinma; cevirme tusu 0,7 sn'de bir basilir (parcacik,
## sarsinti ve hayalet izi calissin). Sonuc: ortalama ms, %99 ms, FPS.
## Yalniz olcer; kayit dosyasina dokunmaz (kaydet cagirilmaz).

var _bolum: int = 9


func _initialize() -> void:
	var arg := OS.get_cmdline_user_args()
	_bolum = int(arg[0]) if arg.size() > 0 else 9
	var kare_n := int(arg[1]) if arg.size() > 1 else 600
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var oyun: Node = load("res://scenes/oyun.tscn").instantiate()
	root.get_node("Ayarlar").secilen_bolum = _bolum
	root.add_child(oyun)
	_kos(oyun, kare_n)


func _kos(oyun: Node, kare_n: int) -> void:
	var sureler: Array[float] = []
	var son := Time.get_ticks_usec()
	var i := 0
	while i < kare_n + 90:
		await process_frame
		var s := Time.get_ticks_usec()
		if i >= 90:
			sureler.append(float(s - son) / 1000.0)
		son = s
		if i % 42 == 0:
			Input.action_press("cevir")
		elif i % 42 == 3:
			Input.action_release("cevir")
		i += 1
	Input.action_release("cevir")
	sureler.sort()
	var top := 0.0
	for x in sureler:
		top += x
	var ort := top / float(sureler.size())
	var p99 := sureler[int(sureler.size() * 0.99)]
	print("FPS_OLCUM bolum=%d kare=%d ort_ms=%.2f p99_ms=%.2f fps=%.1f renderer=%s" % [
		_bolum, sureler.size(), ort, p99, 1000.0 / ort,
		RenderingServer.get_video_adapter_name()])
	oyun.queue_free()
	quit(0)
