# -*- coding: utf-8 -*-
"""scripts/bolumler.gd dosyasini uretir ve her bolumun cozulebilir oldugunu dogrular.

Kullanim:  python arac/uret_bolumler.py
Bolum duzenlemek icin asagidaki L listesini degistir, sonra bu betigi calistir.
Bant = (tip, ilk_sutun, son_sutun);  tip: gap (zeminde delik) | spike (zemin dikeni) | ceil (tavan dikeni)
Hareketli = (tip, satir, ilk_sutun, son_sutun);  tip: plat | spike
"""
import io, os, sys

H = 22        # satir sayisi (22 * 16 px = 352, taban cozunurluk 360'a oturur)
BASLA_C = 3   # baslangic sutunu

L = [
 dict(ad="1 — İlk Adım", w=40, ipucu="A / D ile yürü. Yeşil kapıya ulaş.",
      bands=[], hrk=[]),
 dict(ad="2 — Çevir", w=40, ipucu="BOŞLUK yerçekimini çevirir. Delikten geçmek için tavana düş.",
      bands=[("gap",15,26)], hrk=[]),
 dict(ad="3 — Diken", w=40, ipucu="Kırmızı diken öldürür. Çevirmek yalnızca bir yüzeye değerken çalışır.",
      bands=[("spike",14,22)], hrk=[]),
 dict(ad="4 — İleri Geri", w=40, ipucu="",
      bands=[("spike",8,14),("ceil",19,25),("gap",29,33)], hrk=[]),
 dict(ad="5 — Üç Engel", w=40, ipucu="",
      bands=[("gap",8,13),("ceil",17,23),("spike",27,32)], hrk=[]),
 dict(ad="6 — Asansör", w=40, ipucu="Mor platform gidip geliyor; üstüne ya da altına yapış.",
      bands=[("gap",10,20),("ceil",24,30)], hrk=[("plat",11,10,20)]),
 dict(ad="7 — Dört Vuruş", w=40, ipucu="",
      bands=[("spike",9,12),("ceil",15,19),("spike",22,26),("ceil",29,33)], hrk=[]),
 dict(ad="8 — Gezgin Diken", w=40, ipucu="Gezen diken zemini süpürüyor; tavana kaç.",
      bands=[("gap",12,17),("ceil",21,26)], hrk=[("spike",20,28,33)]),
 dict(ad="9 — Uzun Yol", w=64, ipucu="",
      bands=[("spike",8,12),("ceil",15,20),("gap",23,30),("ceil",33,38),("spike",41,46),("ceil",49,54)], hrk=[]),
 dict(ad="10 — Boşluk Üstü", w=64, ipucu="",
      bands=[("gap",7,12),("ceil",15,19),("spike",22,27),("ceil",30,35),("gap",38,44),("ceil",47,51),("spike",54,57)],
      hrk=[("plat",11,38,44)]),
 dict(ad="11 — Tarak", w=64, ipucu="",
      bands=[("spike",7,11),("ceil",14,18),("spike",21,25),("ceil",28,32),("gap",35,40),("ceil",43,47),("spike",50,54)],
      hrk=[("plat",10,35,40)]),
 dict(ad="12 — Son Kapı", w=64, ipucu="",
      bands=[("spike",7,10),("ceil",13,16),("gap",19,23),("ceil",26,30),("spike",33,37),("ceil",40,44),("gap",47,52),("ceil",55,57)],
      hrk=[("plat",11,47,52)]),
]


def kur(d):
    w = d["w"]
    kapi = w - 4
    g = [["." for _ in range(w)] for _ in range(H)]
    for c in range(w):
        g[0][c] = "#"
        g[H-1][c] = "#"
    for r in range(1, H-1):
        g[r][0] = "#"
        g[r][w-1] = "#"
    zemin, tavan = set(), set()
    for tip, c1, c2 in d["bands"]:
        assert 1 <= c1 <= c2 <= w-2, (d["ad"], tip, c1, c2)
        for c in range(c1, c2+1):
            if tip == "gap":
                g[H-1][c] = "."; zemin.add(c)
            elif tip == "spike":
                g[H-2][c] = "^"; zemin.add(c)
            else:
                g[1][c] = "v"; tavan.add(c)
    assert not (zemin & tavan), (d["ad"], "ayni sutunda hem zemin hem tavan tehlikeli")
    bs = sorted(d["bands"], key=lambda b: b[1])
    for i in range(len(bs)-1):
        assert bs[i][2] + 3 <= bs[i+1][1], (d["ad"], "cevirme penceresi cok dar", bs[i], bs[i+1])
    if bs:
        assert bs[0][1] >= BASLA_C + 3, (d["ad"], "ilk bant baslangica cok yakin")
        assert bs[-1][2] + 3 <= kapi, (d["ad"], "son bant kapiya cok yakin")
    for tip, r, c1, c2 in d["hrk"]:
        assert 1 <= r <= H-2 and 1 <= c1 < c2 <= w-2, (d["ad"], "hareketli sinir disi")
        ch = "-" if tip == "plat" else "*"
        for c in range(c1, c2+1):
            assert g[r][c] == ".", (d["ad"], "hareketli cakisiyor", r, c)
            g[r][c] = ch
    assert g[H-2][BASLA_C] == "." and g[H-1][BASLA_C] == "#", d["ad"]
    assert g[H-2][kapi] == "." and g[H-1][kapi] == "#", d["ad"]
    g[H-2][BASLA_C] = "S"
    g[H-2][kapi] = "K"
    return ["".join(r) for r in g]


def main():
    out = io.StringIO()
    out.write('''extends RefCounted
class_name Bolumler
## Butun bolumler ASCII harita olarak burada.
## Bu dosya arac/uret_bolumler.py tarafindan uretilir (elle de duzenlenebilir).
##
## Karakterler:
##   #  kati blok                     .  bos
##   ^  zemin dikeni                  v  tavan dikeni
##   S  baslangic (tam 1 tane)        K  kapi (en az 1 tane)
##   -  yatay hareketli platform      *  yatay hareketli diken
## Ard arda gelen - / * isaretleri o parcanin gidip geldigi araligi belirler.

const BOLUMLER: Array[Dictionary] = [
''')
    for d in L:
        rows = kur(d)
        assert sum(r.count("S") for r in rows) == 1
        assert sum(r.count("K") for r in rows) >= 1
        out.write('\t{\n\t\t"ad": "%s",\n\t\t"ipucu": "%s",\n\t\t"harita": [\n' % (d["ad"], d["ipucu"]))
        for r in rows:
            out.write('\t\t\t"%s",\n' % r)
        out.write('\t\t],\n\t},\n')
    out.write(']\n')
    yol = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "scripts", "bolumler.gd")
    with open(yol, "w", encoding="utf-8", newline="\n") as f:
        f.write(out.getvalue())
    print("%d bolum yazildi -> %s" % (len(L), yol))


if __name__ == "__main__":
    main()
