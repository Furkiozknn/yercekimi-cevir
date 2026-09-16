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
const CEVIR_KOJOT: float = 0.08      ## yuzeyden ayrildiktan sonra cevirme hakki surer
const CEVIR_ITISI: float = 45.0      ## cevirince yuzeyden kopma hizi

# --- Affetme ve yeniden deneme ---
const OLUM_BEKLEME: float = 0.18     ## olumden yeniden dogusa (sahne YENIDEN YUKLENMEZ)
const DIKEN_PAY: int = 3             ## isabet kutusu gorselden her yonden bu kadar kucuk

# --- Oda tabanli kamera ---
## Kamera oyuncuyu izlemez, oda oda atlar: bir odadaki tehlikenin tamami hep ekranda.
const ODA_GENISLIGI: int = 640
const ODA_YUKSEKLIGI: int = 360
const ODA_GECISI: float = 0.16

# --- Hayalet yaris ---
const HAYALET_ARALIGI: int = 2       ## kac fizik karesinde bir konum kaydedilir (60/2 = 30 Hz)
const HAYALET_EN_FAZLA: int = 3600   ## ~2 dakika; daha uzun kosu kaydedilmez
const HAYALET_YOLU: String = "user://hayalet_%d.dat"
const HAYALET_RENGI: Color = Color(0.75, 0.80, 0.90, 0.40)
## Altin hayalet AYRI bir hedeftir (botun olculmus en iyi kosusu), oyuncunun
## kendi hayaletiyle karismamali: hem daha parlak/dolgun hem de etiketli.
const ALTIN_HAYALET_RENGI: Color = Color(1.00, 0.88, 0.30, 0.58)

# --- Yardim modu ---
const YARDIM_EN_YAVAS: float = 0.5   ## oyun hizi alt siniri (%50)

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
const ROTA := preload("res://scripts/rota_verisi.gd")
const SIMGELER := preload("res://scripts/simgeler.gd")

# --- Oturum durumu ---
var secilen_bolum: int = 0       ## Oyun sahnesi acilirken hangi bolum yuklenecek
var donus_sahnesi: String = "res://scenes/menu.tscn"   ## Ayarlar ekranindan cikinca nereye

# --- Ilerleme (kaydedilir) ---
var acilan_bolum: int = 0        ## en yuksek acilan bolum indeksi (0 tabanli)
var en_iyi: Dictionary = {}      ## bolum indeksi (int) -> en iyi sure (float sn)
var madalya: Dictionary = {}     ## bolum indeksi (int) -> 0 yok / 1 bronz / 2 gumus / 3 altin
var kristal: Dictionary = {}     ## bolum indeksi (int) -> true (toplandi)
var en_az: Dictionary = {}       ## bolum indeksi (int) -> o bolumdeki en az cevirme sayisi

# --- Oyuncu ayarlari (kaydedilir) ---
var muzik_ses: float = 0.7
var efekt_ses: float = 0.8
var muzik_acik: bool = true
var efekt_acik: bool = true
var tam_ekran: bool = false
var oyun_hissi: bool = true      ## sarsinti / parcacik / iz

# --- Yaris (kaydedilir) ---
var altin_hayalet: bool = true      ## botun olculmus altin kosusu ayrica kossun

# --- Okunurluk / erisilebilirlik (kaydedilir) ---
var yuksek_kontrast: bool = false   ## tehlikeler parlar, arka plan ve zemin koyulasir
var yercekimi_oku: bool = true      ## oyuncunun yaninda yercekimi yonunu gosteren ok
var inis_gostergesi: bool = true    ## cevirme tusunu basili tutunca inis noktasi

