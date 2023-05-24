import UIKit
import PhotosUI


class ViewController: UIViewController, PHPickerViewControllerDelegate {
    
    var selectedImages: [UIImage] = []
    var isAnimateActivated = false // Görüntü geçiş animasyonunun etkinleştirilip etkinleştirilmediğini belirten bir bayrak
    var currentIndex: Int = 0 // Şu anki görüntü dizinini takip etmek için kullanılır
    var isIncreament: Bool = true
    var timer: Timer? // Otomatik geçiş için kullanılacak zamanlayıcı
    var durationTime = 0.14 // Görüntü geçiş süresi
    var addImageIndex: Int = 0
    
    var selectedImageNames: [String] = [] // Seçilen fotoğraf isimlerinin dizisi
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //        imageView.image = UIImage(named: "test.jpg")
        return imageView
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Play", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside) // Action metodunu belirleme
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside) // Action metodunu belirleme
        return button
    }()
    
    private let slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged) // Slider fonksiyonunu belirleme
        return slider
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Duration Time: 0"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        view.addSubview(playButton)
        view.addSubview(slider)
        view.addSubview(label)
        view.addSubview(addButton)
        
        addConstraints()
    }
    
    private func addConstraints() {
        let constraints = [
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -16),
            
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -16),
            
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            slider.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -16)
            
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    
    @objc func playButtonTapped(_ sender: UIButton) {
        print("Tapped Play")
        
        if isAnimateActivated == false {
            sender.setTitle("Play", for: .normal)
            isAnimateActivated = true
            currentIndex = 0 // İlk görüntüyü göstermek için dizini sıfırla
            
            if selectedImages.count > 0 {
                timer = Timer.scheduledTimer(timeInterval: durationTime, target: self, selector: #selector(showNextImage), userInfo: nil, repeats: true)
            }
        } else if isAnimateActivated == true {
            sender.setTitle(isAnimateActivated ? "Stop" : "Play", for: .normal)
            isAnimateActivated.toggle()
            
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc func addButtonTapped(_ sender: UIButton) {
        print("Tapped Add")
        
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selection = .ordered
        configuration.selectionLimit = 4 // En fazla 4 fotoğraf seçme limiti
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        
        
        let minValue: Float = 0.01
        let maxValue: Float = 0.30
        
        let valueRange = maxValue - minValue
        let scaledValue = minValue + (valueRange * sender.value)
        
        print("Scaled Value: \(scaledValue)")
        durationTime = Double(scaledValue*4)
        let scaledValueString = String(format: "%.2f", scaledValue)
        label.text = scaledValueString + " s"
        
        timer?.invalidate()
        if isAnimateActivated {
            timer = Timer.scheduledTimer(timeInterval: durationTime, target: self, selector: #selector(showNextImage), userInfo: nil, repeats: true)
        }
    }
    
    
    @objc func addPhotoButtonTapped(_ sender: UIBarButtonItem) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 4 // En fazla 4 fotoğraf seçme limiti
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @objc func showNextImage() {
        
        
        print("currentIndex \(currentIndex)")
        
        if currentIndex == (self.selectedImages.count - 1)
        {
            isIncreament = false
        }
        else if currentIndex == 0
        {
            isIncreament = true
        }
        
        
        if isIncreament == true
        {
            currentIndex += 1
        }
        else
        {
            currentIndex -= 1
        }
        self.imageView.image = self.selectedImages[currentIndex]
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    
                    if let image = image as? UIImage {
                        
                        self?.selectedImages.append(image)
                        self?.selectedImageNames.append(result.itemProvider.suggestedName ?? "")
                        
                        print(result.itemProvider.suggestedName ?? "nil")
                    
                    }
                    
                }
            }
        }
    }
}
