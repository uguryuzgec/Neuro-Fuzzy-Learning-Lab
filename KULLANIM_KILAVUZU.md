# Hibrit Zeki Sistemler — kullanım kılavuzu

Bu proje aynı altı veri seti üzerinde NN → FNN → FNN-GA/PSO eğitim akışını
GNU Octave/MATLAB ve Python ile gösterir. Eğitim için ücretli araç kutusu gerekmez.
CSV verileri paketin içindedir; çalıştırırken internet gerekmez.

## İlk çalıştırma

ZIP'i bir klasöre açın. `README.md`, `course_config.m`, `src/`, `python/` ve `data/`
aynı proje kökünde kalmalıdır. Dosyaları tek tek başka yerlere taşımayın.

**Octave/MATLAB:** Current Folder'ı proje kökü yapın, Command Window'a yazın:

```matlab
results = run_interactive();
```

**Python:** Terminali proje kökünde açın. Windows PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r python/requirements.txt
.\.venv\Scripts\python.exe python/run_interactive.py
```

macOS/Linux:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r python/requirements.txt
.venv/bin/python python/run_interactive.py
```

Python 3.10+ ve NumPy/Matplotlib gerekir. Masaüstü grafik pencereleri için Python'ın
Tk veya Qt grafik altyapısı bulunmalıdır. Linux'ta dağıtımın `python3-tk` paketi
gerekebilir. Sunucuda grafik göstermeden kullanım aşağıda anlatılmıştır.

## Her iki dilde seçim sırası

1. Kayıt: `1` evet, `2` hayır.
2. Problem: `1` regresyon, `2` sınıflandırma.
3. İlgili üç veri setinden biri.
4. Seçilen verinin eğitim bölümüne ait tanıtım grafikleri açılır.
5. Modeller: `1` tek model, `2` birkaç model, `3` tüm modeller.
6. Tekli/çoklu seçimde ekrandaki numaraları girin; örneğin `4 5 6` = MLP, ELM, RVFL.

`0` seçimden vazgeçer. Sorular grafik pencerelerinde değil terminal/Command Window'dadır.
Python'da önizlemeye bakarken pencereyi öne alın; terminal girdi beklerken bazı grafik
arka uçlarında araç çubuğu tepkisi gecikebilir. Sonuçta `show()` grafik olay döngüsünü
çalıştırır; program tüm figürler kapatılana kadar bekler.

| Problem | 1 | 2 | 3 |
|---|---|---|---|
| Regresyon | Energy (768 × 8) | Airfoil (1503 × 5) | Yacht (308 × 6) |
| Sınıflandırma | Wine (178 × 13) | Seeds (210 × 7) | Sonar (208 × 60) |

Tek modelde yalnızca o modelin sonuç grafikleri gösterilir. Birden fazla modelde
ek ortak grafik oluşturulur: regresyonda gerçek hedefe göre aynı sıraya konmuş
tahminler, sınıflandırmada model/sınıf bazında F1 çubukları. Sayısal metrikler yalnızca
terminalde tablo olarak gösterilir; ayrı tablo figürü yoktur.

## Modeller

| Model | Öğrenilen bölüm |
|---|---|
| Mean | Hedef ortalaması / sınıf oranları |
| Ridge | Düzenlileştirilmiş doğrusal katsayılar |
| kNN | 5 komşunun ortalama çıktısı; parametrik eğitim yok |
| MLP | Tek tanh gizli katman ve çıktı ağırlıkları; Adam |
| ELM | Sabit rastgele gizli katman; ridge çıktı çözümü |
| RVFL | ELM + doğrudan girdi-çıktı bağlantısı |
| Fixed-TSK1 | Sabit Gauss üyelikleri; doğrusal kural sonuçları ridge ile |
| Adaptive-TSK0 | Sabit kural sonuçları ridge; üyelik merkez/genişlikleri Adam ile |
| ANFIS | Doğrusal kural sonuçları ridge; üyelik merkez/genişlikleri Adam ile |
| Fuzzy-RVFL | Girdi + kural ateşlemeleri + rastgele özellikler; ridge çıktı |
| FNN-GA / FNN-PSO | ANFIS üyeliklerini GA/PSO arar; her adayda ridge sonuç çözümü |

ANFIS seyrek kural tabanlı öğretim uygulamasıdır, MATLAB `anfis` kopyası değildir.
Fuzzy-RVFL belirli bir makalenin birebir uygulaması olarak sunulmaz.
Sınıflandırma one-hot hedeflere en küçük kareler tabanlı skor üretir; softmax değildir.
Sezgisel fitness'ı doğrulama RMSE'sidir; test verisi optimizasyona girmez.

## Kayıtlar

| Ortam | Oturum klasörü | Grafik | Sayısal/model |
|---|---|---|---|
| Octave/MATLAB | `results/session_.../` | PNG + FIG | MAT + CSV |
| Python | `results_python/session_.../` | PNG + SVG | NPZ + JSON + CSV |

