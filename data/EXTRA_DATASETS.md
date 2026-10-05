# Ortak dört ek veri seti

5 Ekim 2026 tarihinde resmi UCI arşivlerinden indirildi. Tümü CC BY 4.0 lisanslıdır.
Atıflar korunmalıdır. CSV dosyaları yereldir; ders sırasında indirme gerekmez.
Python ve Octave/MATLAB aynı CSV ve sabit bölünme dosyalarını kullanır.

| Dosya | Görev | Satır | Girdi | Hedef |
|---|---|---:|---:|---|
| airfoil.csv | Regresyon | 1503 | 5 | Ölçeklenmiş ses basıncı, dB |
| yacht.csv | Regresyon | 308 | 6 | Deplasman ağırlığı başına artık direnç |
| seeds.csv | Sınıflandırma | 210 | 7 | Üç buğday çeşidi, etiketler 1/2/3 |
| sonar.csv | Sınıflandırma | 208 | 60 | Kaya=0 (R), metal silindir=1 (M) |

## Kaynaklar ve atıflar

- **Airfoil Self-Noise:** Brooks, T., Pope, D., & Marcolini, M. (1989).
  [UCI](https://archive.ics.uci.edu/dataset/291/airfoil+self-noise),
  [DOI: 10.24432/C5VW2C](https://doi.org/10.24432/C5VW2C).
  `airfoil_self_noise.dat`: frekans, hücum açısı, kord uzunluğu, akış hızı,
  yer değiştirme kalınlığı, hedef ses basıncı. Hücum açısı sayısal/sürekli kullanılır.
- **Yacht Hydrodynamics:** Gerritsma, J., Onnink, R., & Versluis, A. (1981).
  [UCI](https://archive.ics.uci.edu/dataset/243/yacht+hydrodynamics),
  [DOI: 10.24432/C5XG7R](https://doi.org/10.24432/C5XG7R).
  `yacht_hydrodynamics.data`: kaldırma merkezi konumu, prizmatik katsayı,
  uzunluk/deplasman, en/su çekimi, uzunluk/en, Froude sayısı ve hedef.
- **Seeds:** Charytanowicz, M., Niewczas, J., Kulczycki, P., Kowalski, P., & Lukasik, S. (2010).
  [UCI](https://archive.ics.uci.edu/dataset/236/seeds),
  [DOI: 10.24432/C5H30K](https://doi.org/10.24432/C5H30K).
  `seeds_dataset.txt`: alan, çevre, kompaktlık, tane uzunluğu/genişliği,
  asimetri, oluk uzunluğu ve sınıf. Her sınıf 70 örnek içerir.
- **Connectionist Bench (Sonar, Mines vs. Rocks):** Sejnowski, T. & Gorman, R. (1988).
  [UCI](https://archive.ics.uci.edu/dataset/151/connectionist+bench+sonar+mines+vs+rocks),
  [DOI: 10.24432/C5T01Q](https://doi.org/10.24432/C5T01Q).
  `sonar.all-data`: 60 bant enerjisi ve sınıf. 97 R, 111 M örneği.

## Dönüşüm ve tekrar üretim

`import_extra_datasets.ps1` resmi ZIP dosyalarını indirir; boş satırları atlar,
ayraçları virgüle dönüştürür ve başlık ekler. Sonar R/M etiketleri 0/1 yapılır.
Örnek sırası, girdi değerleri ve tüm dolu satırlar korunur. Özellik seçimi,
ölçekleme, örnek azaltma veya başarıya göre satır eleme yapılmaz.
Kaynak ZIP dosyaları `sources_extra/`, indirme adresleri ve SHA256 değerleri
`extra_sources.json` içindedir.

`create_extra_splits.m`, Octave `rng(42,'twister')` ve mevcut `prepare_data`
üzerinden yaklaşık %60/%20/%20 bölünmeyi bir kez üretir. Sınıflandırmada her sınıf
ayrı bölünür. Yeni `*_split42.csv` dosyaları tüm modellerce ortak kullanılır;
MATLAB aynı dosyaları okuduğu için farklı rastgele sayı üreteci sonuçları etkilemez.
Betik mevcut bölünme dosyalarının üzerine yazmaz. Eski Energy/Wine bölünmeleri değişmedi.

## Ders yorumu

Sonar az örnek/çok özellik koşulunu; Seeds üç sınıflı geometrik ayrımı;
Airfoil ve Yacht farklı fiziksel regresyon ilişkilerini gösterir. Kolay/zor sıralaması
önceden garanti edilmez ve veri seçimi test başarısına göre yapılmadı.
Regresyon hedef ölçekleri farklı olduğundan veri setleri arasında ham RMSE'leri
doğrudan sıralamayın; R² ve her veri setinin kendi baseline'ına göre farkı inceleyin.

Rastgele satır bölünmeleri ders içi karşılaştırmadır. Yacht'ta aynı gövdenin farklı
hız ölçümleri, Airfoil'de ortak deney koşulları bulunabilir. Yeni gövde/deney koşuluna
genelleme iddiası için grup bazlı bölünme ayrıca kurulmalıdır. Tek bölünme ve tek
seed sonucu bir modelin genel üstünlüğünü kanıtlamaz.
