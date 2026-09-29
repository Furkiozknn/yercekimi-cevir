extends SceneTree
## Proje temasini (assets/tema.tres) kodla uretir. .tres'i elle yazmak BOM/kacis
## tuzaklarina aciktir; ResourceSaver dogru yazar.
##   godot --headless --path . -s res://tools/tema_uret.gd
## Sonra: godot --headless --path . --import
##
## Video dili: duz dolgu, golgesiz. Birincil dugme = camgobegi + murekkep yazi;
## ikincil = seffaf + kagit 2 px cizgi. Kart = kagit zemin, murekkep yazi.

const KAGIT := Color("f1ece2")
const MUREKKEP := Color("0e0d0b")
const CAM := Color("7dd4e7")
const PANEL := Color("10101a")


func _initialize() -> void:
	var t := Theme.new()
	var govde := _font("res://assets/fonts/InstrumentSans-Regular.ttf", 0.0)
	var kalin := _font("res://assets/fonts/InstrumentSans-Bold.ttf", 0.0)
	var mono := _font("res://assets/fonts/JetBrainsMono-Regular.ttf", 1.2)
	var mono_kalin := _font("res://assets/fonts/JetBrainsMono-Bold.ttf", 1.2)
	t.default_font = govde
	t.default_font_size = 12

	# --- Label ---
	t.set_color("font_color", "Label", KAGIT)
	t.set_font("font", "Label", govde)
	t.set_font_size("font_size", "Label", 12)
	_varyasyon(t, "Baslik", "Label", kalin, 40, KAGIT)
	_varyasyon(t, "Baslik2", "Label", kalin, 22, KAGIT)
	_varyasyon(t, "Etiket", "Label", mono, 8, Color(KAGIT, 0.7))
	_varyasyon(t, "EtiketKalin", "Label", mono_kalin, 8, KAGIT)
	_varyasyon(t, "KartBaslik", "Label", kalin, 20, MUREKKEP)
	_varyasyon(t, "KartYazi", "Label", govde, 12, MUREKKEP)
	_varyasyon(t, "KartEtiket", "Label", mono, 8, Color(MUREKKEP, 0.65))
	_varyasyon(t, "Odul", "Label", mono_kalin, 9, Color("ffc21a"))
	_varyasyon(t, "Vurgu", "Label", mono_kalin, 8, Color("e94f36"))

	# --- Button (ikincil) ---
	t.set_font("font", "Button", kalin)
	t.set_font_size("font_size", "Button", 13)
	for renk_adi in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		t.set_color(renk_adi, "Button", KAGIT)
	t.set_color("font_disabled_color", "Button", Color(KAGIT, 0.35))
	t.set_stylebox("normal", "Button", _kutu(Color(KAGIT, 0.0), Color(KAGIT, 0.85), 2, 3, 10, 6))
	t.set_stylebox("hover", "Button", _kutu(Color(KAGIT, 0.10), KAGIT, 2, 3, 10, 6))
	t.set_stylebox("pressed", "Button", _kutu(Color(KAGIT, 0.22), KAGIT, 2, 3, 10, 6))
	t.set_stylebox("disabled", "Button", _kutu(Color(KAGIT, 0.0), Color(KAGIT, 0.22), 2, 3, 10, 6))
	t.set_stylebox("focus", "Button", _kutu(Color(CAM, 0.0), CAM, 2, 3, 10, 6))
	t.set_constant("outline_size", "Button", 0)

	# --- Button/Birincil: camgobegi dolgu, murekkep yazi ---
	t.add_type("Birincil")
	t.set_type_variation("Birincil", "Button")
	t.set_font("font", "Birincil", kalin)
	t.set_font_size("font_size", "Birincil", 20)
	for renk_adi in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		t.set_color(renk_adi, "Birincil", MUREKKEP)
	t.set_stylebox("normal", "Birincil", _kutu(CAM, CAM, 0, 3, 16, 9))
	t.set_stylebox("hover", "Birincil", _kutu(Color("a4e4f1"), Color("a4e4f1"), 0, 3, 16, 9))
	t.set_stylebox("pressed", "Birincil", _kutu(Color("58bfd6"), Color("58bfd6"), 0, 3, 16, 9))
	t.set_stylebox("focus", "Birincil", _kutu(Color(KAGIT, 0.0), KAGIT, 2, 3, 16, 9))
	t.set_stylebox("disabled", "Birincil", _kutu(Color(CAM, 0.3), Color(CAM, 0.3), 0, 3, 16, 9))

	# --- Button/Kucuk: satir ve izgara hucreleri (Bolum Sec) ---
	t.add_type("Kucuk")
	t.set_type_variation("Kucuk", "Button")
	t.set_font("font", "Kucuk", govde)
	t.set_font_size("font_size", "Kucuk", 10)
	t.set_stylebox("normal", "Kucuk", _kutu(Color(KAGIT, 0.06), Color(KAGIT, 0.0), 0, 3, 4, 3))
	t.set_stylebox("hover", "Kucuk", _kutu(Color(KAGIT, 0.16), Color(KAGIT, 0.0), 0, 3, 4, 3))
	t.set_stylebox("pressed", "Kucuk", _kutu(Color(KAGIT, 0.28), Color(KAGIT, 0.0), 0, 3, 4, 3))
	t.set_stylebox("disabled", "Kucuk", _kutu(Color(KAGIT, 0.03), Color(KAGIT, 0.0), 0, 3, 4, 3))
	t.set_stylebox("focus", "Kucuk", _kutu(Color(CAM, 0.0), CAM, 2, 3, 4, 3))

	# --- Panel: kagit kart (duraklat / bitis) ---
	t.set_stylebox("panel", "Panel", _kutu(PANEL, Color(KAGIT, 0.22), 2, 12, 0, 0))
	t.add_type("Kagit")
	t.set_type_variation("Kagit", "Panel")
	t.set_stylebox("panel", "Kagit", _kutu(KAGIT, KAGIT, 0, 12, 0, 0))
	t.add_type("Perde")
	t.set_type_variation("Perde", "Panel")
	t.set_stylebox("panel", "Perde", _kutu(Color(PANEL, 0.72), Color(PANEL, 0.0), 0, 0, 0, 0))
	t.add_type("Rozet")
	t.set_type_variation("Rozet", "Panel")
	t.set_stylebox("panel", "Rozet", _kutu(Color(PANEL, 0.82), Color(PANEL, 0.0), 0, 6, 0, 0))

	# --- Kaydirici ---
	t.set_stylebox("slider", "HSlider", _kutu(Color(KAGIT, 0.22), Color(KAGIT, 0.0), 0, 2, 0, 0, 4))
	t.set_stylebox("grabber_area", "HSlider", _kutu(CAM, CAM, 0, 2, 0, 0, 4))
	t.set_stylebox("grabber_area_highlight", "HSlider", _kutu(Color("a4e4f1"), Color("a4e4f1"), 0, 2, 0, 0, 4))
	var tutamak: Texture2D = load("res://assets/sprites/tutamak.png")
	t.set_icon("grabber", "HSlider", tutamak)
	t.set_icon("grabber_highlight", "HSlider", tutamak)
	t.set_icon("grabber_disabled", "HSlider", tutamak)
	t.set_constant("center_grabber", "HSlider", 0)

	# --- Anahtar ---
	t.set_icon("checked", "CheckButton", load("res://assets/sprites/anahtar_acik.png"))
	t.set_icon("unchecked", "CheckButton", load("res://assets/sprites/anahtar_kapali.png"))
	t.set_icon("checked_disabled", "CheckButton", load("res://assets/sprites/anahtar_acik_pasif.png"))
	t.set_icon("unchecked_disabled", "CheckButton", load("res://assets/sprites/anahtar_kapali_pasif.png"))
	t.set_icon("checked_mirrored", "CheckButton", load("res://assets/sprites/anahtar_acik.png"))
	t.set_icon("unchecked_mirrored", "CheckButton", load("res://assets/sprites/anahtar_kapali.png"))
	t.set_icon("checked_disabled_mirrored", "CheckButton", load("res://assets/sprites/anahtar_acik_pasif.png"))
	t.set_icon("unchecked_disabled_mirrored", "CheckButton", load("res://assets/sprites/anahtar_kapali_pasif.png"))
	t.set_font("font", "CheckButton", govde)
	t.set_font_size("font_size", "CheckButton", 12)
	for renk_adi in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color",
			"font_hover_pressed_color"]:
		t.set_color(renk_adi, "CheckButton", KAGIT)
	t.set_color("font_disabled_color", "CheckButton", Color(KAGIT, 0.4))
	var bos := StyleBoxEmpty.new()
	for d in ["normal", "hover", "pressed", "disabled", "hover_pressed"]:
		t.set_stylebox(d, "CheckButton", bos)
	t.set_stylebox("focus", "CheckButton", _kutu(Color(CAM, 0.0), CAM, 2, 8, 2, 2))

	var hata := ResourceSaver.save(t, "res://assets/tema.tres")
	print("tema.tres yazildi: ", "TAMAM" if hata == OK else "HATA %d" % hata)
	quit(0 if hata == OK else 1)


func _font(yol: String, aralik: float) -> FontVariation:
	var f := FontVariation.new()
	f.base_font = load(yol)
	f.fallbacks = [load("res://assets/fonts/simgeler.ttf")]
	f.spacing_glyph = int(round(aralik))
	return f


func _varyasyon(t: Theme, ad: String, taban: String, font: Font, boyut: int, renk: Color) -> void:
	t.add_type(ad)
	t.set_type_variation(ad, taban)
	t.set_font("font", ad, font)
	t.set_font_size("font_size", ad, boyut)
	t.set_color("font_color", ad, renk)


func _kutu(dolgu: Color, cerceve: Color, kalinlik: int, yaricap: int,
		yatay: int, dikey: int, yukseklik: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = dolgu
	s.border_color = cerceve
	s.set_border_width_all(kalinlik)
	s.set_corner_radius_all(yaricap)
	s.content_margin_left = yatay
	s.content_margin_right = yatay
	s.content_margin_top = dikey
	s.content_margin_bottom = dikey
	if yukseklik > 0:
		s.content_margin_top = yukseklik / 2.0
		s.content_margin_bottom = yukseklik / 2.0
	s.anti_aliasing = true
	return s
