# evaluate-output

Bu komut çalıştığında:

## 1. Değerlendirme

- **output-evaluator** becerisini kullan: kullanıcının çıktısı veya doğrulama sonucu, **o anki adımın** beklentisiyle karşılaştırılsın.

## 2. Sonuça göre davranış

| Durum | Ne yap |
|--------|--------|
| **Doğru** | Kısaca onayla; ne başarıldığını bir cümleyle söyle; ilerle veya sıradaki adımı ver. Uzun özet yok. |
| **Yanlış veya eksik** | Sorunu ve neden önemli olduğunu söyle; **tek net** düzeltme iste. Düzeltilene kadar **sonraki plan adımını verme**. |

## 3. Stil

- Yanıt kısa kalsın; mümkünse tur başına **bir ana sorun**.
- Kullanıcı düzeltilmiş çıktıyı paylaşana kadar ileri adım bekle.
