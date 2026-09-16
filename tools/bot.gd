extends Node
## Madalya surelerini FORMULDEN degil OLCUMDEN cikaran bot.
##
##   godot --headless --path . res://tools/bot.tscn --fixed-fps 60 -- [kosu] [bolum] [iz] [insan]
##
##   "insan": tepki gecikmesi 0,18-0,35 sn (insan gorsel tepki suresi bandi;
##   bot 0,05-0,20 ile olcer). Bu modda DOSYA YAZILMAZ, yalniz tablo basilir —
##   amaci botun insani ne kadar gectigini olcmek (madalya carpani gerekcesi).
##
## Nasil calisir — iki asama:
##
## 1. PLAN. Bolumun ASCII haritasindan her sutunun hangi yuzeyde (zemin/tavan)
##    gecilebilecegini cikarir: zemin deligi ve zemin dikeni "tavanda ol" der,
##    tavan dikeni "zeminde ol" der, gezen diken bulundugu yuzeyi kapatir.
##    Plan onceden bir liste olarak degil, her karede "onumdeki ilk tehlikeye
##    kac piksel var" sorusuyla yurutulur — boylece hareketli parcalarin O ANKI
##    konumu da hesaba girer.
##
## 2. KOSU. Bot bunu GERCEK FIZIKTE oynar: gercek Oyun sahnesi, gercek
##    oyuncu.gd, gercek carpisma. Girdi Input.action_press ile basilir, yani
##    cevirme tamponu ve kojotu da isin icinde. Her cevirme kararina
##    0,05-0,20 sn rastgele TEPKI GECIKMESI eklenir (Neon White'in "gelistirici
##    kendi oyununda fazla iyi" tuzagi).
##
## Bolum basina KOSU kadar kosu yapilir, olcu ORTANCADIR. Bitiremedigi
## bolumlerin suresi bitirdiklerinden olculen sn/px olceginden tahmin edilir ve
## kayitta "tahmin": true ile isaretlenir.
##
## Cikti: scripts/rota_verisi.gd (esikler + en az cevirme) ve
##        scripts/altin_hayalet.gd (botun en iyi kosusunun yolu).

const OYUN := preload("res://scenes/oyun.tscn")

# --- olcum ayarlari ---
const KOSU_SAYISI: int = 5
const EN_FAZLA_KARE: int = 5400        ## 90 sn: bundan uzun kosu "bitiremedi"
const TEPKI_EN_AZ: float = 0.05
const TEPKI_EN_COK: float = 0.20
## "insan" modu: basit gorsel tepki suresi ortancasi ~0,25 sn (laboratuvar
## 0,20-0,25; humanbenchmark.com ortancasi ~0,27). Onceden gorulen tehlikeye
## insan biraz erken davranir, o yuzden bant 0,18-0,35.
const INSAN_TEPKI_EN_AZ: float = 0.18
const INSAN_TEPKI_EN_COK: float = 0.35
const KOTU_KOSU_CARPANI: float = 1.5   ## en iyinin bu katindan kotu kosu ortancaya girmez
const AYKIRI_BOLUM_CARPANI: float = 2.0 ## olcegin bu katindan yavas bolum tahmine devreder

# --- madalya carpanlari (gerekce: gelistirme-4 raporu, "insan payi") ---
## Insan tepki bandindaki bot (0,18-0,35 sn, "insan" modu) 20 bolumun 20'sinde
## botun ortancasinin en fazla 1,30 katinda bitirdi (ortanca 1,02; 6-7-15'te
## bir zorunlu fren = +%26-30). x1,15 ile o bot 3 bolumde altin alamiyordu,
## yani insan icin ulasilmaz altin vardi. Altin = dogru hat + insan tepkisi +
## olumsuz; gumus = bir olum ya da birkac tereddut (olum ~+%55); bronz = iki olum.
const ALTIN: float = 1.35
const GUMUS: float = 1.75
const BRONZ: float = 2.40

