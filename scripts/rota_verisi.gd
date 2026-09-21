extends RefCounted
class_name RotaVerisi
## URETILIR: tools/bot.gd — elle duzenleme ustune yazilir.
## Olcum: bolum basina 5 kosu, gercek fizikte, karar basina 0,05-0,20 sn
## tepki gecikmesi; deger ortanca. Carpanlar: altin x1.35, gumus x1.75, bronz x2.40.
##   "sure"    botun ortanca kosusu (sn)
##   "tahmin"  true ise bot bu bolumu bitiremedi, sure sn/px olceginden cikarildi
##   "cevirme" botun OLCULEN en az cevirmesi (tahminde geometri hedefi)
const VERI: Array = [
	{"sure": 4.217, "altin": 5.693, "gumus": 7.379, "bronz": 10.120, "cevirme": 0, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 5.693, "gumus": 7.379, "bronz": 10.120, "cevirme": 2, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 5.693, "gumus": 7.379, "bronz": 10.120, "cevirme": 2, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 5.693, "gumus": 7.379, "bronz": 10.120, "cevirme": 2, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 5.693, "gumus": 7.379, "bronz": 10.120, "cevirme": 0, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 5.693, "gumus": 7.379, "bronz": 10.120, "cevirme": 4, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 5.693, "gumus": 7.379, "bronz": 10.120, "cevirme": 4, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 5.693, "gumus": 7.379, "bronz": 10.120, "cevirme": 2, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 5.183, "altin": 6.998, "gumus": 9.071, "bronz": 12.440, "cevirme": 4, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 5.217, "altin": 7.043, "gumus": 9.129, "bronz": 12.520, "cevirme": 4, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 5.183, "altin": 6.998, "gumus": 9.071, "bronz": 12.440, "cevirme": 4, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 5.693, "gumus": 7.379, "bronz": 10.120, "cevirme": 2, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 7.283, "altin": 9.833, "gumus": 12.746, "bronz": 17.480, "cevirme": 6, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 7.283, "altin": 9.833, "gumus": 12.746, "bronz": 17.480, "cevirme": 6, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 8.200, "altin": 11.070, "gumus": 14.350, "bronz": 19.680, "cevirme": 8, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 8.250, "altin": 11.138, "gumus": 14.438, "bronz": 19.800, "cevirme": 6, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 7.283, "altin": 9.833, "gumus": 12.746, "bronz": 17.480, "cevirme": 6, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 7.283, "altin": 9.833, "gumus": 12.746, "bronz": 17.480, "cevirme": 6, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 8.233, "altin": 11.115, "gumus": 14.408, "bronz": 19.760, "cevirme": 6, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 9.150, "altin": 12.353, "gumus": 16.012, "bronz": 21.960, "cevirme": 8, "tahmin": false, "biten": 5, "kosu": 5},
]
