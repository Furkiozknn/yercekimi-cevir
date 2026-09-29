# -*- coding: utf-8 -*-
"""Oyunun butun varliklarini kodla uretir -> assets/sprites/*.png

Kullanim:  python tools/uret_sprite.py

v1.0 (arayuz yenilemesi): pixel-art EDG32 "laboratuvar" temasi yerine tanitim
videosundaki DUZ renk dunyasi (bkz. docs/TASARIM.md). Her sey duz dolgu:
golge, degrade, dis cizgi yok. Kenarlar 4x4 alt ornekleme ile yumusatilir, bu
yuzden proje dokusu filtresi dogrusal (project.godot).

Neden kodla: bu makinede GUI cizim araci yok ve Pillow kurulu degil. PNG yazici
asagida (zlib + struct); sekiller matematiksel maskelerden cizilir. Her sey
yeniden uretilebilir: dosyalari silip betigi calistir.

Bolumun blok ve dikenleri PNG degil: scripts/bolum.gd _draw ile vektor cizer
(tema rengine boyanir, her olcekte keskin). Eski karo/diken/tek_yonlu
dosyalari _eski/sprites-v0.9/ altinda.
"""
import os
import struct
import zlib

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CIKTI = os.path.join(KOK, "assets", "sprites")

# --- Palet (scripts/tema.gd ile ayni) ---------------------------------------
MUREKKEP = "#0e0d0b"
KAGIT = "#f1ece2"
DIKEN = "#e94f36"
OYUNCU = "#4585bd"
CAM = "#7dd4e7"
SARI = "#ffc21a"
SARI_KOYU = "#e0a200"
GRI = "#8a8478"
GUMUS = "#c9ccd6"
BRONZ = "#c9865a"
BEYAZ = "#ffffff"


def rgb(h, a=255):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)


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


# --- maskeler: (px, py) -> bool ---------------------------------------------
def dikdortgen(x0, y0, x1, y1):
    return lambda x, y: x0 <= x < x1 and y0 <= y < y1


def yuvarlak_dikdortgen(x0, y0, x1, y1, r):
    def f(x, y):
        if not (x0 <= x < x1 and y0 <= y < y1):
            return False
        cx = min(max(x, x0 + r), x1 - r)
        cy = min(max(y, y0 + r), y1 - r)
        return (x - cx) ** 2 + (y - cy) ** 2 <= r * r
    return f


def daire(cx, cy, r):
    return lambda x, y: (x - cx) ** 2 + (y - cy) ** 2 <= r * r


def eleman(cx, cy, rx, ry):
    """Elmas (donmus kare): |dx|/rx + |dy|/ry <= 1."""
    return lambda x, y: abs(x - cx) / rx + abs(y - cy) / ry <= 1.0


def ucgen(a, b, c):
    def isaret(p1, p2, p3):
        return (p1[0] - p3[0]) * (p2[1] - p3[1]) - (p2[0] - p3[0]) * (p1[1] - p3[1])

    def f(x, y):
        p = (x, y)
        d1, d2, d3 = isaret(p, a, b), isaret(p, b, c), isaret(p, c, a)
        neg = d1 < 0 or d2 < 0 or d3 < 0
        poz = d1 > 0 or d2 > 0 or d3 > 0
        return not (neg and poz)
    return f


def birlesim(*maskeler):
    return lambda x, y: any(m(x, y) for m in maskeler)


def fark(a, b):
    return lambda x, y: a(x, y) and not b(x, y)


def halka(cx, cy, r_dis, r_ic):
    return lambda x, y: r_ic * r_ic <= (x - cx) ** 2 + (y - cy) ** 2 <= r_dis * r_dis


