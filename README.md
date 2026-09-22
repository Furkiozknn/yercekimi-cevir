# Yerçekimi Çevir

*No jump button — one key flips gravity and you fall onto the ceiling. 20 hand-built precision platformer rooms (Godot 4, Turkish UI), each one or two screens, with no-flip zones and one-way platforms introduced as separate ideas. 841 headless checks.*

[![CI](https://github.com/Furkiozknn/yercekimi-cevir/actions/workflows/ci.yml/badge.svg)](https://github.com/Furkiozknn/yercekimi-cevir/actions/workflows/ci.yml)

Zıplama yok: tek tuşla yerçekimini ters çevirip tavana "düşerek" dikenlerden kaçtığın
kısa ve zor bir hassas platform oyunu. **20 bölüm**, her bölüm 1–2 ekran.

![Ana menü](docs/01-menu.png)
![Çevirme anı](yayin/ekran/07-cevirme.png)

## Kontroller

| Eylem | Klavye | Gamepad | Dokunmatik |
|---|---|---|---|
| Yürü | `A` / `D` ya da ok tuşları | sol çubuk / D-pad | ekranın sol yarısı |
| **Çevir** | `Boşluk` ya da `W` | `A` | ekranın sağ yarısı |
| Duraklat | `Esc` | `Start` | — |

Çevirme **yalnızca bir yüzeye değerken** çalışır — havada ikinci kez çeviremezsin.
İki yönlü affetme var: yüzeye değmeden ~0,1 sn önce bastıysan sayılır (giriş
tamponu) ve yüzeyden ayrıldıktan sonra da ~0,08 sn hakkın sürer (kojot çevirme).
"Bir kare geç bastım" ölümü bu yüzden yok.

Dokunmatikte küçük düğme aramazsın: ekranın sol yarısı hareket (sol çeyrek sol,
sağ çeyrek sağ), sağ yarısı çevirme. Solak seçeneği tarafları değiştirir —
alan harfleri **ve** ekrandaki ipucu metni de onunla birlikte taraf değiştirir;
düğme opaklığı ve titreşim ayarlardan.

Diken ya da ekran dışına düşmek öldürür; ölünce **0,18 sn** sonra otomatik olarak
bölüm başına — ya da geçtiysen **kontrol noktasına** — dönersin. Sahne yeniden
yüklenmez, hareketli platformlar dahil her şey sıfırlanır. Süre sayacı ölümlerle
sıfırlanmaz, bölüm değişince sıfırlanır.

## Bölümde ne var

- **Gizli kristal** (her bölümde 1). Her zaman ana rotanın dışında: genelde tavanda,
  zeminde yürürken kaçamak yapman gereken bir yerde. Toplanınca kalıcı kaydedilir.
- **Madalya süreleri.** Her bölümün altın / gümüş / bronz hedefi var; arayüzün sağ
  üstünde yazıyor, en iyi madalyan Bölüm Seç'te görünüyor. Hedefler **formülden
  değil ölçümden**: bir bot 20 bölümün hepsini gerçek fizikte, bölüm başına
  5 kez oynuyor (her karara 0,05–0,20 sn tepki gecikmesiyle) ve eşikler o
  koşuların ortancasından çıkıyor. Çarpanlar (altın ×1,35, gümüş ×1,75,
  bronz ×2,40) aynı botun **insan tepki bandında** (0,18–0,35 sn) yeniden
  koşturulmasıyla gerekçeli: altın, insan tepkisiyle ölümsüz doğru hattın süresi.
- **Kontrol noktası.** 64 sütunluk uzun bölümlerin ortasında bir mavi direk;
  ona değdikten sonra ölünce oraya dönersin.
- **"En az çevirme" ikinci hedefi.** Süreden bağımsız: her bölümün kaç çevirmeyle
  çözülebileceği **ölçülmüş** (botun gerçekten bitirdiği en az çevirme sayısı),
  senin en iyi çevirme sayın kaydediliyor. Hızlı bitirmek ve az çevirmek iki ayrı oyun.
- **Hayalet yarış.** O bölümdeki en iyi koşun yarı saydam olarak yanında koşar;
  rengi o koşunun madalyası — altın koşu altın hayalet.
- **Altın hayalet.** Botun ölçülmüş en iyi koşusu ayrı bir yarış hedefi olarak
  koşar. Kendi hayaletinle karışmasın diye ikisi de etiketli ("sen" / "altın") —
  renk yetmiyor, çünkü altın madalyan varsa senin hayaletin de altın renkte olur.
  Ayarlardan kapatılır.
- **Ölüm haritası.** Bölüm bitince bölümün küçültülmüş planı ve öldüğün her nokta
  X ile. "Burada takılıyorsun" demenin en kısa yolu.
- **Günün bölümü.** Ana menüden: tarihten seçilen bir bölüm + küçük bir
  değiştirici — **ters başlangıç** (tavandan doğarsın; kontrol noktasından
  dönüş normal), **kristal zorunlu** (kapı kristal alınmadan açılmaz;
  kristal ana oyunda toplanmış olsa da o gün yeniden yerinde) ya da
  **hayalet yarışı** (botun ölçülmüş altın hayaleti rakiptir; kapı yalnız
  ondan önce varılınca sayılır, geç kalırsan "hayalet kazandı" ve bölüm
  baştan). Aynı gün herkes aynı bölümü oynar. Kaydı **ayrı**: günün en iyi
  süresi menüde yazar, gün değişince sıfırlanır; madalya, hayalet, kristal
  sayacı ve açılan bölüm **değişmez**. Kendi hayaletin günlük modda kapalı
  (normal başlangıcın kaydı, ters başlangıçta yalan söyler).
- **Seri ve paylaşım.** Günün bölümünü ardışık günlerde bitirirsen seri büyür
  ("seri 3 gün" menüde yazar); bir gün atlarsan sonraki bitiş 1'den başlatır.
  Bitişte açılan panel bölüm adı, değiştirici, süre, ölüm, çevirme ve seriyi
  üç satırlık bir metin olarak gösterir; **Paylaşım Metnini Kopyala** panoya
  alır (web'de de çalışır — kopyalama bir düğmeye bağlı, çünkü tarayıcı panoya
  yazmayı yalnız kullanıcı dokunuşunda kabul eder).
- **Bölüm grubu müziği.** 1–7 sakin, 8–14 gergin, 15–20 hızlı; üçü de
  `tools/muzik_uret.gd` ile üretilmiş döngüler, menü müziği ayrı. Grup
  değişmediyse parça bölüm geçişinde kesilmez.
- **Kapı ve kristal parıldar.** Dört kareli sayfalar (`tools/uret_sprite.py`),
  0,15 sn'de bir kare; HUD ve menüdeki kristal simgesi tek kare kalır.
- **Çevirme yasağı bölgesi** (v0.7). Yüzeye bitişik, kesik çizgili turuncu kutu ve
  ortasında kilit: içindeyken yerçekimi çevrilemez, basılan tuş yutulur (bölgeden
  çıkınca "kendiliğinden" çevirme olmaz), üstte **ÇEVİRME KİLİTLİ** rozeti ve kısa
  kilit sesi. Bölge yalnız kendi yüzeyini bağlar: zemindeki kutunun üstünde tavanda
  yürüyen serbesttir. 9 — Salıncak'ta dikenin hemen önünde (kararı kutuya girmeden
  vermelisin), 16 — Kılçık'ta tavanda (altındaki dikeni geçerken inemezsin) ve
  zeminde. Üreteç kuralı: bölgenin yüzeyinde ölümcül engel olamaz.
- **Tek yönlü platform** (v0.7). Oklu gri karo: oklar hangi yöne bakıyorsa o yönde
  içinden geçilir, öbür yandan gelince tutar. `_` üstüne inilir (yerçekimi aşağı),
  alttan geçilir; `~` altına inilir (yerçekimi yukarı), üstten geçilir. Katı yüz
  sabittir, yerçekimiyle dönmez — aynı platform iki yerçekiminde farklı davranır.
  14 — Boşluk Üstü'nde altında delik, üstünde tavan dikeni olan bir `~` köprü (tek
  yol platformun altında yürümek, sonra zemine çevirmek); 20 — Son Kapı'nın son
  deliğinde `_` (tavandan düşüp üstüne inersin, kapıya yürürsün). İniş göstergesi ve
  bot ikisini de görür.
