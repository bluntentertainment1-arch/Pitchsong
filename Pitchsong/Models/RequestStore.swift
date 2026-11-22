import SwiftUI

enum RequestStatus: String, Codable, CaseIterable, Identifiable {
    case requested, paid, inProgress, completed

    var id: String { rawValue }

    var label: String {
        switch self {
        case .requested: return "Requested"
        case .paid: return "Paid"
        case .inProgress: return "In progress"
        case .completed: return "Completed"
        }
    }

    var color: Color {
        switch self {
        case .requested: return Theme.violet2Text
        case .paid: return Theme.cyanText
        case .inProgress: return Theme.amberText
        case .completed: return Theme.successText
        }
    }
}

struct SongRequest: Identifiable, Codable, Equatable {
    var id = UUID()
    var artistName: String
    var songTitle: String
    var songLink: String
    var genre: String
    var packageID: String
    var packageName: String
    var categoryTitle: String
    var createdAt = Date()
    var status: RequestStatus = .requested
}

/// Keeps the artist's order history on this device only (no server).
final class RequestStore: ObservableObject {
    @Published private(set) var requests: [SongRequest] = []

    private let key = "pitchsong.requests.v1"

    init() {
        load()
    }

    func add(_ request: SongRequest) {
        requests.insert(request, at: 0)
        save()
    }

    func setStatus(_ status: RequestStatus, for request: SongRequest) {
        guard let index = requests.firstIndex(where: { $0.id == request.id }) else { return }
        requests[index].status = status
        save()
    }

    func delete(_ request: SongRequest) {
        requests.removeAll { $0.id == request.id }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        if let decoded = try? JSONDecoder().decode([SongRequest].self, from: data) {
            requests = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(requests) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
