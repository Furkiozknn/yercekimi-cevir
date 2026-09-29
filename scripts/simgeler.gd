class_name Simgeler
extends RefCounted
## Yazı tiplerinde (Instrument Sans, JetBrains Mono, Godot'nun gömülü Open Sans'ı) olmayan simgeler için yedek yazı tipi.
## Masaüstünde sistem yazı tipleri bu eksiği örtüyor; web'de örtmüyor (simge yerine kutu çıkıyor).
## Kapsanan simgeler: ★☆✓✔✗✘←↑→↓↔↕▲▶▼◀△▷▽◁■□●○◆◇⟲⟳₺♥♡⚙
## Kullanım: ilk açılan sahnenin _ready() başında (ya da autoload'da) Simgeler.kur().
## Birden çok çağrı zararsızdır.

const YOL := "res://assets/fonts/simgeler.ttf"


static func kur() -> void:
	var ana := ThemeDB.fallback_font
	if ana == null or not ResourceLoader.exists(YOL):
		return
	var yedek: Font = load(YOL)
	if yedek == null or ana.fallbacks.has(yedek):
		return
	var liste := ana.fallbacks.duplicate()
	liste.append(yedek)
	ana.fallbacks = liste


## Oyunun asıl yazı tipi: proje temasının varsayılan yazı tipi (Instrument Sans +
## simge yedeği, bkz. assets/tema.tres); tema yoksa Godot'nun gömülü yazı tipi.
static func ana() -> Font:
	var t := ThemeDB.get_project_theme()
	if t != null and t.has_default_font():
		return t.default_font
	return ThemeDB.fallback_font


## Test için: verilen metindeki her karakter yazı tipi zincirinde var mı? Eksikleri döndürür.
static func eksikler(metin: String) -> String:
	var yazi := ana()
	var sonuc := ""
	for ch in metin:
		if ch.unicode_at(0) > 32 and not yazi.has_char(ch.unicode_at(0)) and not sonuc.contains(ch):
			sonuc += ch
	return sonuc
