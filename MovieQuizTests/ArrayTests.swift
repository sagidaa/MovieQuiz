import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        //Given/Дано — это состояние, когда мы получаем начальные данные, с которыми будем работать.
        let array = [1, 1, 2, 3, 5]
        
        //When/Когда — действие, которое мы собираемся тестировать, когда оно уже произошло.
        let value = array[safe: 2]
        
        //Then/Тогда — проверка действия, которое произошло.
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        //Given/Дано — это состояние, когда мы получаем начальные данные, с которыми будем работать.
        let array = [1, 1, 2, 3, 5]
        
        //When/Когда — действие, которое мы собираемся тестировать, когда оно уже произошло.
        let value = array[safe: 20]
        
        //Then/Тогда — проверка действия, которое произошло.
        XCTAssertNil(value)
    }
}

