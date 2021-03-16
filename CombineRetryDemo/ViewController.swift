import UIKit
import Combine

class ViewController: UIViewController {

    var cancellables = Set<AnyCancellable>()
    
    enum FruitError: Error {
        case bad
    }
    var fruit = "apple"
    
    func getFruit() -> String {
        fruit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        Just(getFruit)
            .print("start")
            .map{$0()}
            .setFailureType(to: FruitError.self)
            .print("test")
            .flatMap { value -> AnyPublisher<String, FruitError> in
                print("in flat map \(value)")
                if value == "apple" {
                    self.fruit = "pineapple"
                    return Fail(error: FruitError.bad).eraseToAnyPublisher()
                }
                return Just("banana").setFailureType(to: FruitError.self).eraseToAnyPublisher()
        }
        .retry(1)
        .sink(receiveCompletion: { print($0) }, receiveValue: {print($0)})
        .store(in: &cancellables)
    }
}

