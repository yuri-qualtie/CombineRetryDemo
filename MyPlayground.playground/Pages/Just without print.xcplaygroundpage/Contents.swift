import Combine
var cancellables = Set<AnyCancellable>()

enum FruitError: Error {
    case bad
}
var fruit = "apple"

func getFruit() -> String {
    fruit
}


Just(getFruit)
    .map{$0()}
    .flatMap { value -> AnyPublisher<String, FruitError> in
        print("in flat map \(value)")
        if value == "apple" {
            fruit = "pineapple"
            return Fail(error: FruitError.bad).eraseToAnyPublisher()
        }
        return Just("banana").setFailureType(to: FruitError.self).eraseToAnyPublisher()
    }
    .retry(1)
    .sink(receiveCompletion: { print($0) }, receiveValue: {print($0)})
    .store(in: &cancellables)
