import Combine

/// retry no leaks
/// is a replacement for Apple Combine retry that leaks memory
/// adoped from cx-org/CombineX - Open-source implementation of Apple's Combine for processing values over time.
/// see  https://raw.githubusercontent.com/cx-org/CombineX/43037a7ae90e8aa022e478706b854d9a7cea5a70/Sources/CombineX/Publishers/B/Combined/Retry.swift

extension Publisher {

    /// Attempts to recreate a failed subscription with the upstream publisher using a specified number of attempts to establish the connection.
    ///
    /// After exceeding the specified number of retries, the publisher passes the failure to the downstream receiver.
    /// - Parameter retries: The number of times to attempt to recreate the subscription.
    /// - Returns: A publisher that attempts to recreate its subscription to a failed upstream publisher.
    public func retryNoLeaks(_ retries: Int) -> Publishers.RetryNoLeaks<Self> {
        return .init(upstream: self, retries: retries)
    }
}

extension Publishers.RetryNoLeaks: Equatable where Upstream: Equatable {}

extension Publishers {

    /// A publisher that attempts to recreate its subscription to a failed upstream publisher.
    public struct RetryNoLeaks<Upstream: Publisher>: Publisher {

        public typealias Output = Upstream.Output

        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The maximum number of retry attempts to perform.
        ///
        /// If `nil`, this publisher attempts to reconnect with the upstream publisher an unlimited number of times.
        public let retries: Int?

        /// Creates a publisher that attempts to recreate its subscription to a failed upstream publisher.
        ///
        /// - Parameters:
        ///   - upstream: The publisher from which this publisher receives its elements.
        ///   - retries: The maximum number of retry attempts to perform. If `nil`, this publisher attempts to reconnect with the upstream publisher an unlimited number of times.
        public init(upstream: Upstream, retries: Int?) {
            self.upstream = upstream
            self.retries = retries
        }

        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {

            guard let retries = self.retries else {
                self.upstream
                    .catch { _ in self.upstream }
                    .subscribe(subscriber)
                return
            }

            self.upstream
                .catch { e -> AnyPublisher<Output, Failure> in
                    if retries == 0 {
                        return Fail<Output, Failure>(error: e).eraseToAnyPublisher()
                    } else {
                        return self.upstream.retryNoLeaks(retries - 1).eraseToAnyPublisher()
                    }
                }
                .subscribe(subscriber)
        }
    }
}
