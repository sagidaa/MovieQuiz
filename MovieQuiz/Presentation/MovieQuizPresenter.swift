import Foundation

final class MovieQuizPresenter {

    // MARK: - Nested Types

    private enum Constants {
        static let resultsTitle = "Раунд окончен!"
        static let resultsButtonText = "Сыграть ещё раз"
        static let errorTitle = "Ошибка"
        static let errorButtonText = "Попробовать еще раз"
    }

    // MARK: - Properties

    weak var viewController: MovieQuizViewController?
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?

    var correctAnswers: Int = 0
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0

    // MARK: - Methods
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    private func handleAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        let isCorrect = isYes == currentQuestion.correctAnswer
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }
    
    func yesButtonClicked() {
        handleAnswer(isYes: true)
    }

    func noButtonClicked() {
        handleAnswer(isYes: false)
    }

    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            
        }
    }

    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            showResults()
            return
        }

        self.switchToNextQuestion()
        showNextQuestion()
    }

    private func showNextQuestion() {
        questionFactory?.requestNextQuestion()
    }

    private func showResults() {
        statisticService.store(correct: correctAnswers, total: questionsAmount)

        let bestGame = statisticService.bestGame

        let text = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """

        let viewModel = QuizResultsViewModel(
            title: Constants.resultsTitle,
            text: text,
            buttonText: Constants.resultsButtonText
        )

            viewController?.show(quiz: viewModel)
    }
}
