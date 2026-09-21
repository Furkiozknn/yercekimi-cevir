# butler komutları — HAZIR, ÇALIŞTIRILMADI

> Bu komutların **hiçbiri çalıştırılmadı.** itch.io'ya yükleme dışa açılan bir
> işlemdir; kararı Furki verir. Sayfa da açılmadı — butler var olmayan bir
> projeye push edemez, önce itch.io'da proje sayfası elle oluşturulmalı.

## Ön koşullar

```bash
# butler kurulu mu
butler version

# oturum (bir kez; anahtar butler_creds içinde tutuluyor)
butler login
```

Kullanıcı adı ve proje slug'ı: `<itch-kullanici>/yercekimi-cevir`.
Aşağıdaki komutlarda `<kullanici>` yerine gerçek itch.io kullanıcı adını yaz.

## Yapıları hazırla

```bash
cd D:/Repolar/yercekimi-cevir

# Temiz yeniden üretim (klasörler var olmalı, Godot kendisi oluşturmuyor)
mkdir -p build/windows build/web
godot --headless --path . --import
godot --headless --path . res://tests/testler.tscn          # çıkış kodu 0 olmalı
godot --headless --path . --export-release "Windows Masaustu"
godot --headless --path . --export-release "Web (HTML5)"
```

Beklenen çıktı:

```
build/windows/yercekimi-cevir.exe   ~109 MB
build/windows/yercekimi-cevir.pck   ~828 KB   (exe ile birlikte dağıtılmalı; v0.7: +kilit sesi, +2 sprite)
build/web/index.html + index.wasm + index.pck + index.js + 2 worklet
```

## Yükleme

```bash
# Tarayıcıda oynanan sürüm
butler push build/web     <itch-kullanici>/yercekimi-cevir:html5   --userversion 0.7.0

# Windows
butler push build/windows <itch-kullanici>/yercekimi-cevir:windows --userversion 0.7.0
```

`html5` kanalı itch.io tarafında otomatik olarak "oynanabilir" işaretlenir.
`index.html` zip'in **kökünde** olmalı — `build/web` klasörünü doğrudan push
etmek bunu sağlıyor.

## Doğrulama

```bash
butler status <itch-kullanici>/yercekimi-cevir
```

Yükleme sonrası itch.io proje ayarlarında:

- **Kernel/Embed:** 1280 × 720, "Click to launch" veya doğrudan gömülü
- **SharedArrayBuffer:** işaretlenmemeli. Web yapısı `variant/thread_support=false`
  ile alındı; kutu işaretlenirse gereksiz COOP/COEP başlıkları eklenir.
- **Windows:** "This file will be downloaded" + Windows işareti

## Geri alma

```bash
# Yanlış yapı gittiyse: eski sürümü yeniden push etmek yerine kanalı boşalt
butler wipe <itch-kullanici>/yercekimi-cevir:html5
```
