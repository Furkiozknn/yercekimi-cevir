# -*- coding: utf-8 -*-
"""Ham RGB kare dizisini animasyonlu GIF'e cevirir. Harici kutuphane YOK.

Kullanim:
    python tools/gif_yap.py yayin/tanitim/kareler.raw yayin/tanitim/tanitim.gif 320 180 10
    python tools/gif_yap.py --dogrula        # LZW kodlayicinin oz denetimi

Girdi `tests/ekran.gd -- -5` tarafindan yazilir: W*H*3 bayt RGB8 kareler arka
arkaya. Pillow bu makinede kurulu degil (bkz. tools/uret_sprite.py), bu yuzden
palet + LZW burada elle yaziliyor.

Palet: butun karelerdeki renkler sayilir, en sik 256 tanesi alinir, kalanlar en
yakinina esleniyor. Oyun zaten 32 renkli bir palete (Endesga 32) bagli; 256
kutuyu dolduran sey arka plan tonlamasi ve yazi kenar yumusatmasi.
"""
import io
import os
import struct
import sys
from collections import Counter


class BitYazici:
    """GIF LZW akisi: kodlar dusuk bitten yuksege dogru paketlenir."""

    def __init__(self):
        self.cikti = bytearray()
        self._tampon = 0
        self._bit = 0

    def yaz(self, kod, bit):
        self._tampon |= kod << self._bit
        self._bit += bit
        while self._bit >= 8:
            self.cikti.append(self._tampon & 0xFF)
            self._tampon >>= 8
            self._bit -= 8

    def bosalt(self):
        if self._bit > 0:
            self.cikti.append(self._tampon & 0xFF)
            self._tampon = 0
            self._bit = 0


def lzw_sikistir(veri, taban_bit):
    """GIF'in degisken kod genisligi olan LZW'si.

    Kod genisligi bir kod GECIKMELI buyur (asagidaki +1'e bak); cozucunun
    tablosu kodlayicininkinden bir geridedir. Bu bir kod kaydirilirsa dosya
    sessizce bozuk cikar — bu yuzden gercek bir cozucuyle gidis-donus denetimi
    var (dogrula()).
    """
    temiz = 1 << taban_bit
    bitir = temiz + 1
    bw = BitYazici()
    genislik = taban_bit + 1
    tablo = {bytes([i]): i for i in range(temiz)}
    sonraki = bitir + 1
    bw.yaz(temiz, genislik)
    tampon = b""
    for b in veri:
        yeni = tampon + bytes([b])
        if yeni in tablo:
            tampon = yeni
            continue
        bw.yaz(tablo[tampon], genislik)
        if sonraki < 4096:
            tablo[yeni] = sonraki
            sonraki += 1
            # +1 KASITLI: cozucu tabloya bir kod GECIKMELI ekliyor (okudugu
            # kodun karsiligini bir sonraki kodda ogreniyor), yani onun tablosu
            # her zaman bir geridedir. Kodlayici genisligi bir kod erken
            # buyutursa cozucu hala dar okur ve dosya sessizce bozulur —
            # dogrula() ilk yazimda tam bunu yakaladi.
            if sonraki == (1 << genislik) + 1 and genislik < 12:
                genislik += 1
        else:
            bw.yaz(temiz, genislik)
            tablo = {bytes([i]): i for i in range(temiz)}
            sonraki = bitir + 1
            genislik = taban_bit + 1
        tampon = bytes([b])
    if tampon:
        bw.yaz(tablo[tampon], genislik)
    bw.yaz(bitir, genislik)
    bw.bosalt()
    return bytes(bw.cikti)


def lzw_coz(akis, taban_bit):
    """Yalniz dogrulama icin: yukaridaki kodlayicinin ciktisini geri okur."""
    temiz = 1 << taban_bit
    bitir = temiz + 1
    genislik = taban_bit + 1
    tablo = [bytes([i]) for i in range(temiz)] + [b"", b""]
    cikti = bytearray()
    onceki = None
    tampon = 0
    bit = 0
    i = 0
    while True:
        while bit < genislik:
            if i >= len(akis):
                return bytes(cikti)
            tampon |= akis[i] << bit
            bit += 8
            i += 1
        kod = tampon & ((1 << genislik) - 1)
        tampon >>= genislik
        bit -= genislik
        if kod == temiz:
            tablo = [bytes([j]) for j in range(temiz)] + [b"", b""]
            genislik = taban_bit + 1
            onceki = None
            continue
        if kod == bitir:
            return bytes(cikti)
        if kod < len(tablo):
            giris = tablo[kod]
        else:
            giris = onceki + onceki[:1]
        cikti += giris
        if onceki is not None:
            tablo.append(onceki + giris[:1])
            if len(tablo) == (1 << genislik) and genislik < 12:
                genislik += 1
        onceki = giris
    return bytes(cikti)


