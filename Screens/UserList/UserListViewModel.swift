import Foundation
import Combine
import CombineStorable

final class UserListViewModel: NSObject, Storable, ObservableObject {
    
    let input: Input
    let output: Output
    
    init(
        input: Input = .init(),
        output: Output
    ) {
        self.input = input
        self.output = output
        super.init()
        bind(input: input, output: output)
    }
}

extension UserListViewModel {
    
    final class Input {
        let didTapSns: PassthroughSubject<User?, Never>
        
        init(didTapSns: PassthroughSubject<User?, Never> = .init()) {
            self.didTapSns = didTapSns
        }
    }
    
    final class Output {
        let models: [User]
        let openSns: PassthroughSubject<URL, Never>
        var title: String {
            models.first is StaffUser ? "Staff" : "Speaker"
        }
        
        init(
            models: [User], 
            openSns: PassthroughSubject<URL, Never> = .init()
        ) {
            self.models = models
            self.openSns = openSns
        }
    }
}

extension UserListViewModel {
    
    func bind(input: Input, output: Output) {
        input
            .didTapSns
            .compactMap { $0?.twAccount }
            .compactMap { URL(string: "\(Constants.twitterBaseUrl)/\($0)") }
            .sink { output.openSns.send($0) }
            .store(in: &cancellables)
    }
}
