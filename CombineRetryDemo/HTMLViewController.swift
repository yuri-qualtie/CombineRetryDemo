import UIKit
import Combine

struct SampleError: Error {
}

class HTMLViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CurrentValueSubject<SampleError, Never>(SampleError())
            .flatMap { error -> Fail<Void, SampleError> in
                Fail(error: error)
            }
            .sink(
                receiveCompletion: { print("completed \($0)") },
                receiveValue: { print("value \($0)") })
            .store(in: &cancellables)
    }
    
    deinit {
        print("de inited")
    }
}
