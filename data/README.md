# Veri kaynakları ve atıf

Octave/MATLAB için eklenen Airfoil, Yacht, Seeds ve Sonar kaynakları,
lisansları ve dönüşümleri [EXTRA_DATASETS.md](EXTRA_DATASETS.md) dosyasındadır.
Bu dört veriyle her iki dilde 3 regresyon + 3 sınıflandırma vardır.

Veriler 21 Eylül 2026 tarihinde aşağıdaki UCI kaynaklarından indirildi.
Çalışma sırasında internet veya Kaggle hesabı gerekmez. Kaggle bağlantıları keşif
içindir; paket dosyaları UCI sürümleridir. Yeniden dağıtımda bu atıf dosyasını koruyun.

## Energy Efficiency

- Kaynak: https://archive.ics.uci.edu/dataset/242/energy+efficiency
- DOI: https://doi.org/10.24432/C51307
- Yazarlar: A. Tsanas ve A. Xifara, 2012.
- Lisans: UCI üzerinde CC BY 4.0 — https://creativecommons.org/licenses/by/4.0/
- Kaggle: https://www.kaggle.com/datasets/elikplim/eergy-efficiency-dataset
- Makale: Tsanas, A. ve Xifara, A. (2012), Accurate quantitative estimation of
  energy performance of residential buildings using statistical machine learning tools,
  Energy and Buildings, 49, 560–567.
- İndirme: https://archive.ics.uci.edu/static/public/242/energy%2Befficiency.zip
- Kaynak ZIP SHA256: `499441eee27929a4b00417f58fd8c63c9cc14b8a71520cd0dd27fcb626738351`

`ENB2012_data.xlsx` dosyasının ilk 10 sütunundaki 768 dolu sayısal satır, sıra
değiştirilmeden `energy.csv` biçimine dönüştürüldü. Tamamen boş sondaki satırlar
alınmadı; değerler üzerinde başka değişiklik yapılmadı.

Sütunlar X1 göreli kompaktlık, X2 yüzey alanı, X3 duvar alanı, X4 çatı alanı,
X5 toplam yükseklik, X6 yönelim, X7 cam alanı, X8 cam dağılımı,
Y1 ısıtma yükü, Y2 soğutma yüküdür. Veriler bina enerji simülasyonlarından gelir.
Paket Y1'i hedefler; Y2 girdi değildir.

## Wine Recognition

- Kaynak: https://archive.ics.uci.edu/dataset/109/wine
- DOI: https://doi.org/10.24432/C5PC7J
- Atıf: Aeberhard, S. ve Forina, M. (1992). Wine [Dataset]. UCI Machine Learning Repository.
- Lisans: UCI üzerinde CC BY 4.0.
- Kaggle: https://www.kaggle.com/datasets/tawfikelmetwally/wine-dataset
- İndirme: https://archive.ics.uci.edu/static/public/109/wine.zip
- Kaynak ZIP SHA256: `2bae62c4481220623579d4c4fb36b55652b6b75e06e49fa1981b8198362dfdab`

`wine.data` içindeki 178 satır korunarak yalnızca bir CSV başlık satırı eklendi.
İlk sütun sınıf (1, 2, 3), sonraki 13 sütun kimyasal ölçümlerdir.
Bu veri Wine Quality veri setiyle karıştırılmamalıdır.

## Ortak bölünme

`*_split42.csv`: veriyle aynı satır sırası, 0=eğitim, 1=doğrulama, 2=test.
NumPy `default_rng(42)` ile yaklaşık %60/%20/%20 bölünme bir kez üretildi.
Wine'da her sınıf ayrı karıştırılıp bölündü. Bölünme dosyaları iki dile ortak girdi olur.
`sha256.json`, iki veri dosyasının ve iki bölünme dosyasının SHA256 özetlerini içerir.
