# CPPLamb Uygulama Planı

Bu belge, CPPLamb (C++ derin öğrenme çerçevesi) projesinin adım adım nasıl inşa edileceğini, her bileşenin özelliklerini ve dikkat edilmesi gereken noktaları açıklar. Alanında yeni ancak yazılımda deneyimli biri için hazırlanmıştır.

---

## 1. Genel Bakış ve Sıra

Proje, birbirine bağımlı katmanlar halinde ilerler. Aşağıdaki sıraya uymak, her adımda test edilebilir ve çalışan bir yapı kurmanıza yardımcı olur.

| Aşama | Bileşen | Kısa Açıklama |
|-------|---------|----------------|
| 0 | Build sistemi ve üçüncü parti | CMake, bağımlılıklar, dizin yapısı |
| 1 | Çekirdek (core) | Tip, cihaz, bellek, dispatcher altyapısı |
| 2 | Tensor | Tensor, storage, shape, strides |
| 3 | Operasyonlar (ops) | Şema, codegen, kernel kaydı, basit op’lar |
| 4 | Autograd | Grad modu, değişken, graf, geri yayılım motoru |
| 5 | NN ve Optim | Modül, parametre, katmanlar, SGD/Adam |
| 6 | Backend’ler ve eklentiler | CPU/CUDA ayrımı, plugin örnekleri |
| 7 | Araçlar, test, doküman | Codegen, testler, örnekler, dokümantasyon |

Aşağıda her bileşen için: **ne oluşturulacak**, **özellikler**, **dikkat edilecekler** ve **iç aşamalar** verilmiştir.

---

## 2. Aşama 0: Build Sistemi ve Üçüncü Parti Kütüphaneler

### 2.1 Ne Oluşturulacak

- **Kök `CMakeLists.txt`**: Proje adı, C++ standardı (örn. C++17), alt dizinlerin eklenmesi.
- **`cmake/`**:  
  - Toolchains (isteğe bağlı, farklı derleyiciler/hedefler için).  
  - Modules: bağımlılık bulma (Eigen, fmt, spdlog vb.).  
  - `Sanitize.cmake`: AdressSanitizer, UndefinedBehaviorSanitizer.  
  - `Warnings.cmake`: Uyarı seviyesi (örn. `-Wall -Wextra`), hata sayılan uyarılar.
- **`third_party/`**: Eigen, fmt, spdlog (zorunlu); googletest, benchmark (test/benchmark için); pybind11 (opsiyonel).
- **Temel dizin yapısı**: `include/ai/`, `src/ai/`, `tests/`, `examples/`, `docs/` vb. boş veya iskelet halinde.

### 2.2 Özellikler

- Tek komutla derleme: örn. `cmake -B build && cmake --build build`.
- Install hedefleri: kütüphane ve public header’ların kurulumu.
- Opsiyonel bileşenler: TEST, BENCHMARK, PYTHON_BINDINGS gibi CMake seçenekleri.
- Sanitizer’lar özellikle test build’inde; Release’te genelde kapalı.

### 2.3 Dikkat Edilecekler

- Üçüncü parti kütüphaneleri `add_subdirectory` veya `FetchContent` ile alın; sistem kütüphanelerine bağımlılığı azaltın.
- `include/` sadece public API için kullanılsın; implementasyon detayları `src/` içinde kalsın.
- Windows/Linux/macOS için yaygın derleyicilerle (MSVC, GCC, Clang) en azından temel build’in çalıştığından emin olun.

### 2.4 İç Aşamalar

1. **0.1** Kök `CMakeLists.txt` ve `include/`, `src/` yapısı; boş bir `ai.h` ile “hello world” kütüphane.
2. **0.2** `cmake/Modules`, `Warnings.cmake`, `Sanitize.cmake` eklenmesi.
3. **0.3** Eigen, fmt, spdlog entegrasyonu; basit bir `#include` ve kullanım testi.
4. **0.4** Googletest ile `tests/` ve bir dummy test; isteğe bağlı Benchmark.
5. **0.5** Install kuralları ve paket konfigürasyonu (opsiyonel).

---

