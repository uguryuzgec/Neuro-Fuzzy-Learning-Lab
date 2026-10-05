# Python kullanım kılavuzu

Kurulum ve ortak seçim akışı [ana kılavuzda](KULLANIM_KILAVUZU.md).
Aşağıdaki komutlar proje kökünden, sanal ortamın Python'uyla çalıştırılır.
Windows'ta `python` yerine `.venv\Scripts\python.exe`; macOS/Linux'ta
`.venv/bin/python` kullanabilirsiniz.

## Etkileşimli girişler

```text
python python/run_interactive.py
python python/01_nn.py
python python/02_fnn.py
python python/03_fnn_ga_pso.py
python python/run_interactive.py --profile smoke
```

Ana menü 12 modeli bir kez listeler. Ders girişleri sırasıyla NN/baseline,
FNN ve ANFIS–GA–PSO gruplarını listeler. Kayıt, problem, veri, model seçimleri sorulur.
Sonuç figürleri kapatılana kadar uygulama çalışır. Tek figür içinde grafiğe ayrılmış
paneller bulunur; uzun açıklamalar ve sayısal tablo terminalde kalır.

## Menüsüz deneyler

```text
python python/run_course.py --stage 0 --datasets airfoil sonar --models ELM ANFIS FNN-PSO --no-save
python python/run_course.py --stage 0 --profile smoke --no-plots --no-save
python python/run_course.py --stage all --profile classroom --no-plots
python python/run_course.py --stage 2 --datasets seeds --hide-figures
```

`--stage 0` 12 benzersiz modeldir; `--stage all` ders 1,2,3'ü ayrı çalıştırır ve
ANFIS ders 2 ve 3'te yer alır. `--no-plots` grafik üretmez; `--hide-figures` kaydeder
ama pencere göstermez; `--no-save` deney dosyası yazmaz. Varsayılan tüm altı veridir.

Grafik altyapısı olmayan sunucuda `MPLBACKEND=Agg` seçin ve `--hide-figures` kullanın.
PowerShell örneği: `$env:MPLBACKEND='Agg'`. Masaüstüne dönerken değişkeni kaldırın:
`Remove-Item Env:MPLBACKEND`. `Agg` pencereleri göstermez.

Programatik kullanım (`python/` dizininden):

```python
from course_core import Config, examples
from run_course import run_stage
cfg = Config(save_results=False, show_figures=True)
data = [e for e in examples() if e['name']=='sonar']
rows = run_stage(0, cfg, data, names=['ELM','ANFIS'])
import matplotlib.pyplot as plt
plt.show()
```

## Kayıt ve tekrar açma

PNG rapor, SVG düzenlenebilir vektör çıktısıdır. NPZ tahmin/geçmiş/bölünme indekslerini;
JSON model katsayıları, ön işleme, ayarları saklar. `replot.py` bir NPZ ve aynı adlı
JSON'dan model figürünü yeniden oluşturur. Pickle yüklemesi kullanılmaz.
CSV/JSON'da sınıflandırma oranları 0–1, ekrandaki accuracy yüzdedir.

```text
python python/replot.py results_python/session_.../stage_0/sonar_ELM_seed11.npz
```

## Test

Proje kökünden:

```text
python -m unittest discover -s python -p "test_*.py" -v
```

Sayısal testler gradyanları, ridge çözümünü, veri sızıntısı önlemlerini ve optimizer
bütçelerini kontrol eder. İş akışı testleri 72 kısa model/veri çalışmasını, seçilen
veriyi, tekli/çoklu menüyü, kayıt kapalı durumu, PNG/SVG üretimini ve yeniden çizimi
denetler. Testler grafik için Agg kullanır; görünür masaüstü etkileşimi ayrı kontroldür.

BLAS çok sayıda CPU iş parçacığı açarsa küçük matrislerde çalışma yavaşlayabilir.
Gerekirse Python'ı başlatmadan `OPENBLAS_NUM_THREADS=1` ile çalıştırın; bu matematiksel
model ayarını değiştirmez. NumPy/BLAS sürümleri küçük sayısal farklar yaratabilir.
