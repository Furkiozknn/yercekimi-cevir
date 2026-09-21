# Yerçekimi Çevir

Zıplama yok: tek tuşla yerçekimini ters çevirip tavana "düşerek" dikenlerden kaçtığın
kısa ve zor bir hassas platform oyunu. **20 bölüm**, her bölüm 1–2 ekran.

![Ana menü](docs/01-menu.png)
![Çevirme anı](yayin/ekran/04-cevirme.png)

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

Kod ve varlıklar bu depoya ait. `assets/fonts/simgeler.ttf` ("Oyun Simgeleri")
DejaVu Sans Bold'un 34 simgelik alt kümesidir; Bitstream Vera lisansı altında
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

python arac/uret_bolumler.py     # 20 bölümü yeniden üret (çözülebilirliği doğrular)
python tools/uret_sprite.py      # tüm pixel art'ı yeniden üret
python tools/uret_ses.py         # tüm ses efektlerini yeniden üret
```

Dışa aktarılmış yapı: `build/windows/yercekimi-cevir.exe`, `build/web/index.html`.
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
| `tests/` | Headless otomatik test (748 doğrulama) + ekran görüntüsü aracı. |

Bölüm haritaları TileMapLayer yerine ASCII + kod üretimi: 20 bölüm tek dosyada
düzenlenebiliyor ve `arac/uret_bolumler.py` üretim sırasında her bölümün
çözülebilirliğini doğruluyor — çevirme penceresi yeterince geniş mi, aynı sütunda
hem zemin hem tavan tehlikesi var mı, kristal kaçamağı ölümcül mü.

## Bu turda verilen kararlar

- **Zorluk:** prototip raporunda 9–12 arası "insan için fazla zor olabilir" dendi.
  Bölüm sayısı 20'ye çıkarıldı ve araya kolay bölümler serpiştirilmek yerine
  **eğri baştan kuruldu**: her yeni öğe (çevirme, tavan yürüyüşü, zemin dikeni,
  tavan dikeni, hareketli platform, gezgin diken) önce tek başına ve güvenli bir
  bölümde tanıtılıyor. Kapı çarpışma kutusu da büyütüldü (tam hücre genişliği,
  3 hücre boy) — yukarıdan inen oyuncu kapıyı ıskalamıyor.
- **Madalya süreleri elle değil geometriden:** yol uzunluğu / yürüme hızı + bant
  başına bir çevirme bedeli. Bölüm değişince süreler kendiliğinden güncelleniyor,
  20 bölüm elle ayarlanmıyor.
- **Kristal yeri de otomatik:** ana rotanın dışında ve her tehlike bandından en az
  8 sütun uzakta — beceriksiz bir kaçamak ölümle bitmesin diye.
- **Pixel art kodla üretiliyor.** Bu makinede GUI çizim aracı ve Pillow yok;
  `tools/uret_sprite.py` saf Python'la (zlib + struct, 20 satırlık PNG yazıcı)
  üretiyor. Tek palet: Endesga 32.
- **Ses efektleri perde kaydırmayla çeşitlendirildi.** rFXGen v5.0'ın komut satırı
  ön ayarları deterministik — aynı ön ayar hep aynı dosyayı veriyor. 5 ön ayardan
  9 ayrı efekt çıkarmak için yeniden örnekleme kullanıldı (`tools/sesler.md`).
- **Oyun hissi kapatılabilir.** Sarsıntı, parçacık ve çevirme izi tek bir ayarla
  kapanıyor; rahatsız eden oyuncu mekaniği kaybetmeden kapatabilsin.

## 2. turda verilen kararlar (v0.3 — rakip analizinden)

Kaynak: `oyun-terminalleri/tasarim/yercekimi-cevir-rakip-analizi.md` (VVVVVV,
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
  tek hayalet var ve rengi o koşunun madalyası.
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

## Durum

**v0.6 — tavan HUD, seri, hayalet yarışı, müzik grupları, parıltı.** v0.5'in
üstüne: üst HUD şeritleri tavandaki oyuncuya yol veriyor, günün bölümünde seri
sayacı ve panoya kopyalanan paylaşım metni, üçüncü değiştirici (hayalet
yarışı), bölüm grubuna göre üç müzik parçası, parıldayan kapı ve kristal.
Yükleme yapılmadı. Sonraki adımlar: `YOL-HARITASI.md`.

İlerleme ve ayarlar `user://kayit.cfg` dosyasında (Windows'ta
`%APPDATA%\Godot\app_userdata\Yerçekimi Çevir\kayit.cfg`).