# --- bot davranisi ---
const ONGORU: float = 170.0            ## tehlikeyi bu kadar once gormeye baslar
## Indigi noktadan sonra yuzeyin temiz kalmasi gereken mesafe. KUCUK olmali:
## bolumler bilerek 3 hucrelik (48 px) pencerelerle kuruluyor (bkz.
## arac/uret_bolumler.py), yani "indikten sonra 6 hucre bos olsun" demek
## bolumlerin yarisini cozulemez ilan etmek olurdu. Bot fren yaptigi icin
## neredeyse dik iniyor; inis karesinin kendisi zaten ayrica denetleniyor.
## Indigi yuzeyin temiz kalmasi gereken en az mesafe. Yalniz "inip durabilmeli
## ve yeniden cevirebilmeli" kadar: tam hizda fren 7 px, SON_FREN 20 px.
## 64 px denendiginde 19. bolum cozulemez cikiyordu — oradaki tek gecis
## yolu 40. sutuna inmek ve 43. sutundaki delige 3 hucre kala yeniden
## cevirmek, yani 43 px'lik bir pencere.
const TEMIZ_INIS: float = 32.0
## SON FREN: tehlike bu kadar yaklastiysa ve cevirme hala guvenli degilse dur.
## Mumkun oldugunca KUCUK olmali (tam hizda fren mesafesi 7 px). 56 px
## denendiginde bot tehlikeden 3,5 hucre once duruyordu ve tam orasi
## inemedigi yerdi: 9-12 sutunlarinda zemin dikeni varken 11. sutunda durup
## sonsuza kadar bekliyordu. Gec fren onu 14. sutune, yani inilebilir tek
## pencereye tasiyor.
const SON_FREN: float = 20.0
const TARAMA_ADIMI: float = 4.0

var _oyun: Node2D = null
var _bolum: Bolum = null
var _o: CharacterBody2D = null
var _harita: Array = []
var _satir: int = 0
var _sutun: int = 0
var _kapi_x: float = 0.0

var _gecikme: float = -1.0             ## bekleyen cevirme karari (sn), -1 = yok
var _basili: int = 0                   ## cevir tusu kac kare daha basili kalacak
var _fren: bool = false                ## cevirme guvenli olana kadar hizi kesiyor
var _donma: int = 0                    ## cevirmeden sonra girdinin dondugu kare sayisi
var _iz: bool = false                  ## tek bolum tanilamasi: her karari yaz
var _insan: bool = false               ## insan tepki bandi, dosya yazilmaz
var _tepki_az: float = TEPKI_EN_AZ
var _tepki_cok: float = TEPKI_EN_COK
var _kare_no: int = 0
var _son_olum: int = 0


## Tanilama satiri: bot o anda nerede, hangi yuzeyde, onunde ne var.
func _yaz_iz(etiket: String) -> void:
	var ust: bool = _o.yercekimi_yonu < 0.0
	var x: float = _o.global_position.x
	print("    %-6s kare %4d  x=%6.1f (sutun %2d)  %s  mesafe=%5.1f  hiz=%6.1f  fren=%s" % [
		etiket, _kare_no, x, int(x / 16.0), "TAVAN" if ust else "zemin",
		_tehlike_mesafesi(x, ust, 0.0, ONGORU), _o.velocity.x, "E" if _fren else "h"])


func _ready() -> void:
	var arg := OS.get_cmdline_user_args()
	var kosu: int = int(arg[0]) if arg.size() > 0 else KOSU_SAYISI
	var tek: int = int(arg[1]) if arg.size() > 1 else -1
	_iz = arg.size() > 2 and String(arg[2]) == "iz"
	_insan = arg.has("insan")
	if _insan:
		_tepki_az = INSAN_TEPKI_EN_AZ
		_tepki_cok = INSAN_TEPKI_EN_COK
		print("INSAN MODU: tepki %.2f-%.2f sn, dosya yazilmaz" % [_tepki_az, _tepki_cok])

	Ayarlar.sifirla()
	# Bot olcum icin birkac ayari degistiriyor, ama Ayarlar.bolum_bitti()
	# her bolum sonunda kaydet() cagiriyor — yani bu degisiklikler kullanicinin
	# user://kayit.cfg dosyasina YAZILIYOR. Bu sessizce iki ekran goruntusu
	# turunu bozdu (oyun hissi ve inis gostergesi kapali cekildi), o yuzden
	# cikista geri veriliyor.
	var yedek := {
		"hissi": Ayarlar.oyun_hissi, "inis": Ayarlar.inis_gostergesi,
		"yardim": Ayarlar.yardim_acik,
	}
	Ayarlar.yardim_acik = false
	Ayarlar.oyun_hissi = false          ## parcacik/tween olcumu degistirmez, yalniz yavaslatir
	Ayarlar.inis_gostergesi = false
	Ayarlar.acilan_bolum = Ayarlar.bolum_sayisi() - 1

	_oyun = OYUN.instantiate()
	add_child(_oyun)
	await get_tree().process_frame

	var kayit: Array = []
	for i in Ayarlar.bolum_sayisi():
		if tek >= 0 and i != tek:
			kayit.append(null)
			continue
		kayit.append(await _bolumu_olc(i, kosu))
	if _insan:
		_insan_tablosu(kayit)
	else:
		_yaz(kayit)

	Ayarlar.oyun_hissi = bool(yedek["hissi"])
	Ayarlar.inis_gostergesi = bool(yedek["inis"])
	Ayarlar.yardim_acik = bool(yedek["yardim"])
	Ayarlar.kaydet()
	print("kullanici ayarlari geri verildi")

	Ses.kapat()
	await get_tree().create_timer(0.25).timeout
	get_tree().quit(0)


