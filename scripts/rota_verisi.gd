extends RefCounted
class_name RotaVerisi
## URETILIR: tools/bot.gd — elle duzenleme ustune yazilir.
## Olcum: bolum basina 5 kosu, gercek fizikte, karar basina 0,05-0,20 sn
## tepki gecikmesi; deger ortanca. Carpanlar: altin x1.15, gumus x1.50, bronz x2.00.
##   "sure"    botun ortanca kosusu (sn)
##   "tahmin"  true ise bot bu bolumu bitiremedi, sure sn/px olceginden cikarildi
##   "cevirme" botun OLCULEN en az cevirmesi (tahminde geometri hedefi)
const VERI: Array = [
	{"sure": 4.217, "altin": 4.849, "gumus": 6.325, "bronz": 8.433, "cevirme": 0, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 4.849, "gumus": 6.325, "bronz": 8.433, "cevirme": 2, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 4.849, "gumus": 6.325, "bronz": 8.433, "cevirme": 2, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 4.849, "gumus": 6.325, "bronz": 8.433, "cevirme": 2, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 4.849, "gumus": 6.325, "bronz": 8.433, "cevirme": 0, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 4.849, "gumus": 6.325, "bronz": 8.433, "cevirme": 4, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 4.849, "gumus": 6.325, "bronz": 8.433, "cevirme": 4, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 4.849, "gumus": 6.325, "bronz": 8.433, "cevirme": 2, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 5.183, "altin": 5.961, "gumus": 7.775, "bronz": 10.367, "cevirme": 4, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 5.217, "altin": 5.999, "gumus": 7.825, "bronz": 10.433, "cevirme": 4, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 5.183, "altin": 5.961, "gumus": 7.775, "bronz": 10.367, "cevirme": 4, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 4.217, "altin": 4.849, "gumus": 6.325, "bronz": 8.433, "cevirme": 2, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 7.283, "altin": 8.376, "gumus": 10.925, "bronz": 14.567, "cevirme": 6, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 7.283, "altin": 8.376, "gumus": 10.925, "bronz": 14.567, "cevirme": 6, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 8.200, "altin": 9.430, "gumus": 12.300, "bronz": 16.400, "cevirme": 8, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 9.300, "altin": 10.695, "gumus": 13.950, "bronz": 18.600, "cevirme": 8, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 7.283, "altin": 8.376, "gumus": 10.925, "bronz": 14.567, "cevirme": 6, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 7.283, "altin": 8.376, "gumus": 10.925, "bronz": 14.567, "cevirme": 6, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 7.333, "altin": 8.433, "gumus": 11.000, "bronz": 14.667, "cevirme": 6, "tahmin": false, "biten": 5, "kosu": 5},
	{"sure": 9.233, "altin": 10.618, "gumus": 13.850, "bronz": 18.467, "cevirme": 8, "tahmin": false, "biten": 5, "kosu": 5},
]
