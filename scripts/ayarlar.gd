extends Node
## Tum denge sabitleri, oyuncu ayarlari ve ilerleme kaydi burada.
## Ayar yapacaksan tek durak bu dosya.

# --- Izgara ---
const HUCRE: int = 16          ## piksel / kare (bolum yuksekligi haritadan gelir)

# --- Hareket ---
const HIZ: float = 125.0             ## yatay en yuksek hiz
const IVME: float = 900.0            ## yon tusuna basiliyken
const SURTUNME: float = 1100.0       ## tus birakildiginda
const HAVA_CARPANI: float = 0.75     ## havadayken yatay kontrol
const YERCEKIMI: float = 900.0
const EN_YUKSEK_DUSUS: float = 430.0
const CEVIR_TAMPONU: float = 0.10    ## yuzeye degmeden once basilan cevirmeyi hatirla
const CEVIR_ITISI: float = 45.0      ## cevirince yuzeyden kopma hizi

# --- Hareketli parcalar ---
const PLATFORM_HIZI: float = 46.0
const GEZGIN_DIKEN_HIZI: float = 62.0
const PLATFORM_GENISLIGI: float = 48.0

# --- Oyuncu govdesi ---
const GOVDE: Vector2 = Vector2(12, 20)

# --- Oyun hissi (hepsi "oyun_hissi" ayariyla kapatilabilir) ---
const IZ_SURESI: float = 0.45        ## cevirdikten sonra bu kadar sure hayalet birak
const IZ_ARALIGI: float = 0.045
const IZ_RENGI: Color = Color(0.17, 0.91, 0.96, 0.55)
const EZILME_SURESI: float = 0.14    ## inis/cevirme esneme-sikisma suresi
const SARSINTI_CEVIR: float = 1.6
const SARSINTI_OLUM: float = 5.0
const SARSINTI_SONUM: float = 14.0   ## saniyede bu kadar soner
const ARKA_DUZ: Color = Color(1.0, 1.0, 1.0)        ## normal yercekiminde arka plan tonu
const ARKA_TERS: Color = Color(0.74, 0.86, 1.22)    ## ters yercekiminde (soguk kayma)
const ARKA_GECIS: float = 0.25

# --- Renkler (arayuz) ---
const RENK_METIN: Color = Color(0.90, 0.92, 0.97)
const MADALYA_AD: Array = ["—", "Bronz", "Gümüş", "Altın"]
const MADALYA_RENK: Array = [
	Color(0.55, 0.59, 0.70), Color(0.72, 0.44, 0.31),
	Color(0.75, 0.79, 0.86), Color(1.00, 0.91, 0.38),
]

const KAYIT_YOLU: String = "user://kayit.cfg"
const LISTE := preload("res://scripts/bolumler.gd")

# --- Oturum durumu ---
var secilen_bolum: int = 0       ## Oyun sahnesi acilirken hangi bolum yuklenecek
var donus_sahnesi: String = "res://scenes/menu.tscn"   ## Ayarlar ekranindan cikinca nereye

# --- Ilerleme (kaydedilir) ---
var acilan_bolum: int = 0        ## en yuksek acilan bolum indeksi (0 tabanli)
var en_iyi: Dictionary = {}      ## bolum indeksi (int) -> en iyi sure (float sn)
var madalya: Dictionary = {}     ## bolum indeksi (int) -> 0 yok / 1 bronz / 2 gumus / 3 altin
var kristal: Dictionary = {}     ## bolum indeksi (int) -> true (toplandi)

# --- Oyuncu ayarlari (kaydedilir) ---
var muzik_ses: float = 0.7
var efekt_ses: float = 0.8
var muzik_acik: bool = true
var efekt_acik: bool = true
var tam_ekran: bool = false
var oyun_hissi: bool = true      ## sarsinti / parcacik / iz


func _ready() -> void:
	yukle()
	ses_uygula()
	ekran_uygula()


func bolum_sayisi() -> int:
	return LISTE.BOLUMLER.size()


func bolum(i: int) -> Dictionary:
	return LISTE.BOLUMLER[clampi(i, 0, bolum_sayisi() - 1)]


func acik_mi(i: int) -> bool:
	return i >= 0 and i <= acilan_bolum and i < bolum_sayisi()


## Sureden madalya: 3 altin, 2 gumus, 1 bronz, 0 yok.
func madalya_hesapla(i: int, sure: float) -> int:
	var v := bolum(i)
	if sure <= float(v["altin"]):
		return 3
	if sure <= float(v["gumus"]):
		return 2
	if sure <= float(v["bronz"]):
		return 1
	return 0


func madalya_al(i: int) -> int:
	return int(madalya.get(i, 0))


func kristal_var(i: int) -> bool:
	return bool(kristal.get(i, false))