# --- olcum -------------------------------------------------------------------

func _bolumu_olc(i: int, kosu: int) -> Dictionary:
	var ad: String = String(Ayarlar.bolum(i)["ad"])
	var sonuclar: Array = []
	for k in kosu:
		var s := await _kosu(i, i * 1000 + k)
		sonuclar.append(s)
		print("  bolum %2d kosu %d: %s  %.3f sn  cevirme %d  olum %d  %s" % [
			i + 1, k + 1, "BITTI " if s["bitti"] else "kaldi ", s["sure"],
			s["cevirme"], s["olum"], s["neden"]])
	var bitenler: Array = sonuclar.filter(func(s: Dictionary) -> bool: return bool(s["bitti"]))
	var sonuc := {
		"ad": ad, "bolum": i, "yatay": _yatay_px(i),
		"biten": bitenler.size(), "kosu": kosu,
		"sure": 0.0, "cevirme": int(Ayarlar.bolum(i).get("cevirme", 0)), "olum": 0,
		"tahmin": true, "yol": PackedVector2Array(),
	}
	if bitenler.is_empty():
		print("bolum %2d %-18s BITIREMEDI (%d/%d)" % [i + 1, ad, 0, kosu])
		return sonuc
	# Kotu kosu ayiklama: tepki gecikmesi kosuyu birkac yuzde uzatir, kacirilan
	# bir cevirme (olum + yeniden dogus) kat kat. Ikisini ayni torbaya koymamak
	# icin en iyinin 1,5 katindan kotusu ortancaya girmiyor.
	var sureler: Array = bitenler.map(func(s: Dictionary) -> float: return float(s["sure"]))
	sureler.sort()
	var en_iyi: float = sureler[0]
	var temiz: Array = sureler.filter(func(v: float) -> bool: return v <= en_iyi * KOTU_KOSU_CARPANI)
	sonuc["sure"] = _ortanca(temiz)
	sonuc["tahmin"] = false
	sonuc["olum"] = int(bitenler.map(func(s: Dictionary) -> int: return int(s["olum"])).min())
	# En az cevirme: bitiren kosular icinde en az cevirmeyle bitiren.
	sonuc["cevirme"] = int(bitenler.map(func(s: Dictionary) -> int: return int(s["cevirme"])).min())
	# Altin hayalet: olumsuz kosular varsa onlarin en hizlisi, yoksa en hizlisi.
	var aday: Array = bitenler.filter(func(s: Dictionary) -> bool: return int(s["olum"]) == 0)
	if aday.is_empty():
		aday = bitenler
	aday.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["sure"]) < float(b["sure"]))
	sonuc["yol"] = aday[0]["yol"]
	print("bolum %2d %-18s ortanca %.3f sn (%d/%d kosu, temiz %d)  en az cevirme %d" % [
		i + 1, ad, sonuc["sure"], bitenler.size(), kosu, temiz.size(), sonuc["cevirme"]])
	return sonuc


