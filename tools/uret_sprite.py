# -*- coding: utf-8 -*-
"""Oyunun butun pixel art varliklarini kodla uretir -> assets/sprites/*.png

Kullanim:  python tools/uret_sprite.py

Neden kodla: bu makinede GUI cizim araci yok ve Pillow kurulu degil. PNG yazici
asagida (zlib + struct, ~20 satir); sprite'lar ASCII haritadan, arka planlar
yordamla ciziliyor. Her sey yeniden uretilebilir: dosyalari silip betigi calistir.

Palet: Endesga 32 (EDG32) — tum oyun bu 32 renkle sinirli.
Tema: "yercekimi laboratuvari" — metal paneller, uyari seritleri, parlayan kapi.
"""
import os
import struct
import zlib

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CIKTI = os.path.join(KOK, "assets", "sprites")

# --- Endesga 32 -------------------------------------------------------------
EDG = {
    "siyah": "#181425", "koyu": "#262b44", "lacivert": "#3a4466",
    "mavigri": "#5a6988", "gri": "#8b9bb4", "acikgri": "#c0cbdc", "beyaz": "#ffffff",
    "kirmizi": "#e43b44", "kankirmizi": "#a22633", "parlakkirmizi": "#ff0044",
    "pembe": "#f6757a", "turuncu": "#f77622", "sari": "#feae34", "acsari": "#fee761",
    "ten": "#ead4aa", "kahve": "#b86f50", "kokahve": "#733e39", "kokahve2": "#3e2731",
    "yesil": "#63c74d", "koyuyesil": "#3e8948", "cokkoyuyesil": "#265c42",
    "camgobegi": "#2ce8f5", "mavi": "#0099db", "komavi": "#124e89",
    "mor": "#68386c", "acikmor": "#b55088",
}


def rgb(ad):
    h = EDG[ad].lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


SEFFAF = (0, 0, 0, 0)


# --- kucuk PNG yazici -------------------------------------------------------
def png_yaz(yol, g, y, piksel):
    ham = bytearray()
    for satir in piksel:
        ham.append(0)
        for px in satir:
            ham.extend(px)

    def parca(tip, veri):
        govde = tip + veri
        return struct.pack(">I", len(veri)) + govde + struct.pack(">I", zlib.crc32(govde) & 0xFFFFFFFF)

    veri = (b"\x89PNG\r\n\x1a\n"
            + parca(b"IHDR", struct.pack(">IIBBBBB", g, y, 8, 6, 0, 0, 0))
            + parca(b"IDAT", zlib.compress(bytes(ham), 9))
            + parca(b"IEND", b""))
    with open(yol, "wb") as f:
        f.write(veri)
    return yol


class Tuval:
    def __init__(self, g, y):
        self.g, self.y = g, y
        self.p = [[SEFFAF] * g for _ in range(y)]

    def nokta(self, x, y, renk):
        if 0 <= x < self.g and 0 <= y < self.y:
            self.p[y][x] = renk

    def kutu(self, x, y, g, yk, renk):
        for j in range(y, y + yk):
            for i in range(x, x + g):
                self.nokta(i, j, renk)

    def cerceve(self, x, y, g, yk, renk):
        for i in range(x, x + g):
            self.nokta(i, y, renk)
            self.nokta(i, y + yk - 1, renk)
        for j in range(y, y + yk):
            self.nokta(x, j, renk)
            self.nokta(x + g - 1, j, renk)

    def bas(self, x, y, harita, sozluk):
        """ASCII haritayi (satir listesi) x,y'den itibaren basar."""
        for j, satir in enumerate(harita):
            for i, ch in enumerate(satir):
                renk = sozluk.get(ch)
                if renk is not None:
                    self.nokta(x + i, y + j, renk)

    def yaz(self, ad):
        URETILEN.append((ad, self))
        return png_yaz(os.path.join(CIKTI, ad), self.g, self.y, self.p)


URETILEN = []


def dogrula(harita, g, ad):
    for i, satir in enumerate(harita):
        assert len(satir) == g, (ad, "satir %d genisligi %d, %d olmali" % (i, len(satir), g))


# --- oyuncu -----------------------------------------------------------------
# o outline · L kask acik · v vizor · V vizor koyu · S tulum · D tulum koyu
# B bot · b bot koyu · . seffaf
OYUNCU_SOZ = {
    ".": None, "o": rgb("siyah"), "L": rgb("sari"), "l": rgb("acsari"),
    "v": rgb("camgobegi"), "V": rgb("mavi"), "S": rgb("turuncu"), "D": rgb("kokahve"),
    "B": rgb("mavigri"), "b": rgb("lacivert"),
}

