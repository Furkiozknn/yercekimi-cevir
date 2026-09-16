# Yerçekimi Çevir — proje kuralları

Bu dosya her oturumda otomatik yüklenir. Kısa ve güncel tut.

## Ne bu

Godot 4.7 / GDScript, 2B hassas platform oyunu. Tek dikey eylem **çevirme**:
yerçekimi işareti ters döner, oyuncu tavana "düşer". Zıplama yok. 20 bölüm.
Arayüz ve tüm belgeler **Türkçe**.

## Değişmez teknik kararlar

| Konu | Karar | Neden |
|---|---|---|
| Renderer | **GL Compatibility** | Tümleşik GPU (Intel UHD) hedefi; web export'ta da tek yol |
| Doku filtresi | `default_texture_filter=0` (nearest) | pixel art bulanıklaşmasın |
| Piksel oturtma | `snap_2d_transforms_to_pixel` + `snap_2d_vertices_to_pixel` açık | titreme olmasın |
| Taban çözünürlük | 640×360, pencere 1280×720, stretch `canvas_items` / `keep` | 16×16 ızgara tam oturuyor (22 satır = 352 px) |
| Dosya kodlaması | **BOM'suz UTF-8, LF** | `.gitattributes` zorluyor |
| Ses düzeyi | `AudioServer.set_bus_volume_db()` — oynatıcıda **değil** | web'de Sample yolunda `volume_db` sessizce yok sayılıyor |
| Web ses yolu | `audio/general/default_playback_type.web=2` (Stream) | Sample yolunda perde/döngü de bozuluyor (Godot #95850) |
| WAV | 16 bit, 22050 Hz, mono | 8 bit WAV'lar içe aktarımda hata basıyor |

## Klasör yapısı

```
scripts/     ayarlar.gd (TÜM denge sabitleri + kayıt + ayarlar) · ses.gd (autoload)
             bolum.gd (ASCII harita -> sahne) · oyuncu.gd · oyun.gd · menu.gd
             bolum_sec.gd · ayarlar_ekrani.gd · bolumler.gd (ÜRETİLİR, elle düzenleme)
scenes/      menu · bolum_sec · ayarlar_ekrani · oyun · oyuncu
assets/      sprites/*.png (ÜRETİLİR) · audio/*.wav (ÜRETİLİR) · oyuncu_frames.tres
tools/       uret_sprite.py · uret_ses.py · muzik_uret.gd · sesler.md
arac/        uret_bolumler.py
tests/       testler.gd (otomatik test) · ekran.gd (ekran görüntüsü aracı)
yayin/       itch.io paketi (yüklenmemiş)
docs/        README görselleri · varliklar.png (sprite denetim levhası)
build/       dışa aktarma çıktısı — `.gdignore` var, SİLME
```

**Denge sabitleri tek yerde:** `scripts/ayarlar.gd`. Hız, yerçekimi, çevirme
tamponu, iz/sarsıntı/ezilme değerleri, madalya renkleri hep orada.

## Üretilen varlıklar — elle düzenleme

Üçü de yeniden çalıştırılabilir; çıktıyı elle düzeltme, betiği düzelt.

```bash
python arac/uret_bolumler.py     # scripts/bolumler.gd (çözülebilirliği doğrular)
python tools/uret_sprite.py      # assets/sprites/*.png + docs/varliklar.png
python tools/uret_ses.py         # assets/audio/*.wav (rFXGen gerekir)
godot --headless --path . -s res://tools/muzik_uret.gd -- --cikti res://assets/audio/muzik_oyun.wav --ruh gizemli --tohum 5
```

Sprite üretiminden sonra **`--import` çalıştır**, yoksa Godot eski PNG'yi kullanmayı sürdürür
(bu bir kez ekran görüntüsünde yakalandı: dosya değişti, oyun eskisini gösteriyordu).

## Komutlar

```bash
godot --headless --path . --import                      # 0 hata vermeli
godot --headless --path . res://tests/testler.tscn      # çıkış kodu 0 = geçti
godot --path . res://tests/ekran.tscn -- -2 <klasör>    # yayın paketi görselleri
godot --path . res://tests/ekran.tscn -- -1 <klasör>    # menü / bölüm seç / ayarlar
godot --headless --path . --export-release "Windows Masaustu"
godot --headless --path . --export-release "Web (HTML5)"
```

Dışa aktarmadan önce `build/windows` ve `build/web` klasörleri **var olmalı**
(Godot yolu kendisi oluşturmuyor, "dışa aktarım yolu mevcut değil" der).

## Godot kilidi

Aynı anda birden çok oyun oturumu çalışabiliyor, RAM dar. Godot çalıştırmadan önce:

```bash
[ -f D:/Repolar/.godot-kilit ] || echo "yercekimi-cevir" > D:/Repolar/.godot-kilit
# ... iş bitince
rm -f D:/Repolar/.godot-kilit
```

Kilit varsa ve 15 dakikadan yeniyse 30 sn bekle. Açık Godot süreci bırakma.

## Yayın

**Push yok, GitHub deposu yok, itch.io yüklemesi yok.** Yerel commit ve
`git tag` serbest. Yayın paketi `yayin/` altında yalnız hazırlanır;
`yayin/butler-komutlari.md` içindeki komutlar **çalıştırılmamıştır**,
kararı Furki verir.

## Bilinen tuzaklar (hepsi sessizce yanlış davranıyordu)

1. **Yeni Area2D bayat örtüşme tetikler.** Bölüm kodla yeniden kurulurken oyuncu
   hâlâ önceki bölümün konumundadır; `monitoring=true` ile doğan alan bunu
   `body_entered` sayar ve bölüm atlanır. Çözüm: `monitoring=false` ile kur,
   ilk fizik karesinden sonra aç (`Bolum._alan_gecikmesi`).
2. **Sinyal işlenirken `monitoring` değiştirilemez** — `set_deferred("monitoring", false)`.
3. **`const X: Array = [PackedStringArray([...])]` derlenmez**; düz `Array` kullan.
4. **Kapanışta müzik.** Godot ağacı alttan yukarı söküyor: `_exit_tree()` çalıştığında
   oynatıcı zaten ağaçtan çıkmış oluyor. `Ses.kapat()` çıkmadan **önce** çağrılmalı,
   üstüne bir karıştırma turu beklenmeli — yoksa "resource still in use at exit".
5. **`--quit-after` ile yapılan duman testleri** müzik çalarken süreci öldürdüğü için
   bu uyarıyı basar; gerçek çıkış yolu ve test paketi temizdir.
6. **Arka planda yatay çizgi yapma.** İlk turda arka plandaki uyarı şeridi
   platform sanılıyordu; arka plan artık yalnız dikey öğeler içeriyor.
