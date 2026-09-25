#!/usr/bin/env bash
# Test kapisi: testler.tscn'in cikis kodu tek basina yeterli bir sinyal degil.
#
#   tests/kapi.sh <test-gunlugu> <en-az-dogrulama>        # tests/testler.tscn
#   tests/kapi.sh --bot <bot-gunlugu> <en-az-bolum>       # tools/bot.tscn ... denetle
#
# testler.gd yalnizca `_hata > 0` ise 1 ile cikiyor. Oysa GDScript'te bir
# calisma zamani hatasi (null erisimi, int == bool, eksik metot) yalnizca o
# fonksiyonu keser: motor "SCRIPT ERROR" yazar, fonksiyonun kalan
# dogrulamalari hic sayilmaz ve takim yine "N dogrulama, 0 hata" /
# "TESTLER GECTI" ile 0 dondurur. Yani bir test bolumu sessizce yarida
# kalabilir ve CI yesil kalir. Bot icin de ayni: bir olcum fonksiyonu
# kesilirse denetim eksik bolumle "temiz" diyebilir.
#
# Test kipi gunlugu okuyup dort seyi zorunlu kilar:
#   1. "N dogrulama, H hata" satiri var (takim sonuna kadar kostu),
#   2. H == 0 ve "TESTLER GECTI" satiri var,
#   3. N >= en-az-dogrulama (ci.yml -> TEST_TABANI; sayi bilinen tabanin
#      altina dusmedi),
#   4. gunlukte "SCRIPT ERROR" / "Parse Error" yok.
# Bot kipi: "denetim temiz: N bolumun hepsi bitiyor" satiri var, N >=
# en-az-bolum, ve betik hatasi yok.
#
# Motorun cikista yazdigi "ERROR: N resources still in use at exit" satiri
# test sonucuyla ilgili degil; onu bilerek aramiyoruz.
#
# Sinamasi: tests/kapi_sinama.sh (Godot gerektirmez).
set -euo pipefail

kip=test
if [ "${1:-}" = "--bot" ]; then
  kip=bot
  shift
fi
if [ "$#" -ne 2 ]; then
  echo "kullanim: $0 [--bot] <gunluk> <en-az>" >&2
  exit 2
fi
gunluk="$1"
alt_sinir="$2"

if [ ! -r "$gunluk" ]; then
  echo "KAPI: gunluk okunamadi: $gunluk" >&2
  exit 1
fi

if grep -anE 'SCRIPT ERROR|Parse Error' "$gunluk" >&2; then
  echo "KAPI: gunlukte betik hatasi var (yukarida). Bir bolum yarida kesilmis olabilir." >&2
  exit 1
fi

if [ "$kip" = bot ]; then
  satir="$(grep -aoE 'denetim temiz: [0-9]+ bolumun hepsi bitiyor' "$gunluk" | tail -n 1 || true)"
  if [ -z "$satir" ]; then
    echo "KAPI: 'denetim temiz: N bolumun hepsi bitiyor' satiri yok; denetim temiz bitmedi." >&2
    exit 1
  fi
  bolum="$(sed -E 's/^denetim temiz: ([0-9]+) .*$/\1/' <<<"$satir")"
  if [ "$bolum" -lt "$alt_sinir" ]; then
    echo "KAPI: denetim $bolum bolum saydi, taban $alt_sinir." >&2
    exit 1
  fi
  echo "KAPI: denetim temiz, $bolum bolum (taban $alt_sinir), betik hatasi yok."
  exit 0
fi

sonuc="$(grep -aoE '^[0-9]+ dogrulama, [0-9]+ hata$' "$gunluk" | tail -n 1 || true)"
if [ -z "$sonuc" ]; then
  echo "KAPI: 'N dogrulama, H hata' satiri yok; takim sonuna kadar kosmadi." >&2
  exit 1
fi

sayi="$(sed -E 's/^([0-9]+) dogrulama, ([0-9]+) hata$/\1/' <<<"$sonuc")"
hata="$(sed -E 's/^([0-9]+) dogrulama, ([0-9]+) hata$/\2/' <<<"$sonuc")"

if [ "$hata" -ne 0 ]; then
  echo "KAPI: $hata dogrulama basarisiz." >&2
  exit 1
fi
if ! grep -aqx 'TESTLER GECTI' "$gunluk"; then
  echo "KAPI: 'TESTLER GECTI' satiri yok." >&2
  exit 1
fi
if [ "$sayi" -lt "$alt_sinir" ]; then
  echo "KAPI: $sayi dogrulama, taban $alt_sinir. Bir bolum atlanmis ya da yarida kalmis." >&2
  exit 1
fi

echo "KAPI: $sayi dogrulama (taban $alt_sinir), 0 hata, betik hatasi yok."
