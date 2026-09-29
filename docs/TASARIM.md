# Tasarım — v1.0 arayüz yenilemesi

Hedef: oyunu açan biri **tanıtım videosundaki dünyayı** bulsun — aynı renkler,
aynı yazı karakteri, aynı hareket dili. Çekirdek mekanik (tek dikey eylem,
kojot/tampon, 20 bölüm, madalya, hayalet, günün bölümü, bot doğrulaması)
**değişmedi**; fizik, harita ve `scripts/rota_verisi.gd` aynı. Bulgular
`docs/DENETIM.md`'de.

## 1. Videodan çıkarılan stil rehberi

Kaynak: `assets/sosyal/yercekimi-cevir-dikey.mp4` (1080×1920, 15 sn) kareleri;
renkler piksel örneklenerek doğrulandı (29 Eylül 2026, sıkıştırma payı ±2):

| Öğe | Videoda ölçülen | Oyunda kullanılan |
|---|---|---|
| Gece zemini | `#1c141c` | `#1c141c`, blok `#f1ece2` |
| Pembe kâğıt zemini | `#f1d7cd` | `#f0d6cc`, blok `#2b1517` |
| Kâğıt zemini | `#f0efe8` | `#f1ede5`, blok `#14121a` |
| Menü / kart zemini | `#10101a` | `#10101a` |
| Tehlike | `#e84d37` | `#e94f36` (üçgen diken, gezen diken) |
| Oyuncu | mavi yuvarlatılmış kare | `#4585bd`, 14×20 px, köşe 4 px, tek göz |
| Birincil düğme | camgöbeği dolgu + mürekkep yazı | `#7dd4e7` / `#0e0d0b` |
| Ödül | — | `#ffc21a`: yalnız kapı, kristal, madalya |

Kurallar: **düz renk, gölgesiz, dış çizgisiz**; bir sahnede zemin + blok + tek
vurgu (tehlike). Yazı: **Instrument Sans** (gövde, başlık) + **JetBrains
Mono** (köşe etiketleri, büyük harf, `01 / İLK ADIM` biçimi); ikisi de OFL,
`assets/fonts/` içinde lisans metniyle. `★ ✓ ⟳ ● ← →` gibi simgeler bu
yazı tiplerinde yok: temadaki her yazı tipinin yedeği `simgeler.ttf`
(`FontVariation.fallbacks`) — `_simge_testi` yedek çıkarılınca simgelerin
gerçekten eksik çıktığını ve Türkçe harflerin (İıŞşĞğ…) yazı tiplerinde
bulunduğunu ölçüyor.

### Hareket dili

| Öğe | Süre | Yumuşatma |
|---|---|---|
| Menü öğeleri girişi | 220 ms, 40 ms arayla sırayla | ease-out cubic |
| Düğme basışı | 90 ms %96'ya küçülür, 120 ms geri | ease-out |
| Ekran geçişi | renk bandı 260 ms örter, 200 ms açar (`#e94f36`) | ease-out / ease-in cubic |
| Bölüm sonu kartı | 180 ms alfa, 220 ms ölçek 0,96→1 | ease-out |
| Yerçekimi çevrilince | zemin ve blok rengi **yer değiştirir**, 250 ms | ease-out cubic |
| Squash/stretch | oyuncu inişte/çevirmede 140 ms | (rehberin tek yaylanma istisnası) |

Yerçekimi ters dönünce zemin ile blok rengi yer değiştirir (kâğıt ↔ gece,
pembe ↔ koyu pembe): videodaki koyu bordo kare bu. Durum artık renkten de
okunuyor. Arka plan, videodaki eğik uzun bloklardır (`arka_0..2`, üç katman,
%7–18 opaklık, x'te 320 px periyodik — ParallaxLayer aynalama kuralı,
CLAUDE.md tuzak 21).

## 2. Ekranlar

