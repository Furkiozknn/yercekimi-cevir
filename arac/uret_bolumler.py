# -*- coding: utf-8 -*-
"""scripts/bolumler.gd dosyasini uretir ve her bolumun cozulebilir oldugunu dogrular.

Kullanim:  python arac/uret_bolumler.py
Bolum duzenlemek icin asagidaki L listesini degistir, sonra bu betigi calistir.

Bant      = (tip, ilk_sutun, son_sutun)
            tip: gap (zeminde delik) | spike (zemin dikeni) | ceil (tavan dikeni)
Hareketli = (tip, satir, ilk_sutun, son_sutun);  tip: plat | spike

Kristal ve kontrol noktasi ELLE degil, otomatik yerlesir (bkz. kristal_sec /
kontrol_sec): kristal ana rotanin disina, kontrol noktasi uzun bolumlerin ortasina.
Madalya sureleri de geometriden hesaplanir (bkz. madalyalar).
"""
import io, os

H = 22        # satir sayisi (22 * 16 px = 352, taban cozunurluk 360'a oturur)
BASLA_C = 3   # baslangic sutunu
HUCRE = 16    # piksel / kare   (Ayarlar.HUCRE ile ayni olmali)
HIZ = 125.0   # yatay en yuksek hiz (Ayarlar.HIZ ile ayni olmali)
PAY = 8       # kristal kacamagi icin guvenli sutun payi
UZUN = 56     # bu genislikten sonra kontrol noktasi konur

L = [
 dict(ad="1 — İlk Adım", w=40, ipucu="A / D ile yürü. Yeşil kapıya ulaş.",
      bands=[], hrk=[], kristal="zemin"),
 dict(ad="2 — Çevir", w=40, ipucu="BOŞLUK yerçekimini çevirir. Delikten geçmek için tavana düş.",
      bands=[("gap", 15, 26)], hrk=[]),
 dict(ad="3 — Tavan Yolu", w=40, ipucu="Tavanda yürüyorsun. Boşluğu geçince tekrar çevir.",
      bands=[("gap", 12, 24)], hrk=[]),
 dict(ad="4 — Diken", w=40, ipucu="Kırmızı diken öldürür. Çevirmek yalnızca bir yüzeye değerken çalışır.",
      bands=[("spike", 14, 22)], hrk=[]),
 dict(ad="5 — Tavan Dikeni", w=40, ipucu="Tavanda da diken var. Burada zeminde kal.",
      bands=[("ceil", 13, 22)], hrk=[]),
 dict(ad="6 — İleri Geri", w=40, ipucu="",
      bands=[("spike", 8, 13), ("ceil", 18, 24), ("gap", 28, 33)], hrk=[]),
 dict(ad="7 — Üç Engel", w=40, ipucu="",
      bands=[("gap", 8, 13), ("ceil", 17, 22), ("spike", 26, 32)], hrk=[]),
 dict(ad="8 — Asansör", w=40, ipucu="Mor platform gidip geliyor; üstüne ya da altına yapış.",
      bands=[("gap", 10, 20), ("ceil", 25, 31)], hrk=[("plat", 11, 10, 20)]),
 dict(ad="9 — Salıncak", w=40, ipucu="",
      bands=[("gap", 9, 16), ("ceil", 20, 25), ("spike", 29, 33)], hrk=[("plat", 11, 9, 16)]),
 dict(ad="10 — Dört Vuruş", w=40, ipucu="",
      bands=[("spike", 9, 12), ("ceil", 15, 19), ("spike", 22, 26), ("ceil", 29, 33)], hrk=[]),
 dict(ad="11 — Gezgin Diken", w=40, ipucu="Gezen diken zemini süpürüyor; zamanla ya da tavana kaç.",
      bands=[("gap", 12, 17), ("ceil", 21, 26)], hrk=[("spike", 20, 28, 33)]),
 dict(ad="12 — Süpürge", w=40, ipucu="",
      bands=[("ceil", 8, 13), ("gap", 26, 32)], hrk=[("spike", 20, 14, 22)]),
 dict(ad="13 — Uzun Yol", w=64, ipucu="Mavi kontrol noktası ölünce seni oraya döndürür.",
      bands=[("spike", 8, 12), ("ceil", 16, 21), ("gap", 25, 32), ("ceil", 36, 41),
             ("spike", 45, 50), ("ceil", 54, 57)],
      hrk=[]),
 dict(ad="14 — Boşluk Üstü", w=64, ipucu="",
      bands=[("gap", 7, 12), ("ceil", 16, 20), ("spike", 24, 29), ("ceil", 33, 38),
             ("gap", 42, 48), ("ceil", 52, 56)],
      hrk=[("plat", 11, 42, 48)]),
 dict(ad="15 — Tarak", w=64, ipucu="",
      bands=[("spike", 7, 11), ("ceil", 15, 19), ("spike", 23, 27), ("ceil", 31, 35),
             ("gap", 39, 44), ("ceil", 48, 52), ("spike", 56, 57)],
      hrk=[("plat", 10, 39, 44)]),
 dict(ad="16 — Kılçık", w=64, ipucu="",
      bands=[("ceil", 7, 10), ("spike", 14, 17), ("ceil", 21, 24), ("spike", 28, 31),
             ("ceil", 35, 38), ("spike", 42, 45), ("ceil", 49, 52), ("spike", 56, 57)],
      hrk=[]),
 dict(ad="17 — İki Asansör", w=64, ipucu="",
      bands=[("gap", 8, 15), ("ceil", 19, 24), ("gap", 28, 35), ("ceil", 39, 44),
             ("spike", 48, 53), ("ceil", 57, 57)],
      hrk=[("plat", 11, 8, 15), ("plat", 10, 28, 35)]),
 dict(ad="18 — Koridor", w=64, ipucu="",
      bands=[("spike", 8, 13), ("ceil", 17, 22), ("spike", 26, 31), ("ceil", 35, 40),
             ("gap", 44, 50), ("ceil", 54, 57)],
      hrk=[("spike", 20, 32, 38)]),
 dict(ad="19 — Fırtına", w=64, ipucu="",
      bands=[("gap", 7, 13), ("ceil", 17, 22), ("spike", 26, 30), ("ceil", 34, 39),
             ("gap", 43, 49), ("ceil", 53, 57)],
      hrk=[("plat", 11, 43, 49), ("spike", 20, 32, 38)]),
 dict(ad="20 — Son Kapı", w=64, ipucu="",
      bands=[("spike", 7, 10), ("ceil", 14, 17), ("gap", 21, 26), ("ceil", 30, 34),
             ("spike", 38, 42), ("ceil", 46, 50), ("gap", 54, 57)],
      hrk=[("plat", 11, 21, 26), ("plat", 10, 54, 57)]),
]


