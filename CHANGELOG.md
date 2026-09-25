# Değişiklik günlüğü

Her sürümün ne getirdiği ve **neden** öyle karar verildiği. 0.2–0.7 arasındaki
bölümler önceden README'de "N. turda verilen kararlar" başlıklarıyla duruyordu;
metin aynen buraya taşındı. Tarihler git etiketinin tarihidir (0.2 etiketlenmedi).
Etiketler: `git tag -l 'v*'`; yayımlanmış sürüm notları:
[Releases](https://github.com/Furkiozknn/yercekimi-cevir/releases).

## [Yayımlanmamış]

Oynanış değişmedi; yalnız depo ve belge işleri.

- **CI eylemleri Node 24'e taşındı.** `actions/checkout@v4`,
  `upload-artifact@v4`, `download-artifact@v4`, `configure-pages@v5`,
  `deploy-pages@v4` ve `codeql-action/upload-sarif@v3` Node 20 üzerinde
  koşuyordu; GitHub her koşuda "Node.js 20 is deprecated" uyarısı basıyor ve
  onları zorla Node 24'te çalıştırıyordu. Hepsi Node 24'lü ana sürümlere
  yükseltildi (`checkout@v7`, `upload-artifact@v7`, `download-artifact@v8`,
  `configure-pages@v6`, `upload-pages-artifact@v5`, `deploy-pages@v5`,
  `upload-sarif@v4`). Adımlar ve girdiler aynı.
- **README yeniden düzenlendi:** amaç, "şimdi nasıl oynarım", platform ve
  paket boyutları, kaynaktan ilk çalıştırma (Git LFS dahil) ve elle duman testi
  en üste yakın; sürüm sürüm karar geçmişi bu dosyaya taşındı.
- **Yanlış paket boyutları düzeltildi.** README "web paketi ~10 MB, Windows
  ~38 MB" diyordu; bunlar Actions artifact'ının **zip** boyutları. Açılmış
  hâlleri Yapı koşusunun kendi günlüğünde: web 39 MB (`index.wasm`
  39.514.754 bayt, motorun kendisi), Windows 105 MB (`.exe` 109.147.136 bayt).
- **`tools/uret_ses.py` için eksik ön koşul yazıldı:** rFXGen v5.0 gerekiyor
  (depoda değil, yolu `RFXGEN` ortam değişkeniyle); yoksa betik
  "rFXGen bulunamadi" deyip 1 ile çıkıyor.

## [0.7.2] — 2026-09-22

Belge/altyapı turu — oynanış v0.7 ile aynı.

- MIT lisansı (`LICENSE`), mevcut yazı tipi atıflarının yanına eklendi.
- GitHub Actions: `main` push ve PR'larda **841 doğrulama** (Godot 4.7.2, Linux, Git LFS).
  Varsayılan dal `master` → `main`.
- 21 belge düzeltmesi. En önemlisi yanlış bir "bilinen sınır"ın kaldırılması: README
  bölüm başı ipucu metninin HUD ile çakıştığını söylüyordu; sahnede metin ekranın
  ortasında (y 96–114), HUD şeritleri y 0–39 — ilk commit'ten beri çakışma yok.
  Ayrıca kırık README görseli, yazı tipi simge sayısı (34 → 32), ses efekti sayıları
  (6 ön ayardan 10 efekt), dışa aktarma ön ayarının aksansız adı, oyun sonu bitiş
  özeti ekranının hiç belgelenmemiş olması.
- `*.gif` LFS'e alındı (`.gitattributes` kuralı artık gerçekten tutuyor).

Doğrulama (sürüm notlarından): 841 doğrulama 0 hata (yerel ve CI); yeniden dışa
aktarımda web pck bayt bayt aynı çıktı (827.904 bayt, aynı SHA256).

## [0.7.1] — 2026-09-22

Belge/lisans/CI turu — oyun kodu v0.7 ile aynı.

- `LICENSE` (MIT); README'nin "Lisanslar" bölümüne MIT ifadesi eklendi.
- Kırık README görseli düzeltildi: `yayin/ekran/04-cevirme.png` →
  `07-cevirme.png` (04 diye bir dosya depoda yok).
- `yayin/butler-komutlari.md`: `<itch-kullanici>` yer tutucusu ve `:html5` kanalı.
- `.github/workflows/ci.yml` izlemeye alındı: dosya diskte vardı ama git'e hiç
  eklenmemişti, yani README'deki CI rozeti var olmayan bir iş akışını
  gösteriyordu. Varsayılan dal `master` → `main`, iş akışının tetiği de `main`.

## [0.7] — 2026-09-21

*7. tur: yeni mekanikler, tabela, süre listesi, kol sallanması.*

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

## [0.6] — 2026-09-21

*6. tur: tavan HUD, seri, hayalet yarışı, müzik grupları, parıltı.*

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

## [0.5] — 2026-09-16

*5. tur: solak, fırtına, günün bölümü, insan payı.*

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

## [0.4] — 2026-09-16

*4. tur: ölçüm turu.*

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

## [0.3.1] — 2026-09-16

*3. tur: web düzeltmesi.*

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

## [0.3] — 2026-09-16

*2. tur: rakip analizinden.*

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

## [0.2] — etiketsiz

*1. tur: ilk yayına hazır sürüm.*

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
  `"tahmin": false`) — bkz. aşağıdaki 0.4 bölümü.
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
