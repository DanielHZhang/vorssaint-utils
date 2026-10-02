// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import ApplicationServices

/// Closes every notification in Notification Center from a global shortcut,
/// the native port of the Hammerspoon/JXA recipe: the center's window, down
/// through its groups to the scroll area, then "Clear All" (preferred) or
/// "Close" on each section. Requires Accessibility for the accessibility
/// walk; without it the shortcut says so once instead of silently doing
/// nothing.
final class CloseNotificationsService: ObservableObject {
    static let shared = CloseNotificationsService()

    @Published private(set) var shortcutRegistrationFailed = false

    private let hotkey = QuickToolHotkey(id: 26)

    /// The accessibility walk can stall on a busy Notification Center, and
    /// its default timeout is seconds long, so the walk runs here and the
    /// answer comes back on the main thread for the HUD.
    private let walkQueue = DispatchQueue(label: "com.vorssaint.utils.close-notifications",
                                          qos: .userInitiated)

    /// The permission prompt fires at most once per launch, so a shortcut
    /// mashed without Accessibility nags once instead of five times.
    private var promptedForAccessibility = false

    private init() {
        hotkey.onPress = { [weak self] in self?.closeAllNotifications() }
    }

    func syncWithPreferences() {
        let enabled = AppFeature.closeNotifications.isAvailable
            && UserDefaults.standard.bool(forKey: DefaultsKey.closeNotificationsShortcutEnabled)
        let shortcut = GlobalShortcut.saved(for: DefaultsKey.closeNotificationsShortcut,
                                            fallback: .closeNotificationsDefault)
        shortcutRegistrationFailed = !hotkey.sync(enabled: enabled, shortcut: shortcut,
                                                  storageKey: DefaultsKey.closeNotificationsShortcut)
    }

    func suspend() {
        hotkey.unregister()
    }

    /// The one entry point: shortcut, Settings button and menu panel tile
    /// all land here.
    func closeAllNotifications() {
        guard AXIsProcessTrusted() else {
            if promptedForAccessibility {
                NSSound.beep()
            } else {
                promptedForAccessibility = true
                Permissions.shared.requestAccessibility()
            }
            return
        }
        walkQueue.async { [weak self] in
            let outcome = Self.performCloseAll()
            DispatchQueue.main.async { self?.announce(outcome) }
        }
    }

    private func announce(_ outcome: CloseNotificationsSupport.Outcome) {
        let strings = FeatureStrings.closeNotifications(L10n.shared.language)
        switch outcome {
        case .closed:
            QuickToolHUD.show(icon: "bell.slash.fill", message: strings.hudCleared)
        case .nothingToClose, .noSurface:
            QuickToolHUD.show(icon: "bell.slash", message: strings.hudNone)
        case .unavailable:
            NSSound.beep()
        }
    }

    private static func performCloseAll() -> CloseNotificationsSupport.Outcome {
        guard let pid = notificationCenterPID() else { return .noSurface }
        let access = CloseNotificationsNativeAccess(pid: pid)
        return CloseNotificationsSupport.closeAll(access: access, titles: actionTitles())
    }

    private static func notificationCenterPID() -> pid_t? {
        let applications = NSWorkspace.shared.runningApplications
        if let app = applications.first(where: {
            $0.bundleIdentifier == "com.apple.notificationcenterui"
                || $0.bundleIdentifier == "com.apple.NotificationCenter"
        }) {
            return app.processIdentifier
        }
        return applications.first { $0.localizedName == "NotificationCenter" }?.processIdentifier
    }

    /// The action titles in the Notification Center's own language, from its
    /// bundle; the English originals always ride along inside `Titles`.
    private static func actionTitles() -> CloseNotificationsSupport.Titles {
        let bundle = Bundle(path: "/System/Library/CoreServices/NotificationCenter.app")
        func title(_ key: String) -> String? {
            bundle?.localizedString(forKey: key, value: nil, table: "Localizable")
        }
        return CloseNotificationsSupport.Titles(
            clearAll: Set([title("Clear All")].compactMap { $0 }),
            close: Set([title("Close")].compactMap { $0 }))
    }
}

/// Thin native adapter over the Notification Center process, in the
/// notification reader's style: every call gets the same short messaging
/// timeout so a busy center cannot hold the walk for seconds.
private struct CloseNotificationsNativeAccess: CloseNotificationAccess {
    typealias Element = AXUIElement
    private enum Failure: Error { case unavailable }
    private let application: AXUIElement

    init(pid: pid_t) {
        application = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(application, 0.1)
    }

    func windows() throws -> [AXUIElement] {
        guard let value = try value(application, kAXWindowsAttribute) else { return [] }
        guard let elements = value as? [AXUIElement] else { throw Failure.unavailable }
        return elements
    }

    func children(_ element: AXUIElement) throws -> [AXUIElement] {
        guard let value = try value(element, kAXChildrenAttribute) else { return [] }
        guard let elements = value as? [AXUIElement] else { throw Failure.unavailable }
        return elements
    }

    func role(_ element: AXUIElement) throws -> String? {
        guard let value = try value(element, kAXRoleAttribute) else { return nil }
        guard let role = value as? String else { throw Failure.unavailable }
        return role
    }

    func actions(_ element: AXUIElement) throws -> [CloseNotificationAction] {
        AXUIElementSetMessagingTimeout(element, 0.1)
        var result: CFArray?
        let error = AXUIElementCopyActionNames(element, &result)
        if error == .notImplemented || error == .actionUnsupported { return [] }
        guard error == .success, let names = result as? [String] else { throw Failure.unavailable }
        return names.map { name in
            var description: CFString?
            let described = AXUIElementCopyActionDescription(element, name as CFString, &description)
            return CloseNotificationAction(name: name,
                                           description: described == .success
                                               ? description.map { $0 as String } : nil)
        }
    }

    func perform(_ action: String, on element: AXUIElement) -> Bool {
        AXUIElementSetMessagingTimeout(element, 0.1)
        return AXUIElementPerformAction(element, action as CFString) == .success
    }

    private func value(_ element: AXUIElement, _ attribute: String) throws -> CFTypeRef? {
        AXUIElementSetMessagingTimeout(element, 0.1)
        var result: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, attribute as CFString, &result)
        if error == .noValue || error == .attributeUnsupported { return nil }
        guard error == .success else { throw Failure.unavailable }
        return result
    }
}
