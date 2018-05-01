import Foundation

public class HtmlGenerator {
  public init() {}

  public func generate(report: Report, plistPath: URL, outDir: URL) throws {
    // Create out dir
    if !FileManager.default.fileExists(atPath: outDir.path) {
      FileManager.default
      try FileManager.default.createDirectory(atPath: outDir.path,
                                              withIntermediateDirectories: true,
                                              attributes: nil)
    }

    let reportSummary = ReportSummary(report: report)
    

    let jsonEncoder = JSONEncoder()

    let html = html_index(
      reportData: String(data: try! jsonEncoder.encode(report), encoding: .utf8)!,
      reportSummaryData: String(data: try! jsonEncoder.encode(reportSummary), encoding: .utf8)!
    )

    let htmlUrl = outDir.appendingPathComponent("index.html")

    try html.write(to: htmlUrl, atomically: true, encoding: .utf8)

    try copyAttachments(report: report, plistPath: plistPath, outDir: outDir)
    try copyLogo(outDir: outDir)
  }

  func copyAttachments(report: Report, plistPath: URL, outDir: URL) throws {
    
    let plistDirUrl = plistPath.deletingLastPathComponent()
    let files = attachmentFiles(report: report)
    
    let attachmentsDir = plistDirUrl.appendingPathComponent("Attachments")
    let outAttachmentsDir = outDir.appendingPathComponent("Attachments")

    if !FileManager.default.fileExists(atPath: outAttachmentsDir.path) {
      try FileManager.default.createDirectory(atPath: outAttachmentsDir.path,
                                              withIntermediateDirectories: true,
                                              attributes: nil)
    }


    files.forEach { file in
      do {
        try FileManager.default.copyItem(at: attachmentsDir.appendingPathComponent(file),
                                         to: outAttachmentsDir.appendingPathComponent(file))
      } catch {
        
      }
    }
  }

  func copyLogo(outDir: URL) throws {
    let outUrl = outDir.appendingPathComponent("XcodeTestReporter.svg")

    try svg_XcodeTestReporter.write(to: outUrl, atomically: true, encoding: .utf8)
  }

  func attachmentFiles(report: Report) -> [String] {
    return report.TestableSummaries.flatMap { summary in
      attachmentFiles(tests: summary.Tests)
    }
  }

  func attachmentFiles(tests: [Test]?) -> [String] {

    guard let tests = tests else { return [] }
    return tests.flatMap { attachmentFiles(test: $0) }
  }

  func attachmentFiles(test: Test) -> [String] {
    var files: [String] = []
      
    let activitySummaries = test.ActivitySummaries ?? []

    activitySummaries.forEach { activitySummary in
      guard let attachments = activitySummary.Attachments else { return }

      attachments.forEach { attachment in
        files.append(attachment.Filename)
      }
    }

    files.append(contentsOf: attachmentFiles(tests: test.Subtests))

    return files
  }
}
