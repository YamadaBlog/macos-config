// Replaces -[NSWindow constrainFrameRect:toScreen:]: the window may rise up to the PHYSICAL top edge of the screen
// (menu bar / notch area), but never overflows the screen. Feasibility test only.
#import <AppKit/AppKit.h>
#import <objc/runtime.h>

static IMP gOrig;

static NSRect sansEncoche(id self, SEL _cmd, NSRect r, NSScreen *screen) {
    NSRect o = ((NSRect (*)(id, SEL, NSRect, NSScreen *))gOrig)(self, _cmd, r, screen);
    NSScreen *s = screen ?: [(NSWindow *)self screen] ?: NSScreen.mainScreen;
    if (!s) return o;
    NSRect full = s.frame;                              // physical frame (includes the notch band)
    if (!(((NSWindow *)self).styleMask & NSWindowStyleMaskTitled)) return o;
    NSRect res = r;                                     // keep the request…
    if (NSMaxY(res) > NSMaxY(full)) res.origin.y = NSMaxY(full) - res.size.height;  // …without exceeding the physical top
    if (res.origin.y < NSMinY(full)) res.origin.y = NSMinY(full);
    if (res.size.height > full.size.height) res.size.height = full.size.height;
    res.origin.x = o.origin.x; res.size.width = o.size.width;  // horizontal: original behaviour
    return res;
}

__attribute__((constructor)) static void installer(void) {
    Method m = class_getInstanceMethod(NSWindow.class, @selector(constrainFrameRect:toScreen:));
    gOrig = method_setImplementation(m, (IMP)sansEncoche);
    NSLog(@"[sansencoche] menu bar constraint replaced in %@", NSProcessInfo.processInfo.processName);
}