| Ekran | Sahne | İçerik |
|---|---|---|
| **Başlangıç** | `menu.tscn` | Büyük `OYNA` (birincil, ilk odak), tek satır "A / D ile yürü · BOŞLUK yerçekimini çevirir", altında Bölüm Seç · Günün Bölümü · Ayarlar (· Çıkış yalnız masaüstü). Köşelerde mono etiketler, dil düğmesi (TR/EN). Zemin: eğik bloklar + kırmızı dikenler. |
| **Oyun içi HUD** | `oyun.tscn` | Yalnız gerekli: sol üst `01 / İLK ADIM ◆ 14 / 20`, sağ üst `SÜRE 2.75 · ÖLÜM 1 · ÇEVİRME 1 · ODA 01 / 20`. Etiketler blok renginde küçük sekmede, yazı zemin renginde (tavan bloğuyla birleşir, delikte kendini gösterir). Tavanda yürüyünce sekme solar. İpucu tek satır, ilk 3 bölümde. |
| **Duraklatma** | `oyun.tscn` | Perde + koyu kart: **Devam** (birincil) · Bölümü baştan · (Atla, yardım modunda) · Ayarlar · Menü. `Esc`/`P`; ilk odak Devam. |
| **Bölüm sonu** | `oyun.tscn` | Kâğıt kart: `ODA 08 / 20 TAMAM`, büyük süre, "Altın madalya · YENİ REKOR", "En iyi 2.67 sn · 0 çevirme". Ölüm olduysa altında ölüm haritası kartı. Otomatik geçiş süresi değişmedi (1,0 / 2,4 sn). |
| **Oyun sonu** | `oyun.tscn` | Perde + kart: toplam süre, ölüm, kristal, madalya, en az çevirme; **Tekrar oyna** (birincil, ilk odak) · Menüye dön. Günün bölümünde ayrıca Paylaşım Metnini Kopyala. |
| **Ayarlar** | `ayarlar_ekrani.tscn` | İki sütun; **Dil** satırı en üstte, sonra müzik/efekt (kaydırıcı + anahtar), tam ekran, oyun hissi, yüksek kontrast, yerçekimi oku, iniş göstergesi; sağda hayalet, yardım modu, dokunmatik. |
| **Bölüm Seç** | `bolum_sec.tscn` | Izgara (numara, süre, madalya, kristal) ve Süre Listesi aynı dilde. |

### Önce / sonra

| Önce (v0.7.2) | Sonra (v1.0) |
|---|---|
| ![](tasarim/once-menu.png) | ![](tasarim/sonra-menu.png) |
| ![](tasarim/once-oyun.png) | ![](tasarim/sonra-oyun-gece.png) |
| ![](tasarim/once-ayarlar.png) | ![](tasarim/sonra-ayarlar.png) |
| ![](tasarim/once-bolum-sec.png) | ![](tasarim/sonra-bolum-sec.png) |

Üç tema (kâğıt · gece · pembe kâğıt):

![kâğıt](tasarim/sonra-oyun-kagit.png)
![gece](tasarim/sonra-oyun-gece.png)
![pembe](tasarim/sonra-oyun-pembe.png)

İngilizce (tarayıcı dili Türkçe değilse varsayılan):

![menü](tasarim/sonra-menu-en.png)
![duraklat](tasarim/sonra-duraklat-en.png)
![bölüm sonu](tasarim/sonra-bolum-sonu-en.png)

## 3. Uygulama

- **Tema**: `assets/tema.tres`, `gui/theme/custom` olarak bağlı; `tools/tema_uret.gd`
  üretiyor (`godot --headless --path . -s res://tools/tema_uret.gd`, sonra
  `--import`). Tür varyasyonları: `Baslik`, `Baslik2`, `Etiket`, `EtiketKalin`,
  `KartBaslik/KartYazi/KartEtiket`, `Birincil` (düğme), `Kucuk` (hücre/satır),
  `Perde`, `Rozet`, `Kagit` (panel).
- **Renkler**: `scripts/tema.gd` (`Tema`): üç tema, bölüm→tema eşlemesi (müzik
  gruplarıyla aynı: 1–7 kâğıt, 8–14 gece, 15–20 pembe), `renkler(tema, ters)`.
