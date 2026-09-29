# Denetim — arayüz yenilemesi öncesi durum (29 Eylül 2026)

Kapsam: `main` dalının `0c67cec` hâli (v0.7.2 + README düzeltmeleri). Oyun bu
makinede (Windows 11, Intel UHD, Godot 4.7.2) gerçekten açılıp oynandı;
yalnızca kod okunmadı. Bulguların hepsi görsel kanıtla desteklidir:
`docs/tasarim/once-*.png` (bu belgede geçen "önce" kareleri).

## Nasıl denetlendi

| Yol | Ne yapıldı |
|---|---|
| Masaüstü (Godot) | `tests/ekran.tscn` ile menü / Bölüm Seç / Ayarlar / 10. bölüm oynanışı 1280×720 karelere alındı; `tools/fps.gd` ile kare süresi ölçüldü. |
| Web, yerel | `main`'den `--export-release "Web (HTML5)"`, `build/web` içinde `python -m http.server 8060`; Claude Browser ile açıldı, `Enter` / `D` / `Boşluk` ile oynandı, konsol okundu. |
| Web, canlı | `https://furkiozknn.github.io/yercekimi-cevir/` açıldı: menü geldi, Başla 1. bölümü yükledi, Boşluk yerçekimini çevirdi. |
| Mobil | Tarayıcıda 375×812 dokunmatik emülasyonu (yeni yapıda; eski yapıda dikey ipucu yoktu). Gerçek telefonda denenmedi. |
| Girdi gecikmesi | `tools/his_olc.gd`: tuş olayından `cevirdi` sinyaline süre, 100 deneme, rastgele faz. |

## Bulgular

### İlk 30 saniye anlaşılıyor mu?

Yarı yarıya.

- Menüde dört eşit ağırlıklı, koyu-gri düz düğme var (`Başla`, `Bölüm Seç`,
  `Günün Bölümü`, `Ayarlar`); hangisinin asıl eylem olduğu belli değil.
  Yeşil başlık ve sarı "günün bölümü" satırı dikkat için yarışıyor.
- Alt başlık "Zıplama yok. Tek tuş: yerçekimini çevir." diyor, ama oyun iki
  girdi istiyor: **A/D ile yürü + Boşluk ile çevir**. "Tek tuş" ile ilk
  oyun arasında bir boşluk var; tuş adları hiçbir yerde tek satırda yazmıyor.
