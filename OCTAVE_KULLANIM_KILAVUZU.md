# GNU Octave kullanım kılavuzu

Octave uygulamasını açın. Current Folder'ı proje köküne ayarlayın.
**Command Window** bölümüne şunları yazın:

```matlab
% Current Folder: README.md dosyasinin bulundugu klasor
results = run_interactive();
```

Ek araç kutusu veya internet gerekmez. Seçimleri grafik pencerelerine değil, Command Window'a yazıp Enter'a basın. Grafik pencereleri işlem sonunda açık kalır.

## Ekrandaki sıra

Octave/MATLAB tarafında artık **3 regresyon + 3 sınıflandırma** veri seti vardır.
Problem seçiminden sonra aşağıdaki gruptan veri seti seçilir:

| Problem | Menü sırası | Veri seti | Örnek / girdi |
|---|---:|---|---:|
| Regresyon | 1 | energy_heating — bina ısıtma yükü | 768 / 8 |
| Regresyon | 2 | airfoil — kanat profili ses basıncı | 1503 / 5 |
| Regresyon | 3 | yacht — yat hidrodinamik direnci | 308 / 6 |
| Sınıflandırma | 1 | wine — üç şarap/üzüm çeşidi | 178 / 13 |
| Sınıflandırma | 2 | seeds — üç buğday çeşidi | 210 / 7 |
| Sınıflandırma | 3 | sonar — kaya/metal silindir | 208 / 60 |

Ek verilerin resmi kaynakları ve atıfları `data/EXTRA_DATASETS.md` içindedir.
Sonar'da 0=kaya, 1=metal silindir. Yeni veriler tüm 12 modele açıktır.

1. **Kayıt:** `1` PNG + FIG + MAT + CSV kaydeder; `2` dosya kaydetmeden gösterir. Kayıt tercihi veri tanıtım grafiklerini de kapsar.
2. **Problem:** `1` regresyon, `2` sınıflandırma. Seçilen problem için birden fazla veri tanımlanmışsa ayrıca veri seti sorulur.
3. **Veri tanıtımı:** Yalnızca seçilen veri seti gösterilir. Grafikler eğitim bölümünden çizilir; açıklamalar Command Window'a yazılır.
4. **Modeller:** `1` tek model, `2` seçilen birkaç model, `3` listedeki tüm modeller. Birkaç model için örneğin `4 5 6` veya `4,5,6` yazın. Numaralar ekrandaki listeye aittir. `0` iptal eder.
5. **Sonuçlar:** Her modelin grafikleri açılır. Sayısal metrik tablosu yalnızca Command Window'a yazılır ve `results` değişkeninde kalır. Birden fazla model seçildiğinde ek bir ortak grafik açılır: regresyonda aynı sıradaki gerçek değer ve tüm tahminler; sınıflandırmada model ve sınıf bazında gruplanmış F1 çubukları. Sınıf numaralarını sürekli değerler gibi çizgiyle birleştirmek yerine her sınıfın başarısı karşılaştırılır.

Örnek: kayıt sorusuna `2`, problem sorusuna `1`, veri setine `1`, model çalışma biçimine `2`, model numaralarına `4 5 6` girerseniz enerji verisinde MLP, ELM ve RVFL çalışır; dosya yazılmaz.

## Dersleri ayrı açmak

```matlab
nn          % Mean, Ridge, kNN, MLP, ELM, RVFL
fnn         % Fixed-TSK1, Adaptive-TSK0, ANFIS, Fuzzy-RVFL
fnngapso    % ANFIS, FNN-GA, FNN-PSO
```

Bu üç giriş de aynı seçim akışını kullanır. `run_interactive()` bütün aileleri tek listede sunar; ANFIS tekrarlanmaz. Regresyonda RMSE/MAE küçüldükçe, R² büyüdükçe; sınıflandırmada accuracy, macro-F1 ve balanced accuracy büyüdükçe sonuç iyileşir. Eğitim süresi grafik üretimini ve dosya kaydını içermez.

## Kaydedilen dosyalar

Her etkileşimli çalışma proje kökündeki `results/session_TARIH_SAAT/` altında yeni klasör açar. Önceki oturumun sonuçları ezilmez.

- `data_preview/`: veri tanıtımlarının PNG ve FIG dosyaları.
- `stage_0/` (veya ders girişine göre `stage_1/2/3/`): model grafikleri ve birden fazla model varsa ortak grafiğin PNG/FIG dosyaları. Tablo figürü üretilmez.
- `metrics.csv`: model karşılaştırmaları.
- Model başına `.mat`: model, ön işleme bilgileri, veri bölünmesi, tahminler ve eğitim geçmişi.
- `summary.mat`: sonuç tablosu ve deney ayarları.

PNG sunum ve raporlarda kullanılır. FIG düzenlenebilir Octave şeklidir. Yeniden açmak için gerçek dosya yolunu kullanın:

```matlab
openfig(fullfile(pwd,'results','session_TARIH_SAAT','stage_0','wine_ELM_seed11.fig'));
```

Yoldaki `session_TARIH_SAAT` yerine çalışma sonunda yazdırılan klasörü girin. Octave FIG dosyasının MATLAB ile birebir uyumlu olması garanti edilmez. Kayıt kapalıysa grafikler ve `results` bellekte kalır; uygulamayı kapatmadan ihtiyaç duyduklarınızı saklayın.

## Hızlı deneme ve menüsüz kullanım

```matlab
setup_course();
cfg = course_config('smoke');
results = run_interactive(0,cfg);
```

`smoke` az eğitim adımı kullanır; ders veya yayın karşılaştırması için varsayılan `classroom` ayarlarını kullanın. Grafikler çok sayıda pencere açabilir; inceledikten sonra `close all` ile kapatabilirsiniz.

Menüsüz, belirli bir veri ve model seçimi de mümkündür:

```matlab
setup_course();
cfg = course_config('classroom');
cfg.examples = cfg.examples(1); % Energy; ikinci örnek Wine
cfg.save_results = false;
cfg.show_figures = true;
results = run_stage(0,cfg,{'ELM','ANFIS','FNN-PSO'});
```

`run_all` toplu çalışma girişidir; etkileşimli değildir. Yeni menü için `run_interactive` kullanın.
Python aynı seçim akışına sahiptir; [Python kılavuzuna](PYTHON_KULLANIM_KILAVUZU.md) bakın.

## Doğrulama

GNU Octave 11.3 üzerinde sayısal testler ve kısa ayarlarla 12 model × 2 problem çalıştırıldı. 26 sonuç FIG dosyasının yeniden açılması, PNG üretimi, tekli/çoklu seçim, kayıt kapalıyken çıktı klasörü oluşmaması ve şekillerin açık kalma durumu kontrol edildi. Otomatik grafik testleri gnuplot altyapısını kullanır; etkileşimli kullanım Octave'ın mevcut grafik altyapısını kullanır.

```matlab
setup_course();
test_course();
test_octave_workflow();
```

İkinci test kendi çıktılarını `work/octave_check_...` altında oluşturur. Test sonuçları düşük bütçeli işlev kontrolüdür; yayın için performans kanıtı değildir. Deney ayarlarını test sonuçlarına bakarak seçmeyin; doğrulama bölümünü kullanın.
