import UIKit
import Combine

class HTMLViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        URLSession.shared
            .dataTaskPublisher(for: URL(string: "https://www.apple.com/")!)
            .tryCatch { _ in
                URLSession.shared
                    .dataTaskPublisher(for: URL(string: "https://www.example.com/")!)
            }
            .retryNoLeaks(1)
            .map {
                String(decoding: $0.data, as: UTF8.self)
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
