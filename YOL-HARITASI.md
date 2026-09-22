# Yol Haritası — Yerçekimi Çevir

## Tur 0 — oynanabilir prototip (2026-09-16)

- [x] Çevirme mekaniği: `up_direction` + yerçekimi işareti ters çevirme, `flip_v`,
      yalnızca yüzeydeyken, ~0,1 sn giriş tamponu
- [x] Yatay ivmeli yürüme, havada azaltılmış kontrol, zıplama yok
- [x] 12 bölüm, hareketli platform, gezgin diken
- [x] Diken teması ve ekran dışına düşme = ölüm; 0,3 sn sonra otomatik yeniden deneme
- [x] Bölüm başına süre + ölüm sayacı, en iyi süre kaydı (`user://kayit.cfg`)
- [x] Ana menü, Bölüm Seç, duraklatma menüsü — hepsi Türkçe
- [x] Klavye + gamepad girdisi; dokunmatik cihazda 3 ekran düğmesi
- [x] Headless otomatik test + geliştirici ekran görüntüsü aracı
- [x] Windows ve Web dışa aktarımı

## Tur 1 — yayına hazır ilk sürüm v0.2 (2026-09-16)

- [x] **CLAUDE.md**: projenin kalıcı kuralları, komutlar, kilit kuralı, bilinen tuzaklar
- [x] **20 bölüm.** Zorluk eğrisi baştan kuruldu; her yeni öğe önce güvenli bir bölümde
- [x] **Gizli kristal** (bölüm başına 1, otomatik olarak ana rotanın dışına yerleşiyor);
      Bölüm Seç'te ve ana menüde toplam görünüyor
- [x] **Madalya süreleri** (altın/gümüş/bronz, geometriden hesaplanıyor); arayüzde,
      Bölüm Seç'te ve bitiş ekranında; en iyi madalya kaydediliyor
- [x] **Kontrol noktası** uzun bölümlerde; ölünce oraya dönülüyor
- [x] **Gerçek pixel art** (Endesga 32): oyuncu 8 kare, karo seti + uyarı şeritli
      yürüyüş yüzeyi, diken, gezgin diken, platform, parlayan kapı, kristal,
      kontrol noktası, madalya, 3 parallaks katman — hepsi `tools/uret_sprite.py`
- [x] **Ses**: 9 efekt + 3 müzik parçası, `Muzik` / `Efekt` veriyolları, web ses ayarı
- [x] **Ayarlar ekranı**: müzik/efekt düzeyi ve aç-kapa, tam ekran, oyun hissi anahtarı
- [x] **Oyun hissi**: çevirme hayalet izi, esneme-sıkışma, ekran sarsıntısı,
      iniş/ölüm/toplama parçacıkları, bölüm geçişinde kararma,
      ters yerçekiminde arka planın soğuğa kayması — hepsi tek ayarla kapanıyor
- [x] **Yayın paketi** `yayin/`: itch sayfa metni (EN + TR), 4 ekran görüntüsü
      (1280×720), kapak (630×500), butler komutları (çalıştırılmadı)
- [x] Testler 97 → 362 doğrulama; Windows + Web dışa aktarımı temiz

## Tur 2 — rakip analizi iyileştirmeleri v0.3 (2026-09-16)

Kaynak: `oyun-terminalleri/tasarim/yercekimi-cevir-rakip-analizi.md`.

### Affetme (türün "haksız ölüm" şikâyeti)

- [x] **Kojot çevirme** 0,08 sn — yüzeyden ayrıldıktan sonra da çevirebilirsin.
      Mevcut 0,10 sn giriş tamponu korundu; ikisi birlikte çalışıyor
- [x] **Öldürücü isabet kutuları görselden 3 px küçük.** Gezen dikenin kutusu
      görseliyle **birebir aynıydı** — asıl hata oradaydı, sabit dikende zaten pay vardı
- [x] **Yeniden deneme 0,30 → 0,18 sn**, sahne yeniden yüklenmiyor, hareketli
      platformlar dahil her şey sıfırlanıyor (testle ölçülüyor)
- [x] **Oda tabanlı kamera**: 640 px'lik odalar arasında atlıyor, oda içinde
      kıpırdamıyor; bir odadaki tehlikenin tamamı hep ekranda

### Erişilebilirlik

- [x] **Yardım modu**: oyun hızı %50–100, dikenler öldürmek yerine itiyor,
      duraklatmadan bölüm atlama. Açıkken süre/madalya/çevirme kaydı yok,
      kristal sayılıyor. Metin suçlayıcı değil
