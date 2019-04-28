import UIKit

struct Palette {

    let objects: [Any]

    func current() -> Any {
        return objects[ThemeSelector.themeIndex]
    }

    func typedCurrent<Type>() -> Type {
        return current() as! Type
    }
}

protocol Theme {

    var name: String { get }

    var statusBarStyle: UIStatusBarStyle { get }

    var barStyle: UIBarStyle { get }

    var effect: UIVisualEffect { get }

    var colors: [ColorKey: UIColor] { get }
}

enum ColorKey: Int {

    case backgroundPage
    case backgroundContent
    case separator
    case tint
    case backgroundHighlight
    case headerColor
    case actionColor
    case captionColor
    case arrowColor
    case deselectedColor
    case dateColor
    case chartLine
    case maskColor
    case yColor
}

extension Palette {

    static var backgroundPageColor: Palette {
        return ThemeSelector.colorPalette(for: .backgroundPage)
    }

    static var backgroundContentColor: Palette {
        return ThemeSelector.colorPalette(for: .backgroundContent)
    }

    static var statusBarStyle: Palette {
        return ThemeSelector.statusBarPalette()
    }

    static var tintColor: Palette {
        return ThemeSelector.colorPalette(for: .tint)
    }

    static var separatorColor: Palette {
        return ThemeSelector.colorPalette(for: .separator)
    }

    static var backgroundHighlightColor: Palette {
        return ThemeSelector.colorPalette(for: .backgroundHighlight)
    }

    static var headerColor: Palette {
        return ThemeSelector.colorPalette(for: .headerColor)
    }

    static var actionColor: Palette {
        return ThemeSelector.colorPalette(for: .actionColor)
    }

    static var captionColor: Palette {
        return ThemeSelector.colorPalette(for: .captionColor)
    }

    static var arrowColor: Palette {
        return ThemeSelector.colorPalette(for: .arrowColor)
    }

    static var deselectedColor: Palette {
        return ThemeSelector.colorPalette(for: .deselectedColor)
    }

    static var effect: Palette {
        return ThemeSelector.effectPalette()
    }

    static var dateColor: Palette {
        return ThemeSelector.colorPalette(for: .dateColor)
    }

    static var chartLine: Palette {
        return ThemeSelector.colorPalette(for: .chartLine)
    }

    static var maskColor: Palette {
        return ThemeSelector.colorPalette(for: .maskColor)
    }

    static var yColor: Palette {
        return ThemeSelector.colorPalette(for: .yColor)
    }
}
