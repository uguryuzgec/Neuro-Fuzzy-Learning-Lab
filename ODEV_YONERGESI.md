# Dönem projesi — FNN–XX

Bu metin öğretim elemanının düzenleyebileceği **öneri yönergedir**; aşağıdaki
sayılar ve puanlar henüz resmî ders değerlendirme koşulları değildir.

## Amaç ve teslimler

Bir hibrit model makalesini okuyup çevirin. Seçtiğiniz sezgisel algoritmayı açık
neuro-fuzzy altyapısına ekleyin; yeni veri setlerinde temel modellerle karşılaştırın
ve deneylerinizi makale düzeninde raporlayın.

Önerilen teslim sırası:

1. Makalenin tam künyesi, çevirisi ve bir sayfalık yöntem değerlendirmesi.
2. Seçilen sezgiselin özgün kaynağı, matematiksel adımları, ANFIS ile bağlantısı.
3. Çalışan FNN–XX kodu, veri kaynakları, çalıştırma yönergesi ve ön deney.
4. Tekrarlı deneyler, karşılaştırma ve ablation sonuçları.
5. Makale, kaynak kod, deney ayarları, ham sonuçlar ve sunum.

Çeviri makalesiyle uygulama algoritmasının aynı olması zorunluluğu bu taslakta
varsayılmamıştır; öğretim elemanı isterse bunu ayrı bir koşul yapabilir.

## Veri ve model kapsamı

Kaggle'dan seçilecek yeni veri setlerinin özgün kaynağı, lisansı, hedefi ve
örnekleme yapısı belirtilmelidir. Başlangıç önerisi aynı problem türünde en az
üç veri setidir; kapsam ve veri büyüklüğü öğretim elemanıyla belirlenir.
Wine ve Energy, ders demonstrasyonlarıdır; yeni çalışmanın tek kanıtı olmamalıdır.

Karşılaştırma çekirdeği:

- Basit referans: ortalama/çoğunluk sınıfı ve Ridge/lojistik regresyon.
- kNN, MLP ve güçlü bir ağaç tabanlı model (ör. Random Forest veya boosting).
- ELM ve RVFL.
- Sabit TSK-1, gradyanla eğitilen aynı ANFIS yapısı.
- FNN–GA, FNN–PSO, öğrencinin FNN–XX modeli.

Paket Mean, Ridge, kNN, MLP, ELM, RVFL ve FNN modellerini içerir.
**Lojistik regresyon, Random Forest, boosting ve SVM bu temel pakette uygulanmamıştır**;
yayın deneylerinde uygun açık kaynak kütüphanelerden eklenmelidir.

## Deney protokolü

Veriyi bölmeden ölçekleme veya imputasyon yapmayın. Grup/kişi/bina kimliği olan
verileri gruplarına göre, zaman serilerini zamana göre ayırın. Enerji örneğinin
rastgele bölünmesi bilinen tasarım uzayında ara değer tahminini ölçer; görülmemiş
bina geometrilerine genelleme iddiası için grup tabanlı değerlendirme gerekir.

Ders paketinin tek doğrulama bölümü 320 kez sorgulanabilir. Yayın çalışmasında
doğrulama bölümüne aşırı uyumu azaltmak için önceden belirlenmiş iç çapraz doğrulama
veya uygun bir iç değerlendirme düzeni kullanın. Dış test bölümü seçime girmemelidir.

Başlangıç önerisi her model için en az 10 bağımsız optimizasyon seed'i ve uygun
dış bölünmelerdir. `repeated` profili yalnızca sabit dış bölünmedeki seed değişimini
ölçer; veri bölünmesi belirsizliğini ölçmez. Aynı bölünmeler modeller arasında paylaşılmalıdır.

GA, PSO ve XX için yalnızca eşit iterasyon yeterli değildir. Başlatma, yeniden
başlatma ve ek yerel aramalar dahil tüm fitness çağrılarını sayın. Aynı değerlendirme
bütçesini, popülasyonu, öncül sınırlarını ve başlangıç modelini raporlayın.
Çalışma süresini ve donanımı da verin. Gradyan adımı ile bir fitness çağrısını eşdeğer
hesaplama maliyeti saymayın. Baseline hiperparametrelerine de makul arama bütçesi ayırın.

GA/PSO hiperparametrelerini veya kural sayısını test skoruna bakıp değiştirmeyin.
En iyi koşuyu seçmek yerine tüm önceden belirlenmiş koşuların sonuçlarını raporlayın.
Seed tekrarlarını bağımsız yeni veri setleriymiş gibi kullanmayın.

## Makalede bulunması beklenenler

Problem ve gerekçe; ilgili çalışmalar; FNN mimarisi ve XX bağlantısı; veri ve ön işlem;
deney düzeni; sonuçlar; tartışma; sınırlılıklar; tekrar üretilebilirlik bilgileri; kaynaklar.

Regresyon: RMSE, MAE, R². Sınıflandırma: accuracy, macro-F1, balanced accuracy,
karışıklık matrisi; olasılık temelli ölçüler kullanılacaksa uygun olasılık modeli/kalibrasyon.
Ortalama, standart sapma veya uygun güven aralıkları; yakınsama ve süre raporları.

Ablation önerileri: sabit üyelikler / öğrenilen üyelikler; farklı kural sayıları;
yalnız merkez / merkez+genişlik optimizasyonu; XX'nin önerilen bileşeni açık/kapalı.
Bu seçeneklerden yalnızca temel mimari karşılaştırmaları pakette hazırdır;
diğer ablation deneyleri öğrenci tarafından eklenir.

**Bir sezgiselin adını değiştirip ANFIS'e bağlamak tek başına yayın özgünlüğü sağlamaz.**
Katkı; gerekçeli bir yöntem değişikliği, veri/problem açısından anlamlı bulgu,
hesaplama verimliliği, kararlılık veya açıklanabilirlik üzerinden somutlaştırılmalıdır.
Negatif sonuçlar da doğru deneylerle raporlanabilir; yayın kabulü garanti edilmez.

## Öneri değerlendirme rubriği

| Bileşen | Puan |
|---|---:|
| Makale çevirisi ve yöntemi kavrama | 15 |
| FNN–XX entegrasyonu ve kodun açıklanabilirliği | 25 |
| Veri yönetimi, adil karşılaştırma ve tekrar üretilebilirlik | 25 |
| Sonuç analizi, ablation ve sınırlılıkların tartışılması | 20 |
| Makale yazımı, kaynak kullanımı ve sunum | 15 |

Sonucun mutlaka baseline'ı geçmesi puan koşulu değildir. Özgün kaynaklara ve
kullanılan yazılım/veri setlerine atıf, çeviri ile öğrencinin kendi yorumunun ayrılması
ve varsa yapay zekâ desteğinin ders politikasına uygun açıklanması beklenir.