- 1. bölümün ipucu yalnız "A / D ile yürü. Yeşil kapıya ulaş." Çevirmenin
  ne olduğu 2. bölüme kadar öğretilmiyor. (Bölüm 1 çevirmeden bitiyor; bu
  bilinçli, ama oyuncu ilk 30 sn'de oyunun tek fikrini görmüyor.)
- Bölüm başı kartı "10 — Dört Vuruş · altın 7.04 sn · en iyi —" bilgi
  veriyor ama ilk kez oynayan için gürültü.
- Üst HUD üç satır: bölüm adı, "Süre 2.76  Ölüm 1  ⟳ 1", "● 7.04 ● 9.13
  ● 12.52 sn · en az ⟳ 4 · en iyi —". Oynarken gereken tek şey süre ve oda;
  gerisi Bölüm Seç'te de var.

![önce: menü](tasarim/once-menu.png)
![önce: oyun](tasarim/once-oyun.png)

### Kontrol tepkisi

- Çevirme tuşu `_physics_process` içinde okunuyordu; olay 60 Hz fizik
  adımını bekliyordu. Ölçüm (`tools/his_olc.gd`, gerçek zamanlı, 100 deneme,
  tuş olayı → `cevirdi`): **ortalama 13,0 ms, %95 = 20,6 ms, en yüksek
  30,5 ms**. Ses, renk geçişi ve parçacık geri bildirimi de bu gecikmeyle
  geliyordu.
- Affetme değerleri: giriş tamponu 0,10 sn, kojot 0,08 sn
  (`Ayarlar.CEVIR_TAMPONU`, `CEVIR_KOJOT`). Testler (`_kojot_testi`,
  `_cevirme_testi`) bunları sınıyor; oynanışta "bir kare geç bastım"
  ölümü yok.
- Dokunmatik alanlar `Input.action_press` ile basıyordu (olay üretmiyor);
  bu yüzden bir iyileştirme dokunmaya da uygulanamazdı.

### Zorluk eğrisi adil mi?

Bot ölçümü (`tools/bot.gd ... insan`: tepki 0,18–0,35 sn, 20 bölüm × 5
koşu, dosya yazılmaz): **20/20 bölümde insan bandındaki bot mevcut altın
eşiğini tutuyor**. En pahalı bölümler botun ortancasına göre 15 (×1,30),
6 (×1,26), 7 (×1,26). Bu bir **bot** ölçümüdür; insan bir politika değildir
(bkz. hafıza notu "bot ölçümü insanı temsil etmez"): bu tablo "bir insan
tepkisiyle bile çözülebilir"in kanıtıdır, "zevkli"nin değil. Tam tablo
`docs/DENETIM-insan-tablosu.txt`.

### Oyun sonu ve bölüm sonu

- Bölüm sonu: ekranda tek satır "BÖLÜM TAMAM — 4.82 sn / Altın madalya",
  1 sn (ölüm haritası varsa 2,4 sn) sonra sonraki bölüm. Süre, rekor ve en
  iyi süre küçük ve kısa ömürlü.
- Ölüm: 0,18 sn'de yeniden doğuş — iyi, dokunulmadı.
- 20. bölümden sonra: düz yazı özeti + tek düğme "Menüye Dön". "Tekrar
  oyna" yok; en fazla bir tık ama menüden tekrar başlatmak gerekiyor.

### Mobil ve dokunmatik

- Dokunmatik alanlar iyi tasarlanmış (ekranın yarısı düğme, solak seçeneği).
- Ama en-boy oranı `keep` (bilinçli, oda kamerası 640×360'a kilitli): dikey
  telefonda oyun ekranın üçte birinde küçük bir şerit. Kullanıcıya "telefonu
  yatay tut" diyen hiçbir şey yoktu.
- Web'de ilk dokunuş `dokunmatik_algilandi`'yı açıyor; bu doğru çalışıyor.

### Konsol ve web

- Yerel eski yapı ve canlı sayfada oyun hata vermeden yükleniyor. Konsolda
  yalnız Godot'nun bilgi satırları (`Godot Engine v4.7.2 ...`, `OpenGL ES 3.0`,
  `single-threaded`). Canlı sayfada açılış sırasında altı adet
  `GL_INVALID_FRAMEBUFFER_OPERATION ... Attachment has zero size` **uyarısı**
  görüldü (boyutu sıfır çerçeve; boyutlandırma sırasında; görüntüyü
  etkilemiyor).
- Web paketi (yerel dışa aktarma, `main`): `index.pck` 830.812 bayt,
  `index.wasm` 39.514.754 bayt, `index.js` 279.815 bayt.

### Erişilebilirlik / okunurluk (kod okuması)

- Simge yazı tipi yedeği (`simgeler.ttf`) doğru kurulu; web'de kutu çıkmıyor.
- Yüksek kontrast seçeneği "tehlikeleri parlat, zemini kıs" yapıyordu.
- Yardım modu var ve iyi; dokunulmadı.

## Ölçümler (önce)

| Ölçüm | Değer | Nasıl |
|---|---|---|
| Kare süresi, 10. bölüm | ort. 2,67 ms, %99 3,67 ms (≈375 FPS) | `tools/fps.gd`, vsync kapalı, 600 kare, Intel UHD |
| Kare süresi, 20. bölüm | ort. 2,87 ms, %99 4,16 ms (≈349 FPS) | aynı |
| Tuş → çevirme | ort. 13,0 ms, %95 20,6 ms, en yüksek 30,5 ms | `tools/his_olc.gd`, 100 deneme |
| Web paketi | pck 830.812 + wasm 39.514.754 + js 279.815 = 40.625.381 bayt | `build/web` |
| Test tabanı | 841 (CI `TEST_TABANI`) | `ci.yml` |

## Sonuç

Çekirdek mekanik sağlam ve çözülebilirlik kanıtlı; sorun oyuncuya nasıl
anlatıldığı ve nasıl göründüğüydü: eşit ağırlıklı menü, iki girdinin tek
tuş diye anlatılması, gürültülü HUD, bölüm sonunun görünmez olması, dikey
telefonda uyarı yokluğu. Bunlar `docs/TASARIM.md`'de ele alındı.
