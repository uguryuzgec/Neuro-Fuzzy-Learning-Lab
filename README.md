# Hibrid Zeki Sistemler — üç aşamalı ders kodu

**Başlangıç:** [Ortak kullanım kılavuzu](KULLANIM_KILAVUZU.md) ·
[Python kılavuzu](PYTHON_KULLANIM_KILAVUZU.md) ·
[GitHub'a yükleme](GITHUB_HAZIRLIK.md)

**Yeni Octave seçim ekranı:** `results = run_interactive();`
Adım adım kullanım: [Octave kullanım kılavuzu](OCTAVE_KULLANIM_KILAVUZU.md).
Veri tanıtımı, problem/model seçimi, açık kalan grafikler ve isteğe bağlı PNG + FIG kaydı içerir.

Bu paket, NN → FNN → FNN–GA/PSO sırasını regresyon ve sınıflandırmada gösterir.
Her iki ortamda aynı 3 regresyon + 3 sınıflandırma veri seti ve sabit bölünmeler vardır.
MATLAB/GNU Octave için `.m`, Python için `.py` dosyaları içerir.
Fuzzy Logic, Neural Network, Statistics veya Optimization Toolbox kullanılmaz.
Python modelleri NumPy ile açık olarak yazılmıştır; grafikler Matplotlib kullanır.

| Ders | Octave / MATLAB başlangıcı | Python başlangıcı | İçerik |
|---|---|---|---|
| 1 — NN | `nn.m` | `python/01_nn.py` | MLP, düzenlileştirilmiş ELM, RVFL; Mean, Ridge, kNN |
| 2 — FNN | `fnn.m` | `python/02_fnn.py` | Sabit TSK-1, adaptif TSK-0, ANFIS tarzı TSK-1, Fuzzy-RVFL öğretim varyantı |
| 3 — FNN–XX | `fnngapso.m` | `python/03_fnn_ga_pso.py` | Aynı TSK-1: gradyan hibrit eğitimi, GA ve PSO |

## Başlangıç

### GNU Octave veya MATLAB

Command Window içinde:

```matlab
% Current Folder: bu README'nin bulundugu proje klasoru
results = run_interactive(); % Veri tanıtımı, problem ve model seçimi
```

Üç dersi birlikte veya kısa denemeyi çalıştırmak için:

```matlab
run_all('classroom');  % Sabit ders ayarları
run_all('smoke');      % Az epoch / az değerlendirme, doğruluk karşılaştırması için değil
setup_course(); test_course();
```

Grafik altyapısı olmayan bir ortamda:

```matlab
setup_course();
cfg = course_config('classroom');
cfg.plots = false;
run_stage(1,cfg);
```

Kod, temel Octave/MATLAB işlemleriyle yazılmıştır. Yeni etkileşimli akış GNU Octave
11.3 üzerinde doğrulandı: iki problemde 24 model çalışması, PNG/FIG üretimi,
FIG yeniden açma ve kayıt kapalı çalışma. Otomatik grafik testleri gnuplot kullanır.
Python menüsü aynı akışı kullanır; MATLAB üzerinde yeni akış ayrıca doğrulanmadı.

### Python

Python 3.10 veya üzeri bir ortamda, terminalden:

```text
python -m venv .venv
.venv\Scripts\python -m pip install -r python/requirements.txt
.venv\Scripts\python python/run_interactive.py
```

Tek komut, kısa doğrulama ve test:

```text
.venv\Scripts\python python/run_course.py --stage 0 --profile classroom --no-plots
.venv\Scripts\python python/run_course.py --stage 0 --profile smoke --no-plots --no-save
.venv\Scripts\python -m unittest discover -s python -p "test_*.py" -v
```

`--no-plots` yalnızca sayısal çıktıları üretir.

## Altı ortak veri seti

| Örnek | Veri | Görev | Eğitim / doğrulama / test |
|---|---|---|---|
| `energy_heating` | Energy Efficiency, 768 satır, 8 ham girdi | Isıtma yükü tahmini | 460 / 153 / 155 |
| `wine` | Wine Recognition, 178 satır, 13 girdi | Üç üzüm çeşidinin sınıflandırılması | 105 / 34 / 39 |
| `airfoil` | Airfoil Self-Noise, 1503 satır, 5 girdi | Ses basıncı regresyonu | 901 / 300 / 302 |
| `yacht` | Yacht Hydrodynamics, 308 satır, 6 girdi | Direnç regresyonu | 184 / 61 / 63 |
| `seeds` | Seeds, 210 satır, 7 girdi | Üç buğday çeşidi | 126 / 42 / 42 |
| `sonar` | Sonar, 208 satır, 60 girdi | Kaya / metal silindir | 124 / 41 / 43 |

Ek verilerin dönüşümleri, lisansları ve kaynakları [data/EXTRA_DATASETS.md](data/EXTRA_DATASETS.md)
içindedir. Problem seçildikten sonra ilgili üç veriden biri seçilir.

Her iki veri Kaggle'da da bulunur. Paketteki dosyalar kaynak takibi için doğrudan
UCI'den alınmıştır; Kaggle hesabı, API anahtarı veya çalışma sırasında internet gerekmez.
Kaynaklar, lisanslar ve dosya doğrulama bilgileri `data/README.md` içindedir.

Enerjide yönelim ve cam dağılımı kategoriktir; yalnızca eğitimde görülen kategorilerden
one-hot kodlama yapılır. Böylece 8 ham girdi 16 sayısal girdiye dönüşür.
Diğer hedef olan soğutma yükü **girdi olarak kullanılmaz**. İstenirse ayrı bir
regresyon örneği için hedef sütunu MATLAB'da 10, Python'da 9 seçilebilir.

Wine örneği Wine Quality değildir; hedef üç çeşitten biridir. Etiketler one-hot
çıktılara çevrilir; her sınıf için bir çıktı skoru öğrenilir ve `argmax` sınıfı belirler.
Bu, **en küçük kareler tabanlı sınıflandırmadır**; softmax/cross-entropy eğitimi değildir.
Skorlar kalibre edilmiş olasılıklar olarak yorumlanmamalıdır.

## Derslerde öğrencinin göreceği fark

**MLP:** `tanh` gizli katmanın ağırlıkları ve çıktı ağırlıkları geri yayılım ve Adam ile öğrenilir.

**ELM:** Rastgele gizli ağırlıklar sabittir; çıktı ağırlıkları ridge en küçük karelerle bulunur.
Bu paket düzenlileştirilmiş bir ELM öğretim uygulamasıdır.

**RVFL:** ELM benzeri rastgele katmana ek olarak girdiden çıktıya doğrudan bağlantı vardır.
ELM ve RVFL her dil içinde aynı seed ile aynı rastgele gizli katmandan başlatılır.

**TSK / ANFIS:** Her kuralın her girdide Gauss üyeliği vardır. Çarpım t-normu ile
kural ateşleme gücü hesaplanır ve normalize edilir. Sıfırıncı derecede kural sonucu
sabittir; birinci derecede girdilerin doğrusal fonksiyonudur.

```text
mu_rj(x_j) = exp(-0.5 * ((x_j - c_rj) / sigma_rj)^2)
w_r       = product_j mu_rj(x_j)
alpha_r   = w_r / sum_s w_s
f_r(x)    = b_r                         [TSK-0]
f_r(x)    = b_r + sum_j a_rj * x_j       [TSK-1]
y_hat     = sum_r alpha_r * f_r(x)
```

Ürün ve normalizasyon log uzayında hesaplanır; çok küçük ateşleme güçlerinde sayısal
sıfıra düşme önlenir. Kural merkezleri araç kutusuz Lloyd kümeleme ile eğitim
girdilerinden başlatılır. Her kurala ait üyelikler bağımsızdır; tüm üyelik kombinasyonlarını
üreten bir ızgara kurulmaz. Kod **seyrek kural tabanlı ANFIS tarzı TSK ağıdır**;
MATLAB `anfis` fonksiyonunun birebir yeniden üretimi değildir.

`Fixed-TSK1`, başlangıç üyeliklerini sabit tutar. `Adaptive-TSK0` ve `ANFIS`,
çıktı katsayılarını ridge çözümüyle, öncül merkez/genişliklerini gradyan ve Adam ile
öğrenir; doğrulama hatasının en iyi olduğu epoch saklanır.

**Fuzzy-RVFL:** `[1, X, normalize kural ağırlıkları, rastgele tanh özellikleri]`
birleştirilir; çıktı ridge ile öğrenilir. Üyelikler sabittir. Bu açıkça adlandırılmış
bir **öğretim varyantıdır**, belirli bir Fuzzy-RVFL makalesinin birebir uygulaması
veya yeni araştırma katkısı olduğu iddia edilmez.

**FNN–GA/PSO:** Mimari ANFIS ile aynıdır. Arama vektörü yalnızca Gauss merkezlerini
ve `log(sigma)` değerlerini taşır. Her adayda çıktı katsayıları yalnızca eğitim
verisinden çözülür. Fitness, doğrulama RMSE'sidir; sınıflandırmada one-hot skor RMSE'sidir.
Test verisi fitness fonksiyonunun arayüzünde bulunmaz.

Enerji örneğinde 6 × 16 × 2 = **192**, Wine'da 6 × 13 × 2 = **156** öncül
parametresi aranır. Çıktı katsayıları bu vektöre eklenmez.

## Deneylerin ortak düzeni

- Aynı CSV bölünme dosyaları üç aşamada ve iki dilde kullanılır. Wine bölünmesi sınıf oranlarını gözetir.
- Ölçekleme ve kategorilerin öğrenilmesi yalnızca eğitim bölümünde yapılır.
- Regresyon ölçütleri orijinal hedef ölçeğinde RMSE, MAE ve R²'dir.
- Sınıflandırma ölçütleri accuracy, macro-F1, balanced accuracy ve karışıklık matrisidir.
- GA/PSO aynı popülasyon büyüklüğü ve **başlatma dahil 320 fitness çağrısı** kullanır.
- GA/PSO her dil içinde aynı ilk popülasyondan başlar; başlangıç FNN'si ilk adaydır.
- Merkezler eğitim aralığı ±0,5, standartlaştırılmış girdilerde sigma 0,15–3 ile sınırlanır.
- `repeated` profili aynı bölünmede 10 farklı model/optimizasyon seed'i çalıştırır. Bu çapraz doğrulama değildir.
- Python ve MATLAB RNG'leri farklıdır; aynı seed aynı rastgele ağırlıkları garanti etmez.
  İki dilin stokastik modellerinden birebir aynı skor beklenmez. Deterministik Ridge çıktıları ayrıca karşılaştırıldı.

## Çıktılar

MATLAB: `results/classroom/stage_1`, `stage_2`, `stage_3`.
Python menüsüz: `results_python/classroom/stage_0` (veya `stage_1/2/3`).
Python menülü: `results_python/session_TARIH_SAAT/`; PNG + SVG ve NPZ + JSON + CSV.

Octave etkileşimli girişinde kayıt seçilirse her çalıştırma için ayrı
`results/session_TARIH_SAAT/` klasörü oluşturulur. Veri tanıtımları `data_preview/`,
model ve ortak tahmin/F1 grafikleri ilgili `stage_0/1/2/3/` klasöründedir.
Sayısal tablo yalnızca Command Window'da gösterilir. Veri tanıtımı problem seçildikten
sonra yalnızca seçilen veri için açılır; tek modelde ortak karşılaştırma grafiği üretilmez.
Şekiller hem PNG hem Octave FIG olarak saklanır; kayıt seçilmezse dosya yazılmaz.

Her aşamada `metrics.csv` bulunur. MATLAB `.mat` dosyaları model, ölçekleyici,
veri bölünmesi, tahminler ve geçmişi saklar. Python `.npz` dosyaları tahmin ve
geçmişleri, `.json` dosyaları model katsayıları ve ön işlemi saklar. Kaydedilen Python
indeksleri sıfır, MATLAB indeksleri bir tabanlıdır.

Sınıflandırma satırlarında regresyon ölçütlerinin, regresyon satırlarında sınıflandırma
ölçütlerinin `NaN` olması beklenir. Aynı ayarlarla yeniden çalıştırmak ilgili sonuç
dosyalarını günceller; farklı deneyleri ayrı profile/klasör adıyla saklayın.

Önceki Octave ders ölçümleri `data/SIX_DATASETS_VALIDATION.md` içindedir.
Güncel test kapsamı `VALIDATION.md` dosyasındadır. Yerel deney sonuçları teslim paketine
dahil edilmez; komutlarla yeniden üretilebilir.

## Öğrencinin yeni veri ve sezgisel eklemesi

MATLAB'da `course_config.m` içindeki `cfg.examples` listesini; Python'da
`course_core.examples()` listesini yeni CSV, girdi ve hedef sütunlarıyla değiştirin.
Yeni veri için eski split dosyasını kullanmayın: MATLAB `split_file=''`,
Python `split_file=None` seçimi yeni, sınıflandırmada tabakalı bir bölünme oluşturur.
İki dil arasında karşılaştırılacaksa bu bölünmeyi bir kez CSV'ye kaydedip paylaşın.

CSV'nin tek başlık satırı, sayısal sütunları ve eksiksiz değerleri olmalıdır.
Metin kategorileri, eksik veriler, zaman serileri ve grup verileri için uygun ön işlem
ayrı tasarlanmalıdır; basit rastgele bölünme her veri seti için doğru değildir.

```matlab
setup_course();
cfg=course_config('classroom');
cfg.examples=cfg.examples(1);
cfg.examples(1).name='yeni_veri';
cfg.examples(1).csv_path=fullfile(pwd,'data','yeni_veri.csv');
cfg.examples(1).feature_columns=1:6;
cfg.examples(1).target_column=7;
cfg.examples(1).categorical_columns=[];
cfg.examples(1).split_file='';
run_student(@optimizer_xx_template,cfg);  % Önce bu şablonu uygulayın.
```

Python tarafında `student_example.py`, çalışan PSO bağlantısını gösterir.
`optimizers.py` içindeki `optimizer_xx_template` sözleşmesini uygulayıp
`run_student(optimizer_xx, cfg, datasets)` çağırın. Python sütunları sıfır tabanlıdır.
Her sezgisel aynı `objective, lower, upper, initial, opts` arayüzünü kullanır.

Ödev kapsamı ve makale beklentisi `ODEV_YONERGESI.md`, ders anlatım akışı
`DERS_AKISI.md` içindedir.