# --- Dokunmatik ---
## Klavye terimlerini dokunma karsiligiyla degistiren tablo. Bolum ipuclari
## uretilen bolumler.gd'de duruyor; orayi elle duzenlemek yerine metni burada
## ceviriyoruz, boylece menu yazisi da ayni tablodan gecer.
const DOKUNMA_METNI: Array = [
	["A / D ile yürü", "Sol alttaki iki alanla yürü"],
	["BOŞLUK yerçekimini çevirir", "Sağ yarıya dokunmak yerçekimini çevirir"],
	["Tek tuş", "Tek dokunuş"],
]

## Cihaz dokunmatik bildirmese de ilk ekran dokunusunda acilir (bkz. _input).
## Kaydedilmez: cihazin kendisi soyler, kullanici ayari degil.
var dokunmatik_algilandi: bool = false

# --- Dokunmatik ayarlari (kaydedilir) ---
var solak: bool = false             ## cevirme sol yarida, hareket sag yarida
var dokunmatik_opaklik: float = 0.35
var titresim: bool = true

# --- Yardim modu (kaydedilir) ---
## Amaci oyunu herkesin bitirebilmesi. Acikken sure/madalya/cevirme kaydi
## tutulmaz, kristaller sayilir. Dil suclayici degil: bu bir ayar, itiraf degil.
var yardim_acik: bool = false
var yardim_hiz: float = 1.0         ## 0.5 - 1.0
var yardim_olumsuz: bool = false    ## diken oldurmez, geri iter

## Dokunmatik ilk kez algilandiginda: arayuz metinleri ve dokunma alanlari
## icin. Sahneler bagli kalir, cunku dokunus menu acildiktan sonra gelebilir.
signal dokunmatik_degisti


func _ready() -> void:
	# Web yapisinda sistem yazi tipi yedegi yok; ⟳ ● — gibi simgeler
	# gomulu Open Sans'ta olmadigi icin kutu olarak cikiyorlardi.
	SIMGELER.kur()
	yukle()
	ses_uygula()
	ekran_uygula()


## Cihaz dokunmatik bildirmiyorsa bile ilk ekran dokunusu bunu ortaya cikarir
## (tarayicida DisplayServer her zaman dogru sonuc vermiyor).
func _input(olay: InputEvent) -> void:
	if not dokunmatik_algilandi and olay is InputEventScreenTouch:
		dokunmatik_algilandi = true
		dokunmatik_degisti.emit()


func dokunmatik_mi() -> bool:
	return dokunmatik_algilandi or DisplayServer.is_touchscreen_available()


## Klavye metnini dokunmatik cihazda dokunma karsiligiyla verir.
## Masaustunde metin oldugu gibi doner.
func kontrol_metni(m: String) -> String:
	if not dokunmatik_mi():
		return m
	for c in DOKUNMA_METNI:
		m = m.replace(String(c[0]), String(c[1]))
	return m


func bolum_sayisi() -> int:
	return LISTE.BOLUMLER.size()


func bolum(i: int) -> Dictionary:
	return LISTE.BOLUMLER[clampi(i, 0, bolum_sayisi() - 1)]


func acik_mi(i: int) -> bool:
	return i >= 0 and i <= acilan_bolum and i < bolum_sayisi()


## Madalya esikleri ve en az cevirme hedefi TEK YERDEN gelir: tools/bot.gd'nin
## urettigi scripts/rota_verisi.gd. Dosya bossa (olcum yapilmamis) bolum
## verisindeki geometri yedegine duser — oyun yine calisir.
func esik(i: int) -> Dictionary:
	if i >= 0 and i < ROTA.VERI.size():
		return ROTA.VERI[i]
	var v := bolum(i)
	return {"sure": float(v["altin"]), "altin": float(v["altin"]),
		"gumus": float(v["gumus"]), "bronz": float(v["bronz"]),
		"cevirme": int(v.get("cevirme", 0)), "tahmin": true, "biten": 0, "kosu": 0}


## Sureden madalya: 3 altin, 2 gumus, 1 bronz, 0 yok.
func madalya_hesapla(i: int, sure: float) -> int:
	var v := esik(i)
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


