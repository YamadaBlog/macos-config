// Audio files open in QuickTime Player instead of Apple Music (Music hangs when its Apple account save waits on a stuck passd).
// Run: swift scripts/default-audio-app.swift
import AppKit
import UniformTypeIdentifiers

let app = URL(fileURLWithPath: "/System/Applications/QuickTime Player.app")
let types = ["public.audio", "public.mp3", "com.microsoft.waveform-audio", "public.aiff-audio", "public.aifc-audio",
             "public.mpeg-4-audio", "com.apple.m4a-audio", "org.xiph.flac", "org.xiph.ogg-audio", "public.ulaw-audio"]
let group = DispatchGroup()
for id in types {
    guard let t = UTType(id) else { continue }
    group.enter()
    NSWorkspace.shared.setDefaultApplication(at: app, toOpen: t) { err in
        print(id, err.map { "error: \($0.localizedDescription)" } ?? "QuickTime Player")
        group.leave()
    }
}
group.wait()
