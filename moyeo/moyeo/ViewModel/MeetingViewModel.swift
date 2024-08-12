import SwiftUI
import Combine

struct Meeting: Decodable {
    let name: String
    let fixedDate: String
    let fixwdTime: String
    let fixedPlace: String
    let numverOfPeple: String
}

class MeetingViewModel: ObservableObject {
    @Published var meeting = Meeting(name: "", fixedDate: "", fixwdTime: "", fixedPlace: "", numverOfPeple: "")
    var cancellables = Set<AnyCancellable>()

    func fetchMeeting() {
        
        let url = URL(string: "URL 집어넣기")!
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Meeting.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] meeting in
                self?.meeting = meeting
            })
            .store(in: &cancellables)
    }
}
