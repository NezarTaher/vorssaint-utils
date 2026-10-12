// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

struct MenuBarOrganizerFeatureStrings {
    let title: String
    let hubDescription: String
    let enable: String
    let enableCaption: String
    /// One `%@`: the macOS version this Mac runs.
    let unsupportedOSFormat: String
    let unsupportedAPI: String
    /// One `%@`: the name of the other menu bar manager.
    let otherManagerFormat: String
    let hiddenSection: String
    let visibleSection: String
    let hiddenEmpty: String
    let visibleEmpty: String
    let hideItem: String
    let showItem: String
    let lockedSystem: String
    let lockedOwn: String
    let lockedHelper: String
    let apply: String
    /// One `%d`: how many items changed position.
    let applyPendingFormat: String
    let discard: String
    let applying: String
    /// `%1$d` moved, `%2$d` failed.
    let applyReportFormat: String
    let applyHint: String
    let dragHint: String
    let perAppNote: String
    let systemExtrasNote: String
    let autoRehide: String
    let autoRehideNever: String
    /// One `%d`: seconds.
    let autoRehideSecondsFormat: String
    let showHiddenIcons: String
    let hideIcons: String
    let statusCollapsed: String
    let statusExpanded: String
    let refresh: String
    let problemAccessibility: String
    let problemChevronNotFound: String
    /// One `%@`: the underlying error.
    let problemActivationFormat: String
    let problemNothingToHide: String
}

extension FeatureStrings {
    static func menuBarOrganizer(_ language: AppLanguage) -> MenuBarOrganizerFeatureStrings {
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
        case .uk: return .uk
        case .zhHans: return .zhHans
        case .zhTW: return .zhTW
        case .zhHK: return .zhHK
        }
    }
}

