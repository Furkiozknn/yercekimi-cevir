# Yerçekimi Çevir

Zıplama yok: tek tuşla yerçekimini ters çevirip tavana "düşerek" dikenlerden kaçtığın
kısa ve zor bir hassas platform oyunu. **20 bölüm**, her bölüm 1–2 ekran.

![Ana menü](docs/01-menu.png)
![Çevirme anı](yayin/ekran/04-cevirme.png)

## Kontroller

| Eylem | Klavye | Gamepad | Dokunmatik |
|---|---|---|---|
| Yürü | `A` / `D` ya da ok tuşları | sol çubuk / D-pad | ekrandaki `<` `>` |
| **Çevir** | `Boşluk` ya da `W` | `A` | ekrandaki `ÇEVİR` |
| Duraklat | `Esc` | `Start` | — |

Çevirme **yalnızca bir yüzeye değerken** çalışır — havada ikinci kez çeviremezsin.
Yüzeye değmeden ~0,1 sn önce bastıysan yine de sayılır (giriş tamponu).
Dokunmatik düğmeler sadece dokunmatik cihazda görünür.

Diken ya da ekran dışına düşmek öldürür; ölünce 0,3 sn sonra otomatik olarak
bölüm başına — ya da geçtiysen **kontrol noktasına** — dönersin. Süre sayacı
ölümlerle sıfırlanmaz, bölüm değişince sıfırlanır.

## Bölümde ne var

- **Gizli kristal** (her bölümde 1). Her zaman ana rotanın dışında: genelde tavanda,
  zeminde yürürken kaçamak yapman gereken bir yerde. Toplanınca kalıcı kaydedilir.
- **Madalya süreleri.** Her bölümün altın / gümüş / bronz hedefi var; arayüzün sağ
  üstünde yazıyor, en iyi madalyan Bölüm Seç'te görünüyor.
- **Kontrol noktası.** 64 sütunluk uzun bölümlerin ortasında bir mavi direk;
  ona değdikten sonra ölünce oraya dönersin.

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
| `scripts/oyuncu.gd` | Çevirme mekaniği, yatay ivme, ölüm, hayalet izi, esneme-sıkışma. |
| `scripts/oyun.gd` | Bölüm döngüsü, kristal/kontrol noktası/madalya, sarsıntı, parçacık, geçiş. |
| `tools/` | Varlık üreticileri (pixel art, ses) + `sesler.md`. |
| `tests/` | Headless otomatik test (362 doğrulama) + ekran görüntüsü aracı. |

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

## Durum

**Yayına hazır ilk sürüm (v0.2).** Çekirdek mekanik, 20 bölüm, gerçek pixel art,
ses, ayarlar ekranı, oyun hissi, kristal/madalya/kontrol noktası, ilerleme kaydı
ve yayın paketi tamam. Yükleme yapılmadı. Sonraki adımlar: `YOL-HARITASI.md`.

İlerleme ve ayarlar `user://kayit.cfg` dosyasında (Windows'ta
`%APPDATA%\Godot\app_userdata\Yerçekimi Çevir\kayit.cfg`).
