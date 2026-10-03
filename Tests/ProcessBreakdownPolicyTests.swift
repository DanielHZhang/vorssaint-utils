// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Pins the breakdown presentation policy: combined-by-default rows with
/// activity cutoffs, and the looser per-process listing behind the Monitor
/// setting (no consolidation, no cutoffs, wider row budget).
enum ProcessBreakdownPolicyTests {
    static func run(_ suite: TestSuite) {
        suite.expect(ProcessBreakdownPolicy.effectiveLimit(requested: 15, individual: false) == 15,
                     "the combined listing keeps the requested row count")
        suite.expect(ProcessBreakdownPolicy.effectiveLimit(requested: 6, individual: false) == 6,
                     "the combined listing keeps the network row count")
        suite.expect(ProcessBreakdownPolicy.effectiveLimit(requested: 15, individual: true)
                        == ProcessBreakdownPolicy.individualRowLimit,
                     "the individual listing widens 15 rows to the full budget")
        suite.expect(ProcessBreakdownPolicy.effectiveLimit(requested: 100, individual: true) == 100,
                     "the individual listing never narrows a larger request")

        suite.expect(ProcessBreakdownPolicy.cpuThreshold(individual: false) == 0.01
                        && ProcessBreakdownPolicy.cpuThreshold(individual: true) == 0,
                     "the CPU cutoff applies only to the combined listing")
        suite.expect(ProcessBreakdownPolicy.gpuThreshold(individual: false) == 0.05
                        && ProcessBreakdownPolicy.gpuThreshold(individual: true) == 0,
                     "the GPU cutoff applies only to the combined listing")
        suite.expect(ProcessBreakdownPolicy.energyThreshold(individual: false) == 2
                        && ProcessBreakdownPolicy.energyThreshold(individual: true) == 0,
                     "the energy cutoff applies only to the combined listing")

        suite.expect(ProcessBreakdownPolicy.memoryCandidateLimit(requested: 15, individual: false) == 150,
                     "the combined memory listing ranks the top 150 candidates at 15 rows")
        suite.expect(ProcessBreakdownPolicy.memoryCandidateLimit(requested: 2, individual: false) == 120,
                     "the combined memory listing never ranks fewer than 120 candidates")
        suite.expect(ProcessBreakdownPolicy.memoryCandidateLimit(requested: 15, individual: true) == .max,
                     "the individual memory listing ranks every process in the snapshot")

        suite.expect(Defaults.registeredDefaults[DefaultsKey.monitorIndividualProcesses] as? Bool == false,
                     "the individual process listing starts off")

        for language in AppLanguage.allCases {
            let strings = FeatureStrings.monitorProcessList(language)
            suite.expect(!strings.title.isEmpty && !strings.caption.isEmpty,
                         "process list strings are complete in \(language.rawValue)")
        }

        // Production wiring: every presentation path consults the policy.
        let serviceSource = (try? String(
            contentsOfFile: "Sources/Vorssaint/Services/SystemMonitor/ProcessUsageService.swift",
            encoding: .utf8)) ?? ""
        suite.expect(serviceSource.contains("ProcessBreakdownPolicy.listsIndividually()"),
                     "the usage service reads the individual-listing setting")
        suite.expect(serviceSource.contains("ProcessBreakdownPolicy.effectiveLimit")
                        && serviceSource.contains("ProcessBreakdownPolicy.cpuThreshold")
                        && serviceSource.contains("ProcessBreakdownPolicy.gpuThreshold")
                        && serviceSource.contains("ProcessBreakdownPolicy.energyThreshold")
                        && serviceSource.contains("ProcessBreakdownPolicy.memoryCandidateLimit"),
                     "every breakdown path is governed by the policy")
        suite.expect(serviceSource.contains("listsIndividually ? individualRows"),
                     "individual rows bypass the helper consolidation")
    }
}
