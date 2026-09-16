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

## Sonraki tur

### Önce bunlar (gerçek oyuncu gerektiren)

- [ ] **20 bölümü elle baştan sona oyna.** Hâlâ en büyük belirsizlik. 19'un
      "iki yüzey de ölümlü" tuzağı kalktı ve bot artık frenle geçiyor; ama
      insan bandındaki botun bile 6, 7 ve 15'te bir zorunlu fren yediği ölçüldü —
      gerçek oyuncunun kaç fren yediği ölçülmedi. Altın ×1,35 buna göre
      seçildi; insan oynayınca doğrulanmalı.
- [ ] **20 — Son Kapı'nın sonu:** delik 54–57'den kapı önündeki 2 hücreye (58–59)
      iniş, üretecin izin verdiği en dar bitiş. İnsan bandındaki bot geri
      yürümeyi bilmediği için 5 koşunun 4'ünde tavanda kaldı. İnsan geri
      yürür; ama elle oynanınca bu bitiş "haksız" geliyorsa deliği 1 sütun
      sola al.
- [ ] **Tavanda yürüyen oyuncu üst HUD şeritlerinin arkasında kalıyor**
      (x < 232 ve x > 398; şeritler yarı saydam). Ekran görüntülerinde
      görüldü, oynanışta ne kadar rahatsız ettiği ölçülmedi.
- [ ] Web yapısını tarayıcıda aç: sesin geldiğini ve müziğin **ikinci tura girdiğini**
      doğrula (döngü kodla kuruluyor, tarayıcıda doğrulanmadı). v0.3.1'in simge
      ve dokunmatik metin düzeltmesi de **tarayıcıda görülmedi**, yalnız
      başsız testle ölçüldü.

### Oynanış

- [ ] Yeni mekanik: çevirmeyi engelleyen bölge, tek yönlü platform, dikey kaydırmalı bölüm
- [ ] Bölüm başı tabelası / en iyi süre listesi ekranı
- [ ] Günün bölümü: seri sayacı (ardışık gün), 3. değiştirici (ör. hayalet
      yarışı zorunlu: altın hayaleti geç), günün sonucunu paylaşılabilir metin
      olarak kopyala

### Görsel ve ses

- [ ] Kapı ve kristal için 2–4 kareli parıldama animasyonu (şu an tek kare)
- [ ] Yürüme çevriminde kol sallanması (şu an yalnız bacaklar değişiyor)
- [ ] Müziği bölüm grubuna göre değiştir (1–7 sakin, 8–14 gergin, 15–20 hızlı)

### Mobil

- [ ] Geniş dokunma alanlarını **gerçek telefonda** dene: sol/sağ çeyrek ayrımı
      parmakla ayırt edilebiliyor mu, titreşim rahatsız ediyor mu
- [x] ~~Solak modda dokunma ipucu yanlış tarafı söylüyor~~ — v0.5'te düzeltildi;
      gerçek telefonda tarifin anlaşılır olup olmadığı hâlâ denenmeli
- [ ] Android dışa aktarımı + dokunmatik hedef boyutlarını büyüt
- [ ] Dikey en-boy oranında test

### Yayın

- [ ] itch.io sayfasını aç ve `yayin/butler-komutlari.md` ile yükle — **Furki'nin kararı**
