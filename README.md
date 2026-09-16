# Yerçekimi Çevir

Zıplama yok: tek tuşla yerçekimini ters çevirip tavana "düşerek" dikenlerden kaçtığın
kısa ve zor bir hassas platform oyunu. 12 bölüm, her bölüm 1–2 ekran.

![Ana menü](docs/menu.png)
![Tavanda yürürken](docs/04-tavanda.png)

## Kontroller

| Eylem | Klavye | Gamepad | Dokunmatik |
|---|---|---|---|
| Yürü | `A` / `D` ya da ok tuşları | sol çubuk / D-pad | ekrandaki `<` `>` |
| **Çevir** | `Boşluk` ya da `W` | `A` | ekrandaki `ÇEVİR` |
| Duraklat | `Esc` | `Start` | — |

Çevirme **yalnızca bir yüzeye değerken** çalışır — havada ikinci kez çeviremezsin.
Yüzeye değmeden ~0,1 sn önce bastıysan yine de sayılır (giriş tamponu).
Dokunmatik düğmeler sadece dokunmatik cihazda görünür.

Diken ya da ekran dışına düşmek öldürür; ölünce 0,3 sn sonra bölüm başına otomatik
dönersin. Süre sayacı ölümlerle sıfırlanmaz, bölüm değişince sıfırlanır.

## Nasıl çalıştırılır

```
godot --path .                                     # oyunu aç
godot --headless --path . res://tests/testler.tscn  # otomatik testler (çıkış kodu 0 = geçti)
godot --path . res://tests/ekran.tscn -- 2 <klasör> # 3. bölümü sürüp ekran görüntüsü al
godot --path . res://tests/ekran.tscn -- -1 <klasör># menü + bölüm seç ekran görüntüsü
python arac/uret_bolumler.py                        # bölümleri yeniden üret (çözülebilirliği doğrular)
```

Dışa aktarılmış yapı: `build/windows/yercekimi-cevir.exe`, `build/web/index.html`.

## Kod düzeni

| Dosya | İş |
|---|---|
| `scripts/ayarlar.gd` | **Tüm denge sabitleri** (hız, yerçekimi, renkler) + ilerleme kaydı. Ayar yapacaksan tek durak. |
| `scripts/bolumler.gd` | 12 bölüm, ASCII harita olarak. `arac/uret_bolumler.py` üretir. |
| `scripts/bolum.gd` | ASCII haritayı çalışma anında çarpışma gövdesi + çizime çevirir. |
| `scripts/oyuncu.gd` | Çevirme mekaniği, yatay ivme, ölüm. |
| `scripts/oyun.gd` | Bölüm döngüsü, sayaçlar, duraklatma, bitiş ekranı. |
| `tests/` | Headless otomatik test + geliştirici ekran görüntüsü aracı. |

Bölüm haritaları TileMapLayer yerine ASCII + kod üretimi: 12 bölüm tek dosyada
düzenlenebiliyor ve `arac/uret_bolumler.py` her bölümün çözülebilirliğini
(çevirme penceresi yeterince geniş mi, aynı sütunda hem zemin hem tavan tehlikesi
var mı) üretim sırasında doğruluyor.

## Durum

**Oynanabilir prototip.** Çekirdek mekanik, 12 bölüm, ilerleme kaydı, bölüm seç,
duraklatma, bitiş ekranı ve dokunmatik düğmeler çalışıyor. Görseller yer tutucu;
ses yok. Sonraki adımlar: `YOL-HARITASI.md`.

İlerleme `user://kayit.cfg` dosyasında (Windows'ta
`%APPDATA%\Godot\app_userdata\Yerçekimi Çevir\kayit.cfg`).