- **Bölüm başı tabelası** (v0.7). Bölüm yüklenince 1,2 sn "N — Ad · altın X sn ·
  en iyi Y sn" kartı; ilk girdiyle kapanır, süre sayacı durmaz.
- **Süre listesi** (v0.7). Bölüm Seç'te **Süre Listesi** düğmesi 20 bölümü iki
  sütunlu listeye çevirir: ad, en iyi süren, madalyan, altın hedefi. Menüde toplam
  madalya sayısı.
- **Bitiş özeti.** 20. bölüm bitince oyun toplamı tek ekranda: toplam süre,
  toplam ölüm, kristal, madalya kazanılan bölüm ve en az çevirmeyle biten bölüm
  sayısı; ayrı bir bitiş parçası çalar.

## Okunurluk ve yardım

- **Oda tabanlı kamera.** Kamera seni izlemez, 640 px'lik odalar arasında atlar.
  Bir odadaki tehlikenin tamamı hep ekrandadır; ekran dışından gelen ölüm yok.
- **Üst HUD şeritleri solar.** Tavanda yürürken sen (ya da bir hayalet) üst
  şeridin dikdörtgenine girince o şerit yazılarıyla birlikte 0,15 sn'de
  %25 opaklığa iner, çıkınca geri gelir; girdiye dokunmaz.
- **Yerçekimi oku.** Yanındaki küçük ok hangi yöne çekildiğini gösterir —
  durum renkten değil biçimden okunur.
- **İniş göstergesi.** Çevirme tuşunu basılı tutarsan karşı yüzeyde nereye ineceğin
  işaretlenir; yolda diken varsa işaret kırmızıya döner. **Hareketli platformları
  ve gezen dikenleri sayar** ve onları geçiş süresi kadar ileri sarar: geçiş
  ~0,9 sn sürüyor, o sürede platform 42 px yol alıyor, yani "şu an altımda"
  ile "indiğimde orada olacak" aynı şey değil.