# Govde: 0..17 satirlar (kask + govde). Bacaklar ayri, 18..22.
GOVDE = [
    "................",
    "................",
    ".....oooooo.....",
    "....olllllLo....",
    "...olvvvvvvLo...",
    "...olvvvvvvLo...",
    "...olVVVVVVLo...",
    "....oLLLLLLo....",
    ".....oooooo.....",
    "....oSSSSSSo....",
    "...oSSllllSSo...",
    ".oDoSSlSSlSSoDo.",
    ".oDoSSllllSSoDo.",
    ".oDoSSSSSSSSoDo.",
    ".ooooSSSSSSoooo.",
    "....oDSSSSDo....",
    "....oDDDDDDo....",
    ".....oDDDDo.....",
]

BACAK_BIRLIKTE = [
    ".....oDooDo.....",
    ".....oDooDo.....",
    "....oBBooBBo....",
    "....obbooBBo....",
    "....oooooooo....",
]
BACAK_ACIK_A = [
    "....oDDooDo.....",
    "...oDDoooDo.....",
    "...oBBo.oBBo....",
    "...obbo.oBBo....",
    "...ooo...ooo....",
]
BACAK_ACIK_B = [
    ".....oDooDDo....",
    ".....oDoooDDo...",
    "....oBBo.oBBo...",
    "....obbo.oBBo...",
    "....ooo...ooo...",
]
BACAK_TOPLU = [   # havada yukari giderken: bacaklar toplanmis
    "....oDDooDDo....",
    "....oDoooooDo...",
    "...oBBo...oBBo..",
    "...obbo...oBBo..",
    "...oooo...oooo..",
]
BACAK_ACILMIS = [  # havada duserken: bacaklar acilmis
    "...oDDo..oDDo...",
    "..oDDo....oDDo..",
    "..oBBo....oBBo..",
    "..obbo....oBBo..",
    "..oooo....oooo..",
]


def oyuncu_karesi(bacak, yukari=0):
    """16x24 bir kare: govde + bacak. yukari=1 ise govde 1 px yukari kayar (adim hissi)."""
    t = Tuval(16, 24)
    t.bas(0, 0 - yukari, GOVDE, OYUNCU_SOZ)
    t.bas(0, 18, bacak, OYUNCU_SOZ)
    return t


def uret_oyuncu():
    for ad, h in [("GOVDE", GOVDE), ("BIRLIKTE", BACAK_BIRLIKTE), ("ACIK_A", BACAK_ACIK_A),
                  ("ACIK_B", BACAK_ACIK_B), ("TOPLU", BACAK_TOPLU), ("ACILMIS", BACAK_ACILMIS)]:
        dogrula(h, 16, "oyuncu/" + ad)
    kareler = [
        oyuncu_karesi(BACAK_BIRLIKTE),           # idle 0
        oyuncu_karesi(BACAK_BIRLIKTE, 1),        # idle 1 (nefes)
        oyuncu_karesi(BACAK_ACIK_A),             # yuru 0
        oyuncu_karesi(BACAK_BIRLIKTE, 1),        # yuru 1
        oyuncu_karesi(BACAK_ACIK_B),             # yuru 2
        oyuncu_karesi(BACAK_BIRLIKTE, 1),        # yuru 3
        oyuncu_karesi(BACAK_TOPLU),              # zipla (yukari)
        oyuncu_karesi(BACAK_ACILMIS),            # dus
    ]
    sayfa = Tuval(16 * len(kareler), 24)
    for i, k in enumerate(kareler):
        for y in range(24):
            for x in range(16):
                sayfa.nokta(i * 16 + x, y, k.p[y][x])
    return sayfa.yaz("oyuncu.png")


# --- karolar ----------------------------------------------------------------
def uret_karo():
    """16x16 metal panel. Sol-ust acik, sag-alt koyu bizote + perçinler."""
    t = Tuval(16, 16)
    t.kutu(0, 0, 16, 16, rgb("lacivert"))
    for i in range(16):
        t.nokta(i, 0, rgb("mavigri"))
        t.nokta(0, i, rgb("mavigri"))
        t.nokta(i, 15, rgb("siyah"))
        t.nokta(15, i, rgb("siyah"))
    t.kutu(4, 7, 8, 2, rgb("koyu"))          # panel dikisi
    for (x, y) in [(3, 3), (12, 3), (3, 12), (12, 12)]:
        t.nokta(x, y, rgb("gri"))
        t.nokta(x, y + 1, rgb("koyu"))
    return t.yaz("karo.png")