## 3. Aşama 1: Çekirdek (Core)

### 3.1 Ne Oluşturulacak

- **Temel tipler ve sabitler**: `version.h`, `error.h` (hata kodları veya exception türleri), `logging.h` (spdlog ile sarmal).
- **Hesaplama birimi ve veri tipi**: `device.h` (CPU, CUDA, … enum/type), `dtype.h` (float32, int64, …), `scalar.h` (tek değer tutan tip).
- **Yardımcı veri yapıları**: `smallvec.h` (küçük boyutlar için sabit kapasiteli vektör), `intrusive_ptr.h` (referans sayımlı akıllı pointer).
- **Bellek**: `memory/allocator.h` (soyut arayüz), `memory/cpu_allocator.cc` (CPU uygulaması).
- **Dispatcher altyapısı**: `dispatcher/dispatch_key.h` (cihaz + dtype vb. anahtar), `dispatcher/registry.h` (anahtara göre kernel kaydı), `dispatcher/dispatcher.h` (çağrı yönlendirme).

### 3.2 Özellikler

- Cihaz ve dtype’tan bağımsız bir “çekirdek dil”: tüm üst katmanlar Device ve DType ile çalışır.
- Tek bir allocator arayüzü; ileride CUDA/Metal allocator eklenebilir.
- Dispatcher: “Bu op’u bu (Device, DType) için hangi kernel çalıştıracak?” sorusunun merkezi cevabı.

### 3.3 Dikkat Edilecekler

- `intrusive_ptr` kullanıyorsanız referans sayımı kurallarını net yazın (copy/move, thread-safety beklentisi).
- Dispatcher’ı başta basit tutun: örneğin sadece (Backend, DType) ile; karmaşık kurallar sonra eklenebilir.
- Loglama ve hata mesajları tutarlı bir formatta olsun (ör. `[CPPLamb][Modül] Mesaj`).

### 3.4 İç Aşamalar

1. **1.1** `version.h`, `error.h`, `logging.h`; proje içinde kullanım.
2. **1.2** `device.h`, `dtype.h`, `scalar.h`; birim testleri.
3. **1.3** `smallvec.h`, `intrusive_ptr.h` (ve gerekirse bir test sınıfı için kullanım).
4. **1.4** `allocator.h` + `cpu_allocator.cc`; basit allocate/free testi.
5. **1.5** `dispatch_key.h`, `registry.h`, `dispatcher.h`; tek bir “dummy” kernel ile kayıt ve çağrı testi.

---

## 4. Aşama 2: Tensor

### 4.1 Ne Oluşturulacak

- **Storage**: `storage.h` – ham bellek + boyut + allocator referansı; bazen copy-on-write (COW) için referans sayımı.
- **Shape ve strides**: `shape.h` (boyutlar dizisi), `strides.h` (eleman erişimi için adımlar); çok boyutlu indeks → doğrusal indeks.
- **Tensor implementasyonu**: `tensor_impl.h` – storage, shape, strides, dtype, device; `tensor.h` – kullanıcıya açılan, ince sarmalayıcı (PIMPL).
- **Tensor sınıfı ve view işlemleri**: `tensor.cc` (constructor, copy, move, temel erişim), `view_ops.cc` (reshape, slice, view – mümkünse kopyasız).

### 4.2 Özellikler

- Tensor = (storage, shape, strides, dtype, device).  
- View semantiği: reshape/slice aynı storage’ı paylaşabilir; yazma davranışı net tanımlanmalı (COW veya paylaşımlı yazma).
- PIMPL: public header’da sadece arayüz; implementasyon detayları ve bağımlılıklar `tensor_impl.h` ve `.cc` içinde.

### 4.3 Dikkat Edilecekler

- Strides’ın shape ile tutarlı olması (özellikle view’lar sonrası); hatalı stride hesabı sessiz veri bozulmasına yol açar.
- Hareket (move) semantiği: taşınan tensor “boş” veya geçersiz duruma getirilmeli.
- Çok boyutlu indeksleme ve doğrusal indeks arasındaki dönüşümü tek yerde (örn. bir yardımcı fonksiyon) toplayın.

