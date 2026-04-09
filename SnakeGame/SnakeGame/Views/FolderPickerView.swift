import SwiftUI
import UniformTypeIdentifiers

struct FolderPickerView: UIViewControllerRepresentable {
    let onFolderSelected: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onFolderSelected: onFolderSelected)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onFolderSelected: (URL) -> Void

        init(onFolderSelected: @escaping (URL) -> Void) {
            self.onFolderSelected = onFolderSelected
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onFolderSelected(url)
        }
    }
}