- **Yüksek kontrast** seçeneği tehlikeleri parlatır, zemini ve arka planı geri çeker.
- **Yardım modu.** Oyun hızı %50–100, dikenler öldürmek yerine iter, duraklatma
  menüsünden bölüm atlanır. Açıkken süre, madalya ve çevirme kaydı tutulmaz;
  kristaller sayılır. İstediğin an kapatılır.

## Lisanslar

Kod ve varlıklar [MIT](LICENSE) altında — Furki Özkan, 2026; görseller, sesler
ve müzik depodaki üreteclerle koddan üretilir. `assets/fonts/simgeler.ttf` ("Oyun Simgeleri")
DejaVu Sans Bold'un 32 simgelik alt kümesidir; Bitstream Vera lisansı altında
dağıtılır, bildirim `assets/fonts/LISANS-simgeler.txt` dosyasındadır.

## Ekranlar

| | |
|---|---|
| ![Bölüm Seç](docs/02-bolum-sec.png) | ![Ayarlar](docs/03-ayarlar.png) |

## Nasıl çalıştırılır

```bash
godot --path .                                        # oyunu aç
godot --headless --path . res://tests/testler.tscn    # otomatik testler (çıkış kodu 0 = geçti)
godot --path . res://tests/ekran.tscn -- 2 <klasör>   # 3. bölümü sürüp ekran görüntüsü al
godot --path . res://tests/ekran.tscn -- -1 <klasör>  # menü / bölüm seç / ayarlar
godot --path . res://tests/ekran.tscn -- -2 <klasör>  # yayın paketi görselleri + kapak
godot --path . res://tests/ekran.tscn -- -3 <klasör>  # tur 2 özelliklerinin denetim kareleri
godot --path . res://tests/ekran.tscn -- -7 <klasör>  # tur 5 (v0.6): HUD solması, hayalet yarışı, paylaşım, parıltı
godot --path . res://tests/ekran.tscn -- -8 <klasör>  # tur 6 (v0.7): yasak bölge, tek yönlü platform, tabela, süre listesi

python arac/uret_bolumler.py     # 20 bölümü yeniden üret (çözülebilirliği doğrular)
python tools/uret_sprite.py      # tüm pixel art'ı yeniden üret
python tools/uret_ses.py         # tüm ses efektlerini yeniden üret
```

Dışa aktarma çıktısı `build/windows/yercekimi-cevir.exe` ve
`build/web/index.html` yollarına yazılır — **yapı dosyaları depoda yok**
(`.gitignore`), önce klasörleri oluşturup dışa aktarman gerekir:

```bash
mkdir -p build/windows build/web
godot --headless --path . --export-release "Windows Masaustu"
godot --headless --path . --export-release "Web (HTML5)"
```

Yayın paketi (yüklenmedi): `yayin/`.

## Kod düzeni

| Dosya | İş |
|---|---|
| `scripts/ayarlar.gd` | **Tüm denge sabitleri** + ilerleme kaydı + oyuncu ayarları. Ayar yapacaksan tek durak. |
| `scripts/ses.gd` | Efekt havuzu ve müzik (autoload); bölüm grubuna göre parça seçimi. Ses düzeyi AudioServer veriyolunda. |
| `scripts/bolumler.gd` | 20 bölüm, ASCII harita olarak. `arac/uret_bolumler.py` üretir. |
| `scripts/bolum.gd` | ASCII haritayı çalışma anında çarpışma gövdesi + pixel art çizime çevirir. |
| `scripts/oyuncu.gd` | Çevirme mekaniği (tampon + kojot), yerçekimi oku, ölüm, esneme-sıkışma. |
| `scripts/oyun.gd` | Bölüm döngüsü, oda kamerası, hayalet, ölüm haritası, iniş göstergesi, yardım modu. |
| `tools/` | Varlık üreticileri (pixel art, ses) + `sesler.md`. |
| `tests/` | Headless otomatik test (841 doğrulama) + ekran görüntüsü aracı. |

Bölüm haritaları TileMapLayer yerine ASCII + kod üretimi: 20 bölüm tek dosyada
düzenlenebiliyor ve `arac/uret_bolumler.py` üretim sırasında her bölümün
çözülebilirliğini doğruluyor — çevirme penceresi yeterince geniş mi, aynı sütunda
hem zemin hem tavan tehlikesi var mı, kristal kaçamağı ölümcül mü.

## 1. turda verilen kararlar (v0.2 — ilk yayına hazır sürüm)

- **Zorluk:** prototip raporunda 9–12 arası "insan için fazla zor olabilir" dendi.
  Bölüm sayısı 20'ye çıkarıldı ve araya kolay bölümler serpiştirilmek yerine
  **eğri baştan kuruldu**: her yeni öğe (çevirme, tavan yürüyüşü, zemin dikeni,
  tavan dikeni, hareketli platform, gezgin diken) önce tek başına ve güvenli bir
  bölümde tanıtılıyor. Kapı çarpışma kutusu da büyütüldü (tam hücre genişliği,
  3 hücre boy) — yukarıdan inen oyuncu kapıyı ıskalamıyor.