class Tuval:
    ALT = 4          # piksel basina ALT x ALT ornek

    def __init__(self, g, y):
        self.g, self.y = g, y
        self.p = [[SEFFAF] * g for _ in range(y)]

    def boya(self, maske, renk, x_bas=0, y_bas=0, g=None, y=None):
        """Maske icindeki alani renkle boyar (kenarda kaplama orani = alfa).
        x_bas.. arasi kutu yalniz hiz icin; maske zaten sinirlar."""
        g = self.g if g is None else g
        y = self.y if y is None else y
        n = self.ALT
        for j in range(max(0, y_bas), min(self.y, y_bas + y)):
            for i in range(max(0, x_bas), min(self.g, x_bas + g)):
                say = 0
                for sj in range(n):
                    for si in range(n):
                        if maske(i + (si + 0.5) / n, j + (sj + 0.5) / n):
                            say += 1
                if say == 0:
                    continue
                a = renk[3] * say / (n * n) / 255.0
                r0, g0, b0, a0 = self.p[j][i]
                a0f = a0 / 255.0
                ao = a + a0f * (1.0 - a)
                if ao <= 0:
                    continue
                self.p[j][i] = (
                    round((renk[0] * a + r0 * a0f * (1.0 - a)) / ao),
                    round((renk[1] * a + g0 * a0f * (1.0 - a)) / ao),
                    round((renk[2] * a + b0 * a0f * (1.0 - a)) / ao),
                    round(ao * 255))

    def yaz(self, ad):
        URETILEN.append((ad, self))
        return png_yaz(os.path.join(CIKTI, ad), self.g, self.y, self.p)


URETILEN = []
PARILTI_KARE = 4


def _sayfa(kareler, ad):
    """Kareleri yan yana tek levhaya dizer (Sprite2D.hframes = kare sayisi)."""
    g, y = kareler[0].g, kareler[0].y
    s = Tuval(g * len(kareler), y)
    for i, k in enumerate(kareler):
        for j in range(y):
            for x in range(g):
                s.p[j][i * g + x] = k.p[j][x]
    return s.yaz(ad)


# --- oyuncu -----------------------------------------------------------------
def uret_oyuncu():
    """8 kare x 16x24, hepsi AYNI: duz mavi yuvarlatilmis kare + tek goz.
    Kare duzeni (idle 2, yuru 4, zipla 1, dus 1) oyuncu_frames.tres'te durur;
    hareket dili squash/stretch ile (scripts/oyuncu.gd), kare degisimiyle degil.
    Goz bakis yonunu gosterir: flip_h yatay, flip_v tavanda ters cevirir.
    Gorsel 14x20 (isabet kutusu 12x20): kenarda 1 px bosluk, oyuncuyu haksiz
    yere olduren gorsel yok."""
    kare = Tuval(16, 24)
    kare.boya(yuvarlak_dikdortgen(1, 2, 15, 22, 4.0), rgb(OYUNCU))
    kare.boya(daire(10.6, 8.2, 1.7), rgb(KAGIT))
    return _sayfa([kare] * 8, "oyuncu.png")


def uret_hayalet():
    """16x24 BEYAZ oyuncu golgesi: hayalet, altin hayalet ve cevirme izi bunu
    modulate ile boyar (mavi oyuncu dokusu renkle carpilinca bozulurdu)."""
    t = Tuval(16, 24)
    t.boya(yuvarlak_dikdortgen(1, 2, 15, 22, 4.0), rgb(BEYAZ))
    return t.yaz("hayalet.png")


# --- tehlike ---------------------------------------------------------------
def uret_gezgin():
    """24x10 gezgin diken: ortada dar govde, ust ve altta ucgen disler. Duz kirmizi."""
    govde = yuvarlak_dikdortgen(1, 3, 23, 7, 1.5)
    disler = []
    for x in range(2, 22, 4):
        disler.append(ucgen((x, 3.2), (x + 4, 3.2), (x + 2, 0.4)))
        disler.append(ucgen((x, 6.8), (x + 4, 6.8), (x + 2, 9.6)))
    t = Tuval(24, 10)
    t.boya(birlesim(govde, *disler), rgb(DIKEN))
    return t.yaz("gezgin.png")


def uret_platform():
    """48x10 hareketli platform: duz camgobegi, yuvarlak uclu (guvenli + hareketli)."""
    t = Tuval(48, 10)
    t.boya(yuvarlak_dikdortgen(0, 0, 48, 10, 3.0), rgb(CAM))
    return t.yaz("platform.png")


