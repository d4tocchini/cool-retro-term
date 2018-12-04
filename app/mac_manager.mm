#include <Cocoa/Cocoa.h>
#include <QDebug>
#include "mac_manager.h"

void MacManager::removeTitlebarFromWindow(long winId)
{
 if(winId == -1)
 {
    QWindowList windows = QGuiApplication::topLevelWindows();
    QWindow* win = windows.first();
    winId = win->winId();
    MacManager::removeTitlebarFromWindow(winId);
 }
 else {

    qDebug() << winId;

    // QWindow* qtwin = QWindow::fromWinId(winId);
    NSView *nativeView = reinterpret_cast<NSView *>(winId);
    NSWindow* nativeWindow = [nativeView window];

    // for vibrancy/blending
    // - https://bugreports.qt.io/browse/QTBUG-39463?page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel&showAll=true
    // - https://developer.apple.com/documentation/appkit/nsvisualeffectblendingmode
    // - https://mackuba.eu/2018/07/04/dark-side-mac-1/
    nativeWindow.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    // nativeWindow.contentView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    // static const NSRect frameRect = {
    //         { 0.0, 0.0 }
    //     ,
    //         { 500.0, 500.0 }
    //         // { static_cast<CGFloat>(qtwin->width()), static_cast<CGFloat>(qtwin->height()) }
    // };

    // NSVisualEffectView * vibrant = [[NSVisualEffectView alloc] initWithFrame:frameRect];
    // vibrant.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    // [vibrant setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    // NSView* qtView = nativeWindow.contentView;
	// [qtView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
	// nativeWindow.contentView = vibrant;
	// [vibrant addSubview:qtView positioned:NSWindowBelow relativeTo:nil];

    [nativeWindow setTitlebarAppearsTransparent:YES];
    [nativeWindow setMovableByWindowBackground:YES];
    [nativeWindow setBackgroundColor:[NSColor clearColor]];
    [nativeWindow setOpaque:NO];
    // https://developer.apple.com/documentation/appkit/nswindowstylemask?language=objc
    // [nativeWindow setStyleMask:[nativeWindow styleMask] | NSWindowStyleMaskFullSizeContentView | NSWindowTitleHidden];
    [nativeWindow setStyleMask:[nativeWindow styleMask] | NSResizableWindowMask | NSTitledWindowMask | NSFullSizeContentViewWindowMask];
    //  [nativeWindow setMovableByWindowBackground:YES];
    //  [nativeWindow setTitlebarAppearsTransparent:YES];
    [nativeWindow setTitleVisibility:NSWindowTitleHidden];
    [nativeWindow setShowsToolbarButton:NO];
    // [nativeWindow standardWindowButton:NSWindowFullScreenButton].hidden = YES;
    // [nativeWindow standardWindowButton:NSWindowMiniaturizeButton].hidden = YES;
    // [nativeWindow standardWindowButton:NSWindowCloseButton].hidden = YES;
    // [nativeWindow standardWindowButton:NSWindowZoomButton].hidden = YES;
    [nativeWindow makeKeyWindow];
 }


}