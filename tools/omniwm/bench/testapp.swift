import AppKit
import WebKit
// WebKit test bench: N windows with WKWebView (same engine as Safari). Logs occlusion/key changes with timestamps.
let urls = CommandLine.arguments.dropFirst().filter { $0.hasPrefix("http") || $0.hasPrefix("color:") }
let logPath = ProcessInfo.processInfo.environment["WKTEST_LOG"] ?? "/tmp/wktest.log"
FileManager.default.createFile(atPath: logPath, contents: nil)
let log = FileHandle(forWritingAtPath: logPath)!
func note(_ s: String) { log.write("\(CACurrentMediaTime()) \(s)\n".data(using: .utf8)!) }
final class Delegate: NSObject, NSApplicationDelegate {
    var windows: [NSWindow] = []
    var link: CADisplayLink?
    var moveEnd: Double = 0
    var clockPanel: NSPanel?
    var clockLink: CADisplayLink?
    var clockCount = 0
    @objc func tickClock(_ l: CADisplayLink) {
        clockCount = (clockCount + 1) % 256
        clockPanel?.contentView?.layer?.backgroundColor = CGColor(srgbRed: 1, green: 1, blue: CGFloat(clockCount) / 255, alpha: 1)
    }
    @objc func step(_ l: CADisplayLink) {
        guard let w = windows.first else { return }
        if CACurrentMediaTime() > moveEnd { l.invalidate(); return }
        let o = w.frame.origin
        w.setFrameOrigin(NSPoint(x: o.x - 9, y: o.y))
        note(String(format: "selfmove %.6f %.0f", CACurrentMediaTime(), o.x - 9))
    }
    func applicationDidFinishLaunching(_ n: Notification) {
        note("timeoutOverride=\(UserDefaults.standard.object(forKey: "WebKitOverrideActivityStateUpdateTimeout") ?? "default")")
        for (i, u) in urls.enumerated() {
            let selfMove = ProcessInfo.processInfo.environment["WKTEST_SELFMOVE"] == "1"
            let w: NSWindow = selfMove
                ? NSPanel(contentRect: NSRect(x: 1400, y: 300, width: 500, height: 500),
                          styleMask: [.titled, .utilityWindow], backing: .buffered, defer: false)
                : NSWindow(contentRect: NSRect(x: 100 + i * 40, y: 100, width: 900, height: 900),
                           styleMask: [.titled, .closable, .resizable, .miniaturizable], backing: .buffered, defer: false)
            w.title = "wktest \(i)"
            if selfMove { w.level = .popUpMenu; w.collectionBehavior = [.canJoinAllSpaces, .stationary]; (w as? NSPanel)?.hidesOnDeactivate = false }
            if u.hasPrefix("color:") {
                let rgb = u.dropFirst(6).split(separator: ",").map { CGFloat(Double($0)!) }
                w.contentView!.wantsLayer = true
                w.contentView!.layer!.backgroundColor = CGColor(srgbRed: rgb[0], green: rgb[1], blue: rgb[2], alpha: 1)
            } else {
                let v = WKWebView(frame: w.contentView!.bounds); v.autoresizingMask = [.width, .height]
                w.contentView!.addSubview(v); v.load(URLRequest(url: URL(string: u)!))
            }
            w.makeKeyAndOrderFront(nil); w.orderFrontRegardless(); windows.append(w)
            let wid = w.windowNumber
            NotificationCenter.default.addObserver(forName: NSWindow.didChangeOcclusionStateNotification, object: w, queue: .main) { _ in
                note("win=\(wid) occlusion visible=\(w.occlusionState.contains(.visible))") }
            for (name, label) in [(NSWindow.didBecomeKeyNotification, "key"), (NSWindow.didResignKeyNotification, "resignKey"),
                                  (NSWindow.didBecomeMainNotification, "main"), (NSWindow.didResignMainNotification, "resignMain"),
                                  (NSWindow.didChangeScreenNotification, "screen")] {
                NotificationCenter.default.addObserver(forName: name, object: w, queue: .main) { _ in note("win=\(wid) \(label)") }
            }
        }
        // Self-move control: WKTEST_SELFMOVE=1 moves window 0 by itself (in-process setFrameOrigin) every display
        // frame for 2 s after a 2 s delay, logging "selfmove t x" - the macOS pipeline without Accessibility.
        if ProcessInfo.processInfo.environment["WKTEST_SELFMOVE"] == "1", let w = windows.first {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.moveEnd = CACurrentMediaTime() + 2
                if ProcessInfo.processInfo.environment["WKTEST_TIMER"] == "1" {
                    Timer.scheduledTimer(withTimeInterval: 1.0 / 120, repeats: true) { t in
                        if CACurrentMediaTime() > self.moveEnd { t.invalidate(); return }
                        let o = w.frame.origin; w.setFrameOrigin(NSPoint(x: o.x - 9, y: o.y))
                        note(String(format: "selfmove %.6f %.0f", CACurrentMediaTime(), o.x - 9))
                    }
                } else {
                    let link = w.displayLink(target: self, selector: #selector(Delegate.step(_:)))
                    link.add(to: .main, forMode: .common); self.link = link
                }
            }
        }
        // Display clock: WKTEST_CLOCK=1 shows a 24 pt square on the right edge (300 pt up) whose blue channel counts
        // display refreshes (its own display link), so a capture can tell a repeated frame from a dropped capture.
        if ProcessInfo.processInfo.environment["WKTEST_CLOCK"] == "1", let screen = NSScreen.main {
            let f = screen.frame
            let p = NSPanel(contentRect: NSRect(x: f.maxX - 30, y: f.minY + 300, width: 24, height: 24),
                            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
            p.level = .popUpMenu; p.hidesOnDeactivate = false; p.collectionBehavior = [.canJoinAllSpaces, .stationary]
            p.contentView!.wantsLayer = true; p.orderFrontRegardless(); clockPanel = p
            let link = p.displayLink(target: self, selector: #selector(Delegate.tickClock(_:)))
            link.add(to: .main, forMode: .common); clockLink = link
        }
        // Main-thread stall probe: a 2 ms timer; gaps > 50 ms are main-thread blocks.
        var last = CACurrentMediaTime()
        Timer.scheduledTimer(withTimeInterval: 0.002, repeats: true) { _ in
            let now = CACurrentMediaTime(); if now - last > 0.05 { note(String(format: "stall %.0f ms", (now - last) * 1000)) }; last = now }
    }
}
let app = NSApplication.shared
app.setActivationPolicy(.regular)
let d = Delegate(); app.delegate = d; app.run()
