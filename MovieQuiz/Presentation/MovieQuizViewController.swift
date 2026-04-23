import UIKit //мой код//

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Nested Types
    
    private enum Constants {
        static let resultsTitle = "Раунд окончен!"
        static let resultsButtonText = "Сыграть ещё раз"
        static let errorTitle = "Ошибка"
        static let errorButtonText = "Попробовать еще раз"
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    private var correctAnswers: Int = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter = ResultAlertPresenter()
    
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        
        showLoadingIndicator()
        questionFactory?.loadData()
        
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Private Methods
    
    private func configureUI() {
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.image = UIImage(data: step.image) ?? UIImage()
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        setButtonsEnabled(true)
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self else { return }
            
            self.presenter.resetQuestionIndex()
            correctAnswers = 0
            questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        setButtonsEnabled(false)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            showResults()
            return
        }
        
        presenter.switchToNextQuestion()
        showNextQuestion()
    }
    
    private func showNextQuestion() {
        questionFactory?.requestNextQuestion()
    }
    
    private func showResults() {
        statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let text = """
            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
        
        let viewModel = QuizResultsViewModel(
            title: Constants.resultsTitle,
            text: text,
            buttonText: Constants.resultsButtonText
        )
        
        show(quiz: viewModel)
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: Constants.errorTitle,
            message: message,
            buttonText: Constants.errorButtonText) { [weak self] in
                guard let self else { return }
                
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                showLoadingIndicator()
                questionFactory?.loadData()
            }
        
        alertPresenter.show(in: self, model: model)
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func handleAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        let isCorrect = isYes == currentQuestion.correctAnswer
        showAnswerResult(isCorrect: isCorrect)
    }
    
    // MARK: - IBActions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        handleAnswer(isYes: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(isYes: true)
    }
}
