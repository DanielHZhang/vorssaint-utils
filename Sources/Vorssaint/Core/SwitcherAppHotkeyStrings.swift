// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

struct SwitcherAppHotkeyStrings {
    let listTitle: String
    let addButton: String
    let removeButton: String
    let noShortcut: String
    let caption: String
}

extension FeatureStrings {
    static func switcherAppHotkeys(_ language: AppLanguage) -> SwitcherAppHotkeyStrings {
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

extension SwitcherAppHotkeyStrings {
    static let enUS = SwitcherAppHotkeyStrings(
        listTitle: "App window hotkeys",
        addButton: "Add an app…",
        removeButton: "Remove",
        noShortcut: "No shortcut",
        caption: "Bind a shortcut to an app to jump to its most recent window. Press again while holding the modifier to step through that app’s windows in this switcher. A shortcut applies only while its app is running, and the switcher’s own shortcuts take precedence over it."
    )

    static let ptBR = SwitcherAppHotkeyStrings(
        listTitle: "Atalhos de janela por app",
        addButton: "Adicionar app…",
        removeButton: "Remover",
        noShortcut: "Sem atalho",
        caption: "Associe um atalho a um app para ir à janela mais recente dele. Pressione de novo segurando o modificador para percorrer as janelas desse app neste alternador. O atalho só vale enquanto o app está aberto, e os atalhos do próprio alternador têm precedência."
    )

    static let tr = SwitcherAppHotkeyStrings(
        listTitle: "Uygulama pencere kısayolları",
        addButton: "Uygulama ekle…",
        removeButton: "Kaldır",
        noShortcut: "Kısayol yok",
        caption: "Bir uygulamaya kısayol bağlayarak en son penceresine atlayın. Değiştiriciyi basılı tutup tekrar basarsanız bu değiştiricide o uygulamanın pencereleri arasında gezersiniz. Kısayol yalnızca uygulama çalışırken geçerlidir ve değiştiricinin kendi kısayolları önceliklidir."
    )

    static let ru = SwitcherAppHotkeyStrings(
        listTitle: "Сочетания для окон приложений",
        addButton: "Добавить приложение…",
        removeButton: "Удалить",
        noShortcut: "Нет сочетания",
        caption: "Назначьте приложению сочетание, чтобы переходить к его последнему окну. Удерживая модификатор, нажимайте ещё раз, чтобы шагать по окнам этого приложения в этом переключателе. Сочетание действует, только пока приложение запущено, а собственные сочетания переключателя имеют приоритет."
    )

    static let es = SwitcherAppHotkeyStrings(
        listTitle: "Atajos de ventana por app",
        addButton: "Añadir app…",
        removeButton: "Quitar",
        noShortcut: "Sin atajo",
        caption: "Asigna un atajo a una app para saltar a su ventana más reciente. Pulsa de nuevo manteniendo el modificador para recorrer las ventanas de esa app en este selector. El atajo solo se aplica mientras la app está abierta, y los atajos del propio selector tienen prioridad."
    )

    static let sk = SwitcherAppHotkeyStrings(
        listTitle: "Skratky okien podľa aplikácie",
        addButton: "Pridať aplikáciu…",
        removeButton: "Odstrániť",
        noShortcut: "Bez skratky",
        caption: "Priraďte aplikácii skratku na skok do jej posledného okna. Podržaním modifikátora a ďalším stlačením prechádzate oknami tejto aplikácie v tomto prepínači. Skratka platí, len kým aplikácia beží, a vlastné skratky prepínača majú prednosť."
    )

    static let de = SwitcherAppHotkeyStrings(
        listTitle: "Fenster-Hotkeys pro App",
        addButton: "App hinzufügen…",
        removeButton: "Entfernen",
        noShortcut: "Kein Hotkey",
        caption: "Weise einer App einen Hotkey zu, um zu ihrem zuletzt genutzten Fenster zu springen. Erneut drücken bei gehaltener Zusatztaste, um in diesem Umschalter durch die Fenster der App zu blättern. Der Hotkey gilt nur, solange die App läuft, und die eigenen Hotkeys des Umschalters haben Vorrang."
    )

    static let fr = SwitcherAppHotkeyStrings(
        listTitle: "Raccourcis de fenêtre par app",
        addButton: "Ajouter une app…",
        removeButton: "Retirer",
        noShortcut: "Aucun raccourci",
        caption: "Associez un raccourci à une app pour passer à sa fenêtre la plus récente. Appuyez à nouveau en maintenant la touche de modification pour parcourir les fenêtres de cette app dans ce sélecteur. Le raccourci ne s’applique que pendant que l’app est ouverte, et les raccourcis du sélecteur ont la priorité."
    )

    static let it = SwitcherAppHotkeyStrings(
        listTitle: "Scorciatoie finestre per app",
        addButton: "Aggiungi app…",
        removeButton: "Rimuovi",
        noShortcut: "Nessuna scorciatoia",
        caption: "Associa una scorciatoia a un’app per passare alla sua finestra più recente. Premi di nuovo tenendo premuto il modificatore per scorrere le finestre di quell’app in questo selettore. La scorciatoia vale solo mentre l’app è aperta, e le scorciatoie del selettore hanno la precedenza."
    )

    static let ja = SwitcherAppHotkeyStrings(
        listTitle: "Appごとのウインドウショートカット",
        addButton: "Appを追加…",
        removeButton: "削除",
        noShortcut: "ショートカットなし",
        caption: "Appにショートカットを割り当てると、そのAppの最後に使ったウインドウへ移動できます。修飾キーを押したままもう一度押すと、このスイッチャーでそのAppのウインドウを順に切り替えられます。ショートカットはAppの実行中のみ有効で、スイッチャー自体のショートカットが優先されます。"
    )

    static let ko = SwitcherAppHotkeyStrings(
        listTitle: "앱별 창 단축키",
        addButton: "앱 추가…",
        removeButton: "제거",
        noShortcut: "단축키 없음",
        caption: "앱에 단축키를 지정하면 가장 최근 창으로 이동합니다. 수정자 키를 누른 채 다시 누르면 이 전환기에서 해당 앱의 창들을 차례로 이동합니다. 단축키는 앱이 실행 중일 때만 적용되며, 전환기 자체 단축키가 우선합니다."
    )

    static let zhHans = SwitcherAppHotkeyStrings(
        listTitle: "按 App 设置窗口快捷键",
        addButton: "添加 App…",
        removeButton: "移除",
        noShortcut: "无快捷键",
        caption: "为某个 App 绑定快捷键，即可跳到它最近使用的窗口。按住修饰键再次按下，可在此切换器中依次浏览该 App 的窗口。快捷键仅在该 App 运行时有效，且切换器自身的快捷键优先。"
    )

    static let zhTW = SwitcherAppHotkeyStrings(
        listTitle: "各 App 視窗快速鍵",
        addButton: "加入 App…",
        removeButton: "移除",
        noShortcut: "無快速鍵",
        caption: "為 App 綁定快速鍵，即可跳到它最近使用的視窗。按住修飾鍵再按一次，可在此切換器中依序瀏覽該 App 的視窗。快速鍵僅在 App 執行時有效，且切換器自身的快速鍵優先。"
    )

    static let zhHK = SwitcherAppHotkeyStrings(
        listTitle: "各 App 視窗快速鍵",
        addButton: "加入 App…",
        removeButton: "移除",
        noShortcut: "無快速鍵",
        caption: "為 App 綁定快速鍵，即可跳到它最近使用的視窗。按住修飾鍵再按一次，可在此切換器中依序瀏覽該 App 的視窗。快速鍵僅在 App 執行時有效，且切換器自身的快速鍵優先。"
    )

    static let uk = SwitcherAppHotkeyStrings(
        listTitle: "Гарячі клавіші вікон за програмами",
        addButton: "Додати програму…",
        removeButton: "Видалити",
        noShortcut: "Немає поєднання",
        caption: "Прив’яжіть поєднання до програми, щоб переходити до її останнього вікна. Утримуючи модифікатор, натискайте ще раз, щоб крокувати вікнами цієї програми в цьому перемикачі. Поєднання діє, лише доки програма запущена, а власні поєднання перемикача мають пріоритет."
    )
}
