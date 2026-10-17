import Foundation
import CoreGraphics
import QuartzCore
// poll <seconds> <wid>...  : WindowServer bounds every 2 ms -> "t wid x" lines (t = CACurrentMediaTime)
let dur = Double(CommandLine.arguments[1])!
let wids = CommandLine.arguments.dropFirst(2).map { CGWindowID($0)! }
let end = CACurrentMediaTime() + dur
var last: [CGWindowID: CGFloat] = [:]
while CACurrentMediaTime() < end {
    let t = CACurrentMediaTime()
    for w in wids {
        guard let l = CGWindowListCopyWindowInfo([.optionIncludingWindow], w) as? [[String: Any]], let d = l.first,
              let b = CGRect(dictionaryRepresentation: d[kCGWindowBounds as String] as! CFDictionary) else { continue }
        if last[w] != b.minX { print(String(format: "%.6f %u %.1f", t, w, b.minX)); last[w] = b.minX }
    }
    usleep(2000)
}