`data_preview/` veri grafikleri; `stage_0/` tüm ailelerin birleşik listesi;
`stage_1/2/3/` ders girişlerinin sonuçlarıdır. `metrics.csv` tüm metrikleri içerir.
JSON/CSV'deki accuracy ve balanced_accuracy 0–1; ekrandaki tablo yüzdedir.
Uygulanmayan ölçütler CSV'de NaN, Python JSON'da null olarak saklanır.

Kayıt kapalıysa deney sonucu dosyaları/klasörleri yazılmaz; grafikler bellekte kalır.
Matplotlib kendi font önbelleğini işletim sisteminin kullanıcı önbelleğinde oluşturabilir.
Kayıt açık oturumlar farklı isim alır. Menüsüz aynı çıktı klasörüne tekrar yazmak önceki
aynı adlı sonuçların üzerine yazar.

Octave FIG, MATLAB FIG ile her sürümde birebir uyumlu olmayabilir. Python'da yerel
FIG desteği yoktur; SVG vektör düzenleme içindir. Etkileşimli model grafiğini yeniden kurmak:

```powershell
.\.venv\Scripts\python.exe python/replot.py "results_python/session_.../stage_0/sonar_ELM_seed11.npz"
```

NPZ'nin yanında aynı adlı JSON dosyası kalmalıdır. Bu komut modeli yeniden eğitmez;
kaydedilmiş test tahminlerini ve eğitim geçmişini çizer.

## Deneylerin yorumu

Altı veri seti iki dilde aynı kayıtlı eğitim/doğrulama/test satırlarını kullanır.
Ölçekleme yalnızca eğitimden öğrenilir. Stokastik modellerde iki dilin RNG farkları
nedeniyle aynı seed aynı ağırlığı veya başarıyı garanti etmez.

`smoke` işlev testi, `classroom` ders örneği, `repeated` aynı bölünmede 10 model seed'idir.
`repeated` çapraz doğrulama değildir. Varsayılan 24 gizli nöron, 6 kural, 150 epoch,
16 birey/parçacık ve 320 fitness çağrısı kullanılır. Ayarlar yayın için optimize edilmedi.
Veriler arasında hedef ölçekleri farklı olduğundan ham RMSE'leri doğrudan kıyaslamayın.

## Yeni veri / model eklemek

CSV tek başlıklı, sayısal, eksiksiz ve en az 30 gözlemli olmalıdır. Metin etiketlerini
sayısal kodlayın; kategorik girdileri ayrıca belirtin. Hedef ve kimlik girdi olmamalıdır.

Octave: `course_config.m` içindeki `cfg.examples` listesine aynı alanlarla yeni kayıt
ekleyin. Sütunlar 1 tabanlıdır. Yeni veri için `split_file=''` otomatik bölünme üretir.
Python: `python/course_core.py` içindeki `examples()` listesine şu tür bir kayıt ekleyin:

```python
dict(name='yeni_veri', task='regression', path=ROOT/'data/yeni_veri.csv',
     features=list(range(6)), target=6, categorical=[], split_file=None)
```

Python sütunları 0 tabanlıdır. Sınıflandırma için `task='classification'` kullanın.
İki dilde aynı deney için bölünmeyi bir kez CSV'ye kaydedip iki yapılandırmada aynı
dosyayı belirtin. Eski veri setinin bölünmesini yeni veriyle kullanmayın.
Zaman/grup yapılı veride uygun bölünmeyi ayrıca tasarlayın.

Yeni model için eğitim ve tahmin fonksiyonunu yazın; Octave'da `stage_models.m`,
`run_stage.m`, `predict_model.m`; Python'da `STAGES`, `run_stage()` ve `predict()`
bağlantılarını ekleyin. Regresyon çıktısı standartlaştırılmış N×1, sınıflandırma çıktısı
sınıf sırasına göre N×K skor olmalıdır. Test verisini eğitim fonksiyonuna vermeyin.

Yeni sezgisel için Octave `optimizer_xx_template.m`, Python `optimizers.py` şablonunu
uygulayın. `objective, lower, upper, initial, opts` alır; `best_position`, `best_cost`,
`history`, `evals` döndürür. Başlangıç dahil tam değerlendirme bütçesine uyun.
`run_student` ve `student_example.py` basit algoritma deneme girişleridir; tam menü
için yeni `FNN-XX` modelini yukarıdaki model listesine/eğitim yönlendirmesine bağlayın.

## Diğer belgeler

- [Python ayrıntıları ve testler](PYTHON_KULLANIM_KILAVUZU.md)
- [Octave ayrıntıları](OCTAVE_KULLANIM_KILAVUZU.md)
- [Ders akışı](DERS_AKISI.md) ve [ödev taslağı](ODEV_YONERGESI.md)
- [Veri atıfları](data/README.md), [ek veri atıfları](data/EXTRA_DATASETS.md)
- [GitHub'a yükleme](GITHUB_HAZIRLIK.md) ve [lisans durumu](LICENSING.md)