def uret_inis():
    """20x5 inis gostergesi: iki uc direk + ince cizgi, beyaz. Rengi kodda
    boyanir (mavi = temiz inis, kirmizi = yolda diken var)."""
    t = Tuval(20, 5)
    t.boya(birlesim(yuvarlak_dikdortgen(0, 0, 2.5, 5, 1.0), yuvarlak_dikdortgen(17.5, 0, 20, 5, 1.0),
                    dikdortgen(2, 2, 18, 3)), rgb(BEYAZ))
    return t.yaz("inis.png")


def uret_kilit():
    """12x12 asma kilit, BEYAZ: bolum blok rengine boyanir (tema neyse o)."""
    t = Tuval(12, 12)
    kanca = fark(halka(6, 4.6, 3.6, 2.2), dikdortgen(0, 5, 12, 12))
    govde = fark(yuvarlak_dikdortgen(1.5, 5, 10.5, 11.5, 1.5), daire(6, 8, 1.1))
    t.boya(birlesim(kanca, govde), rgb(BEYAZ))
    return t.yaz("kilit.png")


# --- hedef, toplanabilir, kontrol noktasi -----------------------------------
def _kapi_karesi(kare):
    """16x48 kapi: sari govde, icinde koyu sari oyuk ve yukari kayan acik cizgi."""
    t = Tuval(16, 48)
    t.boya(yuvarlak_dikdortgen(0, 0, 16, 48, 3.0), rgb(SARI))
    t.boya(yuvarlak_dikdortgen(4, 5, 12, 43, 2.0), rgb(SARI_KOYU))
    y = 36 - kare * 9
    t.boya(yuvarlak_dikdortgen(6, y, 10, y + 7, 1.5), rgb(KAGIT))
    return t


def uret_kapi():
    """64x48: 4 kareli kapi (yalniz scripts/bolum.gd kullanir)."""
    return _sayfa([_kapi_karesi(k) for k in range(PARILTI_KARE)], "kapi.png")


def _kristal_karesi(kare):
    t = Tuval(12, 12)
    t.boya(eleman(6, 6, 5.6, 5.6), rgb(SARI_KOYU if kare == 2 else SARI))
    lekeler = [None, (4.2, 4.2), (6.0, 3.6), (7.6, 5.0)]
    if lekeler[kare]:
        t.boya(daire(lekeler[kare][0], lekeler[kare][1], 1.0), rgb(KAGIT))
    return t


def uret_kristal():
    """12x12 TEK kare: HUD, menu ve Bolum Sec simgesi (parildamaz)."""
    return _kristal_karesi(0).yaz("kristal.png")


def uret_kristal_parilti():
    """48x12: bolum icindeki kristalin 4 kareli sayfasi."""
    return _sayfa([_kristal_karesi(k) for k in range(PARILTI_KARE)], "kristal_parilti.png")


def uret_kontrol():
    """32x24: iki kare — 0 pasif (gri), 1 aktif (camgobegi). Direk + ucgen bayrak."""
    t = Tuval(32, 24)
    for i, renk in enumerate([GRI, CAM]):
        x = i * 16
        t.boya(yuvarlak_dikdortgen(x + 5.5, 2, x + 7.5, 24, 1.0), rgb(renk))
        t.boya(ucgen((x + 7.5, 2.5), (x + 7.5, 11.5), (x + 15, 7)), rgb(renk))
    return t.yaz("kontrol.png")


def uret_madalya():
    """36x12: altin / gumus / bronz — duz daire."""
    t = Tuval(36, 12)
    for i, renk in enumerate([SARI, GUMUS, BRONZ]):
        t.boya(daire(i * 12 + 6, 6, 5.2), rgb(renk))
    return t.yaz("madalya.png")


# --- arayuz parcalari --------------------------------------------------------
def uret_arayuz():
    """Kaydirici tutamagi ve anahtar (CheckButton) resimleri."""
    t = Tuval(16, 16)
    t.boya(daire(8, 8, 6.5), rgb(CAM))
    t.yaz("tutamak.png")
    for ad, acik, engelli in [("anahtar_acik", True, False), ("anahtar_kapali", False, False),
                              ("anahtar_acik_pasif", True, True), ("anahtar_kapali_pasif", False, True)]:
        s = Tuval(32, 16)
        alfa = 90 if engelli else 255
        if acik:
            s.boya(yuvarlak_dikdortgen(0, 1, 32, 15, 7.0), rgb(CAM, alfa))
            s.boya(daire(23.5, 8, 5.2), rgb(MUREKKEP, alfa))
        else:
            s.boya(yuvarlak_dikdortgen(0, 1, 32, 15, 7.0), rgb(KAGIT, 60 if not engelli else 30))
            s.boya(daire(8.5, 8, 5.2), rgb(KAGIT, 200 if not engelli else 90))
        s.yaz(ad + ".png")


