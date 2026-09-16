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

## Sonraki tur

### Önce bunlar (gerçek oyuncu gerektiren)

- [ ] **20 bölümü elle baştan sona oyna.** 2. turda affetme ve kamera düzeldi ama
      zorluk eğrisi hâlâ hesapla dengelendi;
      bot ölçümü insanı temsil etmiyor. Özellikle 16 (Kılçık) ve 19 (Fırtına)
      şüpheli — bant aralığı 3 hücre, çevirme geçişi ~7 hücre sürüyor.
- [ ] **Madalya sürelerini gerçek koşuyla doğrula.** Altın = temel × 1,15 + bant × 0,45
      formülü hiç insan koşusuyla karşılaştırılmadı; altın fazla kolay ya da
      imkânsız olabilir.
- [ ] Web yapısını tarayıcıda aç: sesin geldiğini ve müziğin **ikinci tura girdiğini**
      doğrula (döngü kodla kuruluyor, tarayıcıda doğrulanmadı).

### Oynanış

- [ ] Yeni mekanik: çevirmeyi engelleyen bölge, tek yönlü platform, dikey kaydırmalı bölüm
- [ ] Bölüm başı tabelası / en iyi süre listesi ekranı
- [ ] **Hedef hayaleti.** Şu an tek hayalet var (senin en iyi koşun). Gerçek bir
      altın koşu kaydedilirse "altın hayalet" ayrı bir yarış hedefi olabilir —
      madalya süreleri formülden geldiği için elde böyle bir koşu yok
- [ ] **İniş göstergesi hareketli platformları saymıyor** (sabit harita üzerinden
      hesaplıyor). Platformlu bölümlerde tahmin zeminin kendisini gösteriyor
- [ ] **"En az çevirme" hedefi cömert.** Gezen dikenler tehlike sayıldığı için
      hedef gerçek en iyiden yüksek olabilir; gerçek koşularla karşılaştır

### Görsel ve ses

- [ ] Kapağı itch'in **120×45** küçük kapsülünde gerçekten gör. 2. turda yeniden
      çizildi ama bu makinede görüntü ölçekleyici yok, o boyutta denenmedi
- [ ] Kapı ve kristal için 2–4 kareli parıldama animasyonu (şu an tek kare)
- [ ] Yürüme çevriminde kol sallanması (şu an yalnız bacaklar değişiyor)
- [ ] Müziği bölüm grubuna göre değiştir (1–7 sakin, 8–14 gergin, 15–20 hızlı)

### Mobil

- [ ] Geniş dokunma alanlarını **gerçek telefonda** dene: sol/sağ çeyrek ayrımı
      parmakla ayırt edilebiliyor mu, titreşim rahatsız ediyor mu
- [ ] Android dışa aktarımı + dokunmatik hedef boyutlarını büyüt
- [ ] Dikey en-boy oranında test

### Yayın

- [ ] itch.io sayfasını aç ve `yayin/butler-komutlari.md` ile yükle — **Furki'nin kararı**
- [ ] Tanıtım GIF'i (çevirme anı en iyi gösteren 3 saniye)
