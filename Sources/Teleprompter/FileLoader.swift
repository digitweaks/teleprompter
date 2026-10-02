import Foundation
import AppKit

@MainActor
enum FileLoader {

    /// Reads a user-selected file and writes its text content into the view model.
    /// Supports UTF-8 text files and RTF documents.
    /// Returns a localised error string on failure so the caller can surface it
    /// as an alert — errors are NEVER written into rawText.
    @discardableResult
    static func load(url: URL, into viewModel: TeleprompterViewModel) -> String? {

        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let text: String

            if url.pathExtension.lowercased() == "rtf" {
                let data = try Data(contentsOf: url)

                let attributedString = try NSAttributedString(
                    data: data,
                    options: [
                        .documentType: NSAttributedString.DocumentType.rtf
                    ],
                    documentAttributes: nil
                )

                text = attributedString.string
            } else {
                text = try String(contentsOf: url, encoding: .utf8)
            }

            viewModel.rawText        = text
            viewModel.isLoaded       = true
            viewModel.loadedFileName = url.lastPathComponent
            viewModel.scrollOffset   = 0
            viewModel.isPlaying      = false

            return nil   // success

        } catch {
            return error.localizedDescription
        }
    }
}
