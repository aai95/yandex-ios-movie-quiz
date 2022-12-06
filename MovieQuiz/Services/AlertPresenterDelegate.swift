import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didPresentAlert(_ alertToPresent: UIAlertController)
}
