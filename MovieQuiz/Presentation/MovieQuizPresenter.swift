import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    let questionsAmount: Int = 10
    
    private var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    
    weak private var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        
        self.viewController?.showLoadingIndicator()
        loadQuestions()
    }
    
    func loadQuestions() {
        questionFactory?.loadData()
    }
    
    func restartGame() {
        correctAnswers = 0
        currentQuestionIndex = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func countAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        countAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.enableButtons(set: false)
        viewController?.enableImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                return
            }
            self.viewController?.disableImageBorder()
            self.viewController?.enableButtons(set: true)
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: makeResultsMessage(),
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func makeResultsMessage() -> String {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        let errorMessage = "Невозможно получить результат"
        guard let gamesCount = statisticService?.gamesCount else { return errorMessage }
        guard let bestGame = statisticService?.bestGame else { return errorMessage }
        guard let totalAccuracy = statisticService?.totalAccuracy else { return errorMessage }
        
        let resultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let countLine = "Количество сыгранных квизов: \(gamesCount)"
        let bestLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageLine = "Средняя точность: \(String(format: "%.2f", totalAccuracy))%"
        
        return [resultLine, countLine, bestLine, averageLine].joined(separator: "\n")
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
}
