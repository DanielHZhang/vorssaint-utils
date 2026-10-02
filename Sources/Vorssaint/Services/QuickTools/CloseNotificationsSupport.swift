// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// One accessibility action an element offers, with the human-readable
/// description macOS gives it. Notification Center's group actions carry
/// their title either as that description or inside the action name itself
/// (a first line of the form "Name:Close"), depending on the macOS release,
/// so both representations cross this boundary and matching accepts either.
struct CloseNotificationAction: Equatable {
    let name: String
    let description: String?
}

/// Only the operations the close-all walk needs cross this boundary. A failed
/// read throws so a partial tree can never authorize pressing anything: the
/// actions are collected first and performed only once the whole candidate
/// list is known, the same rule the notification reader lives by.
protocol CloseNotificationAccess {
    associatedtype Element
    func windows() throws -> [Element]
    func children(_ element: Element) throws -> [Element]
    func role(_ element: Element) throws -> String?
    func actions(_ element: Element) throws -> [CloseNotificationAction]
    func perform(_ action: String, on element: Element) -> Bool
}

/// The traversal behind "close every notification", ported from the
/// Hammerspoon/JXA recipe: Notification Center window, down through its
/// groups to the scroll area, then the scroll area's first group's elements
/// together with the groups themselves (the "Clear all" hierarchy). Pure
/// logic over an injected access adapter, so the production walk also runs
/// against synthetic trees.
enum CloseNotificationsSupport {
    enum Outcome: Equatable {
        /// This many close/clear actions were performed.
        case closed(Int)
        /// The list was there but no element offered a close action.
        case nothingToClose
        /// No Notification Center surface with a scrollable list exists
        /// right now (the center is closed, or nothing is showing).
        case noSurface
        /// A read failed or the walk ran out of budget; nothing was pressed.
        case unavailable
    }

    /// The action titles the walk looks for. The system strings are
    /// localized, so the caller supplies the Notification Center bundle's
    /// own words; the English originals always ride along because action
    /// names keep them on some releases regardless of the interface language.
    struct Titles: Equatable {
        var clearAll: Set<String>
        var close: Set<String>

        init(clearAll: Set<String>, close: Set<String>) {
            self.clearAll = clearAll.union(["Clear All"])
            self.close = close.union(["Close"])
        }
    }

    private static let groupRole = "AXGroup"
    private static let scrollAreaRole = "AXScrollArea"
    /// The JXA chain reaches the scroll area four levels under the window;
    /// six leaves room for a wrapper without wandering the whole tree.
    private static let scrollAreaSearchDepth = 6
    private static let maximumDepth = 10
    private static let maximumChildrenPerNode = 64
    private static let maximumNodes = 256
    private static let timeBudget: TimeInterval = 0.8

    /// Closes every notification the Notification Center list currently
    /// shows. Each candidate element contributes at most one action, with
    /// "Clear All" preferred over "Close", exactly as the JXA reduced its
    /// action list. Nothing is performed unless the candidate list was
    /// collected completely.
    static func closeAll<Access: CloseNotificationAccess>(
        access: Access, titles: Titles,
        clock: @escaping () -> TimeInterval = { ProcessInfo.processInfo.systemUptime }
    ) -> Outcome {
        let walk = Walk(access: access, titles: titles, clock: clock)
        return walk.run()
    }

    /// The action to perform on one element: the single action whose
    /// description (or "Name:"-prefixed name) matches a title in `titles`.
    /// Ambiguity refuses, mirroring the reader's close-action rule: two
    /// actions with the same title cannot tell the walk which one the
    /// system means.
    static func matchingAction(in actions: [CloseNotificationAction],
                               titles: Set<String>) -> String? {
        let matches = actions.filter { action in
            if let description = action.description,
               titles.contains(description.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return true
            }
            let firstLine = action.name.components(separatedBy: "\n").first ?? ""
            return titles.contains { firstLine == "Name:" + $0 }
        }
        return matches.count == 1 ? matches.first?.name : nil
    }

