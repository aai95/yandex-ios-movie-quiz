import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
    
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    private var presenter: MovieQuizPresenter!
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.masksToBounds = true
        
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    func didPresentAlert(_ alertToPresent: UIAlertController) {
        present(alertToPresent, animated: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
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
                self.presenter?.loadQuestions()
                self.showLoadingIndicator()
            })
        
        alertPresenter?.presentAlert(model: alertModel)
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
                self.presenter.restartGame()
            })
        
        alertPresenter?.presentAlert(model: alertModel)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                return
            }
            self.imageView.layer.borderWidth = 0
            
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
            
            self.presenter.showNextQuestionOrResults()
        }
    }
}