## Ikinci hedef: bolumu bitirmek icin gereken en az cevirme.
## Olcum varsa botun GERCEKTEN bitirdigi en az cevirme, yoksa geometri tahmini.
func en_az_hedef(i: int) -> int:
	return int(esik(i).get("cevirme", 0))


## Oyuncunun o bolumde yaptigi en az cevirme; -1 = henuz bitirmedi.
func en_az_al(i: int) -> int:
	return int(en_az.get(i, -1))


## Bolum bitince cagrilir.
## {"rekor": bool, "madalya": int, "yeni_madalya": bool, "az_rekor": bool, "yardim": bool}
## Yardim modu acikken sure, madalya ve cevirme rekoru KAYDEDILMEZ; bolum yine
## acilir, kristal yine sayilir.
func bolum_bitti(i: int, sure: float, cevirme: int = -1) -> Dictionary:
	var yardim := yardim_acik
	var rekor := false
	var m := 0
	var yeni := false
	var az_rekor := false
	if not yardim:
		rekor = not en_iyi.has(i) or sure < float(en_iyi[i])
		if rekor:
			en_iyi[i] = sure
		m = madalya_hesapla(i, sure)
		yeni = m > madalya_al(i)
		if yeni:
			madalya[i] = m
		if cevirme >= 0 and (not en_az.has(i) or cevirme < int(en_az[i])):
			en_az[i] = cevirme
			az_rekor = true
	if i + 1 > acilan_bolum and i + 1 < bolum_sayisi():
		acilan_bolum = i + 1
	kaydet()
	return {"rekor": rekor, "madalya": m, "yeni_madalya": yeni,
		"az_rekor": az_rekor, "yardim": yardim}


## Yardim modunda bolum atlama: bir sonrakini acar, sure/madalya vermez.
func bolum_ac(i: int) -> void:
	if i + 1 > acilan_bolum and i + 1 < bolum_sayisi():
		acilan_bolum = i + 1
		kaydet()


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


## Yardim modundaki oyun hizi. Menulerde 1.0'a doner (zaman_sifirla).
func zaman_uygula() -> void:
	Engine.time_scale = clampf(yardim_hiz, YARDIM_EN_YAVAS, 1.0) if yardim_acik else 1.0


func zaman_sifirla() -> void:
	Engine.time_scale = 1.0


## Botun olculmus altin kosusu. Olcum yoksa (tahmin bolumu) bos doner.
func altin_hayalet_yolu(i: int) -> PackedVector2Array:
	if not altin_hayalet:
		return PackedVector2Array()
	return AltinHayalet.yol(i)


## Hayalet = en iyi kosunun konum dizisi. Yardim modunda kaydedilmez.
func hayalet_kaydet(i: int, yol: PackedVector2Array) -> void:
	if yardim_acik or yol.size() < 2 or yol.size() > HAYALET_EN_FAZLA:
		return
	var f := FileAccess.open(HAYALET_YOLU % i, FileAccess.WRITE)
	if f == null:
		push_warning("Hayalet yazilamadi: %d" % i)
		return
	f.store_var(yol)
	f.close()