- [x] **Yüksek kontrast** seçeneği: tehlike parlıyor, zemin ve arka plan geri çekiliyor
- [x] **Yerçekimi yönü oku** oyuncunun yanında (durum renkten değil biçimden okunuyor)
- [x] **İniş göstergesi**: çevirme tuşu basılı tutulunca karşı yüzeydeki iniş
      noktası; yolda diken varsa kırmızı
- [x] Diken dış çizgisi: zaten vardı (`diken.png` ve `gezgin.png` siyah konturlu)

### Mobil

- [x] **Görünmez geniş alanlar**: sol yarı hareket (sol çeyrek sol, sağ çeyrek sağ),
      sağ yarı çevirme. Düğme görselleri kalktı, yalnız soluk ipucu harfi kaldı
- [x] **Solak seçeneği** (tarafları değiştirir), **düğme opaklığı**, **titreşim**

### Farklılaştıranlar

- [x] **Hayalet yarış**: bölümün en iyi koşusu yarı saydam koşuyor, rengi o koşunun
      madalyası. `user://hayalet_<bolum>.dat`
- [x] **Ölüm haritası**: bölüm bitince bölümün küçültülmüş planı + her ölüm X ile
- [x] **"En az çevirme" ikinci hedefi**: hedef bölüm geometrisinden hesaplanıyor,
      rekor kaydediliyor, Bölüm Seç ve bitiş ekranında görünüyor

### Diğer

- [x] Kapak görseli yeniden çizildi (2x yakınlaştırma, aydınlatılmış arka plan,
      dolu koyu şerit, parlak başlık + camgöbeği alt satır)
- [x] Ayarlar ekranı iki sütuna ayrıldı (13 ayar tek ekrana sığıyor)
- [x] Testler 362 → **464 doğrulama**; ekran aracına özellik denetim modu (`-3`)

## Tur 3 — web düzeltmesi v0.3.1 (2026-09-16)

Bulutta Chromium'da açılan v0.3 web yapısından çıkan iki hata.

- [x] `⟳` ve `●` web'de kutu çıkıyordu → `assets/fonts/simgeler.ttf` yedek yazı
      tipi, `Simgeler.kur()` `Ayarlar._ready()` içinde. Test: `_simge_testi`
      (yedek kaldırılınca gerçekten kalıyor, yani web durumunu ölçüyor)
- [x] Dokunmatikte klavye metni ("A / D ile yürü", "BOŞLUK...", "Tek tuş") →
      `Ayarlar.kontrol_metni()` terim tablosu. Dokunmatik ilk ekran dokunuşunda
      da açılır, alanlar o anda görünür olur. Test: `_dokunma_metni_testi`
