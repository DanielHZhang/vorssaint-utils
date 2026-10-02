// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Localized strings for the close-notifications quick tool.
struct CloseNotificationsFeatureStrings {
    let pageTitle: String
    let hubDescription: String
    let panelCaption: String
    let clearButton: String
    let hudCleared: String
    let hudNone: String
}

extension FeatureStrings {
    static func closeNotifications(_ language: AppLanguage) -> CloseNotificationsFeatureStrings {
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

extension CloseNotificationsFeatureStrings {
    static let enUS = CloseNotificationsFeatureStrings(
        pageTitle: "Close notifications",
        hubDescription: "Closes every notification in Notification Center",
        panelCaption: "Clears the Notification Center list with one shortcut, like opening it and pressing Clear All.",
        clearButton: "Close them now",
        hudCleared: "Notifications closed",
        hudNone: "No notifications to close"
    )

    static let ptBR = CloseNotificationsFeatureStrings(
        pageTitle: "Fechar notificações",
        hubDescription: "Fecha todas as notificações da Central de Notificações",
        panelCaption: "Limpa a lista da Central de Notificações com um atalho, como abrir e tocar em Limpar tudo.",
        clearButton: "Fechar agora",
        hudCleared: "Notificações fechadas",
        hudNone: "Nenhuma notificação para fechar"
    )

    static let tr = CloseNotificationsFeatureStrings(
        pageTitle: "Bildirimleri kapat",
        hubDescription: "Bildirim Merkezi’ndeki tüm bildirimleri kapatır",
        panelCaption: "Bildirim Merkezi listesini tek kısayolla, açıp Tümünü Temizle’ye basmış gibi temizler.",
        clearButton: "Şimdi kapat",
        hudCleared: "Bildirimler kapatıldı",
        hudNone: "Kapatılacak bildirim yok"
    )

    static let ru = CloseNotificationsFeatureStrings(
        pageTitle: "Закрыть уведомления",
        hubDescription: "Закрывает все уведомления в Центре уведомлений",
        panelCaption: "Очищает список Центра уведомлений одним сочетанием клавиш, как кнопка «Очистить все».",
        clearButton: "Закрыть сейчас",
        hudCleared: "Уведомления закрыты",
        hudNone: "Нет уведомлений для закрытия"
    )

    static let es = CloseNotificationsFeatureStrings(
        pageTitle: "Cerrar notificaciones",
        hubDescription: "Cierra todas las notificaciones del Centro de notificaciones",
        panelCaption: "Vacía la lista del Centro de notificaciones con un atajo, como abrirlo y pulsar Borrar todo.",
        clearButton: "Cerrar ahora",
        hudCleared: "Notificaciones cerradas",
        hudNone: "No hay notificaciones para cerrar"
    )

    static let sk = CloseNotificationsFeatureStrings(
        pageTitle: "Zavrieť notifikácie",
        hubDescription: "Zavrie všetky notifikácie v Centre hlásení",
        panelCaption: "Vymaže zoznam Centra hlásení jednou skratkou, ako keby ste ho otvorili a stlačili Vymazať všetko.",
        clearButton: "Zavrieť teraz",
        hudCleared: "Notifikácie zatvorené",
        hudNone: "Žiadne notifikácie na zatvorenie"
    )

    static let de = CloseNotificationsFeatureStrings(
        pageTitle: "Mitteilungen schließen",
        hubDescription: "Schließt alle Mitteilungen in der Mitteilungszentrale",
        panelCaption: "Leert die Liste der Mitteilungszentrale mit einem Kurzbefehl, wie Öffnen und „Alle löschen“.",
        clearButton: "Jetzt schließen",
        hudCleared: "Mitteilungen geschlossen",
        hudNone: "Keine Mitteilungen zum Schließen"
    )

    static let fr = CloseNotificationsFeatureStrings(
        pageTitle: "Fermer les notifications",
        hubDescription: "Ferme toutes les notifications du Centre de notifications",
        panelCaption: "Vide la liste du Centre de notifications avec un raccourci, comme l’ouvrir et toucher Tout effacer.",
        clearButton: "Fermer maintenant",
        hudCleared: "Notifications fermées",
        hudNone: "Aucune notification à fermer"
    )

    static let it = CloseNotificationsFeatureStrings(
        pageTitle: "Chiudi notifiche",
        hubDescription: "Chiude tutte le notifiche nel Centro Notifiche",
        panelCaption: "Svuota l’elenco del Centro Notifiche con una scorciatoia, come aprirlo e toccare Cancella tutto.",
        clearButton: "Chiudi ora",
        hudCleared: "Notifiche chiuse",
        hudNone: "Nessuna notifica da chiudere"
    )

    static let ja = CloseNotificationsFeatureStrings(
        pageTitle: "通知を閉じる",
        hubDescription: "通知センターのすべての通知を閉じます",
        panelCaption: "通知センターを開いて「すべて消去」を押すのと同じように、リストを1つのショートカットで消去します。",
        clearButton: "今すぐ閉じる",
        hudCleared: "通知を閉じました",
        hudNone: "閉じる通知はありません"
    )

    static let ko = CloseNotificationsFeatureStrings(
        pageTitle: "알림 닫기",
        hubDescription: "알림 센터의 모든 알림을 닫습니다",
        panelCaption: "알림 센터를 열어 모두 지우기를 누른 것처럼, 목록을 단축키 하나로 비웁니다.",
        clearButton: "지금 닫기",
        hudCleared: "알림을 닫았습니다",
        hudNone: "닫을 알림이 없습니다"
    )

    static let zhHans = CloseNotificationsFeatureStrings(
        pageTitle: "关闭通知",
        hubDescription: "关闭通知中心里的所有通知",
        panelCaption: "用一个快捷键清空通知中心列表，就像打开它并点按“全部清除”。",
        clearButton: "立即关闭",
        hudCleared: "通知已关闭",
        hudNone: "没有可关闭的通知"
    )

    static let zhTW = CloseNotificationsFeatureStrings(
        pageTitle: "關閉通知",
        hubDescription: "關閉通知中心的所有通知",
        panelCaption: "用一個快捷鍵清空通知中心列表，就像打開它並點按「全部清除」。",
        clearButton: "立即關閉",
        hudCleared: "通知已關閉",
        hudNone: "沒有可關閉的通知"
    )

    static let zhHK = CloseNotificationsFeatureStrings(
        pageTitle: "關閉通知",
        hubDescription: "關閉通知中心的所有通知",
        panelCaption: "用一個快捷鍵清空通知中心列表，就像打開它並點按「全部清除」。",
        clearButton: "立即關閉",
        hudCleared: "通知已關閉",
        hudNone: "沒有可關閉的通知"
    )

    static let uk = CloseNotificationsFeatureStrings(
        pageTitle: "Закрити сповіщення",
        hubDescription: "Закриває всі сповіщення в Центрі сповіщень",
        panelCaption: "Очищає список Центру сповіщень одним сполученням клавіш, як кнопка «Очистити все».",
        clearButton: "Закрити зараз",
        hudCleared: "Сповіщення закрито",
        hudNone: "Немає сповіщень для закриття"
    )
}