def uret_karo_ust():
    """Yuruyus yuzeyi: ustunde uyari seridi olan panel. Ters cevrilerek tavan icin
    de kullanilir, bu yuzden serit ustte."""
    t = Tuval(16, 16)
    t.kutu(0, 0, 16, 16, rgb("lacivert"))
    for i in range(16):
        t.nokta(i, 15, rgb("siyah"))
        t.nokta(15, i, rgb("siyah"))
        t.nokta(0, i, rgb("mavigri"))
    t.kutu(0, 0, 16, 4, rgb("acsari"))       # uyari seridi
    for i in range(16):                      # egik siyah cizgiler
        for j in range(4):
            if (i + j) % 6 < 3:
                t.nokta(i, j, rgb("siyah"))
    t.kutu(0, 4, 16, 1, rgb("sari"))
    t.kutu(4, 9, 8, 2, rgb("koyu"))
    for x in (3, 12):
        t.nokta(x, 13, rgb("gri"))
        t.nokta(x, 14, rgb("koyu"))
    return t.yaz("karo_ust.png")


# --- tehlikeler -------------------------------------------------------------
DIKEN = [
    ".......oo.......",
    ".......rr.......",
    "......orro......",
    "......rWWr......",
    ".....orrrro.....",
    ".....rrWWrr.....",
    "....orrrrrro....",
    "....rrrWWrrr....",
    "...orrrrrrrro...",
    "...rrrWWRRRRr...",
    "..orrrrrrrrrro..",
    "..rrrWWRRRRRRr..",
    ".orrrrrrrrrrrro.",
    ".rrrWWRRRRRRRRr.",
    "oRRRRRRRRRRRRRRo",
    "oooooooooooooooo",
]
DIKEN_SOZ = {
    ".": None, "o": rgb("siyah"), "r": rgb("kirmizi"),
    "R": rgb("kankirmizi"), "W": rgb("pembe"),
}


def uret_diken():
    dogrula(DIKEN, 16, "diken")
    t = Tuval(16, 16)
    t.bas(0, 0, DIKEN, DIKEN_SOZ)
    return t.yaz("diken.png")


def uret_gezgin():
    """24x10 gezgin diken: iki yana disli, ortada kirmizi govde."""
    t = Tuval(24, 10)
    t.kutu(1, 2, 22, 6, rgb("kankirmizi"))
    t.kutu(2, 3, 20, 2, rgb("kirmizi"))
    t.cerceve(1, 2, 22, 6, rgb("siyah"))
    for x in range(2, 22, 3):                # ust ve alt disler
        for j in range(2):
            t.kutu(x + j, 1 - j, 3 - 2 * j, 1, rgb("parlakkirmizi"))
            t.kutu(x + j, 8 + j, 3 - 2 * j, 1, rgb("parlakkirmizi"))
    for x in range(4, 21, 6):
        t.nokta(x, 5, rgb("pembe"))
    return t.yaz("gezgin.png")


def uret_platform():
    """48x10 hareketli platform: mor metal kiris + calisan isiklar."""
    t = Tuval(48, 10)
    t.kutu(0, 0, 48, 10, rgb("mor"))
    t.kutu(1, 1, 46, 3, rgb("acikmor"))
    t.kutu(0, 8, 48, 2, rgb("siyah"))
    t.cerceve(0, 0, 48, 10, rgb("siyah"))
    for x in range(5, 45, 8):
        t.kutu(x, 5, 3, 2, rgb("camgobegi"))
        t.nokta(x + 1, 6, rgb("beyaz"))
    return t.yaz("platform.png")


