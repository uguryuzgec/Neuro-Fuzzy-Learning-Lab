# Altı veri seti doğrulaması — 5 Ekim 2026

GNU Octave 11.3'te `smoke` ve `classroom` ayarlarıyla ayrı ayrı
12 model × 6 veri seti çalıştırıldı. Kısa testte veri boyutları, sonlu değerler,
bölünmelerin ayrık/tam olması, eğitim ölçeklemesi ve model metrikleri doğrulandı.
Yeni veriler sabit bölünme dosyalarıyla MATLAB uyumlu temel `.m` arayüzünü kullanır;
bu değişiklik için MATLAB üzerinde ayrıca çalıştırma yapılmadı.

Octave 11'in bar grafiği FIG kaydında özel `rm_axes_listeners` silme callback'i
yeniden açılan dosyada çözümlenemediği için yalnızca kayıt kopyasından çıkarılır;
canlı grafiğin callback'i hemen geri yüklenir. MATLAB bu düzeltme dalına girmez.

## Aynı ELM, farklı veri setleri

`classroom`, model seed=11; yeni bölünmeler seed=42 ile önceden sabitlendi.

| Veri | Test ölçütü | ELM |
|---|---|---:|
| Energy | R² | 0.9061 |
| Airfoil | R² | 0.5802 |
| Yacht | R² | 0.5050 |
| Wine | Accuracy | %100.00 |
| Seeds | Accuracy | %92.86 |
| Sonar | Accuracy | %79.07 |

Ölçütler farklı görevler arasında aynı anlamda değildir. Bu tablo aynı modelin
veri setine duyarlılığını göstermek içindir; genel model sıralaması değildir.
Hiperparametreler veya bölünmeler bu test sonuçlarına göre değiştirilmedi.

Tam ders sonuçları `work/six_data_classroom/stage_0/metrics.csv`, model ve tahminler
aynı klasördeki MAT dosyalarındadır. Yeni veriler için grafik örnekleri
`work/six_data_graphics/` altında bulunur.

Kontrolleri tekrar çalıştırmak için:

```matlab
setup_course();
test_six_datasets();      % dosya yazmaz, 72 kısa model çalışması
check_extra_graphics();  % gnuplot kurulu Octave; work içine PNG/FIG yazar
```

Menü testi: kayıt=2, problem=2, veri=3, tek model=1, ELM=5 ile yalnızca
Sonar veri tanıtımı ve ELM sonuç figürü açıldığı doğrulandı.
