class_name Tema
extends RefCounted
## Tanitim videosundaki dunya: DUZ renk, golgesiz, disi cizgisiz. Uc tema +
## tek tehlike rengi. Renk kodlari videodan piksel ornekleyerek alindi
## (docs/TASARIM.md). Bolum temasi muzik grubuna baglidir (Ses.bolum_parcasi):
## sakin = kagit, gergin = gece, hizli = pembe kagit.
##
## Yercekimi ters donunce zemin ve blok rengi YER DEGISTIRIR (kagit <-> gece,
## pembe <-> koyu pembe): durum renkten okunur, videodaki gibi.

const MUREKKEP := Color("0e0d0b")
const KAGIT := Color("f1ece2")
const PANEL := Color("10101a")       ## menu ve kart arkasi (video penceresi)
const DIKEN := Color("e94f36")       ## tehlike + tek vurgu
const OYUNCU := Color("4585bd")
const CAM := Color("7dd4e7")         ## birincil dugme, hareketli platform, kontrol noktasi
const SARI := Color("ffc21a")        ## kapi, kristal, madalya: yalniz odul

## Tema dizini: 0 gece, 1 pembe kagit, 2 kagit.
const TEMALAR: Array = [
	{"ad": "gece", "zemin": Color("1c141c"), "blok": Color("f1ece2")},
	{"ad": "pembe", "zemin": Color("f0d6cc"), "blok": Color("2b1517")},
	{"ad": "kagit", "zemin": Color("f1ede5"), "blok": Color("14121a")},
]
const KONTRAST := {"ad": "kontrast", "zemin": Color("000000"), "blok": Color("ffffff")}

const F_GOVDE := "res://assets/fonts/InstrumentSans-Regular.ttf"
const F_KALIN := "res://assets/fonts/InstrumentSans-Bold.ttf"
const F_MONO := "res://assets/fonts/JetBrainsMono-Regular.ttf"
const F_MONO_KALIN := "res://assets/fonts/JetBrainsMono-Bold.ttf"
const F_SIMGE := "res://assets/fonts/simgeler.ttf"
const TEMA_YOLU := "res://assets/tema.tres"


## Bolum indeksinden tema: 0-6 kagit, 7-13 gece, 14-19 pembe.
static func bolum_temasi(i: int) -> int:
	if i < 7:
		return 2
	if i < 14:
		return 0
	return 1


## [zemin, blok] cifti. ters = yercekimi ters: ikisi yer degistirir.
static func renkler(tema: int, ters: bool = false) -> Array:
	var t: Dictionary = KONTRAST if Ayarlar.yuksek_kontrast else TEMALAR[clampi(tema, 0, 2)]
	var z: Color = t["zemin"]
	var b: Color = t["blok"]
	return [b, z] if ters else [z, b]


## Mono etiketlerin rengi: bloktan (mürekkep ya da kagit) %70 opaklik.
static func etiket_rengi(blok: Color) -> Color:
	return Color(blok, 0.7)


## Turkce duyarli buyuk harf: i -> I degil İ. Ingilizcede duz to_upper.
static func buyuk(s: String) -> String:
	if TranslationServer.get_locale().begins_with("tr"):
		return s.replace("i", "İ").replace("ı", "I").to_upper()
	return s.to_upper()


## "1 — İlk Adım" -> ["01", "İLK ADIM"] (ceviri sonrasi metinden).
static func ad_parcala(ad: String) -> Array:
	var p := ad.split(" — ", true, 1)
	if p.size() < 2:
		return ["", buyuk(ad)]
	return ["%02d" % int(p[0]), buyuk(String(p[1]))]


## Etiketin ust satir metni: "01 / İLK ADIM".
static func kisa_baslik(ad: String) -> String:
	var p := ad_parcala(ad)
	return ("%s / %s" % [p[0], p[1]]) if String(p[0]) != "" else String(p[1])

## Gunluk video imkanlarindan alinan renk akisi ve gecis aileleri
## (sosyal/uret/tema.mjs TEMALAR, docs/TASARIM.md "Gunluk video imkanlarindan alinanlar").
## Dunya DUZ kalir; akis yalniz gecislerde, sayac chip'inde ve rekor damgasinda.
## Dizin = tema dizini (0 gece, 1 pembe, 2 kagit). "vurgu" sirayla doner (video:
## renkAkisi); yazi rengi ise vurgunun uzerinde kodla secilir (en az ESIK).
const GECIS_TURLERI: Array[StringName] = [&"iris", &"glitch", &"bloklar", &"itme", &"perde", &"flas", &"kararma", &"zoom"]
const ESIK := 4.5                  ## okunurluk alt siniri (video 5:1, burada 4,5:1)
const AKIS: Array = [
	{"kaynak": "klasik", "acik": Color("f1ece2"), "koyu": Color("0e0d0b"),
		"vurgu": [Color("ffc21a"), Color("19d3e6"), Color("ff7a1a"), Color("ff4d6d"), Color("f1ece2")],
		"gecis": [&"glitch", &"flas", &"itme", &"bloklar"]},
	{"kaynak": "limon", "acik": Color("fbfff0"), "koyu": Color("0d0d0d"),
		"vurgu": [Color("c2006b"), Color("3a1cff"), Color("0b1f6b"), Color("0b5d1e")],
		"gecis": [&"bloklar", &"zoom", &"perde", &"iris"]},
	{"kaynak": "kagit", "acik": Color("fffaf0"), "koyu": Color("16130f"),
		"vurgu": [Color("c1121f"), Color("1f45c9"), Color("13632f"), Color("6a1b9a"), Color("9a3a00")],
		"gecis": [&"perde", &"itme", &"kararma", &"zoom"]},
]


## WCAG goreli parlaklik.
static func parlaklik(c: Color) -> float:
	var k: Array[float] = []
	for v in [c.r, c.g, c.b]:
		k.append(v / 12.92 if v <= 0.04045 else pow((v + 0.055) / 1.055, 2.4))
	return 0.2126 * k[0] + 0.7152 * k[1] + 0.0722 * k[2]


static func kontrast(a: Color, b: Color) -> float:
	var x := parlaklik(a)
	var y := parlaklik(b)
	return (maxf(x, y) + 0.05) / (minf(x, y) + 0.05)


## Vurgu rengi uzerindeki yazi: acik ya da koyu, hangisi daha okunuyorsa.
static func yazi_rengi(zemin: Color, tema: int) -> Color:
	var a: Dictionary = AKIS[clampi(tema, 0, 2)]
	return a["acik"] if kontrast(zemin, a["acik"]) >= kontrast(zemin, a["koyu"]) else a["koyu"]


## Akis paletinden k. renk (sarmal).
static func akis_rengi(tema: int, k: int) -> Color:
	var v: Array = AKIS[clampi(tema, 0, 2)]["vurgu"]
	return v[posmod(k, v.size())]
