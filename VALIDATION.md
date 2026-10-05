# Doğrulama kapsamı

## GNU Octave

GNU Octave 11.3 ile altı veri seti, tüm 12 model (72 kombinasyon) kısa ve normal
ders ayarlarında çalıştırıldı. Sabit veri bölünmeleri, sonlu metrikler ve eğitimden
öğrenilen ölçekleme kontrol edildi. Sonar menü seçimi, tek model ve grafik sayısı
doğrulandı. Yeni veri önizlemeleri PNG/FIG olarak yazılıp FIG dosyaları yeniden açıldı.
MATLAB uyumlu temel işlemler kullanılır; bu sürüm MATLAB'da ayrıca çalıştırılmadı.

## Python

Windows, Python 3.14.3, NumPy 2.5.3, Matplotlib 3.11.2 ile test edildi.
`requirements.txt` desteklenen bağımlılık aralıklarını belirtir; diğer sürüm/platform
kombinasyonlarının tamamı test edilmedi.

- Analitik MLP/FNN gradyanları, skaler ve çok sınıflı çıktılar.
- Ridge normal denklemi, kural ağırlıklarının sayısal kararlılığı.
- GA/PSO sınırları, tam değerlendirme bütçesi ve aynı seed ile tekrar üretim.
- Test satırı değiştirildiğinde eğitim verisinin/ölçeklemenin etkilenmemesi.
- Altı veri seti × 12 model kısa çalışması ve sonlu metrikler.
- Kaydetmeden çalışmada sonuç klasörünün oluşmaması.
- Menüden yalnızca seçilen veri setinin ve seçilen modellerin çalışması.
- Altı veri önizlemesi, bireysel/ortak grafikler, PNG/SVG kaydı, NPZ+JSON'dan yeniden çizim.
- Altı ortak veri setinde deterministik Ridge metrikleri Octave ile tolerans içinde eşleşti.

Grafik otomasyon testleri Agg altyapısında çalışır. Pencerelerin kalıcı olması,
figür nesnelerinin sayısı ve `show` çağrıları sınanır; masaüstü araç çubuğunun bütün
fare etkileşimleri bu test kapsamında değildir.
Windows üzerinde TkAgg ile gerçek Sonar önizleme penceresinin açılıp kapanması
ayrıca doğrulandı.

## Tekrar çalıştırma

```text
python -m unittest discover -s python -p "test_*.py" -v
python tools/check_python_release.py
```

```matlab
setup_course();
test_course();
test_six_datasets();
```

`check_python_release.py` dosyaları `work/python_release_check/` altında üretir.
Önceki Octave `work/six_data_classroom/stage_0/metrics.csv` dosyası varsa aynı
bölünmelerde Ridge metriklerini iki dil arasında karşılaştırır; temiz pakette bu
yerel dosya bulunmadığında grafik kontrollerini gerçekleştirir.

Bu doğrulama bir araştırma başarım iddiası değildir; test sonucuna göre veri veya
bölünme seçilmedi. Stokastik modellerin iki dilde aynı skoru vermesi beklenmez.