### 4.4 İç Aşamalar

1. **2.1** `shape.h`, `strides.h`; shape/strides’tan doğrusal indeks hesabı ve testleri.
2. **2.2** `storage.h` (referans sayımlı, COW isteğe bağlı); allocator ile entegrasyon.
3. **2.3** `tensor_impl.h`, `tensor.h`; constructor, copy, move, `numel()`, `dim()`.
4. **2.4** `tensor.cc` – veri erişimi (ör. `data<T>()`, skaler erişim); basit testler.
5. **2.5** `view_ops.cc` – reshape, slice (en az 1D); view’ların storage paylaştığını doğrulayan testler.

---

## 5. Aşama 3: Operasyonlar (Ops)

### 5.1 Ne Oluşturulacak

- **Ortak altyapı**: `common/op_context.h` (girdi/çıktı tensor’ları, device, dtype), `common/kernel_api.h` (kernel imzası: context alan, sonucu yazan).
- **Şema ve codegen**: `schemas/` altında YAML/tanım dosyaları (örn. op adı, argümanlar, sonuçlar); `tools/codegen/generate_ops.py` ve şablonlar; çıktı `generated/` (DO NOT EDIT).
- **Kernel kaydı**: Codegen’in ürettiği makrolar/fonksiyonlarla her op için (Backend, DType) kernel’ın kaydedilmesi.
- **Örnek kernel’lar**: `cpu/add_kernel.cc`, `cpu/matmul_kernel.cc`; isteğe bağlı `cuda/add_kernel.cu`, `matmul_kernel.cu`.

### 5.2 Özellikler

- Op’lar şema ile tanımlı; kod tek kaynaktan üretilir (tutarlılık, daha az el yazımı hata).
- Tüm kernel’lar aynı “kernel API”ye uyar: örn. `void kernel(OpContext& ctx)`.
- Dispatcher, çağrıyı cihaz/dtype’a göre doğru kernel’a yönlendirir.

### 5.3 Dikkat Edilecekler

- Codegen çıktısı (`generated/`) asla elle düzenlenmemeli; değişiklik şemada veya script’te yapılmalı.
- Op şemasında broadcast, optional argümanlar ve dtype kuralları net yazılmalı.
- İlk etapta sadece CPU kernel’ları yeterli; CUDA sonra eklenebilir.

### 5.4 İç Aşamalar

1. **3.1** `op_context.h`, `kernel_api.h`; tek bir “identity” veya “copy” kernel ile test.
2. **3.2** Basit bir op şeması (örn. `add`) ve codegen script’i; kayıt kodu üretimi.
3. **3.3** CPU add kernel; dispatcher üzerinden `add(op_context)` çağrısı ve test.
4. **3.4** Matmul şeması ve CPU matmul kernel; birim testleri.
5. **3.5** (Opsiyonel) CUDA add/matmul; aynı dispatcher ile seçim.

---

## 6. Aşama 4: Autograd (Otomatik Türev)

### 6.1 Ne Oluşturulacak

- **Grad modu**: `grad_mode.h` – örn. `GradMode::is_enabled()`, RAII ile `NoGrad` scope.
- **Değişken**: `variable.h` – tensor + opsiyonel gradyan + “grad_fn” (backward fonksiyonu için referans).
- **Graf düğümleri**: `function.h`, `node.h` – tek bir backward adımı (örn. AddBackward); girdi değişkenleri, çıktı gradyanı → girdi gradyanları.
- **Motor**: `engine/engine.h`, `engine.cc` – backward çağrısında grafi toplama (topological sıra), her düğümde backward çalıştırma.
- **Backward op’ları**: `ops/add_backward.cc` vb. – her ön op için karşılık gelen gradyan hesabı.

### 6.2 Özellikler

- Define-by-run: forward sırasında her op, grafa bir düğüm ekler; backward’da motor bu grafi çalıştırır.
- `NoGrad`: inference veya ara hesaplamalarda gradyan tutulmaz; bellek ve hız kazanımı.
- Variable, tensor’ı sarmalayarak kullanılır; sadece “grad gerekiyor” denilen yerlerde Variable kullanılır.