def bos_izgara(w):
    g = [["." for _ in range(w)] for _ in range(H)]
    for c in range(w):
        g[0][c] = "#"
        g[H - 1][c] = "#"
    for r in range(1, H - 1):
        g[r][0] = "#"
        g[r][w - 1] = "#"
    return g


def yasak_sutunlar(d):
    """Kristal kacamaginin olumcul oldugu sutunlar (bant + PAY payi)."""
    tavan, zemin = set(), set()
    for tip, c1, c2 in d["bands"]:
        hedef = tavan if tip == "ceil" else zemin
        hedef.update(range(c1 - PAY, c2 + PAY + 1))
    for tip, r, c1, c2 in d["hrk"]:
        if tip != "spike":
            continue
        hedef = tavan if r <= 2 else zemin
        hedef.update(range(c1 - PAY, c2 + PAY + 1))
    return tavan, zemin


def kristal_sec(d, g, kapi):
    """Kristali ana rotanin disina koy: once tavana (zeminde yuruyen oyuncu icin
    kacamak), olmuyorsa zemine. Bant civarindan PAY sutun uzak durur ki
    beceriksiz bir kacamak da olumle bitmesin."""
    tavan, zemin = yasak_sutunlar(d)
    orta = (BASLA_C + kapi) // 2
    tercih = [d["kristal"]] if d.get("kristal") else ["tavan", "zemin"]
    for taraf in tercih:
        r = 1 if taraf == "tavan" else H - 2
        yasak = tavan if taraf == "tavan" else zemin
        adaylar = [c for c in range(BASLA_C + 2, kapi - 1)
                   if c not in yasak and g[r][c] == "." and c not in (BASLA_C, kapi)]
        if adaylar:
            return r, min(adaylar, key=lambda c: abs(c - orta))
    raise AssertionError((d["ad"], "kristale yer bulunamadi"))


def kontrol_sec(d, g, w, kapi):
    """Uzun bolumlerin ortasina, banttan uzak bir zemin karesine kontrol noktasi."""
    if w < UZUN:
        return None
    # Yalniz ZEMIN tehlikeleri onemli: kontrol noktasi zeminde duruyor, tepesindeki
    # tavan dikeni ona dokunmuyor.
    dar = set()
    for tip, c1, c2 in d["bands"]:
        if tip != "ceil":
            dar.update(range(c1 - 2, c2 + 3))
    for tip, r, c1, c2 in d["hrk"]:
        if r >= H - 4:
            dar.update(range(c1 - 2, c2 + 3))
    orta = (BASLA_C + kapi) // 2

    def uygun(kume):
        return [c for c in range(BASLA_C + 4, kapi - 3)
                if c not in kume and g[H - 2][c] == "." and g[H - 1][c] == "#"]

    adaylar = uygun(dar)
    assert adaylar, (d["ad"], "kontrol noktasina yer bulunamadi")
    return min(adaylar, key=lambda c: abs(c - orta))


def madalyalar(d, kapi):
    """Altin/gumus/bronz hedef sureler geometriden: yol uzunlugu + bant basina
    bir cevirme bedeli. Elle ayar yok, bolum degisince kendiliginden guncellenir."""
    temel = (kapi - BASLA_C) * HUCRE / HIZ
    altin = round(temel * 1.15 + 0.45 * len(d["bands"]), 1)
    return altin, round(altin * 1.45, 1), round(altin * 2.1, 1)


