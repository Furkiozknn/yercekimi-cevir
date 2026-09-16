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
sağ çeyrek sağ), sağ yarısı çevirme. Solak seçeneği tarafları değiştirir,
düğme opaklığı ve titreşim ayarlardan.

Diken ya da ekran dışına düşmek öldürür; ölünce **0,18 sn** sonra otomatik olarak
bölüm başına — ya da geçtiysen **kontrol noktasına** — dönersin. Sahne yeniden
yüklenmez, hareketli platformlar dahil her şey sıfırlanır. Süre sayacı ölümlerle
sıfırlanmaz, bölüm değişince sıfırlanır.

## Bölümde ne var

- **Gizli kristal** (her bölümde 1). Her zaman ana rotanın dışında: genelde tavanda,
  zeminde yürürken kaçamak yapman gereken bir yerde. Toplanınca kalıcı kaydedilir.
- **Madalya süreleri.** Her bölümün altın / gümüş / bronz hedefi var; arayüzün sağ
  üstünde yazıyor, en iyi madalyan Bölüm Seç'te görünüyor.
- **Kontrol noktası.** 64 sütunluk uzun bölümlerin ortasında bir mavi direk;
  ona değdikten sonra ölünce oraya dönersin.
- **"En az çevirme" ikinci hedefi.** Süreden bağımsız: her bölümün kaç çevirmeyle
  çözülebileceği bölüm verisinden hesaplanıyor, senin en iyi çevirme sayın
  kaydediliyor. Hızlı bitirmek ve az çevirmek iki ayrı oyun.
- **Hayalet yarış.** O bölümdeki en iyi koşun yarı saydam olarak yanında koşar;
  rengi o koşunun madalyası — altın koşu altın hayalet.
- **Ölüm haritası.** Bölüm bitince bölümün küçültülmüş planı ve öldüğün her nokta
  X ile. "Burada takılıyorsun" demenin en kısa yolu.

## Okunurluk ve yardım

- **Oda tabanlı kamera.** Kamera seni izlemez, 640 px'lik odalar arasında atlar.
  Bir odadaki tehlikenin tamamı hep ekrandadır; ekran dışından gelen ölüm yok.
- **Yerçekimi oku.** Yanındaki küçük ok hangi yöne çekildiğini gösterir —
  durum renkten değil biçimden okunur.
- **İniş göstergesi.** Çevirme tuşunu basılı tutarsan karşı yüzeyde nereye ineceğin
  işaretlenir; yolda diken varsa işaret kırmızıya döner.
- **Yüksek kontrast** seçeneği tehlikeleri parlatır, zemini ve arka planı geri çeker.
- **Yardım modu.** Oyun hızı %50–100, dikenler öldürmek yerine iter, duraklatma
  menüsünden bölüm atlanır. Açıkken süre, madalya ve çevirme kaydı tutulmaz;
  kristaller sayılır. İstediğin an kapatılır.

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
| `scripts/ses.gd` | Efekt havuzu ve müzik (autoload). Ses düzeyi AudioServer veriyolunda. |
| `scripts/bolumler.gd` | 20 bölüm, ASCII harita olarak. `arac/uret_bolumler.py` üretir. |
| `scripts/bolum.gd` | ASCII haritayı çalışma anında çarpışma gövdesi + pixel art çizime çevirir. |
| `scripts/oyuncu.gd` | Çevirme mekaniği (tampon + kojot), yerçekimi oku, ölüm, esneme-sıkışma. |
| `scripts/oyun.gd` | Bölüm döngüsü, oda kamerası, hayalet, ölüm haritası, iniş göstergesi, yardım modu. |
| `tools/` | Varlık üreticileri (pixel art, ses) + `sesler.md`. |
| `tests/` | Headless otomatik test (464 doğrulama) + ekran görüntüsü aracı. |

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

## Durum

**v0.3 — rakip analizi iyileştirmeleri.** v0.2'nin üstüne: affetme (kojot +
küçültülmüş isabet kutusu + 0,18 sn yeniden deneme), oda tabanlı kamera, yardım
modu, yüksek kontrast / yerçekimi oku / iniş göstergesi, geniş dokunmatik alanlar,
hayalet yarış, ölüm haritası, "en az çevirme" ikinci hedefi. Yükleme yapılmadı.
Sonraki adımlar: `YOL-HARITASI.md`.

İlerleme ve ayarlar `user://kayit.cfg` dosyasında (Windows'ta
`%APPDATA%\Godot\app_userdata\Yerçekimi Çevir\kayit.cfg`).
