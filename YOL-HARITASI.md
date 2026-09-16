# Yol Haritası — Yerçekimi Çevir

## Bu turda yapıldı (2026-09-16)

- [x] Çevirme mekaniği: `up_direction` + yerçekimi işareti ters çevirme, `flip_v`,
      yalnızca yüzeydeyken, ~0,1 sn giriş tamponu
- [x] Yatay ivmeli yürüme, havada azaltılmış kontrol, zıplama yok
- [x] 12 bölüm (ilk 3 öğretici + yazılı ipucu, kademeli zorluk)
- [x] Hareketli platform (6, 10, 11, 12) ve gezgin diken (8)
- [x] Diken teması ve ekran dışına düşme = ölüm; 0,3 sn sonra otomatik yeniden deneme
- [x] Bölüm sonu kapısı → sonraki bölüm; son bölümden sonra bitiş ekranı
- [x] Bölüm başına süre + ölüm sayacı, en iyi süre kaydı (`user://kayit.cfg`)
- [x] Ana menü, Bölüm Seç (kilitli/açık), duraklatma menüsü — hepsi Türkçe
- [x] Klavye + gamepad girdisi; dokunmatik cihazda 3 ekran düğmesi
- [x] Headless otomatik test (97 doğrulama) + geliştirici ekran görüntüsü aracı
- [x] Windows ve Web dışa aktarımı

## Sonraki aşamalar

### Oynanış
- [ ] Bölüm sayısını 24'e çıkar; 13+ için yeni mekanik (dikey kaydırmalı bölüm,
      tek yönlü platform, çevirmeyi engelleyen bölge)
- [ ] Çevirme hissini cilala: kısa ekran sarsıntısı, iz (trail), yavaşlatma kareleri
- [ ] Hayalet (ghost) tekrarı — en iyi koşunu bölümde göster
- [ ] Bölüm içi ara kayıt noktası (uzun bölümler için)

### Görsel ve ses
- [ ] Gerçek pixel art (Pixelorama): oyuncu, diken, blok, kapı, arka plan katmanı
- [ ] Ölüm/çevirme/kapı efektleri (parçacık)
- [ ] Ses: çevirme, ölüm, kapı, ambiyans müzik
- [ ] Ters yerçekiminde arka plan renginin kayması (durumu okunur kılar)

### Mobil
- [ ] Dokunmatik düğme yerleşimini gerçek telefonda dene (şu an yalnız kodla ayarlı)
- [ ] Android dışa aktarımı + dokunmatik hedef boyutlarını büyüt
- [ ] Dikey en-boy oranında test

### Yayın
- [ ] Web yapısını tarayıcıda elle doğrula (bu turda yapılmadı)
- [ ] itch.io sayfası, kapak görseli, GIF
- [ ] Bölüm başı tabelası / en iyi süre listesi
