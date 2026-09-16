# itch.io sayfa metni — Yerçekimi Çevir / Gravity Flip

> Bu dosya yalnızca **hazırlanmıştır**. Hiçbir yere yüklenmedi, sayfa açılmadı.
> Kapak: `ekran/03-kapak-630x500.png` · Ekran görüntüleri: `ekran/01,02,04,05*.png`

---

## English

### Gravity Flip

**There is no jump button. There is only one button: flip gravity.**

You are a lab technician stuck inside a gravity testing facility. The floor
kills you, the ceiling kills you, and the only way through is to fall the other
way at exactly the right moment.

Flipping only works while you are touching a surface — no mid-air second
chances. Miss the timing and you land on a spike. Twenty short levels, each one
or two screens wide, each one teaching exactly one new idea before it starts
combining them.

**Features**

- 20 hand-tuned levels, each new mechanic introduced on its own safe level first
- One hidden crystal per level, always on an optional detour off the main route
- Gold / silver / bronze target times, saved per level
- Checkpoints in the longer levels
- Instant respawn — death costs you 0.3 seconds, not your run
- Keyboard, gamepad and touch controls
- Generated pixel art and chiptune audio, single 32-colour palette
- Turkish interface

**Controls**

| Action | Keyboard | Gamepad | Touch |
|---|---|---|---|
| Walk | `A` / `D` or arrow keys | left stick / D-pad | on-screen `<` `>` |
| **Flip gravity** | `Space` or `W` | `A` | on-screen `ÇEVİR` |
| Pause | `Esc` | `Start` | — |

Flipping works **only while touching a surface**. If you press it up to 0.1 s
before you land, it still counts.

Runs in the browser, or download the Windows build.

---

## Türkçe

### Yerçekimi Çevir

**Zıplama tuşu yok. Tek tuş var: yerçekimini çevir.**

Bir yerçekimi deney tesisinde sıkışmış laboratuvar teknisyenisin. Zemin
öldürüyor, tavan öldürüyor; tek çıkış yolu tam doğru anda ters yöne düşmek.

Çevirme yalnızca bir yüzeye değerken çalışır — havada ikinci şans yok.
Zamanlamayı kaçırırsan dikenin üstüne inersin. Yirmi kısa bölüm, her biri
bir-iki ekran genişliğinde; her yeni fikir önce kendi güvenli bölümünde
tanıtılıyor, sonra birleştirilmeye başlıyor.

**Özellikler**

- 20 bölüm, elle dengelenmiş zorluk eğrisi; her yeni mekanik önce güvenli bir bölümde
- Her bölümde 1 gizli kristal — her zaman ana rotanın dışında, isteğe bağlı bir kaçamakta
- Bölüm başına altın / gümüş / bronz hedef süre, en iyi madalya kaydediliyor
- Uzun bölümlerde kontrol noktası
- Anında yeniden doğma — ölüm 0,3 saniyeye mal olur, koşuna değil
- Klavye, gamepad ve dokunmatik
- Kodla üretilmiş pixel art ve chiptune müzik, tek bir 32 renklik palet
- Türkçe arayüz

**Kontroller**

| Eylem | Klavye | Gamepad | Dokunmatik |
|---|---|---|---|
| Yürü | `A` / `D` ya da ok tuşları | sol çubuk / D-pad | ekrandaki `<` `>` |
| **Yerçekimini çevir** | `Boşluk` ya da `W` | `A` | ekrandaki `ÇEVİR` |
| Duraklat | `Esc` | `Start` | — |

Çevirme **yalnızca bir yüzeye değerken** çalışır. Yüzeye değmeden 0,1 saniye
öncesine kadar bastıysan yine de sayılır.

Tarayıcıda oynanır; Windows sürümü de indirilebilir.

---

## Sayfa ayarları (doldurulacak)

| Alan | Değer |
|---|---|
| Başlık | Yerçekimi Çevir (Gravity Flip) |
| Kısa açıklama | No jump button. One button: flip gravity. 20 levels of precision platforming. |
| Sınıflandırma | Game |
| Tür | Platformer |
| Etiketler | `precision-platformer`, `gravity`, `pixel-art`, `one-button`, `godot`, `speedrun`, `turkish` |
| Fiyat | Ücretsiz (bağış açık) |
| Platformlar | HTML5 (tarayıcıda oynanır) + Windows |
| Web çerçevesi | 1280 × 720, "Fullscreen button" açık |
| SharedArrayBuffer | **Kapalı** — web yapısı `thread_support=false` ile alındı, gerek yok |

## Yükleme öncesi kontrol listesi

- [ ] `build/web/` içeriğini zip'le (index.html kökte olmalı)
- [ ] Web yapısını bir tarayıcıda aç, sesin geldiğini ve müziğin **ikinci tura girdiğini** doğrula
- [ ] Windows yapısını zip'le (`yercekimi-cevir.exe` + `.pck` birlikte)
- [ ] Kapak görselini (630×500) ve 4 ekran görüntüsünü yükle
- [ ] Sayfayı önce **taslak** olarak kaydet, sonra yayınla
