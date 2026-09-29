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