extension MenuBarOrganizerFeatureStrings {
    static let enUS = MenuBarOrganizerFeatureStrings(
        title: "Menu Bar Organizer", hubDescription: "Hide menu bar icons behind a chevron, reorder them from Settings and bring them back with one click. macOS 27 or later.",
        enable: "Hide menu bar icons", enableCaption: "Icons left of the chevron hide. Click the chevron to show them.",
        unsupportedOSFormat: "Menu Bar Organizer needs macOS 27 or later. This Mac runs macOS %@.", unsupportedAPI: "This macOS build does not expose the menu bar controls Menu Bar Organizer relies on.",
        otherManagerFormat: "%@ is running. Two menu bar managers hiding icons at once interfere; quit it first.",
        hiddenSection: "Hidden", visibleSection: "Shown", hiddenEmpty: "Nothing hidden. Hold ⌘ and drag an icon to the left of the chevron, or use Hide here.", visibleEmpty: "No icons found. Make sure Accessibility is granted.",
        hideItem: "Hide", showItem: "Show", lockedSystem: "Managed by macOS", lockedOwn: "Vorssaint’s own icon stays visible", lockedHelper: "Drawn by a helper process macOS cannot hide",
        apply: "Apply", applyPendingFormat: "Apply changes (%d)", discard: "Discard", applying: "Moving icons…", applyReportFormat: "%1$d moved, %2$d failed",
        applyHint: "Vorssaint moves icons with ⌘-drags. Keep your hands off the mouse for a moment.", dragHint: "You can also hold ⌘ and drag icons across the chevron in the menu bar.",
        perAppNote: "macOS hides icons per app: several icons from one app hide together.", systemExtrasNote: "While icons are hidden, macOS also removes some of its own extras, such as Focus. They return when the icons are shown.",
        autoRehide: "Hide again automatically", autoRehideNever: "Never", autoRehideSecondsFormat: "After %d s", showHiddenIcons: "Show hidden icons", hideIcons: "Hide icons",
        statusCollapsed: "Icons are hidden", statusExpanded: "Icons are shown", refresh: "Refresh",
        problemAccessibility: "Accessibility is required to read the menu bar.", problemChevronNotFound: "The chevron is not in the menu bar yet. Hiding is paused.",
        problemActivationFormat: "Hiding failed: %@", problemNothingToHide: "Nothing is left of the chevron, so nothing was hidden.")
    static let ptBR = MenuBarOrganizerFeatureStrings(
        title: "Organizador da barra de menus", hubDescription: "Esconda ícones da barra de menus atrás de uma seta, reordene-os nos Ajustes e traga-os de volta com um clique. macOS 27 ou posterior.",
        enable: "Ocultar ícones da barra de menus", enableCaption: "Os ícones à esquerda da seta ficam ocultos. Clique na seta para mostrá-los.",
        unsupportedOSFormat: "O Organizador da barra de menus requer o macOS 27 ou posterior. Este Mac usa o macOS %@.", unsupportedAPI: "Esta versão do macOS não oferece os controles da barra de menus de que o Organizador da barra de menus depende.",
        otherManagerFormat: "%@ está aberto. Dois gerenciadores de barra de menus ocultando ícones ao mesmo tempo atrapalham um ao outro; encerre-o primeiro.",
        hiddenSection: "Ocultos", visibleSection: "Visíveis", hiddenEmpty: "Nada oculto. Mantenha ⌘ pressionada e arraste um ícone para a esquerda da seta, ou use Ocultar aqui.", visibleEmpty: "Nenhum ícone encontrado. Verifique se a Acessibilidade foi concedida.",
        hideItem: "Ocultar", showItem: "Mostrar", lockedSystem: "Gerenciado pelo macOS", lockedOwn: "O ícone do Vorssaint fica sempre visível", lockedHelper: "Desenhado por um processo auxiliar que o macOS não consegue ocultar",
        apply: "Aplicar", applyPendingFormat: "Aplicar alterações (%d)", discard: "Descartar", applying: "Movendo ícones…", applyReportFormat: "Movidos: %1$d, com falha: %2$d",
        applyHint: "O Vorssaint move os ícones arrastando com ⌘. Não toque no mouse por um instante.", dragHint: "Você também pode manter ⌘ pressionada e arrastar ícones de um lado para o outro da seta na barra de menus.",
        perAppNote: "O macOS oculta ícones por app: vários ícones do mesmo app são ocultados juntos.", systemExtrasNote: "Enquanto os ícones estão ocultos, o macOS também remove alguns dos seus próprios itens, como o Foco. Eles voltam quando os ícones são mostrados.",
        autoRehide: "Ocultar de novo automaticamente", autoRehideNever: "Nunca", autoRehideSecondsFormat: "Após %d s", showHiddenIcons: "Mostrar ícones ocultos", hideIcons: "Ocultar ícones",
        statusCollapsed: "Os ícones estão ocultos", statusExpanded: "Os ícones estão visíveis", refresh: "Atualizar",
        problemAccessibility: "É preciso Acessibilidade para ler a barra de menus.", problemChevronNotFound: "A seta ainda não está na barra de menus. A ocultação está em pausa.",
        problemActivationFormat: "Falha ao ocultar: %@", problemNothingToHide: "Não há nada à esquerda da seta, então nada foi ocultado.")
    static let tr = MenuBarOrganizerFeatureStrings(
        title: "Menü Çubuğu Düzenleyici", hubDescription: "Menü çubuğu simgelerini bir okun arkasına gizleyin, Ayarlar’dan yeniden sıralayın ve tek tıklamayla geri getirin. macOS 27 veya sonrası.",
        enable: "Menü çubuğu simgelerini gizle", enableCaption: "Okun solundaki simgeler gizlenir. Göstermek için oka tıklayın.",
        unsupportedOSFormat: "Menü Çubuğu Düzenleyici için macOS 27 veya sonrası gerekir. Bu Mac’te macOS %@ yüklü.", unsupportedAPI: "Bu macOS sürümü, Menü Çubuğu Düzenleyici’nin ihtiyaç duyduğu menü çubuğu denetimlerini sunmuyor.",
        otherManagerFormat: "%@ çalışıyor. Aynı anda simge gizleyen iki menü çubuğu yöneticisi birbirini bozar; önce onu kapatın.",
        hiddenSection: "Gizli", visibleSection: "Görünür", hiddenEmpty: "Gizli simge yok. ⌘ tuşunu basılı tutup bir simgeyi okun soluna sürükleyin veya buradaki Gizle’yi kullanın.", visibleEmpty: "Simge bulunamadı. Erişilebilirlik izninin verildiğinden emin olun.",
        hideItem: "Gizle", showItem: "Göster", lockedSystem: "macOS tarafından yönetiliyor", lockedOwn: "Vorssaint’in kendi simgesi hep görünür kalır", lockedHelper: "macOS’in gizleyemediği bir yardımcı işlem tarafından çiziliyor",
        apply: "Uygula", applyPendingFormat: "%d değişikliği uygula", discard: "Vazgeç", applying: "Simgeler taşınıyor…", applyReportFormat: "%1$d taşındı, %2$d başarısız",
        applyHint: "Vorssaint simgeleri ⌘ ile sürükleyerek taşır. Bir süre fareye dokunmayın.", dragHint: "Menü çubuğunda ⌘ tuşunu basılı tutup simgeleri okun öbür tarafına da sürükleyebilirsiniz.",
        perAppNote: "macOS simgeleri uygulama bazında gizler: aynı uygulamanın birden fazla simgesi birlikte gizlenir.", systemExtrasNote: "Simgeler gizliyken macOS, Odak gibi kendi öğelerinden bazılarını da kaldırır. Simgeler gösterildiğinde geri gelirler.",
        autoRehide: "Otomatik olarak yeniden gizle", autoRehideNever: "Asla", autoRehideSecondsFormat: "%d sn sonra", showHiddenIcons: "Gizli simgeleri göster", hideIcons: "Simgeleri gizle",
        statusCollapsed: "Simgeler gizli", statusExpanded: "Simgeler görünür", refresh: "Yenile",
        problemAccessibility: "Menü çubuğunu okumak için Erişilebilirlik izni gerekir.", problemChevronNotFound: "Ok henüz menü çubuğunda değil. Gizleme duraklatıldı.",
        problemActivationFormat: "Gizleme başarısız: %@", problemNothingToHide: "Okun solunda hiçbir şey olmadığı için hiçbir şey gizlenmedi.")
    static let ru = MenuBarOrganizerFeatureStrings(
        title: "Органайзер строки меню", hubDescription: "Прячьте значки строки меню за стрелкой, меняйте их порядок в настройках и возвращайте одним нажатием. macOS 27 или новее.",
        enable: "Скрывать значки строки меню", enableCaption: "Значки слева от стрелки скрываются. Нажмите стрелку, чтобы показать их.",
        unsupportedOSFormat: "Органайзеру строки меню нужна macOS 27 или новее. На этом Mac установлена macOS %@.", unsupportedAPI: "Эта сборка macOS не предоставляет элементы управления строкой меню, на которые опирается Органайзер строки меню.",
        otherManagerFormat: "Запущено приложение %@. Два менеджера строки меню, скрывающие значки одновременно, мешают друг другу; сначала закройте его.",
        hiddenSection: "Скрытые", visibleSection: "Видимые", hiddenEmpty: "Ничего не скрыто. Удерживая ⌘, перетащите значок левее стрелки или нажмите здесь кнопку скрытия.", visibleEmpty: "Значки не найдены. Убедитесь, что разрешён Универсальный доступ.",
        hideItem: "Скрыть", showItem: "Показать", lockedSystem: "Управляется macOS", lockedOwn: "Значок Vorssaint всегда остаётся на виду", lockedHelper: "Рисуется вспомогательным процессом, который macOS не может скрыть",
        apply: "Применить", applyPendingFormat: "Применить изменения: %d", discard: "Отменить", applying: "Перемещение значков…", applyReportFormat: "Перемещено: %1$d, не удалось: %2$d",
        applyHint: "Vorssaint перемещает значки перетаскиванием с ⌘. Не трогайте мышь несколько секунд.", dragHint: "Значки можно также перетаскивать через стрелку прямо в строке меню, удерживая ⌘.",
        perAppNote: "macOS скрывает значки по приложениям: несколько значков одного приложения скрываются вместе.", systemExtrasNote: "Пока значки скрыты, macOS убирает и некоторые собственные элементы, например Фокусирование. Они вернутся, когда значки будут показаны.",
        autoRehide: "Скрывать снова автоматически", autoRehideNever: "Никогда", autoRehideSecondsFormat: "Через %d с", showHiddenIcons: "Показать скрытые значки", hideIcons: "Скрыть значки",
        statusCollapsed: "Значки скрыты", statusExpanded: "Значки показаны", refresh: "Обновить",
        problemAccessibility: "Чтобы читать строку меню, нужен Универсальный доступ.", problemChevronNotFound: "Стрелки пока нет в строке меню. Скрытие приостановлено.",
        problemActivationFormat: "Не удалось скрыть: %@", problemNothingToHide: "Слева от стрелки ничего нет, поэтому ничего не скрыто.")
    static let es = MenuBarOrganizerFeatureStrings(
        title: "Organizador de la barra de menús", hubDescription: "Oculta iconos de la barra de menús tras una flecha, reordénalos desde Ajustes y recupéralos con un clic. macOS 27 o posterior.",
        enable: "Ocultar iconos de la barra de menús", enableCaption: "Los iconos a la izquierda de la flecha se ocultan. Haz clic en la flecha para mostrarlos.",
        unsupportedOSFormat: "El Organizador de la barra de menús necesita macOS 27 o posterior. Este Mac usa macOS %@.", unsupportedAPI: "Esta versión de macOS no ofrece los controles de la barra de menús de los que depende el Organizador de la barra de menús.",
        otherManagerFormat: "%@ está abierto. Dos gestores de la barra de menús ocultando iconos a la vez se estorban; ciérralo primero.",
        hiddenSection: "Ocultos", visibleSection: "Visibles", hiddenEmpty: "No hay nada oculto. Mantén pulsada ⌘ y arrastra un icono a la izquierda de la flecha, o usa Ocultar aquí.", visibleEmpty: "No se encontraron iconos. Comprueba que has concedido Accesibilidad.",
        hideItem: "Ocultar", showItem: "Mostrar", lockedSystem: "Gestionado por macOS", lockedOwn: "El icono de Vorssaint siempre queda visible", lockedHelper: "Lo dibuja un proceso auxiliar que macOS no puede ocultar",
        apply: "Aplicar", applyPendingFormat: "Aplicar cambios (%d)", discard: "Descartar", applying: "Moviendo iconos…", applyReportFormat: "Movidos: %1$d, fallidos: %2$d",
        applyHint: "Vorssaint mueve los iconos arrastrándolos con ⌘. No toques el ratón durante un momento.", dragHint: "También puedes mantener pulsada ⌘ y arrastrar los iconos al otro lado de la flecha en la barra de menús.",
        perAppNote: "macOS oculta los iconos por app: varios iconos de una misma app se ocultan juntos.", systemExtrasNote: "Mientras los iconos están ocultos, macOS también quita algunos de sus propios elementos, como Concentración. Vuelven cuando se muestran los iconos.",
        autoRehide: "Volver a ocultar automáticamente", autoRehideNever: "Nunca", autoRehideSecondsFormat: "Tras %d s", showHiddenIcons: "Mostrar iconos ocultos", hideIcons: "Ocultar iconos",
        statusCollapsed: "Los iconos están ocultos", statusExpanded: "Los iconos están visibles", refresh: "Actualizar",
        problemAccessibility: "Se necesita Accesibilidad para leer la barra de menús.", problemChevronNotFound: "La flecha aún no está en la barra de menús. La ocultación está en pausa.",
        problemActivationFormat: "No se pudo ocultar: %@", problemNothingToHide: "No hay nada a la izquierda de la flecha, así que no se ocultó nada.")
    static let sk = MenuBarOrganizerFeatureStrings(
        title: "Organizér lišty", hubDescription: "Skryte ikony v lište za šípku, zmeňte ich poradie v Nastaveniach a jedným kliknutím ich vráťte späť. macOS 27 alebo novší.",
        enable: "Skrývať ikony v lište", enableCaption: "Ikony naľavo od šípky sa skryjú. Kliknutím na šípku ich zobrazíte.",
        unsupportedOSFormat: "Organizér lišty vyžaduje macOS 27 alebo novší. Na tomto Macu beží macOS %@.", unsupportedAPI: "Táto verzia macOS neposkytuje ovládanie lišty, ktoré Organizér lišty potrebuje.",
        otherManagerFormat: "Beží aplikácia %@. Dvaja správcovia lišty, ktorí skrývajú ikony naraz, si prekážajú; najprv ju ukončite.",
        hiddenSection: "Skryté", visibleSection: "Zobrazené", hiddenEmpty: "Nič nie je skryté. Podržte ⌘ a potiahnite ikonu naľavo od šípky, alebo tu použite Skryť.", visibleEmpty: "Nenašli sa žiadne ikony. Skontrolujte, či je povolená Prístupnosť.",
        hideItem: "Skryť", showItem: "Zobraziť", lockedSystem: "Spravuje macOS", lockedOwn: "Vlastná ikona Vorssaintu zostáva viditeľná", lockedHelper: "Kreslí ju pomocný proces, ktorý macOS nedokáže skryť",
        apply: "Použiť", applyPendingFormat: "Použiť zmeny: %d", discard: "Zahodiť", applying: "Presúvajú sa ikony…", applyReportFormat: "Presunuté: %1$d, zlyhalo: %2$d",
        applyHint: "Vorssaint presúva ikony ťahaním s ⌘. Chvíľu sa nedotýkajte myši.", dragHint: "Ikony môžete aj priamo v lište potiahnuť cez šípku s podržaným ⌘.",
        perAppNote: "macOS skrýva ikony po aplikáciách: viaceré ikony jednej aplikácie sa skryjú spolu.", systemExtrasNote: "Kým sú ikony skryté, macOS odstráni aj niektoré vlastné položky, napríklad Môj čas. Vrátia sa, keď sa ikony zobrazia.",
        autoRehide: "Znova skryť automaticky", autoRehideNever: "Nikdy", autoRehideSecondsFormat: "Po %d s", showHiddenIcons: "Zobraziť skryté ikony", hideIcons: "Skryť ikony",
        statusCollapsed: "Ikony sú skryté", statusExpanded: "Ikony sú zobrazené", refresh: "Obnoviť",
        problemAccessibility: "Na čítanie lišty je potrebná Prístupnosť.", problemChevronNotFound: "Šípka ešte nie je v lište. Skrývanie je pozastavené.",
        problemActivationFormat: "Skrytie zlyhalo: %@", problemNothingToHide: "Naľavo od šípky nič nie je, takže sa nič neskrylo.")
    static let de = MenuBarOrganizerFeatureStrings(
        title: "Menüleisten-Organizer", hubDescription: "Verstecke Menüleistensymbole hinter einem Pfeil, ordne sie in den Einstellungen neu an und hole sie mit einem Klick zurück. macOS 27 oder neuer.",
        enable: "Menüleistensymbole ausblenden", enableCaption: "Symbole links vom Pfeil werden ausgeblendet. Klicke auf den Pfeil, um sie einzublenden.",
        unsupportedOSFormat: "Der Menüleisten-Organizer benötigt macOS 27 oder neuer. Auf diesem Mac läuft macOS %@.", unsupportedAPI: "Diese macOS-Version stellt die Menüleisten-Steuerung nicht bereit, auf die der Menüleisten-Organizer angewiesen ist.",
        otherManagerFormat: "%@ läuft gerade. Zwei Menüleisten-Manager, die gleichzeitig Symbole ausblenden, stören sich gegenseitig; beende die App zuerst.",
        hiddenSection: "Ausgeblendet", visibleSection: "Eingeblendet", hiddenEmpty: "Nichts ausgeblendet. Halte ⌘ gedrückt und ziehe ein Symbol links neben den Pfeil oder nutze hier Ausblenden.", visibleEmpty: "Keine Symbole gefunden. Prüfe, ob die Bedienungshilfen erlaubt sind.",
        hideItem: "Ausblenden", showItem: "Einblenden", lockedSystem: "Von macOS verwaltet", lockedOwn: "Das eigene Symbol von Vorssaint bleibt sichtbar", lockedHelper: "Wird von einem Hilfsprozess gezeichnet, den macOS nicht ausblenden kann",
        apply: "Anwenden", applyPendingFormat: "Änderungen anwenden (%d)", discard: "Verwerfen", applying: "Symbole werden verschoben…", applyReportFormat: "%1$d verschoben, %2$d fehlgeschlagen",
        applyHint: "Vorssaint verschiebt Symbole per ⌘-Ziehen. Lass die Maus einen Moment lang los.", dragHint: "Du kannst Symbole auch mit gedrückter ⌘-Taste in der Menüleiste über den Pfeil ziehen.",
        perAppNote: "macOS blendet Symbole pro App aus: Mehrere Symbole einer App verschwinden gemeinsam.", systemExtrasNote: "Solange Symbole ausgeblendet sind, entfernt macOS auch einige eigene Einträge, etwa Fokus. Sie kehren zurück, sobald die Symbole eingeblendet werden.",
        autoRehide: "Automatisch wieder ausblenden", autoRehideNever: "Nie", autoRehideSecondsFormat: "Nach %d s", showHiddenIcons: "Ausgeblendete Symbole einblenden", hideIcons: "Symbole ausblenden",
        statusCollapsed: "Symbole sind ausgeblendet", statusExpanded: "Symbole sind eingeblendet", refresh: "Aktualisieren",
        problemAccessibility: "Zum Lesen der Menüleiste sind die Bedienungshilfen erforderlich.", problemChevronNotFound: "Der Pfeil ist noch nicht in der Menüleiste. Das Ausblenden ist pausiert.",
        problemActivationFormat: "Ausblenden fehlgeschlagen: %@", problemNothingToHide: "Links vom Pfeil steht nichts, daher wurde nichts ausgeblendet.")
    static let fr = MenuBarOrganizerFeatureStrings(
        title: "Organisateur de la barre des menus", hubDescription: "Masquez des icônes de la barre des menus derrière un chevron, réorganisez-les depuis les réglages et retrouvez-les d’un clic. macOS 27 ou ultérieur.",
        enable: "Masquer les icônes de la barre des menus", enableCaption: "Les icônes à gauche du chevron sont masquées. Cliquez sur le chevron pour les afficher.",
        unsupportedOSFormat: "L’Organisateur de la barre des menus nécessite macOS 27 ou ultérieur. Ce Mac utilise macOS %@.", unsupportedAPI: "Cette version de macOS ne fournit pas les commandes de la barre des menus dont l’Organisateur de la barre des menus a besoin.",
        otherManagerFormat: "%@ est ouvert. Deux gestionnaires de barre des menus qui masquent des icônes en même temps se gênent\u{00A0}; quittez-le d’abord.",
        hiddenSection: "Masquées", visibleSection: "Affichées", hiddenEmpty: "Rien n’est masqué. Maintenez ⌘ enfoncée et faites glisser une icône à gauche du chevron, ou utilisez Masquer ici.", visibleEmpty: "Aucune icône trouvée. Vérifiez que l’Accessibilité est autorisée.",
        hideItem: "Masquer", showItem: "Afficher", lockedSystem: "Géré par macOS", lockedOwn: "L’icône de Vorssaint reste toujours visible", lockedHelper: "Dessinée par un processus auxiliaire que macOS ne peut pas masquer",
        apply: "Appliquer", applyPendingFormat: "Appliquer les modifications (%d)", discard: "Annuler", applying: "Déplacement des icônes…", applyReportFormat: "Déplacées\u{00A0}: %1$d, échecs\u{00A0}: %2$d",
        applyHint: "Vorssaint déplace les icônes par glissement avec ⌘. Ne touchez pas à la souris pendant un instant.", dragHint: "Vous pouvez aussi maintenir ⌘ enfoncée et faire glisser les icônes de part et d’autre du chevron dans la barre des menus.",
        perAppNote: "macOS masque les icônes par app\u{00A0}: plusieurs icônes d’une même app sont masquées ensemble.", systemExtrasNote: "Tant que des icônes sont masquées, macOS retire aussi certains de ses propres éléments, comme Concentration. Ils reviennent dès que les icônes sont affichées.",
        autoRehide: "Masquer à nouveau automatiquement", autoRehideNever: "Jamais", autoRehideSecondsFormat: "Après %d s", showHiddenIcons: "Afficher les icônes masquées", hideIcons: "Masquer les icônes",
        statusCollapsed: "Les icônes sont masquées", statusExpanded: "Les icônes sont affichées", refresh: "Actualiser",
        problemAccessibility: "L’Accessibilité est requise pour lire la barre des menus.", problemChevronNotFound: "Le chevron n’est pas encore dans la barre des menus. Le masquage est en pause.",
        problemActivationFormat: "Échec du masquage\u{00A0}: %@", problemNothingToHide: "Il n’y a rien à gauche du chevron, donc rien n’a été masqué.")
    static let it = MenuBarOrganizerFeatureStrings(
        title: "Organizzatore barra dei menu", hubDescription: "Nascondi le icone della barra dei menu dietro una freccia, riordinale dalle Impostazioni e riportale indietro con un clic. macOS 27 o successivo.",
        enable: "Nascondi le icone della barra dei menu", enableCaption: "Le icone a sinistra della freccia vengono nascoste. Fai clic sulla freccia per mostrarle.",
        unsupportedOSFormat: "Organizzatore barra dei menu richiede macOS 27 o successivo. Questo Mac usa macOS %@.", unsupportedAPI: "Questa versione di macOS non offre i controlli della barra dei menu su cui si basa Organizzatore barra dei menu.",
        otherManagerFormat: "%@ è in esecuzione. Due gestori della barra dei menu che nascondono icone contemporaneamente si ostacolano; chiudilo prima.",
        hiddenSection: "Nascoste", visibleSection: "Visibili", hiddenEmpty: "Niente di nascosto. Tieni premuto ⌘ e trascina un’icona a sinistra della freccia, oppure usa Nascondi qui.", visibleEmpty: "Nessuna icona trovata. Controlla di aver concesso Accessibilità.",
        hideItem: "Nascondi", showItem: "Mostra", lockedSystem: "Gestita da macOS", lockedOwn: "L’icona di Vorssaint resta sempre visibile", lockedHelper: "Disegnata da un processo ausiliario che macOS non può nascondere",
        apply: "Applica", applyPendingFormat: "Applica modifiche (%d)", discard: "Annulla", applying: "Spostamento delle icone…", applyReportFormat: "Spostate: %1$d, non riuscite: %2$d",
        applyHint: "Vorssaint sposta le icone trascinandole con ⌘. Non toccare il mouse per un momento.", dragHint: "Puoi anche tenere premuto ⌘ e trascinare le icone oltre la freccia nella barra dei menu.",
        perAppNote: "macOS nasconde le icone per app: più icone della stessa app vengono nascoste insieme.", systemExtrasNote: "Mentre le icone sono nascoste, macOS rimuove anche alcuni dei propri elementi, come Full immersion. Tornano quando le icone vengono mostrate.",
        autoRehide: "Nascondi di nuovo automaticamente", autoRehideNever: "Mai", autoRehideSecondsFormat: "Dopo %d s", showHiddenIcons: "Mostra icone nascoste", hideIcons: "Nascondi icone",
        statusCollapsed: "Le icone sono nascoste", statusExpanded: "Le icone sono visibili", refresh: "Aggiorna",
        problemAccessibility: "Serve Accessibilità per leggere la barra dei menu.", problemChevronNotFound: "La freccia non è ancora nella barra dei menu. L’occultamento è in pausa.",
        problemActivationFormat: "Impossibile nascondere: %@", problemNothingToHide: "Non c’è niente a sinistra della freccia, quindi non è stato nascosto nulla.")
    static let ja = MenuBarOrganizerFeatureStrings(
        title: "メニューバーオーガナイザー", hubDescription: "メニューバーのアイコンを矢印の後ろに隠し、設定から並べ替えて、ワンクリックで元に戻せます。macOS 27以降。",
        enable: "メニューバーのアイコンを隠す", enableCaption: "矢印より左のアイコンが隠れます。矢印をクリックすると表示されます。",
        unsupportedOSFormat: "メニューバーオーガナイザーにはmacOS 27以降が必要です。このMacはmacOS %@です。", unsupportedAPI: "このmacOSビルドには、メニューバーオーガナイザーが必要とするメニューバーの制御機能がありません。",
        otherManagerFormat: "%@が実行中です。アイコンを隠すメニューバー管理アプリが2つ同時に動くと干渉します。先に終了してください。",
        hiddenSection: "非表示", visibleSection: "表示", hiddenEmpty: "隠れているアイコンはありません。⌘を押しながらアイコンを矢印の左へドラッグするか、ここで隠すを使ってください。", visibleEmpty: "アイコンが見つかりません。アクセシビリティが許可されているか確認してください。",
        hideItem: "隠す", showItem: "表示", lockedSystem: "macOSが管理", lockedOwn: "Vorssaint自身のアイコンは常に表示されます", lockedHelper: "macOSが隠せないヘルパープロセスが描画しています",
        apply: "適用", applyPendingFormat: "%d 件の変更を適用", discard: "破棄", applying: "アイコンを移動中…", applyReportFormat: "%1$d 件を移動、%2$d 件が失敗",
        applyHint: "Vorssaintは⌘ドラッグでアイコンを移動します。しばらくマウスに触れないでください。", dragHint: "メニューバーで⌘を押しながら、アイコンを矢印の反対側へドラッグすることもできます。",
        perAppNote: "macOSはアプリ単位でアイコンを隠します。同じアプリの複数のアイコンはまとめて隠れます。", systemExtrasNote: "アイコンが隠れている間、macOSは集中モードなど自身の項目の一部も取り除きます。アイコンを表示すると元に戻ります。",
        autoRehide: "自動的に再び隠す", autoRehideNever: "しない", autoRehideSecondsFormat: "%d 秒後", showHiddenIcons: "隠れたアイコンを表示", hideIcons: "アイコンを隠す",
        statusCollapsed: "アイコンは隠れています", statusExpanded: "アイコンは表示されています", refresh: "更新",
        problemAccessibility: "メニューバーを読み取るにはアクセシビリティが必要です。", problemChevronNotFound: "矢印がまだメニューバーにありません。非表示は一時停止中です。",
        problemActivationFormat: "隠せませんでした: %@", problemNothingToHide: "矢印の左に何もないため、何も隠されませんでした。")
    static let ko = MenuBarOrganizerFeatureStrings(
        title: "메뉴 막대 정리", hubDescription: "메뉴 막대 아이콘을 화살표 뒤로 숨기고, 설정에서 순서를 바꾸고, 클릭 한 번으로 다시 꺼냅니다. macOS 27 이상.",
        enable: "메뉴 막대 아이콘 숨기기", enableCaption: "화살표 왼쪽의 아이콘이 숨겨집니다. 화살표를 클릭하면 다시 표시됩니다.",
        unsupportedOSFormat: "메뉴 막대 정리를 사용하려면 macOS 27 이상이 필요합니다. 이 Mac은 macOS %@입니다.", unsupportedAPI: "이 macOS 빌드는 메뉴 막대 정리에 필요한 메뉴 막대 제어 기능을 제공하지 않습니다.",
        otherManagerFormat: "%@이(가) 실행 중입니다. 아이콘을 숨기는 메뉴 막대 관리 앱 두 개가 동시에 실행되면 서로 충돌하니 먼저 종료하세요.",
        hiddenSection: "숨김", visibleSection: "표시", hiddenEmpty: "숨겨진 아이콘이 없습니다. ⌘을 누른 채 아이콘을 화살표 왼쪽으로 드래그하거나 여기에서 숨기기를 사용하세요.", visibleEmpty: "아이콘을 찾을 수 없습니다. 손쉬운 사용 권한이 허용되어 있는지 확인하세요.",
        hideItem: "숨기기", showItem: "표시", lockedSystem: "macOS에서 관리", lockedOwn: "Vorssaint 자체 아이콘은 항상 표시됩니다", lockedHelper: "macOS가 숨길 수 없는 보조 프로세스가 그립니다",
        apply: "적용", applyPendingFormat: "변경 사항 %d개 적용", discard: "취소", applying: "아이콘 이동 중…", applyReportFormat: "%1$d개 이동, %2$d개 실패",
        applyHint: "Vorssaint는 ⌘ 드래그로 아이콘을 옮깁니다. 잠시 마우스에서 손을 떼 주세요.", dragHint: "메뉴 막대에서 ⌘을 누른 채 아이콘을 화살표 반대편으로 드래그할 수도 있습니다.",
        perAppNote: "macOS는 앱 단위로 아이콘을 숨깁니다. 한 앱의 여러 아이콘은 함께 숨겨집니다.", systemExtrasNote: "아이콘이 숨겨진 동안 macOS는 집중 모드 같은 자체 항목 일부도 함께 제거합니다. 아이콘을 표시하면 다시 나타납니다.",
        autoRehide: "자동으로 다시 숨기기", autoRehideNever: "안 함", autoRehideSecondsFormat: "%d초 후", showHiddenIcons: "숨겨진 아이콘 표시", hideIcons: "아이콘 숨기기",
        statusCollapsed: "아이콘이 숨겨져 있습니다", statusExpanded: "아이콘이 표시되어 있습니다", refresh: "새로 고침",
        problemAccessibility: "메뉴 막대를 읽으려면 손쉬운 사용 권한이 필요합니다.", problemChevronNotFound: "화살표가 아직 메뉴 막대에 없습니다. 숨기기가 일시 중지되었습니다.",
        problemActivationFormat: "숨기지 못했습니다: %@", problemNothingToHide: "화살표 왼쪽에 아무것도 없어 숨긴 항목이 없습니다.")
    static let uk = MenuBarOrganizerFeatureStrings(
        title: "Органайзер смуги меню", hubDescription: "Ховайте іконки смуги меню за стрілкою, змінюйте їхній порядок у параметрах і повертайте одним клацанням. macOS 27 або новіша.",
        enable: "Приховувати іконки смуги меню", enableCaption: "Іконки ліворуч від стрілки приховуються. Клацніть стрілку, щоб показати їх.",
        unsupportedOSFormat: "Органайзеру смуги меню потрібна macOS 27 або новіша. На цьому Mac інстальовано macOS %@.", unsupportedAPI: "Ця збірка macOS не надає елементів керування смугою меню, на які спирається Органайзер смуги меню.",
        otherManagerFormat: "Запущено програму %@. Два менеджери смуги меню, що одночасно приховують іконки, заважають один одному; спершу закрийте її.",
        hiddenSection: "Приховані", visibleSection: "Видимі", hiddenEmpty: "Нічого не приховано. Утримуючи ⌘, перетягніть іконку ліворуч від стрілки або скористайтеся тут кнопкою приховання.", visibleEmpty: "Іконок не знайдено. Переконайтеся, що надано Універсальний доступ.",
        hideItem: "Приховати", showItem: "Показати", lockedSystem: "Керується macOS", lockedOwn: "Іконка Vorssaint завжди лишається на видноті", lockedHelper: "Малюється допоміжним процесом, який macOS не може приховати",
        apply: "Застосувати", applyPendingFormat: "Застосувати зміни: %d", discard: "Відхилити", applying: "Переміщення іконок…", applyReportFormat: "Переміщено: %1$d, не вдалося: %2$d",
        applyHint: "Vorssaint переміщує іконки перетягуванням із ⌘. Не торкайтеся миші кілька секунд.", dragHint: "Іконки можна також перетягувати через стрілку просто у смузі меню, утримуючи ⌘.",
        perAppNote: "macOS приховує іконки за програмами: кілька іконок однієї програми приховуються разом.", systemExtrasNote: "Поки іконки приховано, macOS прибирає й деякі власні елементи, як-от Зосередження. Вони повернуться, щойно іконки буде показано.",
        autoRehide: "Автоматично приховувати знову", autoRehideNever: "Ніколи", autoRehideSecondsFormat: "Через %d с", showHiddenIcons: "Показати приховані іконки", hideIcons: "Приховати іконки",
        statusCollapsed: "Іконки приховано", statusExpanded: "Іконки показано", refresh: "Оновити",
        problemAccessibility: "Щоб читати смугу меню, потрібен Універсальний доступ.", problemChevronNotFound: "Стрілки ще немає у смузі меню. Приховування призупинено.",
        problemActivationFormat: "Не вдалося приховати: %@", problemNothingToHide: "Ліворуч від стрілки нічого немає, тож нічого не приховано.")
    static let zhHans = MenuBarOrganizerFeatureStrings(
        title: "菜单栏整理器", hubDescription: "把菜单栏图标藏到箭头后面，在设置中调整顺序，点一下即可重新显示。需要 macOS 27 或更高版本。",
        enable: "隐藏菜单栏图标", enableCaption: "箭头左侧的图标会被隐藏。点按箭头即可显示。",
        unsupportedOSFormat: "菜单栏整理器需要 macOS 27 或更高版本。这台 Mac 运行的是 macOS %@。", unsupportedAPI: "此 macOS 版本未提供菜单栏整理器所依赖的菜单栏控制功能。",
        otherManagerFormat: "%@ 正在运行。两个菜单栏管理工具同时隐藏图标会互相干扰，请先退出它。",
        hiddenSection: "已隐藏", visibleSection: "已显示", hiddenEmpty: "没有隐藏的图标。按住 ⌘ 将图标拖到箭头左侧，或在此处使用隐藏。", visibleEmpty: "未找到图标。请确认已授予辅助功能权限。",
        hideItem: "隐藏", showItem: "显示", lockedSystem: "由 macOS 管理", lockedOwn: "Vorssaint 自己的图标始终显示", lockedHelper: "由 macOS 无法隐藏的辅助进程绘制",
        apply: "应用", applyPendingFormat: "应用 %d 项更改", discard: "放弃", applying: "正在移动图标…", applyReportFormat: "已移动 %1$d 个，失败 %2$d 个",
        applyHint: "Vorssaint 通过按住 ⌘ 拖移来移动图标。请暂时不要碰鼠标。", dragHint: "你也可以在菜单栏中按住 ⌘，将图标拖到箭头的另一侧。",
        perAppNote: "macOS 按 App 隐藏图标：同一个 App 的多个图标会一起隐藏。", systemExtrasNote: "图标隐藏期间，macOS 也会移除自身的部分项目，例如专注模式。图标显示后它们会恢复。",
        autoRehide: "自动重新隐藏", autoRehideNever: "永不", autoRehideSecondsFormat: "%d 秒后", showHiddenIcons: "显示隐藏的图标", hideIcons: "隐藏图标",
        statusCollapsed: "图标已隐藏", statusExpanded: "图标已显示", refresh: "刷新",
        problemAccessibility: "读取菜单栏需要辅助功能权限。", problemChevronNotFound: "箭头尚未出现在菜单栏中。隐藏已暂停。",
        problemActivationFormat: "隐藏失败：%@", problemNothingToHide: "箭头左侧没有任何图标，因此没有隐藏任何内容。")
    static let zhTW = MenuBarOrganizerFeatureStrings(
        title: "選單列整理器", hubDescription: "將選單列圖像藏到箭頭後方，在設定中調整順序，按一下即可重新顯示。需要 macOS 27 或以上版本。",
        enable: "隱藏選單列圖像", enableCaption: "箭頭左側的圖像會被隱藏。按一下箭頭即可顯示。",
        unsupportedOSFormat: "選單列整理器需要 macOS 27 或以上版本。這部 Mac 執行的是 macOS %@。", unsupportedAPI: "此 macOS 版本未提供選單列整理器所仰賴的選單列控制功能。",
        otherManagerFormat: "%@ 正在執行。兩個選單列管理工具同時隱藏圖像會互相干擾，請先將其結束。",
        hiddenSection: "已隱藏", visibleSection: "已顯示", hiddenEmpty: "沒有隱藏的圖像。按住 ⌘ 將圖像拖到箭頭左側，或在此處使用隱藏。", visibleEmpty: "找不到圖像。請確認已授予輔助使用權限。",
        hideItem: "隱藏", showItem: "顯示", lockedSystem: "由 macOS 管理", lockedOwn: "Vorssaint 自己的圖像一律顯示", lockedHelper: "由 macOS 無法隱藏的輔助程序繪製",
        apply: "套用", applyPendingFormat: "套用 %d 項變更", discard: "捨棄", applying: "正在搬移圖像…", applyReportFormat: "已搬移 %1$d 個，失敗 %2$d 個",
        applyHint: "Vorssaint 會按住 ⌘ 拖移來搬移圖像。請暫時不要碰滑鼠。", dragHint: "您也可以在選單列中按住 ⌘，將圖像拖到箭頭的另一側。",
        perAppNote: "macOS 以 App 為單位隱藏圖像：同一個 App 的多個圖像會一起隱藏。", systemExtrasNote: "圖像隱藏期間，macOS 也會移除自身的部分項目，例如專注模式。圖像顯示後它們會恢復。",
        autoRehide: "自動重新隱藏", autoRehideNever: "永不", autoRehideSecondsFormat: "%d 秒後", showHiddenIcons: "顯示隱藏的圖像", hideIcons: "隱藏圖像",
        statusCollapsed: "圖像已隱藏", statusExpanded: "圖像已顯示", refresh: "重新整理",
        problemAccessibility: "讀取選單列需要輔助使用權限。", problemChevronNotFound: "箭頭尚未出現在選單列中。隱藏已暫停。",
        problemActivationFormat: "隱藏失敗：%@", problemNothingToHide: "箭頭左側沒有任何圖像，因此沒有隱藏任何項目。")
    static let zhHK = MenuBarOrganizerFeatureStrings(
        title: "選單列整理工具", hubDescription: "將選單列圖像收到箭嘴後面，在設定中調整次序，按一下即可重新顯示。需要 macOS 27 或以上版本。",
        enable: "隱藏選單列圖像", enableCaption: "箭嘴左邊的圖像會被隱藏。按一下箭嘴即可顯示。",
        unsupportedOSFormat: "選單列整理工具需要 macOS 27 或以上版本。這部 Mac 執行的是 macOS %@。", unsupportedAPI: "此 macOS 版本未提供選單列整理工具所依賴的選單列控制功能。",
        otherManagerFormat: "%@ 正在執行。兩個選單列管理工具同時隱藏圖像會互相干擾，請先將其結束。",
        hiddenSection: "已隱藏", visibleSection: "已顯示", hiddenEmpty: "沒有隱藏的圖像。按住 ⌘ 將圖像拖到箭嘴左邊，或在此處使用隱藏。", visibleEmpty: "找不到圖像。請確認已授予輔助使用權限。",
        hideItem: "隱藏", showItem: "顯示", lockedSystem: "由 macOS 管理", lockedOwn: "Vorssaint 自己的圖像一律顯示", lockedHelper: "由 macOS 無法隱藏的輔助程序繪製",
        apply: "套用", applyPendingFormat: "套用 %d 項變更", discard: "捨棄", applying: "正在移動圖像…", applyReportFormat: "已移動 %1$d 個，失敗 %2$d 個",
        applyHint: "Vorssaint 會按住 ⌘ 拖移來移動圖像。請暫時不要觸碰滑鼠。", dragHint: "您也可以在選單列中按住 ⌘，將圖像拖到箭嘴的另一邊。",
        perAppNote: "macOS 以 App 為單位隱藏圖像：同一個 App 的多個圖像會一併隱藏。", systemExtrasNote: "圖像隱藏期間，macOS 亦會移除自身的部分項目，例如專注模式。圖像顯示後它們會恢復。",
        autoRehide: "自動重新隱藏", autoRehideNever: "永不", autoRehideSecondsFormat: "%d 秒後", showHiddenIcons: "顯示隱藏的圖像", hideIcons: "隱藏圖像",
        statusCollapsed: "圖像已隱藏", statusExpanded: "圖像已顯示", refresh: "重新整理",
        problemAccessibility: "讀取選單列需要輔助使用權限。", problemChevronNotFound: "箭嘴尚未出現在選單列中。隱藏已暫停。",
        problemActivationFormat: "隱藏失敗：%@", problemNothingToHide: "箭嘴左邊沒有任何圖像，因此沒有隱藏任何項目。")
}