### 6.3 Dikkat Edilecekler

- Döngü (cycle) oluşmamalı; graf asiklik (DAG) olarak tasarlanmalı.
- Çoklu kullanım (bir değişkenin birden fazla op’ta girdi olması): gradyanlar toplanmalı (toplam veya accumulate).
- In-place op’lar gradyan tarafında özel dikkat gerektirir; ilk aşamada in-place’den kaçınmak daha güvenlidir.

### 6.4 İç Aşamalar

1. **4.1** `grad_mode.h`; `is_enabled()` ve `NoGrad`; test.
2. **4.2** `node.h`, `function.h`; tek bir “dummy” backward düğümü ile örnek.
3. **4.3** `variable.h` – tensor + grad + grad_fn; forward’da grad_fn ataması (ör. add).
4. **4.4** `engine` – basit backward: tek çıktı, zincir halinde düğümler; gradyan akışı testi.
5. **4.5** `add_backward.cc` ve add op’unun Variable ile entegrasyonu; “add → backward → gradyan doğru mu?” testi.
6. **4.6** Çoklu kullanım: aynı değişken iki yoldan kullanıldığında gradyanların toplanması.

---

## 7. Aşama 5: NN Modülleri ve Optimizer’lar

### 7.1 Ne Oluşturulacak

- **Modül altyapısı**: `module.h` – isim, alt modüller listesi, parametre listesi; `parameter.h` – Variable tabanlı eğitilebilir parametre.
- **Fonksiyonel API**: `functional/` – stateless fonksiyonlar (örn. activation’lar).
- **Katmanlar**: `layers/linear.cc`, `layers/conv2d.cc` – stateful modüller (parametre tutar, forward tanımlar).
- **Optimizer**: `optimizer.h` – parametre listesi, adım (step) arayüzü; `sgd.cc`, `adam.cc` – güncelleme kuralları.

### 7.2 Özellikler

- Modül ağaç yapısı: `parameters()` tüm alt modüllerin parametrelerini toplar.
- Forward: kullanıcı `module.forward(input)` veya benzeri bir arayüzle çağırır; içeride tensor op’ları ve autograd ile uyumlu.
- Optimizer: her step’te parametrelerin gradyanına göre değer güncellenir; sıfırlama (zero_grad) ayrı bir çağrı olabilir.

### 7.3 Dikkat Edilecekler

- Parametre paylaşımı (aynı parametrenin birden fazla yerde kullanılması) doğru yönetilmeli; kopya/pointer tutarlılığı.
- İlk değer atama (initialization): Linear/Conv için ağırlık ve bias için basit şemalar (örn. Xavier, sıfır bias).
- Optimizer’da learning rate, momentum vb. hiperparametreler net isimlerle ve mümkünse değiştirilebilir olsun.

### 7.4 İç Aşamalar

1. **5.1** `parameter.h`, `module.h`; tek parametreli “Identity” modülü; `parameters()` testi.
2. **5.2** `layers/linear.cc` – forward, init; autograd ile uyumluluk.
3. **5.3** `optimizer.h`, `sgd.cc`; tek parametre ile step ve zero_grad testi.
4. **5.4** `adam.cc`; aynı arayüzle test.
5. **5.5** `layers/conv2d.cc` (isteğe bağlı); `functional/` için birkaç basit fonksiyon (örn. relu).

---

## 8. Aşama 6: Backend’ler ve Eklentiler

### 8.1 Ne Oluşturulacak

- **Backend dizinleri**: `backends/cpu/`, `backends/cuda/` – kendi `CMakeLists.txt`, kernel’lar; ana proje bunları opsiyonel olarak derler.
- **Plugin örnekleri**: `plugins/example_backend/`, `plugins/example_operator_pack/` – nasıl yeni backend veya op paketi ekleneceğini gösteren iskelet ve README.

### 8.2 Özellikler

- Ana çekirdek, “cihaz” ve “dispatcher” ile soyut; backend’ler bu soyutlamaya kernel kaydı ile bağlanır.
- Yeni backend = yeni dizin + kernel implementasyonları + kayıt; çekirdek kodu mümkün olduğunca değişmez.
- Plugin README’leri: bağımlılıklar, derleme, kayıt adımları.

