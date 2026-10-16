extends RefCounted
class_name Tuslar
## Keyboard remapping (accessibility: one-handed play, non-QWERTY layouts,
## a flip key that suits the player's hand). Celeste and VVVVVV both let the
## player rebind every action; this game only has four.
##
## Defaults live in project.godot. The player's choices live in their OWN file
## (user://tuslar.cfg, section [tuslar], action -> physical keycode), so the
## progress save and the key bindings never overwrite each other.
##
## Rules:
##   * Only keyboard events change. Gamepad buttons and sticks stay exactly as
##     in project.godot, so a bad keyboard binding can never lock a pad out.
##   * A custom key REPLACES that action's default keyboard keys.
##   * A key belongs to one action: assigning it moves it (another action's
##     custom key is cleared, and a default key taken by a custom one is
##     dropped from its old action).
##   * Every action keeps at least one keyboard key; an assignment that would
##     leave one keyless is refused. Esc is reserved for "cancel".

## action -> label on the settings screen (Turkish source text, tr() key).
## Order = order on screen.
const EYLEMLER := {
	"move_left": "Sola yürü",
	"move_right": "Sağa yürü",
	"cevir": "Yerçekimini çevir",
	"duraklat": "Duraklat",
}

## Tests point this at a scratch file so the player's bindings stay untouched.
static var yol := "user://tuslar.cfg"

static var _varsayilan: Dictionary = {}   ## action -> Array[InputEvent] from project.godot
static var _ozel: Dictionary = {}         ## action -> physical keycode


## Backs up the project.godot bindings once, before anything is overwritten.
static func _yedekle() -> void:
	if not _varsayilan.is_empty():
		return
	for eylem: String in EYLEMLER:
		if InputMap.has_action(eylem):
			_varsayilan[eylem] = InputMap.action_get_events(eylem).duplicate()


## Reads the bindings file and applies it. Unknown actions, Esc, non-positive
## codes and duplicate keys in a hand-edited file are ignored.
static func yukle() -> void:
	_yedekle()
	_ozel.clear()
	var cfg := ConfigFile.new()
	if cfg.load(yol) == OK and cfg.has_section("tuslar"):
		var gorulen: Array[int] = []
		for eylem: String in cfg.get_section_keys("tuslar"):
			var kod := int(cfg.get_value("tuslar", eylem, 0))
			if EYLEMLER.has(eylem) and kod > 0 and kod != KEY_ESCAPE and not gorulen.has(kod):
				_ozel[eylem] = kod
				gorulen.append(kod)
	uygula()


static func kaydet() -> void:
	var cfg := ConfigFile.new()
	for eylem: String in _ozel:
		cfg.set_value("tuslar", eylem, _ozel[eylem])
	var hata := cfg.save(yol)
	if hata != OK:
		push_warning("Tus atamalari yazilamadi: %d" % hata)


## Current custom bindings (copy): action -> physical keycode.
static func ozel() -> Dictionary:
	return _ozel.duplicate()


static func ozel_var() -> bool:
	return not _ozel.is_empty()


## Assigns `kod` to `eylem`, saves and applies. Returns false (and changes
## nothing) for Esc, an unknown action, or when another action would be left
## without any keyboard key.
static func ata(eylem: String, kod: int) -> bool:
	_yedekle()
	if not EYLEMLER.has(eylem) or kod <= 0 or kod == KEY_ESCAPE:
		return false
	var yeni := _ozel.duplicate()
	for e: String in yeni.keys():
		if e != eylem and int(yeni[e]) == kod:
			yeni.erase(e)
	yeni[eylem] = kod
	for e: String in EYLEMLER:
		if _varsayilan.has(e) and klavye_tuslari(e, yeni).is_empty():
			return false
	_ozel = yeni
	kaydet()
	uygula()
	return true


## Back to project.godot for every action.
static func sifirla() -> void:
	_ozel.clear()
	kaydet()
	uygula()


## Keyboard keys an action would have under `ozel_tablo`: its custom key, or
## its default keys minus any key another action has claimed.
static func klavye_tuslari(eylem: String, ozel_tablo: Dictionary) -> Array[int]:
	var sonuc: Array[int] = []
	if ozel_tablo.has(eylem):
		sonuc.append(int(ozel_tablo[eylem]))
		return sonuc
	var alinan: Array[int] = []
	for e: String in ozel_tablo:
		alinan.append(int(ozel_tablo[e]))
	for olay: InputEvent in _varsayilan.get(eylem, []):
		if olay is InputEventKey:
			var kod := _kod(olay as InputEventKey)
			if not alinan.has(kod):
				sonuc.append(kod)
	return sonuc


## Rebuilds InputMap for the four actions: non-keyboard defaults + keyboard keys.
static func uygula() -> void:
	_yedekle()
	for eylem: String in EYLEMLER:
		if not _varsayilan.has(eylem):
			continue
		InputMap.action_erase_events(eylem)
		for olay: InputEvent in _varsayilan[eylem]:
			if not (olay is InputEventKey):
				InputMap.action_add_event(eylem, olay)
		for kod in klavye_tuslari(eylem, _ozel):
			var k := InputEventKey.new()
			k.physical_keycode = kod as Key
			InputMap.action_add_event(eylem, k)


static func _kod(k: InputEventKey) -> int:
	return int(k.physical_keycode) if k.physical_keycode != 0 else int(k.keycode)


## Readable name of a keycode ("A", "Boşluk"/"Space", "Esc", "Left").
static func kod_adi(kod: int) -> String:
	if kod == KEY_SPACE:
		return TranslationServer.translate("Boşluk")
	if kod == KEY_ESCAPE:
		return "Esc"
	return OS.get_keycode_string(kod as Key)


## Name of the action's first keyboard key, or "—".
static func tus_adi(eylem: String) -> String:
	if not InputMap.has_action(eylem):
		return "—"
	for olay: InputEvent in InputMap.action_get_events(eylem):
		if olay is InputEventKey:
			return kod_adi(_kod(olay as InputEventKey))
	return "—"


## Keyboard hints name the default keys ("A / D", "BOŞLUK" / "SPACE"). After a
## remap they would lie, so the already translated text gets the real names.
## Without custom bindings the text is returned unchanged.
static func metne_uygula(m: String) -> String:
	if _ozel.is_empty():
		return m
	if _ozel.has("move_left") or _ozel.has("move_right"):
		m = m.replace("A / D", "%s / %s" % [tus_adi("move_left"), tus_adi("move_right")])
	if _ozel.has("cevir"):
		var ad := Tema.buyuk(tus_adi("cevir"))
		for eski in ["BOŞLUK", "SPACE"]:
			m = m.replace(eski + " ", ad + " ")
	return m
