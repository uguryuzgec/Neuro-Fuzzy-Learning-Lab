# Ders anlatım akışı

## 1. örnek — NN: öğrenilen ve rastgele bırakılan ağırlıklar

Önce enerji probleminde tek bir örneğin giriş/çıkışını gösterin. Eğitim, doğrulama
ve testin görevlerini ayırın. Ortalama tahmincisini çalıştırıp “öğrenme gerçekten
fayda sağlıyor mu?” sorusuna bir referans oluşturun.

1. MLP'de ileri hesap, hata, zincir kuralı ve ağırlık güncellemesi.
2. ELM'de rastgele gizli katman, tasarım matrisi ve çıktı çözümü.
3. RVFL'de doğrudan bağlantının eklenmesi; ELM ile aynı rastgele katman.
4. Wine üzerinde aynı çıktı matrisini üç sütunlu one-hot hedefe genişletme.
5. RMSE ile sınıflandırma başarısının aynı şey olmadığını gösterme.

Gösterilecek kodlar: `mlp_loss`, `train_random_nn`, `ridge_solve`.
Python karşılıkları aynı isimlerle `course_core.py` içindedir.

Sınıf içi deney: gizli nöron sayısını 8, 24, 64 yapın. Doğrulama hatasıyla seçim
yapın; test skorunu her denemede seçim ölçütü haline getirmeyin. Rastgele seed
değiştiğinde ELM/RVFL sonucunun neden değiştiğini tartışın.

## 2. örnek — FNN: üyelikten tahmine

Bir Gauss üyeliğini çizerek merkez ve genişliğin etkisini anlatın. Bir kuralın
çarpım ateşleme gücünü ve normalize ağırlığını elle hesaplayın.

1. Sabit TSK-1 ile doğrusal kural sonuçlarının nasıl birleştiği.
2. Adaptif TSK-0: her kuralın çıktı sabiti, öğrenilen üyelikler.
3. ANFIS tarzı TSK-1: doğrusal kural sonuçları ve öğrenilen üyelikler.
4. İleri geçişte ridge, geri geçişte öncül gradyanları.
5. Fuzzy-RVFL öğretim varyantıyla özellik birleştirme fikri.

Gösterilecek kodlar: `fnn_design`, `fnn_gradient`, `train_fnn`.
“ANFIS'in hibrit öğrenmesi” (gradyan + en küçük kareler) ile “GA/PSO eklenmiş
hibrit model” kavramlarının farklı olduğunu özellikle açıklayın.

Sınıf içi deney: kural sayısı 3, 6, 10. Daha çok kuralın parametre sayısı ve
genelleme üzerindeki etkisini sorgulayın. TSK-0 ile TSK-1 farkının hem kapasite
hem parametre sayısı farkı olduğunu belirtin.

## 3. örnek — FNN–GA/PSO: ağı sabit tut, eğitimi değiştir

Önce `theta = [merkezler; log(genişlikler)]` vektörünü gösterin. Bir adaydan
modelin tekrar kurulmasını, eğitim bölümünde çıktı çözümünü ve doğrulama
hatasının fitness olarak dönmesini adım adım izleyin.

1. Başlangıç üyelikleri, sınırlar ve popülasyon.
2. GA: turnuva seçimi, gerçek değerli çaprazlama, Gauss mutasyonu, elitizm.
3. PSO: hız, kişisel en iyi, küresel en iyi ve sınır işlemleri.
4. Yakınsama eğrisini iterasyon yerine fitness değerlendirme sayısıyla çizme.
5. Eğitim süresi, doğrulama hatası ve test başarısının farklı ölçüler olduğu.

Gösterilecek kodlar: `fnn_objective`, `train_meta_fnn`, `optimizer_ga`, `optimizer_pso`.
Öğrencinin ekleyeceği yer: `optimizer_xx_template`.

Kapanış sorusu: “Yeni sezgisel bazı veri setlerinde daha kötü çıkarsa bilimsel
olarak ne öğrendik?” Sonucun yönünden çok doğru deney ve açıklama değerlendirilir.

## Kaynaklar

- Jang (1993), ANFIS: Adaptive-Network-Based Fuzzy Inference System.
  https://doi.org/10.1109/21.256541
- Huang, Zhu, Siew (2006), Extreme learning machine: Theory and applications.
  https://doi.org/10.1016/j.neucom.2005.12.126
- Dudek (2020), Are Direct Links Necessary in RVFL NNs for Regression?
  https://arxiv.org/abs/2003.13090
- Mevcut dersin çıkış noktası olan depo:
  https://github.com/uguryuzgec/Meta-Heuristic-based-ANFIS-Training

Bu paket mevcut depodan kod kopyalamadan, yöntemleri açık temel matris işlemleriyle
yeniden kurar. Kullanılan öğretim varyantları kaynak makalelerin birebir yeniden
üretimi olarak sunulmamalıdır.
