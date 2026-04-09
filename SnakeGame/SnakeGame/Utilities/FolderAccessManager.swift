import Foundation
import SwiftUI

@MainActor
class FolderAccessManager: ObservableObject {
    static let shared = FolderAccessManager()

    @Published var hasAccess: Bool = false
    @Published var folderName: String?
    @Published var showPicker: Bool = false

    private let bookmarkKey = "savedFolderBookmark"

    init() {
        restoreAccess()
    }

    func requestAccess() {
        showPicker = true
    }

    func grantAccess(to url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let bookmarkData = try url.bookmarkData(
                options: .minimalBookmark,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(bookmarkData, forKey: bookmarkKey)
            hasAccess = true
            folderName = url.lastPathComponent
        } catch {
            hasAccess = false
            folderName = nil
        }
    }

    func revokeAccess() {
        UserDefaults.standard.removeObject(forKey: bookmarkKey)
        hasAccess = false
        folderName = nil
    }

    func saveGameData(score: Int, highScore: Int) -> Bool {
        guard let url = resolveBookmark() else { return false }
        guard url.startAccessingSecurityScopedResource() else { return false }
        defer { url.stopAccessingSecurityScopedResource() }

        let data: [String: Any] = [
            "score": score,
            "highScore": highScore,
            "date": ISO8601DateFormatter().string(from: Date())
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            let fileURL = url.appendingPathComponent("snake_scores.json")
            try jsonData.write(to: fileURL)
            return true
        } catch {
            return false
        }
    }

    private func restoreAccess() {
        guard let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) else {
            hasAccess = false
            return
        }

        var isStale = false
        do {
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: [],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            if isStale {
                grantAccess(to: url)
            } else {
                hasAccess = true
                folderName = url.lastPathComponent
            }
        } catch {
            hasAccess = false
            folderName = nil
        }
    }

    private func resolveBookmark() -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) else {
            return nil
        }

        var isStale = false
        return try? URL(
            resolvingBookmarkData: bookmarkData,
            options: [],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
    }
}