func _kosu(i: int, tohum: int) -> Dictionary:
	seed(tohum)
	_gecikme = -1.0
	_basili = 0
	_fren = false
	_donma = 0
	_son_olum = 0
	_birak()
	_oyun.bolum_yukle(i)
	await get_tree().physics_frame
	_bolum = _oyun.get_node("Dunya/Bolum")
	_o = _oyun.get_node("Dunya/Oyuncu")
	_harita = _bolum.harita
	_satir = _harita.size()
	_sutun = String(_harita[0]).length()
	_kapi_x = _kapi_sutunu() * float(Ayarlar.HUCRE) + 8.0

	var kare := 0
	_kare_no = 0
	var neden := "sure doldu"
	var bitti := false
	while kare < EN_FAZLA_KARE:
		await get_tree().physics_frame
		kare += 1
		_kare_no = kare
		if _iz and _oyun.olum > _son_olum:
			_son_olum = _oyun.olum
			_yaz_iz("OLUM")
		if _oyun._durum == 2:          # TAMAM
			bitti = true
			neden = ""
			break
		if _oyun._durum == 0:          # OYNA
			_karar_ver(1.0 / 60.0)
		else:                          # OLDU: girdiyi birak, yeniden dogusu bekle
			_birak()
			_gecikme = -1.0
	_birak()
	var yol: PackedVector2Array = _oyun._yol.duplicate()
	return {"bitti": bitti, "sure": float(kare) / 60.0, "cevirme": _oyun.cevirme,
		"olum": _oyun.olum, "yol": yol, "neden": neden}


# --- bot karari ---------------------------------------------------------------

## Her fizik karesinde bir kez.
##
## Oyunun asil pazarligi HIZ: tam hizda cevirince oyuncu karsi yuzeye varana
## kadar ~7 hucre suzuluyor, bantlar ise bilerek 3 hucre arayla kuruluyor.
## Yani dar pencereye sigmanin tek yolu once YAVASLAMAK — hizi kesen oyuncu
## neredeyse dik iner. Bot ayni pazarligi yapiyor: cevirme tam hizda guvenliyse
## hic yavaslamiyor, degilse fren yapip her karede yeniden soruyor.
func _karar_ver(delta: float) -> void:
	if _basili > 0:
		_basili -= 1
		if _basili == 0:
			Input.action_release("cevir")

	# CEVIRMEDEN SONRAKI ILK KARELER. Cevirme yalniz velocity.y'ye 45 px/sn
	# veriyor, yani oyuncu birkac kare daha is_on_floor() = true gorunuyor.
	# O karelerde asagidaki "yerdeyim, yurumeye devam" dali calisirsa gecis
	# tahmin edilen dik dusus degil tam hizli bir suzulme oluyor ve bot kendi
	# dogruladigi cevirmede oluyordu (10. bolumde 47 cevirme, 47 olum).
	if _donma > 0:
		_donma -= 1
		return

	# HAVADAYKEN GIRDIYE DOKUNMA. Inis tahmini o andaki girdiyle yapildi;
	# havada yurume tusuna basmak gercek yorungeyi tahminden kaydirir.
	if not _o.is_on_floor():
		return

	var ust: bool = _o.yercekimi_yonu < 0.0
	var x: float = _o.global_position.x

	# Bekleyen karar: tepki gecikmesi boyunca yurume durumu DEGISMEZ (fren
	# yaptiysa frende kalir), gecikme dolunca karar tekrar dogrulanir —
	# dunya degistiyse insan da vazgecer.
	if _gecikme >= 0.0:
		# Karar degismez ama tehlikenin dibine gelindiyse yine de fren:
		# "yetisemeyecegim" demek de bir insan tepkisidir. Bu olmadan bot
		# tepki suresi boyunca yuruyup 16. bolumde 56. sutundaki dikene
		# giriyordu — cevirme tusuna basmadan.
		if _tehlike_mesafesi(x, ust, 0.0, ONGORU) < SON_FREN:
			_fren = true
		_yuru(not _fren)
		_gecikme -= delta
		if _gecikme <= 0.0:
			_gecikme = -1.0
			if _cevirme_guvenli(ust):
				if _iz:
					_yaz_iz("CEVIR")
				Input.action_press("cevir")
				_basili = 2
				_donma = 8
				_fren = false
		return

	# Tehlike (tavanda: kapi da tehlikedir) gorunurde degilse tam hizda git.
	var mesafe := _tehlike_mesafesi(x, ust, 0.0, ONGORU)
	if mesafe >= ONGORU:
		_fren = false
		_yuru(true)
		return

	# Gorunurde: guvenliyse cevir (tam hizda cevirebiliyorsa hic yavaslamaz),
	# degilse tehlikenin dibine kadar yuru ve orada dur — hizi kesen oyuncu
	# neredeyse dik iner ve 3 hucrelik pencereye ancak oyle sigar.
	var guvenli := _cevirme_guvenli(ust)
	_fren = not guvenli and mesafe < SON_FREN
	_yuru(not _fren)
	if guvenli and _basili == 0:
		_gecikme = randf_range(_tepki_az, _tepki_cok)


