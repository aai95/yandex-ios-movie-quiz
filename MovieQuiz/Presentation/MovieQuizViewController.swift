import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
    
    private var presenter: MovieQuizPresenter?
    private var alertPresenter: AlertPresenter?
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.masksToBounds = true
        
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    
    // MARK: - AlertPresenterDelegate
    
    func didPresentAlert(_ alertToPresent: UIAlertController) {
        present(alertToPresent, animated: true)
    }
    
    // MARK: - Internal functions
    
    func enableButtons(set value: Bool) {
        noButton.isEnabled = value
        yesButton.isEnabled = value
    }
    
    func showImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func hideImageBorder() {
        imageView.layer.borderWidth = 0
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else {
                    return
                }
                self.presenter?.restartGame()
            })
        
        alertPresenter?.presentAlert(model: alertModel)
    }
    
    func showNetworkError(message: String) {
        print("Fail to load data from server: \(message)")
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Что-то пошло не так",
            message: "Невозможно загрузить данные",
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                guard let self = self else {
                    return
                }
                self.showLoadingIndicator()
                self.presenter?.loadQuestions()
            })
        
        alertPresenter?.presentAlert(model: alertModel)
    }
}