- **Madalya süreleri elle değil geometriden:** yol uzunluğu / yürüme hızı + bant
  başına bir çevirme bedeli. Bölüm değişince süreler kendiliğinden güncelleniyor,
  20 bölüm elle ayarlanmıyor. **Bu karar v0.4'te değişti:** eşikler artık
  ölçülmüş bot koşusundan geliyor (`scripts/rota_verisi.gd`, 20 bölümün 20'sinde
  `"tahmin": false`) — bkz. "4. turda verilen kararlar".
- **Kristal yeri de otomatik:** ana rotanın dışında ve her tehlike bandından en az
  8 sütun uzakta — beceriksiz bir kaçamak ölümle bitmesin diye.
- **Pixel art kodla üretiliyor.** Bu makinede GUI çizim aracı ve Pillow yok;
  `tools/uret_sprite.py` saf Python'la (zlib + struct, 20 satırlık PNG yazıcı)
  üretiyor. Tek palet: Endesga 32.
- **Ses efektleri perde kaydırmayla çeşitlendirildi.** rFXGen v5.0'ın komut satırı
  ön ayarları deterministik — aynı ön ayar hep aynı dosyayı veriyor. 6 ön ayardan
  10 ayrı efekt çıkarmak için yeniden örnekleme kullanıldı (`tools/sesler.md`).
- **Oyun hissi kapatılabilir.** Sarsıntı, parçacık ve çevirme izi tek bir ayarla
  kapanıyor; rahatsız eden oyuncu mekaniği kaybetmeden kapatabilsin.

## 2. turda verilen kararlar (v0.3 — rakip analizinden)

Kaynak: ayrı bir rakip analizi çalışması, depoda değil (VVVVVV,
Gravity Guy, Gravity Duck, G-Switch 3, Celeste, Super Meat Boy incelemeleri).

- **Türün en sık şikâyeti "haksız ölüm".** Üç yerden aynı anda saldırıldı: kojot
  çevirme + giriş tamponu (zamanlama), öldürücü şeylerin isabet kutusunun
  görselden 3 px küçük olması (uzamsal), oda tabanlı kamera (görünürlük).
  Basılan platformda böyle bir pay **yok** — orada kutu görselle aynı olmalı,
  yoksa oyuncu havada duruyormuş gibi görünür.
- **Yardım modu Celeste'inki gibi kurgulandı**, çünkü şikâyet "zor" değil
  "bitiremiyorum". Açıkken bölüm yine açılır ve kristal yine sayılır; yalnız
  süre/madalya/çevirme kaydı tutulmaz. Metin suçlayıcı değil, ayar bir itiraf
  değil: "oyunu senin hızına uydurur ... istediğin an kapatabilirsin".
- **"En az çevirme" ikinci hedefi geometriden hesaplanıyor.** Her sütunun zorunlu
  yüzeyi çıkarılıp yüzey değişimleri sayılıyor. Hareketli platformlar sayılmıyor,
  gezen dikenler tehlike sayılıyor — ikisi de hedefi yukarı yuvarlar, yani hedef
  imkânsız olamaz. Ulaşılamayan bir hedef koymaktansa fazla cömert olsun.
- **Hayalet, ayrı bir "altın koşu" verisi değil, senin en iyi koşun.** Elde
  kaydedilmiş bir altın koşu yok; madalya süreleri formülden geliyor. Bu yüzden
  tek hayalet var ve rengi o koşunun madalyası. **Bu karar da v0.4'te değişti:**
  `scripts/altin_hayalet.gd` içinde 20 bölümün ölçülmüş altın koşusu duruyor ve
  ikinci bir hayalet olarak koşuyor (ayarlardan kapatılabilir).
- **İniş göstergesi tuşu basılı tutunca çıkar.** Çevirme tuşa BASINCA olduğu için
  "önce bak sonra çevir" mümkün değil; basılı tutmak "şimdi nereye iniyorum"
  sorusunu havadayken canlı yanıtlıyor.

## 3. turda verilen kararlar (v0.3.1 — web düzeltmesi)

- **Simgeler için ayrı bir yedek yazı tipi.** `⟳` ve `●` web yapısında kutu
  çıkıyordu: Godot'nun gömülü yazı tipinde yoklar, masaüstünde sistem yazı tipi
  örttüğü için Windows ekran görüntülerinde hiç görünmemişti. Simgeleri metinden
  atmak yerine 4 KB'lık bir DejaVu alt kümesi (`assets/fonts/simgeler.ttf`)
  yedek olarak eklendi; sayaç ve madalya satırı olduğu gibi kaldı.
- **Klavye metinleri dokunmatikte çevriliyor.** "A / D ile yürü" telefonda yalan.
  Bölüm ipuçları üretilen `bolumler.gd` içinde durduğu için metinler orada
  değiştirilmedi; `Ayarlar.kontrol_metni()` küçük bir terim tablosundan geçiriyor.
  Dokunmatik, cihaz bildirmese bile **ilk ekran dokunuşunda** açılır ve dokunma
  alanları o anda görünür olur.
- **Geniş telefonlardaki siyah şeritler kaldı** (`stretch/aspect=keep`).
  `expand` görüş alanını yatayda büyütür; oda tabanlı kamera 640 px'lik odalara
  kilitli olduğu için 40 sütunluk (= tam bir oda) bölümlerde bölümün dışındaki
  boşluk görünür, dokunma alanları da 640 px'e göre yerleştiği için sağda ölü
  şerit kalırdı. Siyah şerit, bölüm dışını göstermekten iyidir.

