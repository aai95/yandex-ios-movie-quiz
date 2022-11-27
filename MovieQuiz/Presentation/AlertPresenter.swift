import Foundation
import UIKit

struct AlertPresenter {
    
    weak private var delegate: UIViewController?
    
    init(delegate: UIViewController?) {
        self.delegate = delegate
    }
    
    func presentAlert(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default,
            handler: { _ in
                model.completion()
            })
        
        alert.addAction(action)
        delegate?.present(alert, animated: true)
    }
}
