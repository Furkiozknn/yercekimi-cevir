#!/usr/bin/env bash
# tests/kapi.sh'in kendi sinamasi. Godot gerektirmez; CI'da her push'ta kosar.
# Gunluk ornekleri gercek Godot 4.7.2 ciktisinin bicimini izler
# (25 Eylul 2026: 841 dogrulama; bot denetimi 20 bolum).
set -uo pipefail

kok="$(cd "$(dirname "$0")" && pwd)"
kapi="$kok/kapi.sh"
gecici="$(mktemp -d)"
trap 'rm -rf "$gecici"' EXIT
basarisiz=0

# $1 ad, $2 beklenen cikis (0 gecer / 1 duser), $3.. kapi.sh bayraklari + taban,
# stdin gunluk
bekle() {
  local ad="$1" beklenen="$2" dosya="$gecici/$1.log" kod
  shift 2
  cat >"$dosya"
  local arg=("$@")
  local taban="${arg[-1]}"
  unset 'arg[-1]'
  bash "$kapi" "${arg[@]}" "$dosya" "$taban" >/dev/null 2>&1
  kod=$?
  if [ "$kod" -eq "$beklenen" ]; then
    echo "  tamam  $ad (cikis $kod)"
  else
    echo "  HATA   $ad: beklenen $beklenen, gelen $kod"
    basarisiz=$((basarisiz + 1))
  fi
}

echo "[test kapisi]"

bekle temiz 0 841 <<'EOF'
— Kapi, madalya ve ilerleme —
  [OK] kapi bolumu bitirir
841 dogrulama, 0 hata
TESTLER GECTI
WARNING: 31 ObjectDB instances were leaked at exit (run with `--verbose` for details).
ERROR: 3 resources still in use at exit (run with --verbose for details).
EOF

bekle tabandan_fazla 0 841 <<'EOF'
860 dogrulama, 0 hata
TESTLER GECTI
EOF

bekle dogrulama_hatasi 1 841 <<'EOF'
  [HATA] kapi bolumu bitirir
841 dogrulama, 1 hata
TESTLER KALDI
EOF

# Asil kapattigi aciklik: bir bolum calisma zamani hatasiyla kesildi, kalan
# dogrulamalari sayilmadi, ama takim yine "0 hata" ile bitti.
bekle betik_hatasi_sessiz_atlama 1 841 <<'EOF'
— Hayalet yaris —
SCRIPT ERROR: Invalid access to property or key 'konum' on a base object of type 'Nil'.
          at: _hayalet_yaris_testi (res://tests/testler.gd:2100)
— Yardim modu —
802 dogrulama, 0 hata
TESTLER GECTI
EOF

bekle betik_hatasi_sayi_tam 1 841 <<'EOF'
SCRIPT ERROR: Invalid operands 'int' and 'bool' in operator '=='.
841 dogrulama, 0 hata
TESTLER GECTI
EOF

bekle derleme_hatasi 1 841 <<'EOF'
SCRIPT ERROR: Parse Error: Identifier "Ayarlar" not declared in the current scope.
EOF

bekle tabanin_alti 1 841 <<'EOF'
800 dogrulama, 0 hata
TESTLER GECTI
EOF

bekle gecti_satiri_yok 1 841 <<'EOF'
841 dogrulama, 0 hata
EOF

bekle sonuc_satiri_yok 1 841 <<'EOF'
— Bolum verisi —
— Madalya esikleri —
EOF

bekle bos_gunluk 1 841 </dev/null

echo "[bot denetim kapisi]"

bekle bot_temiz 0 --bot 20 <<'EOF'
--- denetim: yayimlanan esik vs bugunku kosu ---

denetim temiz: 20 bolumun hepsi bitiyor, yayimlanan altin esigi botun bugunku kosusunu kaldiriyor.
kullanici ayarlari geri verildi
ERROR: 7 resources still in use at exit (run with --verbose for details).
EOF

bekle bot_betik_hatasi 1 --bot 20 <<'EOF'
SCRIPT ERROR: Invalid call. Nonexistent function 'olc' in base 'Nil'.
denetim temiz: 20 bolumun hepsi bitiyor, yayimlanan altin esigi botun bugunku kosusunu kaldiriyor.
EOF

bekle bot_eksik_bolum 1 --bot 20 <<'EOF'
denetim temiz: 19 bolumun hepsi bitiyor, yayimlanan altin esigi botun bugunku kosusunu kaldiriyor.
EOF

bekle bot_basarisiz 1 --bot 20 <<'EOF'
DENETIM BASARISIZ: 1 bulgu (1 bolum bitirilemedi).
EOF

if [ "$basarisiz" -ne 0 ]; then
  echo "=== test kapisi: $basarisiz sinama basarisiz ==="
  exit 1
fi
echo "=== test kapisi: tum sinamalar gecti ==="