## Simdi cevirsem: inecek yer var mi, yol temiz mi, indigim yuzey hem yeterince
## hem de SU ANKINDEN DAHA COK temiz mi?
func _cevirme_guvenli(ust: bool) -> bool:
	var t: Dictionary = _oyun._inis_tahmini()
	if not bool(t["var"]) or bool(t["tehlike"]):
		return false
	var yeni_ust: bool = float(t["yon"]) < 0.0
	if yeni_ust == ust:
		return false
	var k: Vector2 = t["konum"]
	# Kapiyi UCARAK gecme. Kapi zemin hizasinda; tavanda ustunden gecen oyuncu
	# ona degmez ve bolum bitmez.
	if k.x > _kapi_x:
		return false
	var gecis: float = float(t.get("sure", 1.0))
	var yeni := _tehlike_mesafesi(k.x, yeni_ust, gecis, ONGORU)
	if yeni < TEMIZ_INIS:
		return false
	# Cevirme beni DAHA ILERI goturmeli. Karsilastirma mutlak x uzerinden:
	# su anki yuzeyde bulundugum yerden ne kadar ilerleyebiliyorum, cevirsem
	# indigim yerden ne kadar? Bu kural olmadan bot indigi yerde hemen geri
	# cevirmek zorunda kaliyor ve 4 cevirmelik bolumu 14 cevirmede (ucu
	# olumle) oynuyordu.
	var simdiki: float = _o.global_position.x + _tehlike_mesafesi(_o.global_position.x, ust, 0.0, ONGORU)
	return k.x + yeni > simdiki


## Verilen yuzeyde x'ten saga yurunurse ilk tehlikeye kac piksel var?
## t0: bu tarama kac saniye SONRA basliyor (hareketli parcalar o kadar ilerletilir).
func _tehlike_mesafesi(x0: float, ust: bool, t0: float, en_fazla: float) -> float:
	var y := _yuzey_merkez(ust)
	var d := 0.0
	while d <= en_fazla:
		var x := x0 + d
		if x >= _kapi_x:
			# Kapi ZEMIN hizasindadir (kutusu 3 hucre boyunda, tabani zeminde).
			# Zeminde ona varmak bolumu bitirir, otesi onemsiz. TAVANDA ise
			# kapinin ustunden gecmek bolumu KAYBETTIRIR — oyuncu kapiya hic
			# degmez ve geri donemez. Yani kapi tavanda bir tehlikedir.
			return d if ust else en_fazla
		if _sutun_tehlikeli(int(floor(x / float(Ayarlar.HUCRE))), ust):
			return d
		if _bolum.hareketli_kesisiyor(
				Rect2(x - Ayarlar.GOVDE.x * 0.5, y - Ayarlar.GOVDE.y * 0.5, Ayarlar.GOVDE.x, Ayarlar.GOVDE.y),
				false, t0 + d / Ayarlar.HIZ):
			return d
		d += TARAMA_ADIMI
	return en_fazla


## Sabit haritadan: bu sutun o yuzeyde gecilebilir mi?
func _sutun_tehlikeli(c: int, ust: bool) -> bool:
	if c < 0 or c >= _sutun:
		return true
	if ust:
		return String(_harita[1])[c] == "v" or String(_harita[0])[c] != "#"
	return String(_harita[_satir - 1])[c] != "#" or String(_harita[_satir - 2])[c] == "^"


## Oyuncunun o yuzeyde durdugundaki merkez y'si.
func _yuzey_merkez(ust: bool) -> float:
	if ust:
		return float(Ayarlar.HUCRE) + Ayarlar.GOVDE.y * 0.5
	return float(_satir - 1) * float(Ayarlar.HUCRE) - Ayarlar.GOVDE.y * 0.5


func _yuru(ac: bool) -> void:
	if ac:
		if not Input.is_action_pressed("move_right"):
			Input.action_press("move_right")
	elif Input.is_action_pressed("move_right"):
		Input.action_release("move_right")


