# -*- coding: utf-8 -*-
"""Oyunun ses efektlerini uretir -> assets/audio/*.wav

Kullanim:  python tools/uret_ses.py

rFXGen v5.0 komut satiri ON AYARI DETERMINISTIK uretir: ayni on ayar her
calistirmada birebir ayni dosyayi verir (md5 ile dogrulandi), yani "birkac aday
uretip begendigini sec" yontemi bu surumde ise yaramiyor. Bunun yerine 5 on
ayardan 8 ayri efekt cikariyoruz: ham dosyayi perde (yeniden ornekleme) ve
kazancla donusturuyoruz. Tum cikti 22050 Hz / 16 bit / mono — Godot'un 8 bit WAV
ice aktarma hatasindan kacinmak icin 16 bit sart.
"""
import os
import struct
import subprocess
import sys
import wave

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CIKTI = os.path.join(KOK, "assets", "audio")
HAM = os.path.join(CIKTI, "ham")
RFXGEN = r"D:\Araclar\rFXGen\rfxgen_v5.0_win_x64\rfxgen.exe"
BICIM = "22050,16,1"

# ad -> (rFXGen on ayari, perde carpani, kazanc)
#   perde > 1 : daha tiz ve kisa · perde < 1 : daha pes ve uzun
EFEKTLER = {
    "cevir":      ("jump",      1.00, 0.85),
    "cevir_ters": ("jump",      0.78, 0.85),   # tavandan zemine donerken
    "kristal":    ("coin",      1.15, 0.90),
    "kontrol":    ("coin",      0.70, 0.80),   # ayni on ayar, pes: "kilit acildi"
    "olum":       ("explosion", 0.85, 0.90),
    "bolum_sonu": ("powerup",   1.00, 0.90),
    "madalya":    ("powerup",   1.35, 0.85),   # bitis ekraninda madalya damgasi
    "menu":       ("blip",      1.00, 0.55),
    "inis":       ("hit",       0.70, 0.35),   # yuzeye konus — kisik olmali
}


def ham_uret():
    os.makedirs(HAM, exist_ok=True)
    for on_ayar in sorted({v[0] for v in EFEKTLER.values()}):
        yol = os.path.join(HAM, on_ayar + ".wav")
        if os.path.exists(yol):
            continue
        subprocess.run([RFXGEN, "--generate", on_ayar, "--output", yol, "--format", BICIM],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return True


def oku(yol):
    with wave.open(yol, "rb") as w:
        assert w.getsampwidth() == 2 and w.getnchannels() == 1, yol
        hiz = w.getframerate()
        ham = w.readframes(w.getnframes())
    return hiz, list(struct.unpack("<%dh" % (len(ham) // 2), ham))


def yaz(yol, hiz, ornekler):
    with wave.open(yol, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(hiz)
        w.writeframes(struct.pack("<%dh" % len(ornekler), *ornekler))


def donustur(ornekler, perde, kazanc):
    """Dogrusal ara degerli yeniden ornekleme + kazanc + 2 ms fade-out (tik sesi olmasin)."""
    n = max(1, int(len(ornekler) / perde))
    cikti = []
    for i in range(n):
        k = i * perde
        a = int(k)
        b = min(a + 1, len(ornekler) - 1)
        o = k - a
        deger = (ornekler[a] * (1.0 - o) + ornekler[b] * o) * kazanc
        cikti.append(int(max(-32768, min(32767, deger))))
    sonel = min(64, len(cikti))
    for i in range(sonel):
        cikti[-1 - i] = int(cikti[-1 - i] * i / sonel)
    return cikti


def main():
    if not os.path.exists(RFXGEN):
        print("rFXGen bulunamadi: %s" % RFXGEN)
        return 1
    os.makedirs(CIKTI, exist_ok=True)
    ham_uret()
    onbellek = {}
    for ad, (on_ayar, perde, kazanc) in sorted(EFEKTLER.items()):
        if on_ayar not in onbellek:
            onbellek[on_ayar] = oku(os.path.join(HAM, on_ayar + ".wav"))
        hiz, ornekler = onbellek[on_ayar]
        sonuc = donustur(ornekler, perde, kazanc)
        yol = os.path.join(CIKTI, ad + ".wav")
        yaz(yol, hiz, sonuc)
        tepe = max(abs(x) for x in sonuc) / 32768.0
        print("  %-12s <- %-10s perde %.2f  %5.2f sn  tepe %.2f"
              % (ad + ".wav", on_ayar, perde, len(sonuc) / hiz, tepe))
    print("%d efekt uretildi -> %s" % (len(EFEKTLER), CIKTI))
    return 0


if __name__ == "__main__":
    sys.exit(main())