# --- hedef, toplanabilir, kontrol noktasi -----------------------------------
def uret_kapi():
    """16x48 parlayan laboratuvar kapisi."""
    t = Tuval(16, 48)
    t.kutu(0, 0, 16, 48, rgb("koyu"))
    t.kutu(2, 2, 12, 44, rgb("cokkoyuyesil"))
    t.kutu(3, 3, 10, 42, rgb("koyuyesil"))
    t.kutu(4, 5, 8, 38, rgb("yesil"))
    for j in range(6, 42, 2):                # yukari akan enerji cizgileri
        t.kutu(5, j, 6, 1, rgb("acsari") if (j // 2) % 4 == 0 else rgb("yesil"))
    t.kutu(6, 8, 4, 32, rgb("beyaz"))        # parlak cekirdek
    t.kutu(7, 6, 2, 36, rgb("beyaz"))
    t.cerceve(0, 0, 16, 48, rgb("siyah"))
    t.kutu(0, 0, 16, 2, rgb("mavigri"))      # ust/alt metal kelepce
    t.kutu(0, 46, 16, 2, rgb("mavigri"))
    t.cerceve(0, 0, 16, 48, rgb("siyah"))
    return t.yaz("kapi.png")


KRISTAL = [
    "....oooo....",
    "...oCCCCo...",
    "..oCWWWWCo..",
    ".oCWWccWWCo.",
    "oCWccccccWCo",
    "oCWccccccWCo",
    "oCcccccccCo.",
    ".oCcccccCo..",
    "..oCcccCo...",
    "...oCcCo....",
    "....oCo.....",
    ".....o......",
]
KRISTAL_SOZ = {
    ".": None, "o": rgb("siyah"), "C": rgb("komavi"),
    "c": rgb("mavi"), "W": rgb("camgobegi"),
}


def uret_kristal():
    dogrula(KRISTAL, 12, "kristal")
    t = Tuval(12, 12)
    t.bas(0, 0, KRISTAL, KRISTAL_SOZ)
    return t.yaz("kristal.png")


def uret_kontrol():
    """32x24: iki kare — 0 pasif (gri), 1 aktif (mavi, isikli)."""
    t = Tuval(32, 24)
    for i, (govde, isik, parlak) in enumerate([
            ("mavigri", "lacivert", "gri"), ("komavi", "mavi", "camgobegi")]):
        x = i * 16
        t.kutu(x + 6, 6, 4, 18, rgb(govde))          # direk
        t.kutu(x + 3, 20, 10, 4, rgb("lacivert"))    # taban
        t.cerceve(x + 3, 20, 10, 4, rgb("siyah"))
        t.kutu(x + 2, 2, 12, 8, rgb("koyu"))         # lamba kutusu
        t.cerceve(x + 2, 2, 12, 8, rgb("siyah"))
        t.kutu(x + 4, 4, 8, 4, rgb(isik))
        t.kutu(x + 5, 5, 6, 2, rgb(parlak))
        if i == 1:
            t.kutu(x + 6, 5, 4, 1, rgb("beyaz"))
    return t.yaz("kontrol.png")


def uret_madalya():
    """36x12: altin / gumus / bronz — Bolum Sec ve bitis ekrani icin."""
    renkler = [("acsari", "sari", "beyaz"), ("acikgri", "gri", "beyaz"),
               ("kahve", "kokahve", "ten")]
    t = Tuval(36, 12)
    for i, (dis, ic, parlak) in enumerate(renkler):
        x = i * 12
        for j in range(12):
            for k in range(12):
                d = (k - 5.5) ** 2 + (j - 6.5) ** 2
                if d <= 20:
                    t.nokta(x + k, j, rgb(dis))
                if d <= 10:
                    t.nokta(x + k, j, rgb(ic))
        for k in (2, 9):                         # iki kurdele ucu
            t.kutu(x + k, 0, 2, 3, rgb("kirmizi"))
            t.nokta(x + k, 3, rgb("kankirmizi"))
        t.nokta(x + 4, 4, rgb(parlak))
        t.nokta(x + 5, 4, rgb(parlak))
        t.nokta(x + 4, 5, rgb(parlak))
    return t.yaz("madalya.png")


# --- parallaks arka plan ----------------------------------------------------
def _gokyuzu(t, ust, alt):
    a, b = rgb(ust), rgb(alt)
    for j in range(t.y):
        o = j / max(1, t.y - 1)
        t.kutu(0, j, t.g, 1, tuple(int(a[k] + (b[k] - a[k]) * o) for k in range(3)) + (255,))


def uret_arka_0():
    """En uzak katman: laboratuvar holunun karanligi + soluk izgara."""
    t = Tuval(320, 360)
    _gokyuzu(t, "siyah", "koyu")
    for x in range(0, 320, 32):              # soluk dikey izgara
        t.kutu(x, 0, 1, 360, rgb("koyu"))
    for y in range(0, 360, 32):
        t.kutu(0, y, 320, 1, rgb("koyu"))
    for x in range(24, 320, 96):             # uzak lamba halkalari
        for y in (60, 300):
            t.kutu(x, y, 10, 2, rgb("lacivert"))
    return t.yaz("arka_0.png")


def uret_arka_1():
    """Orta katman: dev tank siluetleri. Oyun alani onunde durdugu icin KOYU
    tutulur — ilk denemede acik tonlar oynanisin onune geciyordu."""
    t = Tuval(320, 360)
    desen = [(10, 150, 46, 150), (72, 190, 30, 110), (120, 120, 64, 190),
             (200, 170, 38, 120), (252, 140, 52, 160)]
    for x, y, g, yk in desen:
        t.kutu(x, y, g, yk, rgb("siyah"))
        t.kutu(x, y, g, 2, rgb("koyu"))
        for j in range(y + 14, y + yk - 10, 26):   # sonuk gosterge sirasi
            t.kutu(x + 6, j, 3, 2, rgb("koyu"))
    return t.yaz("arka_1.png")


def uret_arka_2():
    """En yakin katman: yalniz dikey kablolar ve sonuk lamba noktalari.
    YATAY hicbir sey yok — arka planda yatay bir cizgi oyuncu tarafindan
    platform saniliyor (ilk denemede ortadaki uyari seridi tam bunu yapti)."""
    t = Tuval(320, 360)
    for x in range(26, 320, 62):             # dikey kablo demeti
        t.kutu(x, 0, 2, 360, rgb("koyu"))
        t.kutu(x + 4, 0, 1, 360, rgb("koyu"))
        for y in range(40, 340, 90):
            t.kutu(x - 2, y, 7, 5, rgb("lacivert"))
            t.nokta(x + 1, y + 2, rgb("komavi"))
    for x in range(58, 320, 62):             # duvar lambasi
        for y in (96, 264):
            t.kutu(x, y, 4, 3, rgb("lacivert"))
            t.nokta(x + 1, y + 1, rgb("mavi"))
    return t.yaz("arka_2.png")


def onizleme(olcek=4):
    """Butun kucuk sprite'lari tek bir buyutulmus levhaya dizer: gozle denetlemek icin.
    Arka planlar cok buyuk oldugu icin disarida birakilir."""
    ogeler = [(ad, t) for ad, t in URETILEN if not ad.startswith("arka_")]
    bosluk = 4
    g = max(t.g for _, t in ogeler) * olcek + bosluk * 2
    g = max(g, 448 * olcek // 3)
    satirlar, x, y, satir_y = [], bosluk, bosluk, 0
    yer = []
    for ad, t in ogeler:
        if x + t.g * olcek > g - bosluk:
            x, y, satir_y = bosluk, y + satir_y + bosluk, 0
        yer.append((x, y, t))
        x += t.g * olcek + bosluk
        satir_y = max(satir_y, t.y * olcek)
    yukseklik = y + satir_y + bosluk
    levha = Tuval(g, yukseklik)
    levha.kutu(0, 0, g, yukseklik, rgb("acikgri"))
    for lx, ly, t in yer:
        levha.kutu(lx - 1, ly - 1, t.g * olcek + 2, t.y * olcek + 2, rgb("siyah"))
        for j in range(t.y):
            for i in range(t.g):
                px = t.p[j][i]
                if px[3] == 0:
                    px = rgb("acikmor") if (i + j) % 2 else rgb("mor")
                levha.kutu(lx + i * olcek, ly + j * olcek, olcek, olcek, px)
    del satirlar
    yol = os.path.join(KOK, "docs", "varliklar.png")
    os.makedirs(os.path.dirname(yol), exist_ok=True)
    png_yaz(yol, levha.g, levha.y, levha.p)
    print("  onizleme -> %s (%dx%d)" % (yol, levha.g, levha.y))


def main():
    os.makedirs(CIKTI, exist_ok=True)
    isler = [uret_oyuncu, uret_karo, uret_karo_ust, uret_diken, uret_gezgin,
             uret_platform, uret_kapi, uret_kristal, uret_kontrol, uret_madalya,
             uret_arka_0, uret_arka_1, uret_arka_2]
    for is_ in isler:
        yol = is_()
        print("  %-28s %6d bayt" % (os.path.basename(yol), os.path.getsize(yol)))
    print("%d varlik uretildi -> %s" % (len(isler), CIKTI))
    onizleme()


if __name__ == "__main__":
    main()