func _birak() -> void:
	for a in ["move_right", "move_left", "cevir"]:
		if Input.is_action_pressed(a):
			Input.action_release(a)


func _kapi_sutunu() -> int:
	for s in _harita:
		var satir: String = s
		var c := satir.find("K")
		if c >= 0:
			return c
	return _sutun - 4


## Bolumun yatay yol uzunlugu (px) — tahmin olceginin tabani.
func _yatay_px(i: int) -> float:
	var h: Array = Ayarlar.bolum(i)["harita"]
	var bas := 0
	var son := 0
	for s in h:
		var satir: String = s
		if satir.find("S") >= 0:
			bas = satir.find("S")
		if satir.find("K") >= 0:
			son = satir.find("K")
	return float(son - bas) * float(Ayarlar.HUCRE)


func _ortanca(dizi: Array) -> float:
	var d: Array = dizi.duplicate()
	d.sort()
	var n := d.size()
	if n == 0:
		return 0.0
	if n % 2 == 1:
		return float(d[n / 2])
	return (float(d[n / 2 - 1]) + float(d[n / 2])) * 0.5


# --- cikti -------------------------------------------------------------------

func _yaz(kayit: Array) -> void:
	# Olcek = oranlarin ORTANCASI (toplam/toplam degil): tek bir kotu bolum
	# butun olcegi kendine cekmesin.
	var oranlar: Array = []
	for k in kayit:
		if k == null or bool(k["tahmin"]) or float(k["yatay"]) <= 0.0:
			continue
		oranlar.append(float(k["sure"]) / float(k["yatay"]))
	var olcek := _ortanca(oranlar) if not oranlar.is_empty() else 0.0090
	print("olcek: %.5f sn/px (%d bolumun orani)" % [olcek, oranlar.size()])

	# Aykiri bolum: bitirdi ama olcegin 2 katindan yavas kostu — bolum zor
	# oldugu icin degil, bot orada kotu oynadigi icin. Esigi ondan almak
	# bolumu bedava altin yapardi; tahmine devrediyoruz.
	for k in kayit:
		if k == null or bool(k["tahmin"]):
			continue
		var oran: float = float(k["sure"]) / maxf(float(k["yatay"]), 1.0)
		if oran > olcek * AYKIRI_BOLUM_CARPANI:
			print("bolum %d aykiri (%.5f sn/px), tahmine devredildi" % [int(k["bolum"]) + 1, oran])
			k["tahmin"] = true

	var satir: Array = []
	var hayalet: Array = []
	for i in Ayarlar.bolum_sayisi():
		var k: Variant = kayit[i] if i < kayit.size() else null
		var yatay: float = _yatay_px(i)
		var sure: float = 0.0
		var tahmin := true
		var cevirme: int = int(Ayarlar.bolum(i).get("cevirme", 0))
		var biten := 0
		var toplam := 0
		var yol := PackedVector2Array()
		if k != null:
			biten = int(k["biten"])
			toplam = int(k["kosu"])
			cevirme = int(k["cevirme"])
			yol = k["yol"]
			if not bool(k["tahmin"]):
				sure = float(k["sure"])
				tahmin = false
		if tahmin:
			sure = olcek * yatay
			yol = PackedVector2Array()
		satir.append({
			"sure": sure, "cevirme": cevirme, "tahmin": tahmin,
			"biten": biten, "kosu": toplam,
			"altin": snappedf(sure * ALTIN, 0.001),
			"gumus": snappedf(sure * GUMUS, 0.001),
			"bronz": snappedf(sure * BRONZ, 0.001),
		})
		hayalet.append(yol)
	_rota_yaz(satir)
	_hayalet_yaz(hayalet)


