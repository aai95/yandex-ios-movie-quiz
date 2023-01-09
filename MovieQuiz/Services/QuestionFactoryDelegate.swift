import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
    func didReceiveNextQuestion(question: QuizQuestion?)
}