func hayalet_yukle(i: int) -> PackedVector2Array:
	var y: String = HAYALET_YOLU % i
	if not FileAccess.file_exists(y):
		return PackedVector2Array()
	var f := FileAccess.open(y, FileAccess.READ)
	if f == null:
		return PackedVector2Array()
	var v: Variant = f.get_var()
	f.close()
	return v if v is PackedVector2Array else PackedVector2Array()


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
	en_az.clear()
	for anahtar in cfg.get_section_keys("en_az") if cfg.has_section("en_az") else []:
		en_az[int(anahtar)] = int(cfg.get_value("en_az", anahtar, 0))
	muzik_ses = clampf(float(cfg.get_value("ayar", "muzik_ses", muzik_ses)), 0.0, 1.0)
	efekt_ses = clampf(float(cfg.get_value("ayar", "efekt_ses", efekt_ses)), 0.0, 1.0)
	muzik_acik = bool(cfg.get_value("ayar", "muzik_acik", muzik_acik))
	efekt_acik = bool(cfg.get_value("ayar", "efekt_acik", efekt_acik))
	tam_ekran = bool(cfg.get_value("ayar", "tam_ekran", tam_ekran))
	oyun_hissi = bool(cfg.get_value("ayar", "oyun_hissi", oyun_hissi))
	altin_hayalet = bool(cfg.get_value("ayar", "altin_hayalet", altin_hayalet))
	yuksek_kontrast = bool(cfg.get_value("ayar", "yuksek_kontrast", yuksek_kontrast))
	yercekimi_oku = bool(cfg.get_value("ayar", "yercekimi_oku", yercekimi_oku))
	inis_gostergesi = bool(cfg.get_value("ayar", "inis_gostergesi", inis_gostergesi))
	solak = bool(cfg.get_value("ayar", "solak", solak))
	dokunmatik_opaklik = clampf(float(cfg.get_value("ayar", "dokunmatik_opaklik", dokunmatik_opaklik)), 0.1, 1.0)
	titresim = bool(cfg.get_value("ayar", "titresim", titresim))
	yardim_acik = bool(cfg.get_value("yardim", "acik", yardim_acik))
	yardim_hiz = clampf(float(cfg.get_value("yardim", "hiz", yardim_hiz)), YARDIM_EN_YAVAS, 1.0)
	yardim_olumsuz = bool(cfg.get_value("yardim", "olumsuz", yardim_olumsuz))


func kaydet() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("ilerleme", "acilan", acilan_bolum)
	for i in en_iyi:
		cfg.set_value("en_iyi", str(i), en_iyi[i])
	for i in madalya:
		cfg.set_value("madalya", str(i), madalya[i])
	for i in kristal:
		cfg.set_value("kristal", str(i), true)
	for i in en_az:
		cfg.set_value("en_az", str(i), en_az[i])
	cfg.set_value("ayar", "muzik_ses", muzik_ses)
	cfg.set_value("ayar", "efekt_ses", efekt_ses)
	cfg.set_value("ayar", "muzik_acik", muzik_acik)
	cfg.set_value("ayar", "efekt_acik", efekt_acik)
	cfg.set_value("ayar", "tam_ekran", tam_ekran)
	cfg.set_value("ayar", "oyun_hissi", oyun_hissi)
	cfg.set_value("ayar", "altin_hayalet", altin_hayalet)
	cfg.set_value("ayar", "yuksek_kontrast", yuksek_kontrast)
	cfg.set_value("ayar", "yercekimi_oku", yercekimi_oku)
	cfg.set_value("ayar", "inis_gostergesi", inis_gostergesi)
	cfg.set_value("ayar", "solak", solak)
	cfg.set_value("ayar", "dokunmatik_opaklik", dokunmatik_opaklik)
	cfg.set_value("ayar", "titresim", titresim)
	cfg.set_value("yardim", "acik", yardim_acik)
	cfg.set_value("yardim", "hiz", yardim_hiz)
	cfg.set_value("yardim", "olumsuz", yardim_olumsuz)
	var hata := cfg.save(KAYIT_YOLU)
	if hata != OK:
		push_warning("Kayit yazilamadi: %d" % hata)


## Testlerin temiz baslamasi icin (ayarlar degil, yalniz ilerleme sifirlanir).
## Hayalet dosyalari da ilerlemedir: onlar da silinir, yoksa onceki kosudan
## kalan kayit testleri (ve yeni bir oyuncunun ilk kosusunu) kirletiyor.
func sifirla() -> void:
	for i in bolum_sayisi():
		DirAccess.remove_absolute(HAYALET_YOLU % i)
	acilan_bolum = 0
	en_iyi.clear()
	madalya.clear()
	kristal.clear()
	en_az.clear()
