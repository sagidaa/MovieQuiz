import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    // MARK: - Counters
    var showStepCalled = 0
    var showResultCalled = 0
    var highlightImageBorderCalled = 0
    var showLoadingCalled = 0
    var hideLoadingCalled = 0
    var showErrorCalled = 0
    
    func show(quiz step: QuizStepViewModel) {
        showStepCalled += 1
    }
    
    func show(quiz result: QuizResultsViewModel) {
        showResultCalled += 1
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        highlightImageBorderCalled += 1
    }
    
    func showLoadingIndicator() {
        showLoadingCalled += 1
    }
    
    func hideLoadingIndicator() {
        hideLoadingCalled += 1
    }
    
    func showNetworkError(message: String) {
        showErrorCalled += 1
    }
}
