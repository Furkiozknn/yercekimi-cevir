# -*- coding: utf-8 -*-
"""scripts/bolumler.gd dosyasini uretir ve her bolumun cozulebilir oldugunu dogrular.

Kullanim:  python arac/uret_bolumler.py
Bolum duzenlemek icin asagidaki L listesini degistir, sonra bu betigi calistir.

Bant      = (tip, ilk_sutun, son_sutun)
            tip: gap (zeminde delik) | spike (zemin dikeni) | ceil (tavan dikeni)
Hareketli = (tip, satir, ilk_sutun, son_sutun);  tip: plat | spike
Yasak     = (yuzey, ilk_sutun, son_sutun);  yuzey: zemin | tavan
            Cevirme yasagi bolgesi: o yuzeyde bu sutunlardayken yercekimi
            cevrilemez. Haritada '=' olarak o yuzeyin yuruyus satirina yazilir.
Tek yonlu = (tip, satir, ilk_sutun, son_sutun);  tip: ust | alt
            ust ('_'): ustune inilir (yercekimi asagi), alttan icinden gecilir.
            alt ('~'): altina inilir (yercekimi yukari), ustten icinden gecilir.

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
PENCERE = 3   # iki tehlike arasindaki en dar cevirme penceresi (hucre)
SUZULME = 6   # bir platformdan dusen oyuncunun tam hizda katedebilecegi yol (hucre)

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
 dict(ad="9 — Salıncak", w=40, ipucu="Kesik çizgili kutuda çevirme yasak. Kutuya girmeden karar ver.",
      bands=[("gap", 9, 16), ("ceil", 20, 25), ("spike", 32, 33)], hrk=[("plat", 11, 9, 16)],
      yasak=[("zemin", 29, 31)]),
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
 dict(ad="14 — Boşluk Üstü", w=64, ipucu="Oklu platform yalnız ok yönünden geçilir; öbür yandan gelince tutar.",
      bands=[("gap", 7, 12), ("ceil", 16, 20), ("spike", 24, 29), ("ceil", 33, 38),
             ("gap", 42, 47), ("ceil", 43, 46), ("ceil", 52, 56)],
      hrk=[], tek=[("alt", 11, 38, 49)]),
 dict(ad="15 — Tarak", w=64, ipucu="",
      bands=[("spike", 7, 11), ("ceil", 15, 19), ("spike", 23, 27), ("ceil", 31, 35),
             ("gap", 39, 44), ("ceil", 48, 52), ("spike", 56, 57)],
      hrk=[("plat", 10, 39, 44)]),
 dict(ad="16 — Kılçık", w=64, ipucu="",
      bands=[("ceil", 7, 10), ("spike", 14, 17), ("ceil", 23, 26), ("spike", 30, 33),
             ("ceil", 37, 40), ("spike", 47, 50), ("ceil", 54, 57)],
      hrk=[], yasak=[("tavan", 12, 19), ("zemin", 44, 46)]),
 dict(ad="17 — İki Asansör", w=64, ipucu="",
      bands=[("gap", 8, 15), ("ceil", 19, 24), ("gap", 28, 35), ("ceil", 39, 44),
             ("spike", 48, 53), ("ceil", 57, 57)],
      hrk=[("plat", 11, 8, 15), ("plat", 10, 28, 35)]),
 dict(ad="18 — Koridor", w=64, ipucu="",
      bands=[("spike", 8, 13), ("ceil", 17, 22), ("spike", 26, 31), ("ceil", 35, 40),
             ("gap", 49, 55)],
      hrk=[("spike", 20, 43, 48)]),
 dict(ad="19 — Fırtına", w=64, ipucu="",
      bands=[("gap", 7, 13), ("ceil", 17, 22), ("spike", 26, 31), ("ceil", 42, 47),
             ("gap", 51, 57)],
      hrk=[("plat", 11, 51, 57), ("spike", 20, 33, 39)]),
 dict(ad="20 — Son Kapı", w=64, ipucu="",
      bands=[("spike", 7, 10), ("ceil", 14, 17), ("gap", 21, 26), ("ceil", 30, 34),
             ("spike", 38, 42), ("ceil", 46, 50), ("gap", 54, 57)],
      hrk=[("plat", 11, 21, 26)], tek=[("ust", 16, 54, 58)]),
]


def yasak_listesi(d):
    return d.get("yasak", [])


def tek_listesi(d):
    return d.get("tek", [])


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
    # Tek yonlu platform araya girer: "alt" platformun ustundeki tavana zeminden
    # cevirerek ULASILAMAZ (platform tutar), "ust" platformun altindaki zemine
    # tavandan inilemez. Oraya konan kristal alinamaz.
    for tip, _r, c1, c2 in tek_listesi(d):
        hedef = tavan if tip == "alt" else zemin
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
    # Yasak bolgenin ve tek yonlu platformun dibinde dogmak adil degil: dogar
    # dogmaz karar vermek gerekir.
    for _y, c1, c2 in yasak_listesi(d):
        dar.update(range(c1 - 2, c2 + 3))
    for _t, _r, c1, c2 in tek_listesi(d):
        dar.update(range(c1 - 2, c2 + 3))
    orta = (BASLA_C + kapi) // 2

    def uygun(kume):
        return [c for c in range(BASLA_C + 4, kapi - 3)
                if c not in kume and g[H - 2][c] == "." and g[H - 1][c] == "#"]

    adaylar = uygun(dar)
    assert adaylar, (d["ad"], "kontrol noktasina yer bulunamadi")
    return min(adaylar, key=lambda c: abs(c - orta))


def en_az_cevirme(d, kapi):
    """Bolumu bitirmek icin gereken EN AZ cevirme sayisi (ikinci hedef).

    Her sutun icin zorunlu yuzeyi cikar: zemin tehlikeliyse tavanda olmak
    zorunlusun, tavan tehlikeliyse zeminde. Oyuncu zeminde baslar ve kapiya
    zeminden varir. Zorunlu yuzey dizisindeki degisim sayisi = cevirme sayisi.

    Hareketli platformlar hesaba KATILMAZ, gezen dikenler tehlike SAYILIR:
    ikisi de hedefi yukari yuvarlar, yani hedef her zaman ulasilabilir kalir
    (fazla dusuk bir hedef imkansiz olurdu).

    Yasak bolge (v0.7) zorunlu yuzeyi UZATIR: bolgenin yuzeyindeyken cevrilemez,
    o yuzden (i) bolgenin icinde karsi yuzey tehlikeliyse bolgenin yuzeyi bolge
    sonuna kadar zorunludur, (ii) bolgenin hemen ardinda kendi yuzeyi tehlikeliyse
    bolge boyunca karsi yuzey zorunludur (ikisi birden = cozumsuz, kur() durdurur).

    Tek yonlu platform (v0.7) ucuncu bir yuzeydir: ustune ancak karsi yuzeyden
    inilir, yani platformdan bir onceki sutunda o yuzey zorunludur; iki yuzey de
    tehlikeliyse platformun kendi yercekimi durumu zorunludur."""
    zorunlu = {}
    for tip, c1, c2 in d["bands"]:
        for c in range(c1, c2 + 1):
            zorunlu[c] = "tavan" if tip in ("gap", "spike") else "zemin"
    for tip, r, c1, c2 in d["hrk"]:
        if tip != "spike":
            continue
        yuzey = "zemin" if r <= 2 else "tavan"
        for c in range(c1, c2 + 1):
            zorunlu.setdefault(c, yuzey)
    _yasak_uygula(d, zorunlu)
    _tek_uygula(d, zorunlu)
    dizi = ["zemin"]
    for c in sorted(zorunlu):
        if zorunlu[c] != dizi[-1]:
            dizi.append(zorunlu[c])
    if dizi[-1] != "zemin":
        dizi.append("zemin")
    return len(dizi) - 1


def tehlikeli_sutunlar(d):
    """(zemin, tavan): o yuzeyde olumcul olan sutunlar (bant + gezen diken)."""
    zemin, tavan = set(), set()
    for tip, c1, c2 in d["bands"]:
        (tavan if tip == "ceil" else zemin).update(range(c1, c2 + 1))
    for tip, r, c1, c2 in d["hrk"]:
        if tip == "spike":
            (tavan if r <= 2 else zemin).update(range(c1, c2 + 1))
    return zemin, tavan


def karsi(yuzey):
    return "tavan" if yuzey == "zemin" else "zemin"


def _yasak_uygula(d, zorunlu):
    zemin_t, tavan_t = tehlikeli_sutunlar(d)
    for yuzey, c1, c2 in yasak_listesi(d):
        kendi = zemin_t if yuzey == "zemin" else tavan_t
        oteki = tavan_t if yuzey == "zemin" else zemin_t
        # (ii) hemen ardinda kendi yuzeyi olumcul: bolge boyunca karsi yuzey
        baglayici = any(c in kendi for c in range(c2 + 1, c2 + 1 + PENCERE))
        if baglayici:
            for c in range(c1, c2 + 1):
                zorunlu[c] = karsi(yuzey)
        # (i) icinde karsi yuzey olumcul: ilk oyle sutundan bolge sonuna kadar kendi yuzeyi
        ilk = [c for c in range(c1, c2 + 1) if c in oteki]
        if ilk:
            for c in range(ilk[0], c2 + 1):
                zorunlu[c] = yuzey


def _tek_uygula(d, zorunlu):
    zemin_t, tavan_t = tehlikeli_sutunlar(d)
    for tip, _r, c1, c2 in tek_listesi(d):
        durum = "zemin" if tip == "ust" else "tavan"     # platformdayken yercekimi durumu
        yaklasma = karsi(durum)                          # ancak karsi yuzeyden inilir
        koprulenen = [c for c in range(c1, c2 + 1)
                      if c in (zemin_t if tip == "ust" else tavan_t)]
        if koprulenen:
            zorunlu.setdefault(c1 - 1, yaklasma)
        for c in range(c1, c2 + 1):
            if c in zemin_t and c in tavan_t:
                zorunlu[c] = durum


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
    # Tek yonlu platformlar: ucuncu yuzey. Kopruledigi sutunlarda iki yuzey
    # birden tehlikeli olabilir (tek yol platformdur); baska yerde olamaz.
    tek_sutun = set()
    for tip, r, c1, c2 in tek_listesi(d):
        assert tip in ("ust", "alt") and 3 <= r <= H - 4 and 1 <= c1 < c2 <= w - 2, (d["ad"], "tek yonlu sinir disi")
        tek_sutun.update(range(c1, c2 + 1))
    cakisan = sorted((zemin_t & tavan_t) - tek_sutun)
    assert not cakisan, (d["ad"], "ayni sutunda hem zemin hem tavan tehlikeli", cakisan)
    bs = sorted(d["bands"], key=lambda b: b[1])
    # Neden 3 hucre: zeminden tavana gecis ~0,94 sn surer (300 px, ivme 900,
    # tavan hiz 430). Yon tusu BASILI tutulursa oyuncu bu sure icinde ~7 hucre
    # yol alir; tusu birakirsa hava surtunmesi (1100 * 0,75) onu 0,15 sn'de,
    # yani ~0,6 hucrede durdurur. Yani 3 hucrelik pencere "tusu birak ve dik in"
    # oynayan icin rahat, hizi koruyan icin dar — zorlugun kaynagi bu, ve
    # bolumler bu yuzden cozulebilir. Pencereyi daraltirsan ilki de imkansizlasir.
    for i in range(len(bs) - 1):
        # Ayni tek yonlu platformun kopruledigi iki bant (delik + ustundeki
        # tavan dikeni) arasinda pencere aranmaz: aralarinda gecis yok, platform var.
        if set(range(bs[i][1], bs[i][2] + 1)) <= tek_sutun and set(range(bs[i + 1][1], bs[i + 1][2] + 1)) <= tek_sutun:
            continue
        assert bs[i][2] + PENCERE <= bs[i + 1][1], (d["ad"], "cevirme penceresi cok dar", bs[i], bs[i + 1])
    if bs:
        assert bs[0][1] >= BASLA_C + PENCERE, (d["ad"], "ilk bant baslangica cok yakin")
        assert bs[-1][2] + PENCERE <= kapi, (d["ad"], "son bant kapiya cok yakin")
    # Yasak bolge kurallari. (a) Bolgenin kendi yuzeyinde olumcul engel yok:
    # icine giren oyuncu cevirme hakkini kaybediyor, olumden kacamaz.
    # (b) Baglayici bolge (ardinda kendi yuzeyi olumcul) icinde karsi yuzey
    # de olumcul olamaz: ikisi birden = cozumsuz. (c) Baglayici bolgenin onunde
    # PENCERE hucre bos olmali: cevirme karari bolgeye girmeden verilir.
    # (d) Bolgenin uzattigi zorunlu yuzeyin ardinda da PENCERE hucre bos olmali.
    zemin_h, tavan_h = tehlikeli_sutunlar(d)          # bant + gezen diken
    for yuzey, c1, c2 in yasak_listesi(d):
        assert 1 <= c1 <= c2 <= w - 2 and c1 > BASLA_C and c2 < kapi, (d["ad"], "yasak bolge sinir disi", c1, c2)
        kendi = zemin_h if yuzey == "zemin" else tavan_h
        oteki = tavan_h if yuzey == "zemin" else zemin_h
        icerde = sorted(kendi & set(range(c1, c2 + 1)))
        assert not icerde, (d["ad"], "yasak bolgenin yuzeyinde olumcul engel", icerde)
        baglayici = any(c in kendi for c in range(c2 + 1, c2 + 1 + PENCERE))
        if baglayici:
            assert not (oteki & set(range(c1, c2 + 1))), (d["ad"], "baglayici yasak bolgede karsi yuzey de olumcul")
            onu = [c for c in range(c1 - PENCERE, c1) if c in oteki]
            assert not onu, (d["ad"], "baglayici yasak bolgenin onunde pencere yok", onu)
        ilk = [c for c in range(c1, c2 + 1) if c in oteki]
        if ilk:
            ardi = [c for c in range(c2 + 1, c2 + 1 + PENCERE) if c in kendi]
            assert not ardi, (d["ad"], "yasak bolge bitince kendi yuzeyi hemen olumcul", ardi)
    # Tek yonlu platform kurallari. (e) Yaklasma yuzeyi (ust: tavan, alt: zemin)
    # platformun ilk PENCERE sutununda temiz: oyuncu orada durur, cevirir ve
    # frenliyse neredeyse dik inip platformu bulur (daha erken cevirirse
    # platformun onune iner — bu ogretilen bir hata, kural degil). (f) Cikis:
    # platform bitince dusulen taban yuzeyi SUZULME hucre temiz YA DA karsi
    # yuzey platform sonunun bir oncesinden SUZULME hucre sonrasina kadar temiz
    # (sondan cevirip inmek icin).
    for tip, r, c1, c2 in tek_listesi(d):
        taban = zemin_h if tip == "ust" else tavan_h       # platformdan dusunce varilan yuzey
        yaklasma = tavan_h if tip == "ust" else zemin_h    # platforma inmek icin bulunulan yuzey
        basi = [c for c in range(c1, c1 + PENCERE) if c in yaklasma]
        assert not basi, (d["ad"], "tek yonlu platformun basinda yaklasma yuzeyi dolu", basi)
        cikis_taban = all(c not in taban for c in range(c2 + 1, min(c2 + 1 + SUZULME, kapi + 1)))
        cikis_karsi = all(c not in yaklasma for c in range(c2 - 1, min(c2 + 1 + SUZULME, kapi + 1)))
        assert cikis_taban or cikis_karsi, (d["ad"], "tek yonlu platformdan cikis yok", c2)
    # Yasak bolge + tek yonlu platform ayni sutunda olamaz (ikisinin de kurali kendine).
    for yuzey, c1, c2 in yasak_listesi(d):
        assert not (set(range(c1, c2 + 1)) & tek_sutun), (d["ad"], "yasak bolge ve tek yonlu platform ust uste")
    # Gezen dikenin KACIS YUZEYI acik olmali. Gezen diken bulundugu yuzeyi
    # menzilinin her sutununda kapatabilir; o sutunlarda karsi yuzey de
    # tehlikeliyse iki yuzey birden olumlu olur ve bolum ancak "tam hizda
    # suzul" ile gecilir — oyunun geri kalaninin ogrettigi "dar yerde fren"
    # refleksinin tersi. 18 ve 19. bolumler tam bunu yapiyordu (tur 4).
    for tip, r, c1, c2 in d["hrk"]:
        if tip != "spike":
            continue
        karsi = tavan_t if r > 2 else zemin_t
        cakisma = sorted(karsi & set(range(c1, c2 + 1)))
        assert not cakisma, (d["ad"], "gezen dikenin kacis yuzeyi kapali", cakisma)

    for tip, r, c1, c2 in d["hrk"]:
        assert 1 <= r <= H - 2 and 1 <= c1 < c2 <= w - 2, (d["ad"], "hareketli sinir disi")
        ch = "-" if tip == "plat" else "*"
        for c in range(c1, c2 + 1):
            assert g[r][c] == ".", (d["ad"], "hareketli cakisiyor", r, c)
            g[r][c] = ch
    for tip, r, c1, c2 in tek_listesi(d):
        ch = "_" if tip == "ust" else "~"
        for c in range(c1, c2 + 1):
            assert g[r][c] == ".", (d["ad"], "tek yonlu platform cakisiyor", r, c)
            g[r][c] = ch
    for yuzey, c1, c2 in yasak_listesi(d):
        r = H - 2 if yuzey == "zemin" else 1
        for c in range(c1, c2 + 1):
            assert g[r][c] == ".", (d["ad"], "yasak bolge dolu kareye dusuyor", r, c)
            g[r][c] = "="
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
    return ["".join(r) for r in g], madalyalar(d, kapi), en_az_cevirme(d, kapi)


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
##   =  cevirme yasagi bolgesi (yuruyus satirinda: 1. satir tavan, sondan 2. zemin)
##   _  tek yonlu platform, USTUNE inilir (alttan icinden gecilir)
##   ~  tek yonlu platform, ALTINA inilir (ustten icinden gecilir)
## Ard arda gelen - / * isaretleri o parcanin gidip geldigi araligi belirler;
## ard arda = / _ / ~ isaretleri bolgenin ya da platformun genisligidir.
##
## "altin"/"gumus"/"bronz": madalya hedef sureleri (saniye).
## "cevirme": ikinci hedef — bolumu bitirmek icin gereken en az cevirme sayisi.

const BOLUMLER: Array[Dictionary] = [
'''


def main():
    out = io.StringIO()
    out.write(BASLIK)
    ozet = []
    for d in L:
        rows, (altin, gumus, bronz), cevirme = kur(d)
        assert sum(r.count("S") for r in rows) == 1, d["ad"]
        assert sum(r.count("K") for r in rows) >= 1, d["ad"]
        assert sum(r.count("C") for r in rows) == 1, d["ad"]
        assert sum(r.count("P") for r in rows) <= 1, d["ad"]
        out.write('\t{\n\t\t"ad": "%s",\n\t\t"ipucu": "%s",\n' % (d["ad"], d["ipucu"]))
        out.write('\t\t"altin": %.1f,\n\t\t"gumus": %.1f,\n\t\t"bronz": %.1f,\n'
                  % (altin, gumus, bronz))
        out.write('\t\t"cevirme": %d,\n' % cevirme)
        out.write('\t\t"harita": [\n')
        for r in rows:
            out.write('\t\t\t"%s",\n' % r)
        out.write("\t\t],\n\t},\n")
        kr = [(i, s.index("C")) for i, s in enumerate(rows) if "C" in s][0]
        kn = [s.index("P") for s in rows if "P" in s]
        ozet.append("  %-20s kristal=%s@%-2d kontrol=%-3s madalya=%.1f / %.1f / %.1f  cevirme>=%d"
                    % (d["ad"], "tavan" if kr[0] < 3 else "zemin", kr[1],
                       kn[0] if kn else "-", altin, gumus, bronz, cevirme))
    out.write("]\n")
    yol = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                       "scripts", "bolumler.gd")
    with open(yol, "w", encoding="utf-8", newline="\n") as f:
        f.write(out.getvalue())
    print("%d bolum yazildi -> %s" % (len(L), yol))
    print("\n".join(ozet))


if __name__ == "__main__":
    main()
