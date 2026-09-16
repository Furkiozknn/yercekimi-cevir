extends Node
## Tum denge sabitleri ve ilerleme kaydi burada. Ayar yapacaksan tek durak bu dosya.

# --- Izgara ---
const HUCRE: int = 16          ## piksel / kare
const SATIR: int = 22          ## her bolum bu kadar satir yuksekliginde

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
const OLUM_PAYI: float = 3.0         ## carpisma kutusunu bu kadar kucult (affedici olsun)

# --- Renkler (yer tutucu gorsel) ---
const RENK_ARKA: Color = Color(0.07, 0.08, 0.13)
const RENK_BLOK: Color = Color(0.20, 0.23, 0.34)
const RENK_BLOK_UST: Color = Color(0.35, 0.40, 0.56)
const RENK_DIKEN: Color = Color(0.91, 0.26, 0.31)
const RENK_KAPI: Color = Color(0.29, 0.85, 0.45)
const RENK_PLATFORM: Color = Color(0.64, 0.43, 0.88)
const RENK_METIN: Color = Color(0.90, 0.92, 0.97)

const KAYIT_YOLU: String = "user://kayit.cfg"
const LISTE := preload("res://scripts/bolumler.gd")

var secilen_bolum: int = 0       ## Oyun sahnesi acilirken hangi bolum yuklenecek
var acilan_bolum: int = 0        ## en yuksek acilan bolum indeksi (0 tabanli)
var en_iyi: Dictionary = {}      ## bolum indeksi (int) -> en iyi sure (float sn)


func _ready() -> void:
	yukle()


func bolum_sayisi() -> int:
	return LISTE.BOLUMLER.size()


func acik_mi(i: int) -> bool:
	return i >= 0 and i <= acilan_bolum and i < bolum_sayisi()


## Bolum bitince cagrilir. Yeni rekor varsa true doner.
func bolum_bitti(i: int, sure: float) -> bool:
	var rekor: bool = false
	if not en_iyi.has(i) or sure < float(en_iyi[i]):
		en_iyi[i] = sure
		rekor = true
	if i + 1 > acilan_bolum and i + 1 < bolum_sayisi():
		acilan_bolum = i + 1
	kaydet()
	return rekor


func en_iyi_metin(i: int) -> String:
	if en_iyi.has(i):
		return "%.2f sn" % float(en_iyi[i])
	return "—"


func yukle() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(KAYIT_YOLU) != OK:
		return
	acilan_bolum = int(cfg.get_value("ilerleme", "acilan", 0))
	acilan_bolum = clampi(acilan_bolum, 0, maxi(0, bolum_sayisi() - 1))
	en_iyi.clear()
	if cfg.has_section("en_iyi"):
		for anahtar in cfg.get_section_keys("en_iyi"):
			en_iyi[int(anahtar)] = float(cfg.get_value("en_iyi", anahtar, 0.0))


func kaydet() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("ilerleme", "acilan", acilan_bolum)
	for i in en_iyi:
		cfg.set_value("en_iyi", str(i), en_iyi[i])
	var hata := cfg.save(KAYIT_YOLU)
	if hata != OK:
		push_warning("Kayit yazilamadi: %d" % hata)


## Testlerin temiz baslamasi icin.
func sifirla() -> void:
	acilan_bolum = 0
	en_iyi.clear()
