// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

struct MonitorProcessListStrings {
    let title: String
    let caption: String
}

extension FeatureStrings {
    static func monitorProcessList(_ language: AppLanguage) -> MonitorProcessListStrings {
        switch language {
        case .enUS: return .enUS
        case .ptBR: return .ptBR
        case .tr: return .tr
        case .ru: return .ru
        case .es: return .es
        case .sk: return .sk
        case .de: return .de
        case .fr: return .fr
        case .it: return .it
        case .ja: return .ja
        case .ko: return .ko
        case .zhHans: return .zhHans
        case .zhTW: return .zhTW
        case .zhHK: return .zhHK
        case .uk: return .uk
        }
    }
}

extension MonitorProcessListStrings {
    static let enUS = MonitorProcessListStrings(
        title: "Show individual processes",
        caption: "The panel's breakdowns list every process on its own instead of combining helpers under the app responsible for them, and include processes with only slight activity."
    )

    static let ptBR = MonitorProcessListStrings(
        title: "Mostrar processos individuais",
        caption: "Os detalhes do painel listam cada processo separadamente, em vez de combinar os auxiliares no app responsável por eles, e incluem processos com atividade mínima."
    )

    static let tr = MonitorProcessListStrings(
        title: "Tek tek işlemleri göster",
        caption: "Panel dökümleri, yardımcı işlemleri sorumlu uygulama altında birleştirmek yerine her işlemi tek başına listeler ve çok az etkinliği olan işlemleri de içerir."
    )

    static let ru = MonitorProcessListStrings(
        title: "Показывать отдельные процессы",
        caption: "В развёрнутых списках панели каждый процесс показан отдельно, а не объединён с приложением, которое за него отвечает, включая процессы с минимальной активностью."
    )

    static let es = MonitorProcessListStrings(
        title: "Mostrar procesos individuales",
        caption: "Los desgloses del panel muestran cada proceso por separado, en lugar de combinar los procesos auxiliares en la app responsable de ellos, e incluyen procesos con actividad mínima."
    )

    static let sk = MonitorProcessListStrings(
        title: "Zobraziť jednotlivé procesy",
        caption: "Rozpisy na paneli uvádzajú každý proces samostatne namiesto spájania pomocných procesov pod zodpovednú aplikáciu a zahŕňajú aj procesy s minimálnou aktivitou."
    )

    static let de = MonitorProcessListStrings(
        title: "Einzelne Prozesse anzeigen",
        caption: "Die Aufschlüsselungen im Panel listen jeden Prozess einzeln auf, statt Hilfsprozesse unter der verantwortlichen App zusammenzufassen, und zeigen auch Prozesse mit nur geringer Aktivität."
    )

    static let fr = MonitorProcessListStrings(
        title: "Afficher les processus individuels",
        caption: "Les détails du panneau listent chaque processus séparément au lieu de regrouper les processus auxiliaires sous l'app responsable, et incluent les processus à très faible activité."
    )

    static let it = MonitorProcessListStrings(
        title: "Mostra i singoli processi",
        caption: "I dettagli del pannello elencano ogni processo singolarmente invece di raggruppare i processi di supporto sotto l'app responsabile, includendo anche i processi con attività minima."
    )

    static let ja = MonitorProcessListStrings(
        title: "個別のプロセスを表示",
        caption: "パネルの内訳では、ヘルパープロセスを担当アプリにまとめず、すべてのプロセスを個別に表示し、わずかな活動しかないプロセスも含めます。"
    )

    static let ko = MonitorProcessListStrings(
        title: "개별 프로세스 표시",
        caption: "패널의 세부 목록에서 도우미 프로세스를 담당 앱으로 합치지 않고 모든 프로세스를 개별적으로 표시하며, 활동이 미미한 프로세스도 포함합니다."
    )

    static let zhHans = MonitorProcessListStrings(
        title: "显示单个进程",
        caption: "面板中的明细会单独列出每个进程，而不是将辅助进程合并到负责的应用下，并包含活动量很低的进程。"
    )

    static let zhTW = MonitorProcessListStrings(
        title: "顯示單一程序",
        caption: "面板中的明細會個別列出每個程序，而不是將輔助程序合併至負責的應用程式之下，並包含活動量極低的程序。"
    )

    static let zhHK = MonitorProcessListStrings(
        title: "顯示個別程序",
        caption: "面板中的明細會逐一列出每個程序，而不是將輔助程序合併至負責的應用程式之下，並包含活動量極低的程序。"
    )

    static let uk = MonitorProcessListStrings(
        title: "Показувати окремі процеси",
        caption: "Розгорнуті списки панелі показують кожен процес окремо, а не об'єднують допоміжні процеси під відповідальним застосунком, і включають процеси з мінімальною активністю."
    )
}
