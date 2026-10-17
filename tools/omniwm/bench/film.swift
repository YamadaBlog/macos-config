import Foundation
import ScreenCaptureKit
import CoreMedia
import QuartzCore
// film <seconds> : capture main display at 120 fps (1/2 scale); per frame print "t xRed xGreen xBlue" = left edges
// of solid red/green/blue windows on the middle row (-1 if absent). t = frame presentation time (CACurrentMediaTime base).
final class Out: NSObject, SCStreamOutput {
    var lines: [String] = []
    func stream(_ s: SCStream, didOutputSampleBuffer sb: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen, let px = CMSampleBufferGetImageBuffer(sb) else { return }
        guard let att = CMSampleBufferGetSampleAttachmentsArray(sb, createIfNecessary: false) as? [[SCStreamFrameInfo: Any]],
              let st = att.first?[.status] as? Int else { return }
        let pts = CMSampleBufferGetPresentationTimeStamp(sb).seconds
        // An idle frame = the display did not change at this refresh (a real repeated frame, not a capture loss).
        if st == SCFrameStatus.idle.rawValue { lines.append(String(format: "%.6f idle", pts)); return }
        guard st == SCFrameStatus.complete.rawValue else { return }
        CVPixelBufferLockBaseAddress(px, .readOnly); defer { CVPixelBufferUnlockBaseAddress(px, .readOnly) }
        let w = CVPixelBufferGetWidth(px), h = CVPixelBufferGetHeight(px), bpr = CVPixelBufferGetBytesPerRow(px)
        let base = CVPixelBufferGetBaseAddress(px)!.assumingMemoryBound(to: UInt8.self)
        let row = base + bpr * (h / 2)
        var first = [-1, -1, -1]
        for x in 0..<w {
            let b = Int(row[x*4]), g = Int(row[x*4+1]), r = Int(row[x*4+2])
            // Wide thresholds: the display is P3, so sRGB #00ff00 arrives as about (117, 251, 76).
            let k = r > 180 && g < 110 && b < 110 ? 0 : (g > 180 && r < 170 && b < 140 ? 1 : (b > 180 && r < 110 && g < 130 ? 2 : -1))
            if k >= 0 && first[k] < 0 { first[k] = x }
        }
        let clock = base + bpr * (h - 312) + (w - 18) * 4   // display-clock square (right edge, 300 pt up): blue channel
        lines.append(String(format: "%.6f %d %d %d %d", pts, first[0], first[1], first[2], Int(clock[0])))
    }
}
let dur = Double(CommandLine.arguments[1])!
let sem = DispatchSemaphore(value: 0)
let out = Out()
Task {
    let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
    let display = content.displays.first!
    let cfg = SCStreamConfiguration()
    cfg.width = display.width; cfg.height = display.height   // points; pixel coords = 1 per point
    cfg.minimumFrameInterval = CMTime(value: 1, timescale: 120)
    cfg.queueDepth = 8; cfg.pixelFormat = kCVPixelFormatType_32BGRA; cfg.showsCursor = false
    let stream = SCStream(filter: SCContentFilter(display: display, excludingWindows: []), configuration: cfg, delegate: nil)
    try stream.addStreamOutput(out, type: .screen, sampleHandlerQueue: DispatchQueue(label: "f"))
    try await stream.startCapture()
    FileHandle.standardError.write("started\n".data(using: .utf8)!)
    try await Task.sleep(nanoseconds: UInt64(dur * 1e9))
    try await stream.stopCapture()
    sem.signal()
}
sem.wait()
print(out.lines.joined(separator: "\n"))