### 8.3 Dikkat Edilecekler

- CUDA için derleyici ve runtime bağımlılığı; CUDA yoksa build’in düşmesini engelleyin (opsiyonel target).
- ABI uyumluluğu: eğer plugin’ler ayrı .so/.dll olarak yüklenecekse, arayüz sabit ve dokümante olmalı.

### 8.4 İç Aşamalar

1. **6.1** `backends/cpu/` – mevcut CPU kernel’larını buraya taşıma veya buradan referans etme; CMake entegrasyonu.
2. **6.2** `plugins/README.md` – “Backend nasıl eklenir”, “Op paketi nasıl eklenir” özeti.
3. **6.3** `example_backend` – minimal kernel + kayıt; `example_operator_pack` – tek op’lı paket iskeleti.
4. **6.4** (Opsiyonel) `backends/cuda/` – CUDA kernel’ları ve ana projede opsiyonel build.

---

## 9. Aşama 7: Araçlar, Test, Örnekler ve Doküman

### 9.1 Ne Oluşturulacak

- **Codegen**: `tools/codegen/op_schema.yaml` (veya benzeri), `generate_ops.py`, `templates/`; build sırasında veya manuel çalıştırma.
- **Lint/format**: `tools/clang_tidy/`, `scripts/` – format.sh, lint.sh; CI’da kullanılacak komutlar.
- **Testler**: `tests/unit/`, `tests/integration/`, `tests/autograd/`, `tests/nn/`, `tests/ops/` – her katman için en az temel testler.
- **Benchmark’lar**: `benchmarks/tensor/`, `benchmarks/ops/` – kritik yol performansı.
- **Örnekler**: `examples/train_mnist/`, `examples/inference_resnet/`, `examples/custom_op/` – uçtan uca kullanım.
- **Doküman**: `docs/architecture/`, `docs/api/`, `docs/dev/` – mimari kararlar, API referansı, geliştirici rehberi.

### 9.2 Özellikler

- Codegen: op ekleme işlemi şema + script ile tekrarlanabilir.
- Testler: birim testleri hızlı, entegrasyon testleri gerçek senaryoya yakın.
- Örnekler: projeyi clone eden birinin hızlıca derleyip çalıştırabileceği minimal senaryolar.

### 9.3 Dikkat Edilecekler

- Codegen’in çıktısı versiyon kontrolüne dahil edilsin mi tartışılabilir; dahil ederseniz “DO NOT EDIT” uyarısı net olsun.
- CI pipeline’da format ve lint’in tek komutla çalışması; dokümandaki komutlar güncel kalsın.

### 9.4 İç Aşamalar

1. **7.1** Codegen’i Aşama 3 ile birlikte kurun; yeni op ekleme adımlarını `docs/dev/` içine yazın.
2. **7.2** Her modül için en az bir birim testi (core, tensor, ops, autograd, nn, optim).
3. **7.3** Bir entegrasyon testi (örn. linear → loss → backward → sgd step).
4. **7.4** `examples/train_mnist/` (veya basit bir regresyon); `examples/custom_op/` iskeleti.
5. **7.5** `docs/architecture/overview.md`; `docs/dev/build.md`, `docs/dev/contributing.md`.
6. **7.6** format.sh, lint.sh ve (opsiyonel) CI config.

---

## 10. Özet Kontrol Listesi

- [ ] Aşama 0: CMake, third_party, dizin yapısı, install.
- [ ] Aşama 1: Core (version, error, logging, device, dtype, scalar, smallvec, intrusive_ptr, allocator, dispatcher).
- [ ] Aşama 2: Tensor (storage, shape, strides, tensor, view_ops).
- [ ] Aşama 3: Ops (op_context, kernel_api, schemas, codegen, CPU add/matmul).
- [ ] Aşama 4: Autograd (grad_mode, variable, node, function, engine, add_backward).
- [ ] Aşama 5: NN + Optim (module, parameter, linear, sgd, adam).
- [ ] Aşama 6: Backends/plugins (cpu/cuda dizinleri, example_backend, README).
- [ ] Aşama 7: Codegen otomasyonu, testler, örnekler, doküman, format/lint.

