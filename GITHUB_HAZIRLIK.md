# GitHub'a yükleme

`dist/hybrid-intelligent-systems_....zip` temiz teslim paketidir. ZIP'i boş bir
klasöre açın ve **içindeki dosyaları** yeni GitHub deponuza yükleyin; ZIP'i tek dosya
olarak yüklemek yerine kaynak dosyaları depoya koyun. ZIP ayrıca release eki olabilir.

Paket kaynak kod, altı CSV veri, altı sabit bölünme, testler, kılavuzlar ve veri
atıflarını içerir. Sanal ortam, sonuç klasörleri, kişisel ayarlar, önbellekler,
ham indirme ZIP'leri ve yerel deney çıktıları dahil edilmez.

1. Depo için bir ad seçin; örnek: `Hybrid-Intelligent-Systems-Course`.
2. ZIP'i çıkarıp README ve ana kullanım kılavuzunu inceleyin.
3. [Lisans notundaki](LICENSING.md) kod lisansı kararını verin. Veri atıflarını koruyun.
4. GitHub web arayüzü veya Git ile kaynakları yükleyin. Hesap/depo adresi pakette sabitlenmedi.
5. Temiz bir kopyada kılavuzdaki kısa test komutlarını çalıştırın.

Git kullanıyorsanız çıkarılan klasörde:

```text
git init
git add .
git commit -m "Add hybrid intelligent systems teaching examples"
git branch -M main
git remote add origin https://github.com/KULLANICI/DEPO.git
git push -u origin main
```

Adresi kendi yeni deponuzla değiştirin. Mevcut bir depoya yüklüyorsanız bu ilk kurulum
adımlarını körlemesine tekrar etmeyin; mevcut geçmişle birleştirin.

Sonraki güncellemelerde temiz paketi yeniden üretmek için proje kökünden:

```text
python tools/build_release.py
```

Betik yalnızca açık dosya türü/klasör listesine göre paketler ve her dosyanın SHA256
özetini `MANIFEST.sha256.json` içine koyar. `dist/` Git tarafından dışlanır.
Kod GitHub'a otomatik gönderilmez.
