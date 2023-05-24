import SwiftUI
import PhotosUI

struct ContentView: View {
    // Değişkenlerin tanımlanması
    @State private var images: [UIImage] = []
    @State private var isPlaying = false
    @State private var currentImageIndex = 0
    @State private var showImagePicker = false
    @State private var transitionDuration: Double = 0.14
    
    // Yeni değişken: Seçilen resim sayısı
    @State private var selectedImageCount = 0

    var body: some View {
        VStack {
            
            // Logo
            Image("cover") // Projenize eklediğiniz logo resim dosyasının adını kullanın
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            
            Spacer()

            // Görüntü alanı
            if images.isEmpty {
                Text("Resim yok")
                    .foregroundColor(.gray)
            } else {
                Image(uiImage: images[currentImageIndex])
                    .resizable()
                    .scaledToFit()
            }

            // Butonlar
            HStack {
                // Resim Seç butonu
                Button(action: {
                    showImagePicker.toggle()
                }, label: {
                    Text("Resim Seç")
                })

                // Oynat/Dur butonu
                Button(action: {
                    isPlaying.toggle()
                }, label: {
                    Text(isPlaying ? "Dur" : "Oynat")
                })
            }

            // Geçiş süresi ayarı ve slider
            VStack {
                Text("Geçiş Süresi: \(transitionDuration, specifier: "%.2f") saniye")
                Slider(value: $transitionDuration, in: 0.01...0.25)
            }
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ZStack {
                PHPickerWrapper(images: $images, selectedImageCount: $selectedImageCount)
            }
        }
        .onReceive(Timer.publish(every: transitionDuration, on: .main, in: .common).autoconnect()) { _ in
            guard isPlaying, !images.isEmpty else { return }
            currentImageIndex = (currentImageIndex + 1) % images.count
        }
    }
}

// PHPickerWrapper tanımı
struct PHPickerWrapper: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Binding var selectedImageCount: Int // Yeni bağlama: Seçilen resim sayısı
    @Environment(\.presentationMode) private var presentationMode
    
    // PHPickerViewController oluşturma
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 5 //  H A T A
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    // Görünüm güncellemesi (bu örnekte yapılandırma yapılmıyor)
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    // Koordinatör oluşturma
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Koordinatör sınıfı
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: PHPickerWrapper // Ana PHPickerWrapper nesnesine referans
        
        // Koordinatörü başlatırken ana nesneyi atayın
        init(_ parent: PHPickerWrapper) {
            self.parent = parent
        }
        
        // Seçim işlemi sonrasında resimleri al
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Sonuçlardan resimleri al
            for result in results {
                let itemProvider = result.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.images.append(image)
                                self.parent.selectedImageCount += 1
                            }
                        }
                    }
                }
            }
            // Seçim işlemi tamamlandığında görünümü kapat
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
