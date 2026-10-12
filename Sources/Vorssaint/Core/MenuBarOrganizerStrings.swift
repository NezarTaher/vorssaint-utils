// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Copy for the menu-bar organizer itself. Keeping this small catalog separate
/// avoids making every feature catalog grow for a control that is optional.
struct MenuBarOrganizerStrings {
    let title: String
    let enabled: String
    let enabledCaption: String
    let hiddenSection: String
    let alwaysHiddenSection: String
    let showSection: String
    let hideSection: String
    let showAlwaysHidden: String
    let hideAlwaysHidden: String
    let arrangeHint: String
    let settings: String
    let revealAll: String
    let modernSystemHint: String
    let visibilityError: String
    let nativeInstructions: String
    let applications: String
    let visible: String
    let search: String
    let updating: String
    let hiddenBar: String
    let noHiddenItems: String
    let grantAccessibility: String
    let accessibilityNeeded: String
    let itemUnavailable: String
    let applicationLocationNeeded: String

    static func localized(_ language: AppLanguage) -> MenuBarOrganizerStrings {
        language == .ar ? .ar : .enUS
    }

    static let enUS = MenuBarOrganizerStrings(
        title: "Menu bar organizer",
        enabled: "Organize menu bar icons",
        enabledCaption: "Adds collapsible sections so you can keep less-used app icons out of sight.",
        hiddenSection: "Hidden section",
        alwaysHiddenSection: "Always-hidden section",
        showSection: "Show hidden section",
        hideSection: "Hide hidden section",
        showAlwaysHidden: "Show always-hidden section",
        hideAlwaysHidden: "Hide always-hidden section",
        arrangeHint: "First reveal all icons. Hold Command and drag: always-hidden icons to the left of ‖, hidden icons between ‖ and │, visible icons to the right of │. Click the separate arrow to hide or show; Option-click reveals the always-hidden section.",
        settings: "Open Vorssaint settings…",
        revealAll: "Reveal all icons for arranging",
        modernSystemHint: "On macOS 27, all icons belonging to an app use the same section. Some additional system indicators may disappear while hiding is active.",
        visibilityError: "The system could not hide the icons. All icons have been restored.",
        nativeInstructions: "Click the menu bar arrow to open hidden icons in a bar below it. Click an icon to open its menu; right-click it to change its section. Option-click the arrow to include always-hidden icons. Right-click any Vorssaint menu bar icon to manage sections or reveal all icons for Command-drag arranging.",
        applications: "Menu bar applications",
        visible: "Visible",
        search: "Search applications",
        updating: "Updating menu bar…",
        hiddenBar: "Hidden menu bar icons",
        noHiddenItems: "No hidden icons. Right-click the arrow to choose which menu bar apps to hide.",
        grantAccessibility: "Allow Accessibility…",
        accessibilityNeeded: "Allow Accessibility to discover and open menu bar icons.",
        itemUnavailable: "This icon is unavailable. Try again after the application responds.",
        applicationLocationNeeded: "Run the installed copy of Vorssaint in Applications to keep the organizer arrow visible. All icons remain visible until then."
    )

    static let ar = MenuBarOrganizerStrings(
        title: "منظّم شريط القوائم",
        enabled: "تنظيم أيقونات شريط القوائم",
        enabledCaption: "يضيف أقسامًا قابلة للطي لإبقاء أيقونات التطبيقات الأقل استخدامًا خارج الشريط.",
        hiddenSection: "القسم المخفي",
        alwaysHiddenSection: "القسم المخفي دائمًا",
        showSection: "إظهار القسم المخفي",
        hideSection: "إخفاء القسم المخفي",
        showAlwaysHidden: "إظهار القسم المخفي دائمًا",
        hideAlwaysHidden: "إخفاء القسم المخفي دائمًا",
        arrangeHint: "أظهر كل الأيقونات أولًا. اضغط ⌘ واسحب: المخفية دائمًا إلى يسار ‖، والمخفية بين ‖ و│، والظاهرة إلى يمين │. اضغط السهم المستقل للإخفاء والإظهار، أو اضغطه مع Option لإظهار المخفية دائمًا.",
        settings: "فتح إعدادات Vorssaint…",
        revealAll: "إظهار كل الأيقونات للترتيب",
        modernSystemHint: "في macOS 27 تكون جميع أيقونات التطبيق في القسم نفسه. قد تختفي بعض مؤشرات النظام الإضافية أثناء تفعيل الإخفاء.",
        visibilityError: "تعذّر على النظام إخفاء الأيقونات. أُعيد إظهار جميع الأيقونات.",
        nativeInstructions: "اضغط سهم شريط القوائم لعرض الأيقونات المخفية في شريط أسفله. اضغط الأيقونة لفتح قائمتها، أو انقرها بالزر الأيمن لتغيير قسمها. اضغط السهم مع Option لتضمين المخفية دائمًا. انقر أي أيقونة لـVorssaint في البار بالزر الأيمن لإدارة الأقسام أو إظهار جميع الأيقونات لترتيبها بالسحب مع ⌘.",
        applications: "تطبيقات شريط القوائم",
        visible: "ظاهر",
        search: "البحث في التطبيقات",
        updating: "جارٍ تحديث شريط القوائم…",
        hiddenBar: "أيقونات شريط القوائم المخفية",
        noHiddenItems: "لا توجد أيقونات مخفية. انقر السهم بالزر الأيمن لاختيار تطبيقات البار التي تريد إخفاءها.",
        grantAccessibility: "السماح بتسهيلات الاستخدام…",
        accessibilityNeeded: "اسمح بتسهيلات الاستخدام لاكتشاف أيقونات شريط القوائم وفتحها.",
        itemUnavailable: "هذه الأيقونة غير متاحة. حاول مجددًا بعد استجابة التطبيق.",
        applicationLocationNeeded: "شغّل نسخة Vorssaint المثبتة في التطبيقات حتى يبقى سهم المنظّم ظاهرًا. ستبقى جميع الأيقونات ظاهرة حتى ذلك الحين."
    )
}