func kristal_topla(i: int) -> void:
	if kristal_var(i):
		return
	kristal[i] = true
	kaydet()


func kristal_sayisi() -> int:
	return kristal.size()


## Bolum bitince cagrilir. {"rekor": bool, "madalya": int, "yeni_madalya": bool}
func bolum_bitti(i: int, sure: float) -> Dictionary:
	var rekor: bool = not en_iyi.has(i) or sure < float(en_iyi[i])
	if rekor:
		en_iyi[i] = sure
	var m := madalya_hesapla(i, sure)
	var yeni := m > madalya_al(i)
	if yeni:
		madalya[i] = m
	if i + 1 > acilan_bolum and i + 1 < bolum_sayisi():
		acilan_bolum = i + 1
	kaydet()
	return {"rekor": rekor, "madalya": m, "yeni_madalya": yeni}


func en_iyi_metin(i: int) -> String:
	if en_iyi.has(i):
		return "%.2f sn" % float(en_iyi[i])
	return "—"


# --- Ayarlarin uygulanmasi ---------------------------------------------------

## Ses duzeyi oynaticiya degil AudioServer veriyoluna yazilir: web'de Sample
## yolunda volume_db yok sayiliyor, veriyolu ise her iki yolda da calisiyor.
func ses_uygula() -> void:
	_veriyolu("Muzik", muzik_ses, muzik_acik)
	_veriyolu("Efekt", efekt_ses, efekt_acik)


func _veriyolu(ad: String, duzey: float, acik: bool) -> void:
	var i := AudioServer.get_bus_index(ad)
	if i < 0:
		push_warning("Ses veriyolu yok: %s" % ad)
		return
	AudioServer.set_bus_volume_db(i, linear_to_db(clampf(duzey, 0.0001, 1.0)))
	AudioServer.set_bus_mute(i, not acik or duzey <= 0.001)


func ekran_uygula() -> void:
	if OS.has_feature("web"):
		return
	var mod := DisplayServer.WINDOW_MODE_FULLSCREEN if tam_ekran else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != mod:
		DisplayServer.window_set_mode(mod)


# --- Kayit -------------------------------------------------------------------

func yukle() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(KAYIT_YOLU) != OK:
		return
	acilan_bolum = clampi(int(cfg.get_value("ilerleme", "acilan", 0)), 0, maxi(0, bolum_sayisi() - 1))
	en_iyi.clear()
	madalya.clear()
	kristal.clear()
	for anahtar in cfg.get_section_keys("en_iyi") if cfg.has_section("en_iyi") else []:
		en_iyi[int(anahtar)] = float(cfg.get_value("en_iyi", anahtar, 0.0))
	for anahtar in cfg.get_section_keys("madalya") if cfg.has_section("madalya") else []:
		madalya[int(anahtar)] = int(cfg.get_value("madalya", anahtar, 0))
	for anahtar in cfg.get_section_keys("kristal") if cfg.has_section("kristal") else []:
		if bool(cfg.get_value("kristal", anahtar, false)):
			kristal[int(anahtar)] = true
	muzik_ses = clampf(float(cfg.get_value("ayar", "muzik_ses", muzik_ses)), 0.0, 1.0)
	efekt_ses = clampf(float(cfg.get_value("ayar", "efekt_ses", efekt_ses)), 0.0, 1.0)
	muzik_acik = bool(cfg.get_value("ayar", "muzik_acik", muzik_acik))
	efekt_acik = bool(cfg.get_value("ayar", "efekt_acik", efekt_acik))
	tam_ekran = bool(cfg.get_value("ayar", "tam_ekran", tam_ekran))
	oyun_hissi = bool(cfg.get_value("ayar", "oyun_hissi", oyun_hissi))


func kaydet() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("ilerleme", "acilan", acilan_bolum)
	for i in en_iyi:
		cfg.set_value("en_iyi", str(i), en_iyi[i])
	for i in madalya:
		cfg.set_value("madalya", str(i), madalya[i])
	for i in kristal:
		cfg.set_value("kristal", str(i), true)
	cfg.set_value("ayar", "muzik_ses", muzik_ses)
	cfg.set_value("ayar", "efekt_ses", efekt_ses)
	cfg.set_value("ayar", "muzik_acik", muzik_acik)
	cfg.set_value("ayar", "efekt_acik", efekt_acik)
	cfg.set_value("ayar", "tam_ekran", tam_ekran)
	cfg.set_value("ayar", "oyun_hissi", oyun_hissi)
	var hata := cfg.save(KAYIT_YOLU)
	if hata != OK:
		push_warning("Kayit yazilamadi: %d" % hata)


## Testlerin temiz baslamasi icin (ayarlar degil, yalniz ilerleme sifirlanir).
func sifirla() -> void:
	acilan_bolum = 0
	en_iyi.clear()
	madalya.clear()
	kristal.clear()