---

## 11. Kaynakça ve Terimler

Aşağıda belgede geçen teknik terimler kısaca açıklanmaktadır.

- **Allocator**: Bellek ayırma ve serbest bırakma işlemlerini yöneten soyut arayüz. Farklı cihazlar (CPU, GPU) için farklı implementasyonlar kullanılır.

- **Autograd**: Otomatik türev (automatic differentiation). Hesaplama adımlarını kaydedip, sonuçtaki bir skaler değere göre gradyanları geri yayılım (backward) ile hesaplama.

- **Backend**: Hesaplamanın fiziksel olarak nerede yapıldığı (CPU, CUDA, Metal, OpenCL). Her backend kendi kernel’larına sahiptir.

- **Codegen (kod üretimi)**: Şema veya tanım dosyalarından (örn. YAML) C++ veya kayıt kodunun otomatik üretilmesi. Elle yazım hatalarını ve tutarsızlıkları azaltır.

- **Copy-on-write (COW)**: Veri paylaşılır; ancak bir taraf yazma yapana kadar kopya oluşturulmaz. Bellek tasarrufu ve view semantiği için kullanılır.

- **Dispatcher**: Çağrıyı, cihaz ve veri tipi gibi anahtarlara göre doğru kernel’a yönlendiren katman. “Bu op’u hangi implementasyon çalıştırsın?” sorusunun merkezi.

- **DType (veri tipi)**: Tensor elemanlarının tipi (örn. float32, int64). Hesaplama ve kernel seçimi dtype’a göre yapılır.

- **Define-by-run**: Hesaplama grafının, program çalışırken (her forward adımında) oluşturulduğu model. Statik graf (define-by-define) ile karşılaştırılır.

- **Grad (gradyan)**: Bir çıktı değişkeninin, bir girdi değişkenine göre türevi. Eğitimde parametre güncellemesi için kullanılır.

- **Intrusive pointer**: Referans sayımı bilgisi nesnenin kendi içinde tutulan akıllı pointer. Paylaşımlı sahiplik ve bellek yönetimi için kullanılır.

- **Kernel**: Belirli bir op’un belirli bir (backend, dtype) kombinasyonu için somut implementasyonu. Örn. “CPU’da float32 add”.

- **PIMPL (Pointer to Implementation)**: Public header’da sadece bir pointer tutarak implementasyon detaylarını gizleme. Derleme süresi ve ABI kararlılığı için faydalı.

- **Registry**: Anahtar (örn. dispatch key) → değer (örn. kernel fonksiyonu) eşlemesi. Dispatcher kayıtları bu yapıda tutulur.

- **Sanitizer**: Bellek hataları (AddressSanitizer) veya tanımsız davranış (UndefinedBehaviorSanitizer) tespiti için derleyici araçları. Genelde debug/test build’lerinde kullanılır.

- **Shape**: Tensor’ın her eksendeki boyutu (örn. [2, 3, 4] → 2×3×4).

- **Strides**: Çok boyutlu indeksten doğrusal indekse geçişte kullanılan “adım” değerleri. Elemanın bellekte nerede olduğunu hesaplamak için shape ile birlikte kullanılır.

- **Storage**: Tensor’ın ham bellek alanı. Birden fazla tensor (view’lar) aynı storage’ı paylaşabilir.

- **Tensor**: Çok boyutlu sayısal dizi; shape, strides, dtype ve device ile tanımlanır. Çerçevenin temel veri yapısıdır.

- **View**: Mevcut bir tensor’ın aynı belleği farklı shape/strides ile göstermesi. Kopya oluşturmaz (reshape, slice vb.).

- **Variable**: Autograd için tensor sarmalayıcı; gradyan ve “grad_fn” (backward bağlantısı) tutar. Sadece gradyan gereken hesaplamalarda kullanılır.

---

*Bu belge CPPLamb projesinin uygulama planıdır. Güncellemeler `docs/` altında versiyon notları ile takip edilebilir.*