# --- arka plan: eGik uzun cubuklar -------------------------------------------
# Videodaki egik bloklar: her katman 320 px genis, x'te PERIYODIK (320) — iki
# kopya yan yana ekrani ortu (CLAUDE.md tuzak 21) ve dikis gorunmez. BEYAZ,
# dusuk alfa: oyun sahnesi blok rengiyle boyar (Oyun._arka_ton).
def _cubuk(t, ofset, egim, genislik, alfa):
    """Her satirda x = ofset + egim*y (mod 320) etrafinda genislik px'lik serit."""
    for j in range(t.y):
        merkez = (ofset + egim * j) % 320.0
        for i in range(t.g):
            d = min(abs(i + 0.5 - merkez), 320 - abs(i + 0.5 - merkez))
            if d <= genislik / 2.0:
                t.p[j][i] = (255, 255, 255, alfa)
            elif d <= genislik / 2.0 + 1.0:
                a = alfa * (1.0 - (d - genislik / 2.0))
                t.p[j][i] = (255, 255, 255, round(a))


def uret_arka_0():
    t = Tuval(320, 360)
    _cubuk(t, 70, 0.55, 46, 18)
    return t.yaz("arka_0.png")


def uret_arka_1():
    t = Tuval(320, 360)
    _cubuk(t, 250, -0.9, 12, 26)
    return t.yaz("arka_1.png")


def uret_arka_2():
    t = Tuval(320, 360)
    _cubuk(t, 160, 0.3, 3, 34)
    return t.yaz("arka_2.png")


def onizleme(olcek=4):
    """Kucuk varliklari tek levhaya dizer (docs/varliklar.png): gozle denetim."""
    ogeler = [(ad, t) for ad, t in URETILEN if not ad.startswith("arka_")]
    bosluk = 6
    g = 720
    yer, x, y, satir_y = [], bosluk, bosluk, 0
    for ad, t in ogeler:
        if x + t.g * olcek > g - bosluk:
            x, y, satir_y = bosluk, y + satir_y + bosluk, 0
        yer.append((x, y, t))
        x += t.g * olcek + bosluk
        satir_y = max(satir_y, t.y * olcek)
    yukseklik = y + satir_y + bosluk
    levha = Tuval(g, yukseklik)
    zemin = rgb("#1c141c")
    for j in range(yukseklik):
        for i in range(g):
            levha.p[j][i] = zemin
    for lx, ly, t in yer:
        for j in range(t.y * olcek):
            for i in range(t.g * olcek):
                px = t.p[j // olcek][i // olcek]
                a = px[3] / 255.0
                if a > 0:
                    z = levha.p[ly + j][lx + i]
                    levha.p[ly + j][lx + i] = tuple(round(px[k] * a + z[k] * (1 - a)) for k in range(3)) + (255,)
    yol = os.path.join(KOK, "docs", "varliklar.png")
    os.makedirs(os.path.dirname(yol), exist_ok=True)
    png_yaz(yol, levha.g, levha.y, levha.p)
    print("  onizleme -> %s (%dx%d)" % (yol, levha.g, levha.y))


def main():
    os.makedirs(CIKTI, exist_ok=True)
    isler = [uret_oyuncu, uret_hayalet, uret_gezgin, uret_platform, uret_inis, uret_kilit, uret_kapi,
             uret_kristal, uret_kristal_parilti, uret_kontrol, uret_madalya,
             uret_arka_0, uret_arka_1, uret_arka_2]
    for is_ in isler:
        yol = is_()
        print("  %-28s %6d bayt" % (os.path.basename(yol), os.path.getsize(yol)))
    uret_arayuz()
    print("%d varlik + arayuz parcalari uretildi -> %s" % (len(isler), CIKTI))
    onizleme()


if __name__ == "__main__":
    main()
