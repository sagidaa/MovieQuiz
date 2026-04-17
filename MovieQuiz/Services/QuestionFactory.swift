import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private var movies: [MostPopularMovie] = []
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
                   
            let question = makeQuestion(movie: movie, imageData: imageData)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    private func makeQuestion(movie: MostPopularMovie, imageData: Data) -> QuizQuestion {
        let rating = Float(movie.rating) ?? 0
        let (threshold, isMoreThan) = generateComparison()
        
        let comparison = isMoreThan ? "больше" : "меньше"
        let text = "Рейтинг этого фильма \(comparison) чем \(Int(threshold))?"
        let correctAnswer = isMoreThan ? rating > threshold : rating < threshold
        
        return QuizQuestion(image: imageData,
                            text: text,
                            correctAnswer: correctAnswer)
    }

    private func generateComparison() -> (threshold: Float, isMoreThan: Bool) {
        let threshold = Float(Int.random(in: 5...9))
        let isMoreThan = Bool.random()
        return (threshold, isMoreThan)
    }
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
}
