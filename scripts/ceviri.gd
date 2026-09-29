class_name Ceviri
extends RefCounted
## Arayuz metinleri: KAYNAK dil Turkce (tr() anahtari Turkce metnin kendisi),
## Ingilizce tablo asagida. Turkce icin ceviri tablosu gerekmez: anahtar
## bulunamazsa Godot metni aynen doner (proje ayari: yedek dil "tr").
##
## Yeni bir arayuz metni eklerken:
##   1. Kodda tr("Turkce metin") ya da sahnede Label/Button metni olarak yaz;
##   2. Asagidaki EN tablosuna ayni anahtarla Ingilizcesini ekle
##      (bicim belirteclerinin sayisi ve sirasi ayni kalsin: %d, %s, %.2f);
##   3. tests/testler.gd -> _ceviri_testi eksik anahtari ve belirtec uyusmazligini yakalar.
##
## Ingilizce metinler dogal ve kisa: "Flip gravity", "Play", "Reach the door";
## dizgi dizgi ceviri degil.

const EN := {
	# --- menu ---
	"Oyna": "Play",
	"Bölüm Seç": "Choose a room",
	"Günün Bölümü": "Daily room",
	"Ayarlar": "Settings",
	"Çıkış": "Quit",
	"Yerçekimi Çevir": "Yerçekimi Çevir",
	"Tek tuş": "One key",
	"Tek dokunuş": "One tap",
	"Tek tuş · 20 oda": "One key · 20 rooms",
	"A / D ile yürü · BOŞLUK yerçekimini çevirir": "A / D to walk · SPACE flips gravity",
	"A / D ile yürü": "A / D to walk",
	"BOŞLUK yerçekimini çevirir": "SPACE flips gravity",
	"{h} alttaki iki alanla yürü": "Walk with the two {h} zones",
	"{c} yarıya dokunmak yerçekimini çevirir": "Tap the {c} half to flip gravity",
	"Sol": "left",
	"Sağ": "right",
	"Günün bölümü: %s · en iyi %s · seri %d gün": "Daily room: %s · best %s · streak %d days",
	"%d / %d kristal · %d / %d madalya · açık bölüm %d / %d": "%d / %d crystals · %d / %d medals · rooms unlocked %d / %d",
	"yardım açık": "assist on",
	"Cihazını yatay çevir": "Rotate your device to landscape",
	# --- bolum secimi ---
	"Kristal %d / %d     Madalya %d / %d     En az çevirme %d / %d": "Crystals %d / %d     Medals %d / %d     Fewest flips %d / %d",
	"Süre Listesi": "Time list",
	"Bölüm Izgarası": "Room grid",
	"Geri": "Back",
	"kilitli": "locked",
	"● %.2f sn": "● %.2f s",
	"%.2f sn": "%.2f s",
	# --- ayarlar ---
	"Dil": "Language",
	"SES VE GÖRÜNTÜ": "SOUND AND DISPLAY",
	"Müzik": "Music",
	"Ses efektleri": "Sound effects",
	"Tam ekran": "Fullscreen",
	"Oyun hissi": "Game feel",
	"Yüksek kontrast": "High contrast",
	"Yerçekimi oku": "Gravity arrow",
	"İniş göstergesi": "Landing marker",
	"YARIŞ, YARDIM VE DOKUNMATİK": "RACE, ASSIST AND TOUCH",
	"Altın hayalet": "Gold ghost",
	"Yardım modu": "Assist mode",
	"Oyun hızı": "Game speed",
	"Dikenler itsin": "Spikes push back",
	"Solak dokunmatik": "Left-handed touch",
	"Düğme opaklığı": "Button opacity",
	"Titreşim": "Vibration",
	"Yardım modu oyunu senin hızına uydurur: yavaşlatır, dikenleri iteklemeye çevirir, duraklatma menüsünden bölüm atlatır. Açıkken süre ve madalya kaydı tutulmaz; kristaller sayılır. İstediğin an kapatabilirsin.":
		"Assist mode adapts the game to your pace: it slows time, makes spikes push you back and lets you skip rooms from the pause menu. While it is on, times and medals are not recorded; crystals still count. Turn it off any time.",
	# --- oyun ici ---
	"sen": "you",
	"altın": "gold",
	"ÇEVİR": "FLIP",
	"ÇEVİRME KİLİTLİ": "FLIP LOCKED",
	"Süre %.2f · ölüm %d · çevirme %d": "Time %.2f · deaths %d · flips %d",
	"Oda %02d / %02d": "Room %02d / %02d",
	"Günün bölümü": "Daily room",
	"kristal alındı": "crystal collected",
	"kristal ZORUNLU — kapı onsuz açılmaz": "crystal REQUIRED — the door stays shut without it",
	"HAYALET YARIŞI — altın hayaleti geç": "GHOST RACE — beat the gold ghost",
	"kristal": "crystal",
	"ters başlangıç": "reversed start",
	"kristal zorunlu": "crystal required",
	"hayalet yarışı": "ghost race",
	"%s · altın %.2f sn · en iyi %s": "%s · gold %.2f s · best %s",
	"%s · günün bölümü: %s · en iyi %s": "%s · daily room: %s · best %s",
	"Yardım modu · hız %d%%": "Assist mode · speed %d%%",
	"dikenler itiyor": "spikes push back",
	"ÖLDÜN": "YOU DIED",
	"KONTROL NOKTASI": "CHECKPOINT",
	"KAPI KAPALI — ÖNCE KRİSTALİ AL": "DOOR LOCKED — GRAB THE CRYSTAL FIRST",
	"HAYALET KAZANDI — baştan": "THE GHOST WON — again",
	"Oda %02d / %02d tamam": "Room %02d / %02d done",
	"Günün bölümü tamam": "Daily room done",
	"%d çevirme · seri %d gün": "%d flips · streak %d days",
	"%d çevirme": "%d flips",
	"%s madalya": "%s medal",
	"Madalya yok": "No medal",
	"YENİ REKOR": "NEW RECORD",
	"En iyi %s": "Best %s",
	"EN AZ ÇEVİRME": "FEWEST FLIPS",
	"GÜNÜN REKORU!": "DAILY RECORD!",
	"Yardım modu açık: süre kaydı tutulmuyor.": "Assist mode is on: the time is not recorded.",
	"Yardım modu açık: süre ve madalya kaydı tutulmuyor, kristaller sayılıyor.": "Assist mode is on: time and medal are not recorded, crystals still count.",
	"Bu bölümde %d kez öldün": "You died %d times in this room",
	"Bronz": "Bronze",
	"Gümüş": "Silver",
	"Altın": "Gold",
	# --- duraklat / bitis ---
	"Duraklatıldı": "Paused",
	"Devam": "Resume",
	"Bölümü Baştan Başlat": "Restart room",
	"Bölümü Atla": "Skip room",
	"Menüye Dön": "Back to menu",
	"Tebrikler": "Well done",
	"Tekrar oyna": "Play again",
	"Paylaşım Metnini Kopyala": "Copy share text",
	"Kopyalandı": "Copied",
	"Tüm %d bölüm bitti!": "All %d rooms cleared!",
	"Toplam süre: %.2f sn": "Total time: %.2f s",
	"Toplam ölüm: %d": "Total deaths: %d",
	"Kristal: %d / %d": "Crystals: %d / %d",
	"Madalya kazanılan bölüm: %d / %d": "Rooms with a medal: %d / %d",
	"En az çevirmeyle biten bölüm: %d / %d": "Rooms cleared with fewest flips: %d / %d",
	"Yerçekimi Çevir · günün bölümü · %02d.%02d.%d\n%s\n%.2f sn · %d ölüm · %d çevirme · seri %d gün":
		"Yerçekimi Çevir · daily room · %02d.%02d.%d\n%s\n%.2f s · %d deaths · %d flips · streak %d days",
	# --- bolum adlari (scripts/bolumler.gd, arac/uret_bolumler.py) ---
	"1 — İlk Adım": "1 — First Step",
	"2 — Çevir": "2 — Flip",
	"3 — Tavan Yolu": "3 — Ceiling Path",
	"4 — Diken": "4 — Spikes",
	"5 — Tavan Dikeni": "5 — Ceiling Spikes",
	"6 — İleri Geri": "6 — Back and Forth",
	"7 — Üç Engel": "7 — Three Hurdles",
	"8 — Asansör": "8 — Elevator",
	"9 — Salıncak": "9 — Swing",
	"10 — Dört Vuruş": "10 — Four Beats",
	"11 — Gezgin Diken": "11 — Wandering Spike",
	"12 — Süpürge": "12 — Sweeper",
	"13 — Uzun Yol": "13 — Long Way",
	"14 — Boşluk Üstü": "14 — Over the Gap",
	"15 — Tarak": "15 — Comb",
	"16 — Kılçık": "16 — Fishbone",
	"17 — İki Asansör": "17 — Two Elevators",
	"18 — Koridor": "18 — Corridor",
	"19 — Fırtına": "19 — Storm",
	"20 — Son Kapı": "20 — Last Door",
	# --- bolum ipuclari ---
	"A / D ile yürü. Sarı kapıya ulaş.": "A / D to walk. Reach the yellow door.",
	"BOŞLUK yerçekimini çevirir. Delikten geçmek için tavana düş.": "SPACE flips gravity. Fall to the ceiling to get past the gap.",
	"Tavanda yürüyorsun. Boşluğu geçince tekrar çevir.": "You are on the ceiling. Flip again once you are past the gap.",
	"Kırmızı diken öldürür. Çevirmek yalnızca bir yüzeye değerken çalışır.": "Red spikes kill. You can only flip while touching a surface.",
	"Tavanda da diken var. Burada zeminde kal.": "The ceiling has spikes too. Stay on the floor here.",
	"Camgöbeği platform gidip geliyor; üstüne ya da altına yapış.": "The cyan platform slides back and forth; stick to its top or underside.",
	"Kesik çizgili kutuda çevirme yasak. Kutuya girmeden karar ver.": "No flipping inside the dashed box. Decide before you enter it.",
	"Gezen diken zemini süpürüyor; zamanla ya da tavana kaç.": "The wandering spike sweeps the floor; time it or escape to the ceiling.",
	"Bayrağa dokunursan öldüğünde oradan devam edersin.": "Touch the flag and you restart from it when you die.",
	"Oklu platform yalnız ok yönünden geçilir; öbür yandan gelince tutar.": "Arrow platforms let you through only in the arrow's direction; from the other side they hold you.",
}


static var _kuruldu: bool = false


## Ingilizce tabloyu TranslationServer'a yukler (birden cok cagri zararsiz).
static func kur() -> void:
	if _kuruldu:
		return
	_kuruldu = true
	var t := Translation.new()
	t.locale = "en"
	for k in EN:
		t.add_message(k, EN[k])
	TranslationServer.add_translation(t)


## Kaynak anahtarin belirtec (%d, %s, %.2f, %%) dizisi: ceviri ile ayni olmali.
static func belirtecler(m: String) -> PackedStringArray:
	var sonuc := PackedStringArray()
	var r := RegEx.new()
	r.compile("%[-+ 0#]*[0-9]*(?:\\.[0-9]+)?[dsf]")
	for e in r.search_all(m):
		sonuc.append(e.get_string())
	return sonuc
