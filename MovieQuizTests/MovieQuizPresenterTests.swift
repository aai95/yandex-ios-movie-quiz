import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func enableButtons(set value: Bool) {}
    
    func showImageBorder(isCorrectAnswer: Bool) {}
    func hideImageBorder() {}
    
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    
    func show(quiz step: QuizStepViewModel) {}
    func show(quiz result: QuizResultsViewModel) {}
    
    func showNetworkError(message: String) {}
}

final class MovieQuizPresenterTests: XCTestCase {
    
    func testConvertModel() throws {
        // Given
        let presenter = MovieQuizPresenter(viewController: MovieQuizViewControllerMock())
        let question = QuizQuestion(image: Data(), text: "Question", correctAnswer: true)
        
        // When
        let viewModel = presenter.convert(model: question)
        
        // Then
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