- **Dünya çizimi**: bloklar ve dikenler PNG değil, `Bolum._draw` içinde vektör
  (`draw_rect`, `draw_colored_polygon`); tema rengine boyanır, her ölçekte
  keskin. Sprite'lar (oyuncu, kapı, kristal, platform, bayrak, kilit, madalya)
  hâlâ `tools/uret_sprite.py` ile kodla üretiliyor, artık düz renk ve 4×4 alt
  örneklemeli kenar. Eski karo/diken/tek-yönlü dosyaları
  `_eski/sprites-v0.9/` altında.
- **Sahne geçişi**: `scripts/gecis.gd` (autoload `Gecis`) + `assets/gecis.gdshader`; sekiz
  geçiş ailesi, tema paleti, hareket azaltmada anında (bkz. bölüm 7).
- **Menü animasyonu**: `scripts/ui.gd` (`UI.sirayla_gir`, `UI.dugmeleri_bagla`).
- **TR/EN**: `scripts/ceviri.gd`. Kaynak dil Türkçe: `tr("Türkçe metin")` ya da
  sahnedeki metnin kendisi anahtar; İngilizce tablo `Ceviri.EN`. Varsayılan dil
  `OS.get_locale_language()` (web'de `navigator.language`): `tr` → Türkçe,
  değilse İngilizce. Ayarlar'da ve menüde dil anahtarı; seçim `user://kayit.cfg`
  içinde **yeni** `ayar/dil` anahtarı olarak durur, eski kayıt ve ilerleme
  anahtarları (`ilerleme/acilan`, `en_iyi`, `madalya`, `kristal`, `en_az`) aynen.
  Bölüm adları, ipuçları, madalya adları, dokunma metinleri çevrildi;
  `_ceviri_testi` her anahtarın belirteç dizisini (`%d %s %.2f`), her bölüm
  adı/ipucunun ve sahnelerdeki her durağan metnin çevirisini denetliyor.
- **Dikey telefon**: pencere dikeyse 4 sn "cihazını yatay çevir" kartı
  (`Gecis`).

## 4. Oynanış hissi — neden, ne ölçüldü

| Değişiklik | Neden | Ölçü |
|---|---|---|
| Çevirme, tuş olayı geldiği anda uygulanır (`oyuncu.gd _input`); fizik adımı beklenmez. Dokunma alanları da artık gerçek olay yolluyor (`Input.parse_input_event`). | Ses, renk geçişi, parçacık ve sarsıntı fizik adımına (60 Hz) bağlıydı. Fizik zaman çizelgesi aynı kalır: hız şimdi atanır, konum sonraki adımda ilerler. Bot ve testler `Input.action_press` ile bastığı için bu yola girmez: **çözülebilirlik ölçümü ve rota_verisi aynı**. | `tools/his_olc.gd`, 100 deneme, tuş olayı → `cevirdi`: **ortalama 13,0 → 6,8 ms, %95 20,6 → 6,9 ms, en yüksek 30,5 → 7,0 ms** (kalan ~7 ms olay dağıtımının ölçüm tabanı). |
| Cevirme patlaması: kalkış yüzeyinden odaya 12 camgöbeği kırıntı. | Çevirme anı tek başına ses ve renk geçişiydi; parçacık "bedava" (Intel UHD: 4000 GPU parçacığı 0,42 ms). | `tools/fps.gd` aşağıda. |
| İlk 3 bölümde tek satır ipucu (mevcut) korundu; 1. bölümün ipucu "Sarı kapıya ulaş"a, menü satırı çevirmeyi de anlatacak biçimde ("A / D ile yürü · BOŞLUK yerçekimini çevirir") yeniden yazıldı. | Denetim: "Tek tuş" iki girdi istiyordu. | Menü ve ilk bölüm metni; `_dokunma_metni_testi`, `_menu_akisi_testi`. |
| Bölüm sonu kartı, bitiş kartı (Tekrar oyna), oyun sonu ilk odağı TEKRAR. | Denetim: bölüm sonu görünmezdi, tekrar için menüye dönmek gerekiyordu. | `_bolum_sonu_testi`. |

**Değişmeyenler (bilerek).** Giriş tamponu 0,10 sn ve kojot 0,08 sn korundu:
ikisi de platform oyunlarında yaygın aralıkta (0,08–0,15 sn) ve
`_kojot_testi`/`_cevirme_testi` bunları sınıyor; bot ölçümü bu değerlerle
yapılmıştı. Değişirse `rota_verisi.gd` ve madalya eşikleri yeniden ölçülür.
`--fixed-fps` dışında insan denemesi bu oturumda yapılmadı; **gerçek insan
elinde his** bu belgedeki ölçümlerin kanıtlayamadığı şeydir.

**Yerçekimi renk geçişi bir kare "gri" üretir.** Zemin ve blok yer değiştirirken
ikisi bir an aynı parlaklığa gelir. Kâğıt temasında düşük kontrast penceresi
(|Δparlaklık| < 0,12), 250 ms ease-out geçişte hesapla ≈17 ms (bir kare);
tehlike (kırmızı) ve oyuncu (mavi) bu sırada da ayırt edilir. Bu, ölçülmüş
bir değil hesaplanmış bir değerdir; kayıt karelerinde geçiş gri kare olarak
görünüyor.

## 5. Performans ve boyut (önce / sonra)

Ölçüm: `tools/fps.gd` (gerçek render, Intel UHD, vsync kapalı, 90 kare ısınma +
600 kare, çevirme tuşu 0,7 sn'de bir); web paketi `build/web`.

| | Önce (v0.7.2) | Sonra (v1.0) |
|---|---|---|
| Kare süresi, 10. bölüm | ort. 2,67 ms, %99 3,67 ms (≈375 FPS) | ort. 2,83 ms, %99 6,16 ms (≈353 FPS) |
| Kare süresi, 20. bölüm | ort. 2,87 ms, %99 4,16 ms (≈349 FPS) | ort. 3,41 ms, %99 7,99 ms (≈294 FPS) |
| `index.pck` | 830.812 bayt | 1.077.440 bayt (+246.628; dört yazı tipi) |
| `index.wasm` | 39.514.754 bayt | 39.514.754 bayt (motor, aynı) |
| `index.js` | 279.815 bayt | 279.815 bayt |
| Toplam (pck+wasm+js) | 40.625.381 bayt | 40.872.009 bayt (+%0,6) |

Hedef 60 FPS; ölçülen sayılar vsync kapalıyken sınırsız FPS'tir, yani 60'ın
çok üstünde. Tek koşu, tekrarlar arasında ±%15 oynama var (aynı yapıda 10. bölüm
bir koşuda 3,23, ötekinde 2,83 ms çıktı). Ortalama kare süresi %6–19 arttı,
%99 kare süresi yaklaşık ikiye katlandı (çevirme parçacığı, renk geçişi ve
vektör çizim); en kötü %1'lik kare bile 16,7 ms bütçenin yarısının altında.

## 6. Bilinen sınırlar

- Dikey telefonda oyun 16:9 şerit olarak kalır (oda kamerası kararı); yalnız
  yatay tutma uyarısı eklendi.
- Ekran görüntülerindeki ölçüm ve tarayıcı denetimi masaüstü Chromium'dadır;
  gerçek telefon, Safari ve Firefox denenmedi.
- Yeni yapıda yerel web denemesinde konsola iki çift WebGL uyarısı
  (`bindBuffer`/`bufferSubData: no buffer`, bir kez açılışta) düşüyor; hata
  değil, görüntü etkilenmiyor. Vektör poligon çiziminden geliyor olabilir;
  kaynağı doğrulanmadı.
- Ödül rengi (`#ffc21a`) hem kapı hem kristal için kullanılıyor; ikisi şekilden
  ayrılıyor (uzun sarı çubuk / küçük elmas), renk tek başına yetmez.

## 7. Günlük video imkânlarından alınanlar

Ek istek (29 Eylül 2026): günlük videolarda kullanılan renk ve geçiş imkânları
oyuna da girdi. **Oyunun kendi kimliği ağır bastı:** tanıtım videosundaki düz
renk dünya (üç tema, tehlike `#e94f36`, oyuncu `#4585bd`) **değişmedi**; akış
paletleri ve geçişler yalnız geçişlerde, sayaç chip'inde ve rekor damgasında.

**Kaynaklar:** `sosyal/uret/tema.mjs` → `TEMALAR` (palet: `akis.vurgular`,
`yazilar`; geçiş aileleri: `gecis`), `sosyal/uret/sahne.js` → `GECIS` (her ailenin
hareketi), `tema.mjs` → `ESIK` (okunurluk kuralı). Canlı örnek olarak
`videolar/*/_yapim/kontak-*.jpg` bakıldı.

| Oyun teması | Video teması (palet + geçiş havuzu) | Vurgu renkleri (sırayla döner) | Geçiş havuzu |
|---|---|---|---|
| Gece (bölüm 8–14) | **klasik** (siyah/krem/sarı) | `#ffc21a #19d3e6 #ff7a1a #ff4d6d #f1ece2` | glitch, flaş, itme, bloklar (klasik `gergin`/`enerjik`) |
| Pembe kâğıt (15–20) | **limon** (doygun limon/eflatun akış) | `#c2006b #3a1cff #0b1f6b #0b5d1e` | bloklar, zoom, perde, iris (limon + klasik zoom + neon iris) |
| Kâğıt (1–7) | **kâğıt** (risograf mürekkepleri) | `#c1121f #1f45c9 #13632f #6a1b9a #9a3a00` | perde, itme, kararma, zoom (kâğıt `perde/yatay/kararma` + klasik `sakin` zoom) |

Neden bu üçü: oyunun üç teması zaten bir koyu, bir pembe-açık, bir krem kâğıt;
klasik koyu zeminle, limon pembe kâğıtla, kâğıt teması krem kâğıtla aynı ruhu
taşıyor. Diğer altı tema (neon, arcade, fosfor, harita, poster, uzay) **alınmadı**:
neon/arcade/fosfor koyu-doygun zeminleri düz renk dünyayı boğardı. Yalnız menü
açılışı ve oyun sonu için neon/uzay ailesinin **iris**'i alındı.

**Geçiş aileleri** (hepsi tek `canvas_item` shader'ı, GL Compatibility'de çalışır;
`p` 0→1 örtme, 1→0 açma; ekran dokusu yalnız glitch ve zoom'da okunur):

| Aile | Video karşılığı (`sahne.js`) | Godot'ta |
|---|---|---|
| iris | `iris` (ortadan büyüyen daire) | daire maskesi, kenarında ikinci renk halka |
| glitch | `glitch` (x kayması + skew) | 28 yatay dilim 30 Hz'de kayar, RGB ayrışır, dilimler palet rengine döner |
| bloklar | `bloklar` (renkli şeritler) | 12×7 kare ızgara, kareler rastgele gecikmeyle ortadan büyür |
| itme | `itme`/`yatay` | eğik bant soldan girer, önünde ikinci renk şerit |
| perde | `perde` (eğik perde + şerit) | eğik kenar, önünde şerit |
| flaş | `flas` | tek vuruş, açık renk |
| kararma | `kararma` | koyu renge alfa |
| zoom | `zoom` | ekran dokusu büyür ve renge erir |

`kes` (video: geçişsiz kesme) ayrı aile değil; hareket azaltma zaten bunu yapıyor.
Ortme 260 ms (ease-out cubic), açma 200 ms (ease-in cubic): stil rehberi süreleri.
Tür seçimi videodaki `gecisHavuz` gibi: havuzu sırayla gezer, art arda tekrar
yok (`Gecis.sec`); renk çifti (`renk`, `renk2`) paletten iki kaydırmalı alınır.

**Kullanım yerleri**

| Yer | Ne oluyor |
|---|---|
| Menü açılışı | İlk açılışta iris ortadan açılır (`Gecis.acilis`); geri dönüşlerde sahne geçişinin kendi açması yeter |
| Sahne geçişleri (menü/ayar/bölüm seç/oyun) | Menü ailesi (gece paleti) ya da çıkılan bölümün teması; havuzdan sıradaki aile |
| Bölüm geçişi | `Gecis.kapat` → `bolum_yukle` → `Gecis.ac` (await yok: oyun açılırken başlar). Eski `Karartma` bandı ve `_karart` silindi, tek uygulama |
| Bölüm sonu | Tek flaş vuruşu (en çok %50 alfa) + kart girişi; **yeni rekorda** kartın köşesine palet renginde dönen "YENİ REKOR" damgası (90 ms adım, sonra ilk renkte durur, 1,5 ölçekten oturur: rehberdeki damga istisnası) |
| Oyun sonu | Bitiş kartı iris ile ortadan açılır |
| Süre/skor sayacı | Her çevirmede ve kristalde sağ chip bir palet rengine **adımla** döner (ara renk yok), 0,30 sn sonra blok rengine döner; en çok ~3 renk değişimi/sn |
| Duraklatma | Perde ailesi kart üstünden açılır (oyun durmuşken de çalışır: `Gecis` `PROCESS_MODE_ALWAYS`) |
| Dil değişimi | Menü ve Ayarlar'da glitch örtüsünün altında metin/sahne yenilenir (`Gecis.ara`) |

**Okunurluk.** Yazı rengi vurgunun üzerinde kodla seçilir (`Tema.yazi_rengi`:
açık ya da koyu, hangisi daha yüksek kontrastlıysa). Ara renk üretilmez (mürekkep
ile krem arasındaki orta tonlarda kontrast 4,06'ya düşer), bu yüzden palet adım
adım döner. Ölçülen en düşük çift **5,89:1**; eşik **4,5:1** (WCAG AA metin;
videodaki 5:1'in biraz altında, çünkü burada doku/vinyet payı yok). Test tüm paletleri doğruluyor.

**Hareket azaltma.** Ayarlar'daki "oyun hissi" kapalıysa **ya da** tarayıcıda
`prefers-reduced-motion: reduce` varsa (`JavaScriptBridge`, yalnız web) geçişler
**anında**: shader hiç açılmaz, bekleme yok, sayaç vurgusu ve damga animasyonu
kapalı. Yüksek kontrast açıkken sayaç vurgusu da kapalı. Kayıtlı ayara
dokunulmaz.

**Performans (Intel UHD, `tools/fps.gd`, vsync kapalı, 10. bölüm, 600 kare):**

| | Önce (geçişsiz, renk bandı) | Sonra |
|---|---|---|
| Oynanış karesi | ort. 2,35 / 2,27 ms, %99 5,23 / 5,06 ms (iki koşu) | ort. 2,56 / 2,33 ms, %99 5,87 / 5,87 ms (iki koşu) |
| Geçiş süren kareler (`fps.gd ... gecis`, 16 geçiş, 8 aile x 3 tema) | yok (bant ~ aynı) | ort. 3,63 ms (≈276 FPS), %99 7,92 ms, **tek en kötü kare 135 ms** |
| `index.pck` | 1.077.440 bayt | 1.085.440 bayt (+8.000: shader) |

Oynanış karesi fark yok (koşular arası ±%10). Geçiş karelerinde bile 16,7 ms
bütçenin çok altı; **tek istisna ilk kullanımdaki shader derlemesi** (135 ms,
yalnız ilk geçiş karesi): menü açılışı bu maliyeti oyuna girmeden, örtünün
altında ödüyor. Bölüm yükleme süresi değişmedi: bölüm geçişi artık `await
Gecis.kapat` (260 ms) ve `Gecis.ac`; önceki `create_timer(0.26)` ile aynı sürede,
hareket azaltmada bekleme sıfır. Ölçüm ortamında başka Godot süreçleri de
çalışıyordu (sayılar bu yüzden ±).

**Test.** `_gecis_testi`: palet okunurluğu, havuz/tekrar, shader uniform'ları,
her ailenin örtüp açması, süre, `ara`, hareket azaltma, sayaç vurgusu, duraklat
perdesi, rekor damgası (963 doğrulama, 48 yeni). Kanıt kareleri:
`kanit/yercekimi-cevir/sonra/19-…35-*.png` (`tests/ekran.tscn -- -10`).
