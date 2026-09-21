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
| Kamera | **Oda tabanlı**, oyuncunun çocuğu değil (`Dunya/Kamera`) | tehlike ekran dışında kalmasın; izleyen kamera bunu garanti etmiyor |
| İsabet kutusu | Öldüren şeyde görselden `DIKEN_PAY` (3 px) küçük, **basılan** yüzeyde birebir | küçük kutu affeder, küçük platform yalan söyler |
| Web ses yolu | `audio/general/default_playback_type.web=2` (Stream) | Sample yolunda perde/döngü de bozuluyor (Godot #95850) |
| WAV | 16 bit, 22050 Hz, mono | 8 bit WAV'lar içe aktarımda hata basıyor |
| Müzik döngü sonu | `loop_end = get_length() * mix_rate` (`ses.gd`) | içe aktarma QOA sıkıştırıyor; `data.size()/2` beşte bire düşüyordu (tuzak 18) |
| Üst HUD | `Arayuz/HudSol` ve `HudSag` grupları, tavandaki oyuncu girince alfa 0,25 | şeritleri daraltmak 640 px'te metni sığdırmıyor |
| Simge yazı tipi | `assets/fonts/simgeler.ttf`, `Simgeler.kur()` `Ayarlar._ready()` içinde | gömülü Open Sans'ta `⟳ ●` yok; web'de sistem yazı tipi yedeği olmadığı için kutu çıkıyordu |
| En-boy oranı | `keep` (siyah şerit) — `expand` **yapılmadı** | oda kamerası 640 px'lik odalara kilitli; geniş görüş alanı 40 sütunluk bölümlerde bölüm dışını gösterir |

## Klasör yapısı

```
scripts/     ayarlar.gd (TÜM denge sabitleri + kayıt + ayarlar + hayalet) · ses.gd (autoload)
             simgeler.gd (web'de eksik simgeler için yedek yazı tipi; ortak dosya)
             bolum.gd (ASCII harita -> sahne) · oyuncu.gd · oyun.gd · menu.gd
             bolum_sec.gd · ayarlar_ekrani.gd · bolumler.gd (ÜRETİLİR, elle düzenleme)
             rota_verisi.gd (ÜRETİLİR: madalya eşikleri + en az çevirme)
             altin_hayalet.gd (ÜRETİLİR: botun en iyi koşusunun yolu)
scenes/      menu · bolum_sec · ayarlar_ekrani · oyun · oyuncu
assets/      sprites/*.png (ÜRETİLİR; kapi.png 4 kare 64×48, kristal.png tek kare = HUD
             simgesi, kristal_parilti.png 4 kare = bölüm içi) · audio/*.wav (ÜRETİLİR;
             muzik_{menu,sakin,gergin,hizli,bitis}) · oyuncu_frames.tres
             fonts/simgeler.ttf + LISANS-simgeler.txt (lisans gereği yanında kalmalı)
_eski/       silinmeyen eskiler (.gdignore): audio/muzik_oyun.wav (v0.5 tek oyun parçası),
             yayin-ekran-v0.x/
tools/       uret_sprite.py · uret_ses.py · muzik_uret.gd · sesler.md
             bot.gd (madalya sürelerini ölçen bot) · gif_yap.py (bağımlılıksız GIF)
arac/        uret_bolumler.py
tests/       testler.gd (otomatik test) · ekran.gd (ekran görüntüsü aracı)
yayin/       itch.io paketi (yüklenmemiş) · yayin/tanitim/ 3 sn tanıtım GIF'i + kareler
docs/        README görselleri · varliklar.png (sprite denetim levhası)
build/       dışa aktarma çıktısı — `.gdignore` var, SİLME
```

**Madalya eşikleri ve "en az çevirme" hedefi tek yerde:** üretilen
`scripts/rota_verisi.gd`, `Ayarlar.esik()` üzerinden okunur. Dosya boşsa
`bolumler.gd` içindeki geometri yedeğine düşer, yani oyun yine çalışır.
**Eşiği kod içinde başka bir yerden okuma** — testler bile `Ayarlar.esik()`
kullanmalı, yoksa iki kaynak olur (bu bir kez oldu: 60 test kaldı).

**Denge sabitleri tek yerde:** `scripts/ayarlar.gd`. Hız, yerçekimi, çevirme
tamponu ve kojotu, ölüm bekleme süresi, diken payı, oda ölçüsü, hayalet aralığı,
iz/sarsıntı/ezilme değerleri, madalya renkleri hep orada.

**Kullanıcı ayarları da orada** ve hepsi `user://kayit.cfg` içinde saklanıyor:
ses, tam ekran, oyun hissi, yüksek kontrast, yerçekimi oku, iniş göstergesi,
solak dokunmatik, düğme opaklığı, titreşim, yardım modu (açık/hız/ölümsüzlük).
Yeni bir ayar eklerken **üç yeri** birden güncelle: `var`, `yukle()`, `kaydet()` —
ve `tests/testler.gd` içindeki `_ayar_kayit_testi` bunu doğruluyor.

**Günün bölümü** (`Ayarlar.gunluk_*`): tarihten seçilen bölüm + değiştirici
(0 ters başlangıç, 1 kristal zorunlu, 2 hayalet yarışı), `[gunluk]` bölümünde
**ayrı kayıt**. `Ayarlar.gunluk_mod` oturum bayrağı; `menu.gd` `_ready()`
içinde kapatır, menü düğmesi açar. Oyun sahnesinde `gunluk_mod` açıkken
`bolum_bitti()`, `kristal_topla()`, `hayalet_kaydet()`, `bolum_ac()`
**çağrılmaz** — `_gunluk_testi` ana ilerlemenin el değmediğini üç
değiştiricide de ölçüyor. Tarihi test/ekran için `Ayarlar.tarih_zorla` ile
sabitle (0 = sistem tarihi). **Seri** (`gunluk_seri`, `gunluk_seri_tarih`)
tarih değişince sıfırlanmaz; `gunluk_seri_al()` bugüne göre geçerli seriyi
verir (son bitiş dün ya da bugün değilse 0). Bitişte menüye dönülmez:
`_gunluk_panel()` paylaşım paneli açar, kopyalama `Kopyala` düğmesine bağlı
(web'de pano yalnız kullanıcı dokunuşuyla yazılır). Hayalet yarışında
`_altin_yol` ayara bakmadan yüklenir; hayaletin yolu bitince (`_hayalet_bitti`)
`_durum = HAYALET` → 1 sn sonra `bolum_yukle(bolum_i)` (tam sıfırlama).

**Müzik** bölüm grubuna göre: `Ses.bolum_parcasi(i)` (0–6 sakin, 7–13 gergin,
14–19 hızlı); `oyun.gd` `bolum_yukle()` içinde çağırır. Tohumlar ve süreler
`tools/sesler.md`. **Parıltı:** kapı ve kristal `hframes=4`, `Bolum._process`
tek sayaçla (`PARILTI_ARALIGI` 0,15 sn) kareyi seçer; bot/test kareye bakmaz.

**Hayalet kayıtları** `user://hayalet_<bolum>.dat` (PackedVector2Array).
`Ayarlar.sifirla()` bunları da siler; silmezse önceki koşudan kalan kayıt
testleri ve yeni oyuncunun ilk koşusunu kirletiyor.

## Üretilen varlıklar — elle düzenleme

Üçü de yeniden çalıştırılabilir; çıktıyı elle düzeltme, betiği düzelt.

```bash
python arac/uret_bolumler.py     # scripts/bolumler.gd (çözülebilirliği doğrular)
godot --headless --path . res://tools/bot.tscn --fixed-fps 60 -- 5
                                 # scripts/rota_verisi.gd + scripts/altin_hayalet.gd
                                 # (5 = bölüm başına koşu; 3. argüman "iz" tanılama yazar)
godot --headless --path . res://tools/bot.tscn --fixed-fps 60 -- 5 -1 - insan
                                 # "insan" tepki bandı (0,18-0,35 sn): DOSYA YAZMAZ,
                                 # yalnız tablo basar — madalya çarpanı gerekçesi için
python tools/uret_sprite.py      # assets/sprites/*.png + docs/varliklar.png
python tools/uret_ses.py         # assets/audio/*.wav (rFXGen gerekir)
godot --headless --path . -s res://tools/muzik_uret.gd -- --cikti res://assets/audio/muzik_sakin.wav  --ruh sakin  --tohum 7   # 1-7, 20,9 sn
godot --headless --path . -s res://tools/muzik_uret.gd -- --cikti res://assets/audio/muzik_gergin.wav --ruh gergin --tohum 3   # 8-14, 13,7 sn
godot --headless --path . -s res://tools/muzik_uret.gd -- --cikti res://assets/audio/muzik_hizli.wav  --ruh hizli  --tohum 11  # 15-20, 12,8 sn
                                 # menü: --ruh sakin --tohum 2 (20,9 sn) · bitiş: --tur jingle --ruh neseli --tohum 1
```

Müzik üreteci `-s` ile çalışırken autoload'lar da yükleniyor: `ses.gd`'deki
`preload`'lar var olmayan bir WAV'a bakıyorsa üreteç hata basar. Yeni parça
eklerken **önce üret, `--import` çalıştır, sonra `ses.gd`'ye ekle.**

Sprite üretiminden sonra **`--import` çalıştır**, yoksa Godot eski PNG'yi kullanmayı sürdürür
(bu bir kez ekran görüntüsünde yakalandı: dosya değişti, oyun eskisini gösteriyordu).

## Komutlar

```bash
godot --headless --path . --import                      # 0 hata vermeli
godot --headless --path . res://tests/testler.tscn      # çıkış kodu 0 = geçti
godot --path . res://tests/ekran.tscn -- -2 <klasör>    # yayın paketi görselleri
godot --path . res://tests/ekran.tscn -- -1 <klasör>    # menü / bölüm seç / ayarlar
godot --path . res://tests/ekran.tscn -- -3 <klasör>    # tur 2 özellik denetim kareleri
godot --path . res://tests/ekran.tscn -- -4 <klasör>    # tur 3: altın hayalet, platformlu iniş
godot --path . res://tests/ekran.tscn -- -5 yayin/tanitim   # 3 sn tanıtım kareleri + kareler.raw
godot --path . res://tests/ekran.tscn -- -6 <klasör>    # tur 4 (v0.5): solak alanlar, 19. bölüm, günün bölümü
godot --path . res://tests/ekran.tscn -- -7 <klasör>    # tur 5 (v0.6): HUD solması, hayalet yarışı, paylaşım paneli, parıltı
python tools/gif_yap.py yayin/tanitim/kareler.raw yayin/tanitim/tanitim.gif 320 180 10
python tools/gif_yap.py --dogrula                       # GIF kodlayıcısının öz denetimi
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
7. **Heredoc ters bölüyü yutuyor.** Bu makinede `bash <<'PY'` ile Python yamaları
   yazarken `\t` / `\n` kaçışları sessizce bozulabiliyor — yama uygulanmış
   görünür ama hiçbir şey değişmez. Yamayı **dosyaya yaz, öyle çalıştır** ve her
   `replace` için `assert s.count(a) == 1` koy.
8. **`Ayarlar` autoload'una `const` içinden erişilemez.** `const ODA := Ayarlar.X`
   derlenmez; `const A := preload("res://scripts/ayarlar.gd")` üzerinden git
   (`bolum.gd` ve `oyun.gd` böyle yapıyor).
9. **Web'de simge yerine kutu.** Godot'nun gömülü yazı tipinde `★ ✓ ⟳ ● ← → ₺`
   gibi simgeler yok. Masaüstünde sistem yazı tipi örttüğü için Windows ekran
   görüntülerinde **görünmez**; web yapısında kutu çıkar. Yeni bir simge
   kullanmadan önce `assets/fonts/LISANS-simgeler.txt` başındaki listeye bak,
   yoksa kullanma. `tests/testler.gd` → `_simge_testi` bunu ölçüyor.
10. **Arayüz metni klavye tuşu adı içeriyorsa** `Ayarlar.kontrol_metni()` ile
   yaz; dokunmatikte "A / D ile yürü" yalan olur. Çeviri tablosu
   `Ayarlar.DOKUNMA_METNI`, testi `_dokunma_metni_testi` (tablodaki terim arayüzden
   kalkarsa test kalır, çeviri sessizce ölü kalmaz).
11. **Geliştirici araçları `user://kayit.cfg`'yi yazıyor.** `tools/bot.gd` ölçüm
   için oyun hissini ve iniş göstergesini kapatıyor; `Ayarlar.bolum_bitti()` her
   bölüm sonunda `kaydet()` çağırdığı için bu **diske yazılıyordu**. İki tur
   yayın ekran görüntüsü bu yüzden oyun hissi kapalı çekildi (çevirme izi yok,
   parçacık yok) ve kimse fark etmedi. Bot artık çıkışta ayarları geri veriyor,
   `tests/ekran.gd` de her çekimden önce `_varsayilan_gorunum()` kuruyor.
   Yeni bir araç ayar değiştirecekse ikisini de yap.
12. **`Bolum._ileri_x()` konumu kendi aralığına geri katlıyor.** Testte bir
   platformu "kenara itip yok saydırmak" işe yaramaz: üçgen dalga formülü
   hangi x'i verirsen ver `[min_x, max_x]` aralığına geri getirir. Platformsuz
   bir bölümle karşılaştır.
13. **GIF'te LZW kod genişliği bir kod GECİKMELİ büyür.** Çözücünün tablosu
   kodlayıcınınkinden bir geridedir; erken büyütürsen dosya hatasız ama bozuk
   çıkar. `tools/gif_yap.py --dogrula` gerçek bir çözücüyle gidiş-dönüş
   denetimi yapıyor, ilk yazımda hatayı o yakaladı.
14. **Bölüm bitiş beklemesi ölüm haritasına bağlı.** Ölüm yoksa 1,0 sn, varsa
   2,4 sn. Testler bu süreye göre bekliyor; sabiti değiştirirsen `_kapiya_dokun`
   beklemesini de değiştir.
15. **Gezen dikenin kaçış yüzeyi açık olmalı.** Gezen dikenin menzilindeki bir
   sütunda karşı yüzey de tehlikeliyse iki yüzey birden öldürür ve bölüm
   yalnız tam hızda süzülerek geçilir (18 ve 19. bölüm v0.4'te böyleydi).
   `arac/uret_bolumler.py` bunu `assert` ile, `_gezgin_kacis_testi` üretilen
   haritada ölçüyor. Bant penceresi kuralı (3 hücre) bunu **yakalamıyordu**.
16. **Günlük bölüm seçiminde Knuth çarpımsal karma kullanma.** Ardışık günler
   bölümleri birer birer geriye sayıyordu (adım mod 20 = 19). `_gunluk_karma`
   32 bit karıştırıcı (`lowbias32` ailesi); `_gunluk_testi` 30 günde en az 10
   farklı bölüm ve en fazla 6 ardışık geçiş istiyor.
17. **Günlük modda bitiş sahneyi değiştirmez (v0.6).** `_sonraki()` günlük modda
   artık `_gunluk_panel()` açar (`_durum = BITTI`), menüye yalnız düğmeyle
   dönülür; test paneli ve `Kopyala` düğmesini bekleyip ölçebilir. v0.5'te
   `_menuye()` çağrılıyor ve `change_scene_to_file` test ağacını söküyordu.
18. **`AudioStreamWAV.data.size()` bayt sayısı, örnek sayısı değil.** İçe aktarma
   müziği QOA ile sıkıştırıyor (`compress/mode=2`, Godot'un varsayılanı);
   `loop_end = data.size()/2` (16 bit varsayımı) parçanın beşte birine düşüyor
   ve müzik ~4 sn'de başa sarıyordu — v0.5'e kadar **hiç fark edilmedi**, test
   yalnız `loop_end > 0`'a bakıyordu. Doğrusu `get_length() * mix_rate`;
   `_ses_testi` artık `loop_end == uzunluk` istiyor.
19. **Ekran aracı ve bot `user://kayit.cfg`'yi yazabilir.** `tests/ekran.gd`
   başta dosyayı yedekleyip çıkışta geri koyuyor (günlük bitişi `kaydet()`
   çağırıyor); bot ayarları geri veriyor. Yeni bir araç bölüm bitirecekse aynı
   yedeklemeyi yap.
20. **Sprite sayfası ile tek kare simge aynı dosya olamaz.** `TextureRect`
   4 kareli sayfayı bütün olarak basar (HUD kristal simgesi 4 kristal olurdu).
   Bu yüzden `kristal.png` tek kare kaldı, bölüm içi sayfa `kristal_parilti.png`.
21. **`ParallaxLayer` aynalaması TEK ek kopya çizer.** Katman konumu `(-M, 0]`
   aralığına sarılır, kopya `+M`'de çizilir; içerik `W` px genişse örtü
   `[konum, konum+W+M)`. 320 px içerik + 320 aynalama ile 640 px'lik ekran
   ancak konum tam 0 iken örtülür: ikinci odada sağda ~15 px, ilk odada
   sarsıntının **negatif** karelerinde sağ YARIM ekran temizleme rengi (gri)
   kalıyordu — v0.2'den v0.5'e kadar kimse görmedi (sarsıntı 0,1–0,4 sn,
   kareler sonra çekiliyordu). Kural: her katmanın içeriği ekran kadar geniş
   (`Gorsel` + `Gorsel2`, 640) ve `motion_mirroring.x` içeriği aşmasın;
   `_parallaks_testi` bunu ölçüyor. Yeni arka plan katmanı eklerken aynı düzen.