    /// Per element, "Clear All" wins over "Close" so a whole app group
    /// collapses in one press instead of closing a single notification.
    static func actionToPerform(in actions: [CloseNotificationAction],
                                titles: Titles) -> String? {
        matchingAction(in: actions, titles: titles.clearAll)
            ?? matchingAction(in: actions, titles: titles.close)
    }

    private final class Walk<Access: CloseNotificationAccess> {
        let access: Access
        let titles: Titles
        let clock: () -> TimeInterval
        private var deadline: TimeInterval = 0
        private var remainingNodes = maximumNodes
        private var incomplete = false

        init(access: Access, titles: Titles, clock: @escaping () -> TimeInterval) {
            self.access = access
            self.titles = titles
            self.clock = clock
        }

        private var usable: Bool { !incomplete && clock() < deadline && remainingNodes > 0 }

        func run() -> Outcome {
            deadline = clock() + timeBudget
            guard let windows = fetch({ try access.windows() }), usable else { return .unavailable }
            // The JXA takes the first window; the walk tries each one until
            // a scrollable list turns up, so a banner window in front of the
            // panel cannot hide the list behind it.
            for window in windows {
                guard let scrollArea = findScrollArea(window, depth: 0) else {
                    if incomplete { return .unavailable }
                    continue
                }
                return closeAll(in: scrollArea)
            }
            return .noSurface
        }

        private func closeAll(in scrollArea: Access.Element) -> Outcome {
            guard let candidates = candidates(under: scrollArea) else { return .unavailable }
            var plan: [(element: Access.Element, action: String)] = []
            for candidate in candidates {
                guard let actions = fetch({ try access.actions(candidate) }), usable else {
                    return .unavailable
                }
                if let action = CloseNotificationsSupport.actionToPerform(in: actions, titles: titles) {
                    plan.append((candidate, action))
                }
            }
            guard usable, !plan.isEmpty else {
                return plan.isEmpty && usable ? .nothingToClose : .unavailable
            }
            var performed = 0
            for step in plan where access.perform(step.action, on: step.element) {
                performed += 1
            }
            return performed > 0 ? .closed(performed) : .unavailable
        }

        /// Breadth-first so the shallowest scroll area wins: the hierarchy
        /// nests them, and the outer one owns the whole list.
        private func findScrollArea(_ window: Access.Element, depth: Int) -> Access.Element? {
            var queue: [(element: Access.Element, depth: Int)] = [(window, depth)]
            var index = 0
            while index < queue.count {
                let (node, level) = queue[index]
                index += 1
                guard visit(depth: level) else { return nil }
                if role(node) == scrollAreaRole { return node }
                guard level < scrollAreaSearchDepth else { continue }
                for child in children(node) {
                    queue.append((child, level + 1))
                }
                guard usable else { return nil }
            }
            return nil
        }

        /// The JXA's candidate set: the first group's elements (each
        /// notification row) plus the groups themselves (each app section,
        /// which is where "Clear All" lives). When no child carries the
        /// group role the walk keeps every child as a section candidate
        /// rather than guessing a narrower set.
        private func candidates(under scrollArea: Access.Element) -> [Access.Element]? {
            let children = children(scrollArea)
            guard usable else { return nil }
            let groups = children.filter { role($0) == groupRole }
            let sections = groups.isEmpty ? children : groups
            var result: [Access.Element] = []
            if let first = sections.first {
                result += self.children(first)
                guard usable else { return nil }
            }
            result += sections
            return result
        }

        private func visit(depth: Int) -> Bool {
            guard usable, depth <= maximumDepth else { incomplete = true; return false }
            remainingNodes -= 1
            return usable
        }

        private func children(_ node: Access.Element) -> [Access.Element] {
            guard let children = fetch({ try access.children(node) }) else { return [] }
            guard children.count <= maximumChildrenPerNode else { incomplete = true; return [] }
            return children
        }

        private func role(_ node: Access.Element) -> String? {
            fetch({ try access.role(node) }) ?? nil
        }

        private func fetch<Value>(_ body: () throws -> Value) -> Value? {
            guard usable else { return nil }
            do {
                let value = try body()
                guard usable else { return nil }
                return value
            } catch {
                incomplete = true
                return nil
            }
        }
    }
}
