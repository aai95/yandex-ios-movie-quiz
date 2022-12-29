import UIKit

struct AlertPresenter {
    
    weak private var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate?) {
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
        alert.view.accessibilityIdentifier = "Game results"
        
        delegate?.didPresentAlert(alert)
    }
}