## 4. turda verilen kararlar (v0.4 — ölçüm turu)

- **Madalya eşikleri formülden ölçüme geçti.** Eski formül (`temel × 1,15 +
  bant × 0,45`) hiçbir koşuyla karşılaştırılmamıştı ve **ortalama 1,35 kat
  gevşekti**: 13. bölümde altın 11,1 sn diyordu, bot bölümü 7,28 sn'de
  bitiriyor. Artık `tools/bot.gd` 20 bölümü gerçek fizikte oynuyor ve eşikler
  ölçülen ortancadan geliyor (altın ×1,15, gümüş ×1,50, bronz ×2,00).
- **"En az çevirme" hedefleri ölçümle DOĞRULANDI, değişmedi.** 2. turun
  şüphesi ("gezen dikenler tehlike sayıldığı için hedef gerçek en iyiden
  yüksek olabilir") ölçümde çıkmadı: yalnız zorunda kaldığında çeviren bot
  20 bölümün 20'sinde de geometri hedefinin tam sayısını kullandı. Nedeni
  ölçülebilir — gezen diken 62 px/sn, oyuncu 125 px/sn; arkadan yetişmek
  çarpışmak demek, yani gezen diken gerçekten bir çevirmeyi zorunlu kılıyor.
- **Bu oyunda tepki süresi saniye değil PENCERE kaybettiriyor.** 5 koşunun
  yayılımı 20 bölümün 13'ünde %0,4'ün altında: çevirme yatay ilerlemeyi
  durdurmadığı için geç basmak süreyi uzatmıyor. Kaybettiğinde ise koşu
  tamamen değişiyor (18 ve 19. bölümde birer koşu 6 yerine 10 çevirme ve bir
  ölümle bitti). Ölçüm bu yüzden ortanca + "en iyinin 1,5 katından kötü koşu
  sayılmaz" kuralıyla yapılıyor.
- **Frenin bedeli ölçüldü: çevirme başına ~1,0–1,2 sn.** Tam hızda çevirirsen
  karşı yüzeye varana kadar ~7 hücre süzülürsün; bantlar 3 hücre arayla
  kurulduğu için dar pencerelerde hızı kesmek ZORUNLU ve neredeyse dik inersin.
  Madalya bandının anlamı bu: altın "gerektiği yerde fren, gerekmediği yerde
  hiç durma", gümüş "her çevirmeden önce dur" koşusu.
- **İniş göstergesi artık gövdeyle ve zamanla çalışıyor.** İki ayrı hata vardı:
  tehlike tek bir "ayak" noktasıyla aranıyordu (çevirdikten sonra o nokta baş
  oluyor, gövdenin geri kalanı dikenin içinden geçerken tahmin "temiz" diyordu),
  ve hareketli parçalar hiç sayılmıyordu.

## 5. turda verilen kararlar (v0.5 — solak, fırtına, günün bölümü, insan payı)

- **Solak ipucu metni tarafı söylüyor.** Dokunma alanları solak ayarıyla yer
  değiştiriyordu ama ipucu "Sol alttaki iki alanla yürü" sabitti. Metin artık
  `{h}`/`{c}` yer tutucularıyla tablodan geçiyor ve `kontrol_metni()` tarafı
  ayara göre dolduruyor. Alan harfleri (`<` `>` `ÇEVİR`) zaten alanla birlikte
  taşınıyordu; iki modun ekran görüntüsü `docs/tur4/01-02`.
- **19 — Fırtına yeniden kuruldu; kök neden bir üreteç kuralı eksikliğiydi.**
  Gezen dikenin menzili (32–38) tavan dikeniyle (34–39) üst üsteydi: o
  sütunlarda iki yüzey de öldürüyordu ve tek çözüm tam hızda süzülmekti —
  oyunun geri kalanının öğrettiği "dar yerde fren" refleksinin tersi. Üreteçteki
  3 hücrelik pencere kuralı bunu **yakalamıyordu**, çünkü gezen dikenler
  bant değil. Yeni kural (`arac/uret_bolumler.py` + `_gezgin_kacis_testi`):
  *gezen dikenin menzilindeki her sütunda karşı yüzey güvenli olmalı.* Kural
  **18 — Koridor'u da yakaladı** (gezgin 32–38, tavan dikeni 35–40); ikisi de
  aynı desenle düzeltildi: gezen diken tavanı temiz bir koridora alındı, tavan
  dikeni onun ardına kaydı. Bot yeni Fırtına'yı 5/5 koşuda ölümsüz bitiriyor
  (eski düzende 5 koşunun biri 14,85 sn'lik bir kazaydı); süresi 7,33 → 8,23 sn,
  yani bölüm **daha yavaş ama artık frenle geçiliyor**. Fırtına hissi (gezen
  diken + platformlu delik + 6 çevirme) korundu.
- **Günün bölümü ayrı bir mod, ayrı bir yuva.** Tarihten 32 bit karıştırıcıyla
  bölüm + değiştirici seçiliyor (Knuth çarpımsal karma denendi, ardışık günler
  bölümleri birer geriye sayıyordu). İki değiştirici: ters başlangıç (tavandan
  doğarsın; kontrol noktasından dönüş normal) ve kristal zorunlu (kapı kristal
  alınmadan açılmaz). Kayıt `[gunluk]` bölümünde: yalnız o günün en iyi süresi
  ve bitiş sayısı, gün değişince sıfırlanır. Ana ilerlemeye (madalya, en iyi,
  kristal, en az çevirme, hayalet, açılan bölüm) **hiç yazılmıyor** ve
  `_gunluk_testi` bunu her iki değiştiricide bitişe kadar oynayarak ölçüyor.
  Hayaletler günlük modda kapalı: normal başlangıcın kaydı, ters başlangıçta
  yanlış yolu gösterirler. Günlük mod açıkken duraklatmadaki "Bölümü Atla"
  gizli (ana ilerlemeyi açıyor).
- **Altın ×1,15 → ×1,35; gümüş ×1,50 → ×1,75; bronz ×2,00 → ×2,40.** Gerekçe
  ölçüm: aynı bot `insan` modunda (tepki 0,18–0,35 sn; basit görsel tepki
  süresinin insan bandı) koşturuldu. 20 bölümün 9'unda süre **hiç değişmedi**
  (tepki penceresi olan yerde yavaşlamak gerekmiyor), ortanca oran 1,02;
  ama 6, 7 ve 15'te gecikme bir zorunlu fren doğurdu ve süre %26–30 uzadı.
  ×1,15 ile insan bandındaki bot 3 bölümde altın **alamıyordu** — yani insan
  için ulaşılmaz altın vardı. ×1,35 ölçülen en kötü oranı (1,297) %4 payla
  örtüyor. Gümüş bir ölüm (ölüm ≈ 0,18 sn + geri yürüme ≈ +%55 kısa bölümde),
  bronz iki ölüm demek. Kanca'daki 1,45'ten düşük kaldı çünkü bu oyunda bot
  insanın yapamadığı bir hile bilmiyor; tek farkı tepki süresi ve onun bedeli
  ölçüldü.
- **İnsan bandında 20 — Son Kapı'yı bot 5 koşunun 1'inde bitirdi** (diğerleri
  90 sn tavanda bekledi, ölüm yok). Bölüm hatası değil, bot sınırı: son delikten
  (54–57) kapı önündeki 2 hücreye (58–59) inmesi gerekiyor; gecikmeyle kapıyı
  geçince "kapının ötesine inme" kuralı çevirmeyi yasaklıyor ve bot geri
  yürümeyi bilmiyor. İnsan geri yürür. Bölüm değiştirilmedi, yol haritasına
  yazıldı.

## 6. turda verilen kararlar (v0.6 — tavan HUD, seri, hayalet yarışı, müzik grupları, parıltı)

- **Şerit solar, oyuncu yer değiştirmez.** Tavandaki oyuncunun üst HUD
  şeridinin arkasında kalması için iki seçenek vardı: şeritleri daraltmak ya
  da oyuncu girince şeridi soldurmak. Daraltmak 640 px'te HUD metnini sığmaz
  hale getiriyordu (hedef satırı zaten bir kez kısaltılmıştı). Soldurma
  seçildi: şerit ve üzerindeki yazılar bir `Control` grubunda, grubun
  `modulate.a` değeri her karede oyuncu/hayalet dikdörtgeniyle kesişime göre
  0,25'e ya da 1,0'a doğru yürür (`Ayarlar.HUD_SOLUK`, `HUD_SOLMA_SURESI`).
  Kesişim ekran uzayında hesaplanıyor (`get_canvas_transform()`), yani oda
  kamerası ikinci odaya atlayınca da doğru.
- **Seri bir rekor değil, oynama alışkanlığı.** Bu yüzden yardım modunda da
  sayılıyor (süre kaydı orada tutulmuyor, seri tutuluyor) ve gün değişince
  sıfırlanmıyor — yalnız bir gün atlanınca kırılıyor. Tarih farkı gün
  sayısına çevrilerek bulunuyor (`Time.get_unix_time_from_datetime_dict`),
  ay ve yıl sınırlarında "dün" doğru çıkıyor; test 30 Eylül → 1 Ekim'i ölçüyor.
- **Paylaşım kopyalama düğmeye bağlı, otomatik değil.** Web'de pano yazımı
  yalnız kullanıcı hareketinden tetiklenince çalışıyor; bitişte kendiliğinden
  kopyalamak masaüstünde çalışır, tarayıcıda sessizce başarısız olurdu. Bu
  yüzden günün bölümü artık bitişte menüye dönmek yerine bir panel açıyor:
  metin görünür, altında **Paylaşım Metnini Kopyala** ve **Menüye Dön**.
  Metin simgesiz ("⟳" yerine "çevirme"): panoya giden metin başka
  uygulamaların yazı tipinde okunacak.
- **Hayalet yarışında altın hayalet ayara bakmaz.** Değiştiricinin özü rakip
  olduğu için `altin_hayalet` ayarı kapalı olsa da koşar. Bitiş ölçütü zaman:
  hayaletin kaydı bitince (ekrandan kaybolduğu kare) kapıya varmış sayılır;
  o andan sonra kapıya değmek sayılmaz, "HAYALET KAZANDI" gelir ve bölüm
  **baştan** yüklenir (süre, ölüm ve hayalet birlikte sıfırlanır — kontrol
  noktasından devam etmek hayaleti yakalanamaz kılardı).
- **Üç değiştirici eşit dağılıyor.** Aynı 32 bit karıştırıcı, `mod 3`:
  1 Eylül'den başlayan 90 takvim gününde 27 / 30 / 33. Test bunu gerçek
  tarihlerle (ay sınırları dahil) ölçüyor.
- **Müzik gruplara göre; eski tek parça `_eski/audio/` altında.** Üretecin
  hazır ruh hâlleri kullanıldı (sakin / gergin / hızlı), tohumlar
  `tools/sesler.md`'de. Menü parçası değişmedi. Parça seçimi `Ses.bolum_parcasi()`
  ile tek yerde; oyun sahnesi her bölüm başında onu çağırıyor, aynı parçaysa
  müzik kesilmiyor.
- **Parıltı tek sayaçla.** Kapı ve kristal `AnimatedSprite2D` değil `hframes=4`
  `Sprite2D`; `Bolum._process` tek sayaçtan kareyi seçiyor. Kapı artık `_draw`
  ile değil kendi düğümüyle çiziliyor. HUD/menü/bölüm seç kristal simgesi tek
  kare (`kristal.png`), bölüm içindeki sayfa ayrı (`kristal_parilti.png`) —
  üç yerde `AtlasTexture` kurmaktan ucuz.
- **Bu turun ekran görüntüleri iki eski hatayı ortaya çıkardı.** (1) Müzik
  döngüsü parçanın beşte birinde başa sarıyordu: içe aktarma parçaları QOA ile
  sıkıştırıyor, `ses.gd` döngü sonunu `data.size()/2` (16 bit PCM varsayımı)
  ile kuruyordu — menü müziği 20,9 yerine 4,2 sn'de dönüyordu, test yalnız
  `loop_end > 0`'a bakıyordu. Artık `get_length() * mix_rate`, test
  `loop_end == uzunluk`. (2) Parallaks arka plan sağda açık kalıyordu: Godot
  `ParallaxLayer` aynalaması tek ek kopya çizer, 320 px içerik 640 px ekranı
  ancak kaydırma tam 320'nin katıyken örtüyor. İkinci odada sağ kenarda 15 px,
  ilk odada sarsıntının negatif karelerinde sağ yarım ekran gri (temizleme
  rengi) kalıyordu — "hayalet kazandı" karesi yakaladı. Her katmana ikinci
  sprite kopyası (640 px) + aynalama 640; `_parallaks_testi` örtüyü ölçüyor.

## 7. turda verilen kararlar (v0.7 — yeni mekanikler, tabela, süre listesi, kol sallanması)

- **Yasak bölge yüzeye bağlı, tam boy değil.** Görev "içindeyken çevrilemeyen
  bölge" diyordu; iki okuma vardı. Tam boy bölge iki yüzeyi birden bağlar ve
  "karşı yüzeydeki diken bölgenin altında" desenini (16'daki tavan bölgesi:
  dikeni tavandan geçerken bölge bitene kadar inemezsin) yasaklardı. Yüzeye
  bağlı bölge daha zengin ve "bölge boyunca o yüzeyde ölümcül engel olmasın"
  kuralına birebir oturuyor. Bölgede basılan tuş **yutulur** (tampon silinir):
  aksi hâlde bölgeden çıkar çıkmaz bekleyen çevirme patlıyor ve oyuncu
  "ben basmadım" diyordu.
- **Tek yönlü platformun katı yüzü sabit.** İlk okuma "yerçekimi yönünden
  katı" idi; ama oyuncu hep yerçekimi yönünde düştüğü için o platform hiç
  geçilmez, sıradan ince platform olurdu. Sabit yüz (`_` üst, `~` alt) iki
  yerçekiminde farklı davranıyor: 14'te `~` köprü zeminden çevirince tutuyor
  (altında delik, üstünde diken — tek yol), 20'de `_` tavandan düşünce tutuyor,
  zeminden çevirince içinden geçiliyor. 20'nin v0.5'ten beri açık "haksız bitiş"
  notu (delik 54–57'den kapı önündeki 2 hücreye iniş) bu platformla kapandı:
  tavandan tam hızda çevirip platforma inip yürüyorsun.
- **Yeni mekanikler mevcut bölümlere sığdı, bölüm sayısı 20 kaldı.** 9'da diken
  bandı 2 hücre sağa kaydı (29–33 → 32–33, önünde bölge 29–31); 16 sekiz banttan
  yediye indi (iki bölge araya girince 3 hücrelik pencereler yetmedi), ölçülen
  süre 9,30 → 8,25 sn ve en az çevirme 8 → 6; 14'te hareketli platformun yerini
  `~` köprü aldı ve deliğin üstüne tavan dikeni geldi; 20'de son hareketli
  platform `_`'ya döndü. Botun 20/20 bölümü 5/5 ölümsüz bitirmesi ölçüt.
- **Üreteç kuralları önce, sonra bölüm.** Bölge: kendi yüzeyinde engel yok,
  bağlayıcıysa (ardında kendi yüzeyi ölümcül) önünde 3 hücre pencere, içinde
  karşı yüzey ölümcül olamaz. Platform: ilk 3 sütununda yaklaşma yüzeyi temiz,
  bitişinde taban yüzeyi 6 hücre temiz ya da karşı yüzeye çevrilebilir; köprülediği
  sütunlarda iki yüzey birden ölümcül olabilir (başka yerde olamaz). Bot da
  bölge kuralını koşudan önce bir daha ölçüyor.
- **Tabela sayacı durdurmuyor.** Kart bilgidir, mola değil; hızlı oyuncu ilk tuşla
  kapatıyor. Ölümde açılmaz (yeniden doğuş bölüm başı değil).
- **Süre listesi ızgaranın yanına değil yerine.** 640×360'ta ikisi sığmıyor; tek
  düğme iki görünümü değiştiriyor, 20 satır iki sütun × 10.
- **Test paketi kayıt dosyasını yedekliyor.** Yarıda kalan bir koşu yardım modu
  ve solak ayarını diske yazdı; 27 test "açıklanamaz" kaldı. Testler artık ekran
  aracı gibi başta yedekleyip çıkışta geri koyuyor (CLAUDE.md tuzak 22).

## Durum

**v0.7.2 — MIT lisans dosyası, her push'ta CI, 21 belge düzeltmesi.**
v0.7'nin üstüne yalnız depo işleri girdi; oynanış aynı. `main`'e her push ve her
PR'da **841 doğrulama** koşuyor (Godot 4.7.2, Linux, Git LFS); varsayılan dal
`master` → `main` oldu; `*.gif` Git LFS'e alındı. En önemli belge düzeltmesi
yanlış bir "bilinen sınır"ın kaldırılması oldu: README bölüm başı ipucu metninin
HUD ile çakıştığını söylüyordu — sahnede metin y 96–114, HUD şeritleri y 0–39;
ilk commit'ten beri çakışma yok.

Yeniden dışa aktarımda web paketi bayt bayt aynı çıktı (827.904 bayt, aynı
SHA256): yayın paketi depodaki kaynakla birebir aynı. Güncel sürümün notları
[Releases](https://github.com/Furkiozknn/yercekimi-cevir/releases) sayfasında.

**v0.7 — çevirme yasağı bölgesi, tek yönlü platform, tabela, süre listesi, kol
sallanması.** v0.6'nın üstüne: iki yeni mekanik (9, 14, 16 ve 20. bölümlerde),
bölüm başı kartı, Bölüm Seç'te iki sütunlu süre listesi ve menüde madalya
sayısı, yürüyüşte sallanan kollar. Yükleme yapılmadı. Sonraki adımlar:
`YOL-HARITASI.md`.

İlerleme ve ayarlar `user://kayit.cfg` dosyasında (Windows'ta
`%APPDATA%\Godot\app_userdata\Yerçekimi Çevir\kayit.cfg`).


## Bilinen sınırlar

Hepsi ölçüldü veya yapılandırmadan doğrulandı — tahmin yok.

- **Yalnızca Windows ve Web.** `export_presets.cfg` iki hedef tanımlıyor:
  `Windows Masaustu` ve `Web (HTML5)` — adlar `export_presets.cfg`'de aksansız,
  `--export-release` ile birebir böyle yazılmalı. Linux, macOS ve Android dışarı
  aktarımı yok.
- **Arayüz yalnızca Türkçe.** `project.godot` içinde çeviri/locale girdisi
  bulunmuyor; metinler sahnelere ve betiklere doğrudan gömülü
  (`scenes/*.tscn` + `scripts/*.gd`), çeviri katmanı yok.
- **Web yapısı tek iş parçacıklı** (`thread_support=false`). itch.io'ya
  yüklerken **SharedArrayBuffer kutusu işaretlenmemeli**.
- **Bölüm başı ipucu metni bölümün üzerine biniyor.** Ekranın ortasında,
  üstten 96 px'te duruyor (`scenes/oyun.tscn` → `Ipucu`); HUD şeritlerinin
  (y 0–39) altında kalıyor ama haritanın 5-6. satırındaki karoların üzerine
  çizilebiliyor. Okunuyor, oynanışı engellemiyor — kozmetik.
- **İlerleme tek makinede.** Kayıt yerel; bulut senkronu yok, dosya
  silinirse tüm bölüm ve madalya ilerlemesi sıfırlanır.

## Test ve CI

```bash
godot --headless --path . --import                    # bir kez, .godot onbellegi
godot --headless --path . res://tests/testler.tscn    # cikis kodu 0 = gecti
```

`main`'e her push'ta ve her pull request'te **aynı komut** GitHub Actions'ta
koşuyor (Godot 4.7.2, Linux
headless, Git LFS çekilerek). Son ölçüm: **841 doğrulama, 0 hata**.

İçe aktarma ayrı bir adım çünkü taze bir klonda `.godot` önbelleği hiç
yok; onsuz testin içeriğiyle ilgisi olmayan ayrıştırma hataları alınır.
