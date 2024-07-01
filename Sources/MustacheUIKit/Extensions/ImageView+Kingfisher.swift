
import Foundation
import Kingfisher

public extension UIImageView {
    
    func load(string: String?, placeholder: UIImage? = nil, cropAlpha: Bool = true) {
        guard let string = string, let url = URL(string: string) else { return }
        self.load(url: url, placeholder: placeholder, cropAlpha: cropAlpha)
    }
    
    func load(url: URL, placeholder: UIImage? = nil, cropAlpha: Bool = true) {
        
        var options: KingfisherOptionsInfo?
        if cropAlpha {
            let processor = CropAlphaProcessor()
            options = [.processor(processor)]
        }
        self.kf.setImage(with: url, placeholder: placeholder, options: options, completionHandler: { [weak self] (result: Result<RetrieveImageResult, KingfisherError>) in
            switch result {
                case .success(let result):
                    self?.image = result.image
                case .failure:
                    self?.image = placeholder
            }
        })
    }
    
}