- [x] Yayın ekran görüntüleri yeni yazı tipiyle yeniden alındı
- [~] Geniş telefonda siyah şerit **bilerek bırakıldı** — gerekçe README'de
      (oda kamerası 640 px'e kilitli, `expand` bölüm dışını gösterir)

## Tur 4 — ölçüm turu v0.4 (2026-09-16)

Kaynak: `oyun-terminalleri/aktif/H8-yercekimi-cevir.md`.

- [x] **Madalya süreleri ölçüldü.** `tools/bot.gd` bölümün ASCII haritasından
      "hangi sütun hangi yüzeyde geçilir" planını çıkarıp bunu GERÇEK fizikte
      oynuyor (gerçek Oyun sahnesi, gerçek oyuncu.gd, `Input.action_press` ile
      basılan girdi). Her çevirme kararına 0,05–0,20 sn rastgele tepki gecikmesi.
      Bölüm başına 5 koşu, ölçü ortanca. **20/20 bölüm ölçüldü, tahmine düşen yok.**
      Eşikler tek yerden: üretilen `scripts/rota_verisi.gd` → `Ayarlar.esik()`
- [x] Çarpanlar gerekçelendirildi (altın ×1,15 / gümüş ×1,50 / bronz ×2,00);
      dayanak ölçülen fren bedeli (çevirme başına ~1,0–1,2 sn)
- [x] **"En az çevirme" hedefleri ölçümle doğrulandı** — 20/20 bölümde geometri
      hedefiyle aynı çıktı, yani 2. turun "cömert olabilir" şüphesi yanlışmış
- [x] **Altın hayalet**: botun ölçülmüş en iyi koşusu ayrı hedef olarak koşuyor
      (`scripts/altin_hayalet.gd`, üretilir). Kendi hayaletinle karışmasın diye
      ikisi de etiketli ("sen" / "altın"); ayarlardan kapatılıyor
- [x] **İniş göstergesi hareketli parçaları sayıyor** ve onları geçiş süresi
      kadar ileri sarıyor; tehlike artık nokta değil GÖVDE kutusuyla aranıyor
- [x] Kapak 315×250 ve 120×45'e küçültülüp gözle denetlendi (`Image.resize`)
- [x] **Tanıtım GIF'i** `yayin/tanitim/tanitim.gif` (3 sn, 10 kare/sn, 292 KB)
      + kareler; `tools/gif_yap.py` bağımlılıksız GIF89a yazıcı
- [x] Testler 486 → **612 doğrulama**; Windows + Web dışa aktarımı temiz

## Tur 5 — solak, fırtına, günün bölümü, insan payı v0.5 (2026-09-16)

Kaynak: `oyun-terminalleri/aktif/H11-yercekimi-cevir.md`.

- [x] **Solak ipucu** tarafı söylüyor: `DOKUNMA_METNI` yer tutuculu (`{h}`/`{c}`),
      `kontrol_metni()` solak ayarına göre dolduruyor. Test iki modda alan
      konumu + ipucu metnini birlikte ölçüyor; ekran görüntüleri `docs/tur4/`
- [x] **19 — Fırtına yeniden kuruldu.** Gezen diken 33–39'a (tavanı temiz koridor),
      tavan dikeni 42–47'ye, platformlu delik 51–57'ye. Bot 8,23 sn, 6 çevirme,
      5/5 ölümsüz (eski: 7,33 sn ama 5 koşunun 1'i kaza). Altın 11,12 sn
- [x] **Kök neden kuralı:** gezen dikenin menzilinde karşı yüzey güvenli olmalı —
      üreteçte `assert`, testte `_gezgin_kacis_testi`. Kural 18 — Koridor'u da
      yakaladı; aynı desenle düzeltildi (gezgin 43–48, delik 49–55)
- [x] **Günün bölümü:** tarihten 32 bit karıştırıcıyla bölüm + değiştirici (ters
      başlangıç / kristal zorunlu), `[gunluk]` ayrı kayıt, menüde günün bölümü ve
      en iyi süre, HUD'da rozet. Ana ilerlemeye yazmıyor — `_gunluk_testi` iki
      değiştiricide de bitişe kadar oynayıp ölçüyor
- [x] **Madalya çarpanları** insan tepki bandı ölçümüyle (`bot.gd -- … insan`)
      yükseltildi: altın ×1,35, gümüş ×1,75, bronz ×2,40. Tablo raporda
- [x] Testler 612 → **672 doğrulama**; ekran aracına tur 4 modu (`-6`);
      Windows + Web dışa aktarımı temiz; yayın paketi 0.5.0

## Tur 6 — tavan HUD, seri, hayalet yarışı, müzik grupları, parıltı v0.6 (2026-09-21)

Kaynak: `oyun-terminalleri/aktif/H14-yercekimi-cevir.md`.

- [x] **Tavan–HUD çakışması:** oyuncu ya da hayalet üst şeridin dikdörtgenine
      girince şerit (arka + yazıları) 0,15 sn'de alfa 0,25'e iner, çıkınca geri
      gelir; girdiye dokunmaz. Ekran uzayında hesaplanıyor. Test:
      `_hud_solma_testi`; kareler `docs/tur5/01-02`
- [x] **Günün bölümü serisi:** ardışık gün sayacı `[gunluk]` kaydında
      (`seri`, `seri_tarih`); bir gün atlanınca 1'e düşer, ay sınırında doğru;
      yardım modunda da sayılır; menüde "seri N gün". Test: `_seri_testi`
- [x] **Paylaşım metni:** bitişte panel (bölüm, değiştirici, süre, ölüm,
      çevirme, seri) + **Paylaşım Metnini Kopyala** düğmesi
      (`DisplayServer.clipboard_set`, düğmeye bağlı olduğu için web'de de çalışır)
- [x] **3. değiştirici — hayalet yarışı:** altın hayalet rakip (ayar kapalıyken
      de koşar); kapı yalnız hayaletten önce sayılır, geç kalınca "HAYALET
      KAZANDI" ve bölüm baştan. Üç değiştirici 90 günde 27/30/33.
      `_gunluk_testi` üçünü de bitişe kadar oynuyor
- [x] **Bölüm grubu müziği:** 1–7 sakin, 8–14 gergin, 15–20 hızlı
      (`Ses.bolum_parcasi`), menü müziği aynı; eski tek parça `_eski/audio/`.
      Test: `_muzik_grubu_testi`
- [x] **Parıltı:** kapı (64×48) ve kristal (48×12) 4 kareli sayfa, 0,15 sn/kare,
      tek sayaç; HUD simgesi tek kare. Test: `_parilti_testi`; levha `docs/tur5/07`
- [x] Ekran aracına tur 5 modu (`-7`) ve kayıt dosyası yedekleme; yayın paketi 0.6.0
- [x] **İki eski hata düzeltildi** (bu turun ölçümleri yakaladı): müzik döngüsü
      QOA yüzünden parçanın beşte birinde başa sarıyordu (`get_length()` ile
      kuruldu, test `loop_end == uzunluk`); parallaks arka plan ikinci odada
      sağ kenarda ve ilk odada sarsıntının negatif karelerinde sağ yarımda
      açık kalıyordu (katman içeriği 640 px'e çıkarıldı, `_parallaks_testi`)

## Tur 7 — yeni mekanikler, tabela, süre listesi, kol sallanması v0.7 (2026-09-21)

Kaynak: `oyun-terminalleri/aktif/H16-yercekimi-cevir.md`.

- [x] **Çevirme yasağı bölgesi** (`=`): yüzeye bitişik kesik çizgili kutu + kilit;
      içindeyken çevirme reddedilir ve tuş yutulur, HUD rozeti + kilit sesi.
      9 — Salıncak (zemin 29–31, ardında diken) ve 16 — Kılçık (tavan 12–19,
      zemin 44–46). Üreteç kuralı `assert` + `_yasak_bolge_testi`; bot bağlayıcı
      bölgeyi tehlike başı sayıyor. Kareler `docs/tur6/01-04`
- [x] **Tek yönlü platform** (`_` üstüne / `~` altına inilir): sabit katı yüz,
      oklu karo; 14 — Boşluk Üstü'nde tek yol `~` köprü, 20 — Son Kapı'da `_`.
      İniş tahmini ve bot görüyor; test iki yerçekiminde davranış. Kareler `05-07`
- [x] **Bölüm başı tabelası** 1,2 sn / ilk girdi; `_tabela_testi`; kare `08`
- [x] **Süre listesi** Bölüm Seç'te (iki sütun × 10, en iyi + madalya + altın);
      menüde toplam madalya; `_sure_listesi_testi`; kareler `09-10`
- [x] **Kol sallanması**: kollar ayrı katman, yürüyüşte dışa/içe, zıplamada
      yukarı, düşüşte T; `_kol_testi`; levha `11`
- [x] Bot yeniden ölçtü (20/20, 5/5 ölümsüz); testler 748 → **841 doğrulama**;
      test paketi `kayit.cfg`'yi yedekliyor; Windows + Web dışa aktarımı temiz;
      web yapısı Playwright ile tarayıcıda denendi (0 sayfa hatası); yayın paketi 0.7.0
- [x] ~~20 — Son Kapı'nın bitişi~~ — `_` platform son deliğin üstünde; bot
      5/5 bitiriyor, ortanca 9,23 → 9,15 sn

## Tur 8 — v0.7.1 / v0.7.2: depo hijyeni (2026-09-21/22)

- [x] MIT `LICENSE`
- [x] GitHub deposu **public** (`Furkiozknn/yercekimi-cevir`, dal `main`), `v0.7.2` etiketi ve Release
- [x] GitHub Actions: 841 doğrulama her `main` push'unda ve her PR'da (Godot 4.7.2 sabit,
      Git LFS çekilerek); README'de rozet
- [x] `*.gif` Git LFS'e alındı (`.gitattributes` kuralı artık gerçekten tutuyor)
- [x] Makineye özel yollar belgelerden ve betiklerden çıkarıldı
- [x] İki tur bağımsız belge denetimi: yanlış bir "bilinen sınır" kaldırıldı (bölüm başı ipucu HUD ile
      çakışmıyor: sahnede y 96-114, HUD y 0-39), kırık README görseli, yazı tipi
      simge sayısı 34 → 32, ses efektleri 6 ön ayardan 10, dışa aktarma ön ayarının
      aksansız adı; oyun sonu bitiş özeti ekranı ilk kez belgelendi
- [x] Varsayılan dal `master` → `main`

## Sonraki tur

### Önce bunlar (gerçek oyuncu gerektiren)

- [ ] **Yeni mekanikleri elle oyna.** Bölge ilk kez 9'da ölümcül bir yerde
      (kutuya girersen dikene düşersin) — ipucu satırı uyarıyor ama ilk karşılaşma
      yine ölümle bitebilir; fazla sertse 8 — Asansör'e zararsız bir bölge koy.
      14'teki `~` köprü tek yol: altında yürüyüp zemine çevirmeyi insan buluyor mu?

- [ ] **20 bölümü elle baştan sona oyna.** Hâlâ en büyük belirsizlik. 19'un
      "iki yüzey de ölümlü" tuzağı kalktı ve bot artık frenle geçiyor; ama
      insan bandındaki botun bile 6, 7 ve 15'te bir zorunlu fren yediği ölçüldü —
      gerçek oyuncunun kaç fren yediği ölçülmedi. Altın ×1,35 buna göre
      seçildi; insan oynayınca doğrulanmalı.
- [x] ~~20 — Son Kapı'nın sonu~~ — v0.7'de son deliğin üstüne `_` platform:
      tavandan düşüp üstüne iniyorsun, kapıya yürüyorsun; insan bandındaki botla
      yeniden ölçülmedi.
- [x] ~~Tavanda yürüyen oyuncu üst HUD şeritlerinin arkasında kalıyor~~ —
      v0.6'da şerit soluyor; **gerçek oynanışta** 0,25'in yeterli olup olmadığı
      (yazı hâlâ okunuyor mu, oyuncu yeterince görünüyor mu) elle denenmeli.
- [ ] Web yapısında **sesi açık** dene: Playwright koşusu sayfa/konsol hatasına bakıyor,
      sese bakmıyor. Müziğin ikinci tura girdiği, üç parçanın geçişi ve hayalet yarışı
      kulakla doğrulanmadı. (Sayfa tarafı v0.7.2'de masaüstü + telefon emülasyonunda
      konsol hatasız açıldı.)
- [ ] **Hayalet yarışı elle oynanmalı:** altın hayalet botun ölümsüz koşusu,
      ×1,35 altın payı bu değiştiricide YOK — insanın onu geçebilmesi için
      hayalete küçük bir gecikme (ör. başlangıçta 0,5 sn) gerekebilir.

### Oynanış

- [x] ~~Yeni mekanik: çevirmeyi engelleyen bölge, tek yönlü platform~~ — v0.7
- [ ] Dikey kaydırmalı bölüm (oda kamerası dikeyde de atlamalı)
- [ ] Hayalet başlangıç gecikmesi (dondurulan v0.8 tur dosyasından)
- [ ] Yasak bölge ve tek yönlü platformu daha çok bölümde kullan (şimdi 4 bölümde);
      insan bandındaki botla (`bot.gd -- … insan`) yeniden ölç — altın çarpanı
      yeni mekaniklerde doğrulanmadı
- [x] ~~Bölüm başı tabelası / en iyi süre listesi ekranı~~ — v0.7
- [x] ~~Günün bölümü: seri sayacı, 3. değiştirici, paylaşılabilir metin~~ — v0.6
- Karar (v0.6): günün bölümünde liste/karşılaştırma yok, yalnız kendi en iyin ve serin;
      paylaşım metni bunun yerine geçiyor

### Görsel ve ses

- [x] ~~Kapı ve kristal için 2–4 kareli parıldama animasyonu~~ — v0.6 (4 kare)
- [x] ~~Yürüme çevriminde kol sallanması~~ — v0.7 (dışa/içe iki poz; tam bir
      "ileri-geri" salınım 16 px'te çizilmedi, gerekirse üçüncü poz)
- [x] ~~Müziği bölüm grubuna göre değiştir~~ — v0.6; parçalar dinlenmedi
      (üreteç tohumları ilk denemede seçildi), beğenilmeyen grupta yalnız
      `--tohum` değiştir

### Mobil

- [ ] Geniş dokunma alanlarını **gerçek telefonda** dene: sol/sağ çeyrek ayrımı
      parmakla ayırt edilebiliyor mu, titreşim rahatsız ediyor mu
- [x] ~~Solak modda dokunma ipucu yanlış tarafı söylüyor~~ — v0.5'te düzeltildi;
      gerçek telefonda tarifin anlaşılır olup olmadığı hâlâ denenmeli
- [ ] Android dışa aktarımı + dokunmatik hedef boyutlarını büyüt
- [ ] Dikey en-boy oranında test

### Yayın

- [ ] itch.io sayfasını aç ve `yayin/butler-komutlari.md` ile yükle — **Furki'nin kararı**