func _rota_yaz(satir: Array) -> void:
	var m := "extends RefCounted\nclass_name RotaVerisi\n"
	m += "## URETILIR: tools/bot.gd — elle duzenleme ustune yazilir.\n"
	m += "## Olcum: bolum basina %d kosu, gercek fizikte, karar basina 0,05-0,20 sn\n" % KOSU_SAYISI
	m += "## tepki gecikmesi; deger ortanca. Carpanlar: altin x%.2f, gumus x%.2f, bronz x%.2f.\n" % [ALTIN, GUMUS, BRONZ]
	m += "##   \"sure\"    botun ortanca kosusu (sn)\n"
	m += "##   \"tahmin\"  true ise bot bu bolumu bitiremedi, sure sn/px olceginden cikarildi\n"
	m += "##   \"cevirme\" botun OLCULEN en az cevirmesi (tahminde geometri hedefi)\n"
	m += "const VERI: Array = [\n"
	for i in satir.size():
		var s: Dictionary = satir[i]
		m += '\t{"sure": %.3f, "altin": %.3f, "gumus": %.3f, "bronz": %.3f, "cevirme": %d, "tahmin": %s, "biten": %d, "kosu": %d},\n' % [
			s["sure"], s["altin"], s["gumus"], s["bronz"], s["cevirme"],
			"true" if bool(s["tahmin"]) else "false", s["biten"], s["kosu"]]
	m += "]\n"
	_dosya("res://scripts/rota_verisi.gd", m)


## Altin hayalet: botun en iyi kosusunun yolu. Tam sayiya yuvarlaniyor (oyun
## piksele oturuyor zaten) ve x,y duz bir dizide — GDScript'te iç ice
## PackedVector2Array sabiti derlenmiyor.
func _hayalet_yaz(hayalet: Array) -> void:
	var m := "extends RefCounted\nclass_name AltinHayalet\n"
	m += "## URETILIR: tools/bot.gd — elle duzenleme ustune yazilir.\n"
	m += "## Her bolum icin botun en iyi kosusunun yolu: [x0, y0, x1, y1, ...]\n"
	m += "## Ornekleme Ayarlar.HAYALET_ARALIGI ile ayni (30 Hz). Bos dizi = kayit yok.\n"
	m += "const YOL: Array = [\n"
	var toplam := 0
	for i in hayalet.size():
		var yol: PackedVector2Array = hayalet[i]
		var p: PackedStringArray = PackedStringArray()
		for v in yol:
			p.append(str(roundi(v.x)))
			p.append(str(roundi(v.y)))
		toplam += yol.size()
		m += "\t[%s],\n" % ",".join(p)
	m += "]\n\n\n"
	m += "static func yol(i: int) -> PackedVector2Array:\n"
	m += "\tvar cikti := PackedVector2Array()\n"
	m += "\tif i < 0 or i >= YOL.size():\n"
	m += "\t\treturn cikti\n"
	m += "\tvar d: Array = YOL[i]\n"
	m += "\tvar j := 0\n"
	m += "\twhile j + 1 < d.size():\n"
	m += "\t\tcikti.append(Vector2(float(d[j]), float(d[j + 1])))\n"
	m += "\t\tj += 2\n"
	m += "\treturn cikti\n"
	_dosya("res://scripts/altin_hayalet.gd", m)
	print("altin hayalet: %d nokta" % toplam)


## "insan" modu: olcumu mevcut esiklerle yan yana bas. Rapora giren tablo bu.
func _insan_tablosu(kayit: Array) -> void:
	print("INSAN TABLOSU  bolum | bot ortanca (rota_verisi) | insan ortanca | oran | altin esigi | insan altin alir mi")
	var altin_alan := 0
	var toplam := 0
	for k in kayit:
		if k == null:
			continue
		var i: int = int(k["bolum"])
		var e: Dictionary = Ayarlar.esik(i)
		var bot: float = float(e["sure"])
		var insan: float = float(k["sure"]) if not bool(k["tahmin"]) else -1.0
		var oran: float = insan / bot if insan > 0.0 and bot > 0.0 else 0.0
		var alir := insan > 0.0 and insan <= float(e["altin"])
		toplam += 1
		if alir:
			altin_alan += 1
		print("INSAN %2d %-16s bot %6.3f  insan %6.3f  oran %.3f  altin %6.3f  %s  (%d/%d bitti)" % [
			i + 1, String(k["ad"]), bot, insan, oran, float(e["altin"]),
			"ALTIN" if alir else "altin yok", int(k["biten"]), int(k["kosu"])])
	print("INSAN OZET: %d/%d bolumde insan bandindaki bot mevcut altin esigini tutuyor" % [altin_alan, toplam])


func _dosya(yol: String, metin: String) -> void:
	var f := FileAccess.open(yol, FileAccess.WRITE)
	if f == null:
		printerr("yazilamadi: %s" % yol)
		return
	f.store_string(metin)
	f.close()
	print("yazildi: %s (%d bayt)" % [yol, metin.length()])
