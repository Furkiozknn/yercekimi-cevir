# Sesler — hangisi nasıl üretildi

Hepsi `python tools/uret_ses.py` ile yeniden üretilir. Çıktı: 22050 Hz / 16 bit / mono.

## rFXGen notu (önemli)

`D:\Araclar\rFXGen\rfxgen_v5.0_win_x64\rfxgen.exe`

```
rfxgen.exe --generate <onayar> --output <dosya.wav> --format 22050,16,1
```

Ortak araçlar belgesi "her çalıştırma rastgele bir varyasyon üretir, 4–6 aday
üretip beğendiğini seç" diyor. **Bu sürümde öyle değil:** aynı ön ayar her
çalıştırmada birebir aynı dosyayı veriyor (5'er aday üretilip md5 ile
doğrulandı — `coin`, `jump`, `explosion` için hepsi aynı hash).

Bu yüzden çeşitlilik **perde kaydırmayla** elde edildi: `uret_ses.py` ham
dosyayı doğrusal ara değerli yeniden örneklemeyle hızlandırıp yavaşlatıyor
(perde + süre birlikte değişir), kazanç uyguluyor ve sonuna 2 ms sönüm koyuyor.

## Efektler

| Dosya | Ön ayar | Perde | Kazanç | Süre | Nerede |
|---|---|---|---|---|---|
| `cevir.wav` | jump | 1.00 | 0.85 | 0.32 sn | zeminden tavana çevirme |
| `cevir_ters.wav` | jump | 0.78 | 0.85 | 0.42 sn | tavandan zemine çevirme (daha pes) |
| `kristal.wav` | coin | 1.15 | 0.90 | 0.25 sn | gizli kristal toplama |
| `kontrol.wav` | coin | 0.70 | 0.80 | 0.40 sn | kontrol noktası etkinleşti |
| `olum.wav` | explosion | 0.85 | 0.90 | 0.16 sn | ölüm |
| `bolum_sonu.wav` | powerup | 1.00 | 0.90 | 0.54 sn | kapıya varış |
| `madalya.wav` | powerup | 1.35 | 0.85 | 0.40 sn | madalya kazanıldı (bölüm sonuyla üst üste) |
| `menu.wav` | blip | 1.00 | 0.55 | 0.11 sn | menü tıklaması, duraklatma |
| `inis.wav` | hit | 0.70 | 0.35 | 0.20 sn | yüzeye konuş — kısık olmalı, çok sık çalıyor |

Ham rFXGen çıktıları `assets/audio/ham/` altında tutulur, depoya girmez
(`.gitignore`) ve `.gdignore` ile içe aktarılmaz.

## Müzik

`tools/muzik_uret.gd` (ortak araçlardan kopya, değiştirilmedi).

```bash
godot --headless --path . -s res://tools/muzik_uret.gd -- --cikti res://assets/audio/muzik_menu.wav   --ruh sakin   --tohum 2
godot --headless --path . -s res://tools/muzik_uret.gd -- --cikti res://assets/audio/muzik_sakin.wav  --ruh sakin   --tohum 7
godot --headless --path . -s res://tools/muzik_uret.gd -- --cikti res://assets/audio/muzik_gergin.wav --ruh gergin  --tohum 3
godot --headless --path . -s res://tools/muzik_uret.gd -- --cikti res://assets/audio/muzik_hizli.wav  --ruh hizli   --tohum 11
godot --headless --path . -s res://tools/muzik_uret.gd -- --cikti res://assets/audio/muzik_bitis.wav  --tur jingle  --ruh neseli --tohum 1
```

| Dosya | Ruh | Süre | Nerede |
|---|---|---|---|
| `muzik_menu.wav` | sakin (tohum 2) | 20,9 sn | menü, bölüm seç, ayarlar |
| `muzik_sakin.wav` | sakin (tohum 7) | 20,9 sn | bölüm 1–7 |
| `muzik_gergin.wav` | gergin (tohum 3) | 13,7 sn | bölüm 8–14 |
| `muzik_hizli.wav` | hızlı (tohum 11) | 12,8 sn | bölüm 15–20 |
| `muzik_bitis.wav` | neşeli (jingle) | 4,3 sn | bitiş ekranı, döngüsüz |

Grup seçimi `Ses.bolum_parcasi(i)` (v0.6). v0.5'e kadarki tek oyun parçası
(`gizemli`, tohum 5, 17,8 sn) `_eski/audio/muzik_oyun.wav` altında.
Parçalar dinlenmedi; beğenilmeyen grupta yalnız `--tohum` değiştir ve yeniden üret.

Döngü noktaları çalışma anında `scripts/ses.gd` içinde kuruluyor
(`loop_mode = LOOP_FORWARD`, `loop_end = get_length() * mix_rate`), içe
aktarma ayarına güvenilmiyor. **`data.size() / 2` kullanma:** içe aktarma
QOA ile sıkıştırıyor (`compress/mode=2`), o zaman bayt/2 parçanın beşte biri
olur ve müzik ~4 sn'de başa sarar — v0.5'e kadar böyleydi. `_ses_testi`
artık `loop_end == uzunluk` istiyor.

## Ses veriyolları

`default_bus_layout.tres`: Master → `Muzik`, `Efekt`. Ses düzeyi
**oynatıcıda değil veriyolunda** ayarlanır (`Ayarlar.ses_uygula()`), çünkü
Godot'un web hedefindeki Sample yolu `volume_db`'yi yok sayabiliyor.