def bloklara_bol(veri):
    """GIF veri alt bloklari: en fazla 255 bayt, sonda 0."""
    cikti = bytearray()
    for i in range(0, len(veri), 255):
        parca = veri[i:i + 255]
        cikti.append(len(parca))
        cikti += parca
    cikti.append(0)
    return bytes(cikti)


def palet_kur(kareler):
    """Butun karelerin renklerini say, en sik 256'yi al."""
    sayac = Counter()
    for k in kareler:
        sayac.update(struct.unpack("3s" * (len(k) // 3), k))
    print("  farkli renk: %d" % len(sayac))
    return [tuple(r) for r, _ in sayac.most_common(256)]


def eslestir(kareler, palet):
    """Her pikseli palet indisine cevir; palet disi renk en yakinina gider."""
    dogrudan = {bytes(r): i for i, r in enumerate(palet)}
    onbellek = dict(dogrudan)
    cikti = []
    for k in kareler:
        pikseller = struct.unpack("3s" * (len(k) // 3), k)
        indis = bytearray(len(pikseller))
        for j, p in enumerate(pikseller):
            i = onbellek.get(p)
            if i is None:
                r, g, b = p[0], p[1], p[2]
                i = min(range(len(palet)),
                        key=lambda n: (palet[n][0] - r) ** 2 + (palet[n][1] - g) ** 2
                        + (palet[n][2] - b) ** 2)
                onbellek[p] = i
            indis[j] = i
        cikti.append(bytes(indis))
    print("  onbellek: %d renk" % len(onbellek))
    return cikti


def gif_yaz(yol, kareler_indis, palet, w, h, gecikme):
    taban = 8
    ciz = bytearray()
    ciz += b"GIF89a"
    ciz += struct.pack("<HHBBB", w, h, 0xF0 | (taban - 1), 0, 0)
    for i in range(256):
        r, g, b = palet[i] if i < len(palet) else (0, 0, 0)
        ciz += bytes((r, g, b))
    # NETSCAPE2.0: sonsuz dongu
    ciz += b"\x21\xFF\x0BNETSCAPE2.0\x03\x01\x00\x00\x00"
    for indis in kareler_indis:
        ciz += b"\x21\xF9\x04\x00" + struct.pack("<H", gecikme) + b"\x00\x00"
        ciz += b"\x2C" + struct.pack("<HHHHB", 0, 0, w, h, 0)
        ciz += bytes([taban])
        ciz += bloklara_bol(lzw_sikistir(indis, taban))
    ciz += b"\x3B"
    with open(yol, "wb") as f:
        f.write(ciz)
    return len(ciz)


def dogrula():
    """LZW kodlayici gercekten geri okunabilir mi? (kod genisligi buyumesi dahil)"""
    import random
    random.seed(7)
    for ad, veri in [
        ("tek renk", bytes(5000)),
        ("dar alfabe", bytes(random.randrange(4) for _ in range(20000))),
        ("genis alfabe", bytes(random.randrange(256) for _ in range(40000))),
        ("tekrarli", (bytes(range(64)) * 400)),
    ]:
        geri = lzw_coz(lzw_sikistir(veri, 8), 8)
        assert geri == veri, "%s: gidis-donus bozuk (%d/%d)" % (ad, len(geri), len(veri))
        print("  [OK] %-14s %6d bayt -> %6d" % (ad, len(veri), len(lzw_sikistir(veri, 8))))
    print("LZW dogrulandi")


def main():
    if "--dogrula" in sys.argv:
        dogrula()
        return
    if len(sys.argv) < 3:
        print(__doc__)
        return
    ham, cikti = sys.argv[1], sys.argv[2]
    w = int(sys.argv[3]) if len(sys.argv) > 3 else 320
    h = int(sys.argv[4]) if len(sys.argv) > 4 else 180
    gecikme = int(sys.argv[5]) if len(sys.argv) > 5 else 10
    with open(ham, "rb") as f:
        veri = f.read()
    boy = w * h * 3
    assert len(veri) % boy == 0, "ham veri %d bayt, kare %d bayta bolunmuyor" % (len(veri), boy)
    kareler = [veri[i:i + boy] for i in range(0, len(veri), boy)]
    print("%d kare, %dx%d" % (len(kareler), w, h))
    palet = palet_kur(kareler)
    indis = eslestir(kareler, palet)
    n = gif_yaz(cikti, indis, palet, w, h, gecikme)
    # Kendi ciktisini geri okuyup ilk kareyi dogrula: bozuk GIF sessizce
    # "acilmiyor" olur, burada patlasin.
    geri = lzw_coz(lzw_sikistir(indis[0], 8), 8)
    assert geri == indis[0], "GIF LZW akisi bozuk"
    print("yazildi: %s  %d bayt  (%d kare, %d ms)" % (cikti, n, len(kareler), gecikme * 10))


if __name__ == "__main__":
    main()
