import UIKit

extension NSObject {

    struct PaletteBlock: Equatable, Hashable {

        let id: String
        let block: (Any) -> Void

        func hash(into hasher: inout Hasher) {
            hasher.combine(id.hashValue)
        }

        static func ==(lhs: PaletteBlock, rhs: PaletteBlock) -> Bool {
            return lhs.id == rhs.id
        }
    }

    typealias Palettes = [PaletteBlock: Palette]

    var palettes: Palettes {
        get {
            if let palettes = objc_getAssociatedObject(self, &palettesKey) as? Palettes {
                return palettes
            }
            let palettes = Palettes()
            objc_setAssociatedObject(self, &palettesKey, palettes, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: .themeUpdateNotificationName, object: nil)
            return palettes
        }
        set {
            objc_setAssociatedObject(self, &palettesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc func updateTheme() {
        palettes.forEach { block, palette in
            block.block(palette.current())
        }
    }
}

private var palettesKey = "palettes_key"