def kur(d):
    w = d["w"]
    kapi = w - 4
    g = bos_izgara(w)
    zemin_t, tavan_t = set(), set()
    for tip, c1, c2 in d["bands"]:
        assert 1 <= c1 <= c2 <= w - 2, (d["ad"], tip, c1, c2)
        for c in range(c1, c2 + 1):
            if tip == "gap":
                g[H - 1][c] = "."
                zemin_t.add(c)
            elif tip == "spike":
                g[H - 2][c] = "^"
                zemin_t.add(c)
            else:
                g[1][c] = "v"
                tavan_t.add(c)
    assert not (zemin_t & tavan_t), (d["ad"], "ayni sutunda hem zemin hem tavan tehlikeli")
    bs = sorted(d["bands"], key=lambda b: b[1])
    for i in range(len(bs) - 1):
        assert bs[i][2] + 3 <= bs[i + 1][1], (d["ad"], "cevirme penceresi cok dar", bs[i], bs[i + 1])
    if bs:
        assert bs[0][1] >= BASLA_C + 3, (d["ad"], "ilk bant baslangica cok yakin")
        assert bs[-1][2] + 3 <= kapi, (d["ad"], "son bant kapiya cok yakin")
    for tip, r, c1, c2 in d["hrk"]:
        assert 1 <= r <= H - 2 and 1 <= c1 < c2 <= w - 2, (d["ad"], "hareketli sinir disi")
        ch = "-" if tip == "plat" else "*"
        for c in range(c1, c2 + 1):
            assert g[r][c] == ".", (d["ad"], "hareketli cakisiyor", r, c)
            g[r][c] = ch
    assert g[H - 2][BASLA_C] == "." and g[H - 1][BASLA_C] == "#", d["ad"]
    assert g[H - 2][kapi] == "." and g[H - 1][kapi] == "#", d["ad"]
    g[H - 2][BASLA_C] = "S"
    g[H - 2][kapi] = "K"

    kr, kc = kristal_sec(d, g, kapi)
    assert g[kr][kc] == ".", (d["ad"], "kristal dolu kareye dusuyor")
    g[kr][kc] = "C"
    kn = kontrol_sec(d, g, w, kapi)
    if kn is not None:
        assert g[H - 2][kn] == ".", (d["ad"], "kontrol noktasi dolu kareye dusuyor")
        g[H - 2][kn] = "P"
    return ["".join(r) for r in g], madalyalar(d, kapi)


BASLIK = '''extends RefCounted
class_name Bolumler
## Butun bolumler ASCII harita olarak burada.
## Bu dosya arac/uret_bolumler.py tarafindan uretilir (elle duzenleme ustune yazilir).
##
## Karakterler:
##   #  kati blok                     .  bos
##   ^  zemin dikeni                  v  tavan dikeni
##   S  baslangic (tam 1 tane)        K  kapi (en az 1 tane)
##   C  gizli kristal (tam 1 tane)    P  kontrol noktasi (0 ya da 1 tane)
##   -  yatay hareketli platform      *  yatay hareketli diken
## Ard arda gelen - / * isaretleri o parcanin gidip geldigi araligi belirler.
##
## "altin"/"gumus"/"bronz": madalya hedef sureleri (saniye).

const BOLUMLER: Array[Dictionary] = [
'''


def main():
    out = io.StringIO()
    out.write(BASLIK)
    ozet = []
    for d in L:
        rows, (altin, gumus, bronz) = kur(d)
        assert sum(r.count("S") for r in rows) == 1, d["ad"]
        assert sum(r.count("K") for r in rows) >= 1, d["ad"]
        assert sum(r.count("C") for r in rows) == 1, d["ad"]
        assert sum(r.count("P") for r in rows) <= 1, d["ad"]
        out.write('\t{\n\t\t"ad": "%s",\n\t\t"ipucu": "%s",\n' % (d["ad"], d["ipucu"]))
        out.write('\t\t"altin": %.1f,\n\t\t"gumus": %.1f,\n\t\t"bronz": %.1f,\n'
                  % (altin, gumus, bronz))
        out.write('\t\t"harita": [\n')
        for r in rows:
            out.write('\t\t\t"%s",\n' % r)
        out.write("\t\t],\n\t},\n")
        kr = [(i, s.index("C")) for i, s in enumerate(rows) if "C" in s][0]
        kn = [s.index("P") for s in rows if "P" in s]
        ozet.append("  %-20s kristal=%s@%-2d kontrol=%-3s madalya=%.1f / %.1f / %.1f"
                    % (d["ad"], "tavan" if kr[0] < 3 else "zemin", kr[1],
                       kn[0] if kn else "-", altin, gumus, bronz))
    out.write("]\n")
    yol = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                       "scripts", "bolumler.gd")
    with open(yol, "w", encoding="utf-8", newline="\n") as f:
        f.write(out.getvalue())
    print("%d bolum yazildi -> %s" % (len(L), yol))
    print("\n".join(ozet))


if __name__ == "__main__":
    main()
