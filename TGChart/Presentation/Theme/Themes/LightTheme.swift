import UIKit

struct LightTheme: Theme {

    let name = "Day"

    let statusBarStyle: UIStatusBarStyle = {
        if #available(iOS 13, *) {
            return .darkContent
        } else {
            return .default
        }
    }()

    let barStyle: UIBarStyle = .default

    let effect: UIVisualEffect = UIBlurEffect(style: .extraLight)

    let colors: [ColorKey : UIColor] = [
        .backgroundPage: .hex(0xefeff3),
        .backgroundContent: .hex(0xfefefe),
        .tint: .black,
        .separator: .hex(0xc8c7cc),
        .backgroundHighlight: .hex(0xdddddd),
        .headerColor: .hex(0x6d6d72),
        .actionColor: .hex(0x367cde),
        .captionColor: .hex(0x8E8E93),
        .arrowColor: UIColor.hex(0xcad2db),
        .deselectedColor: UIColor.hex(0xf6f8fa).withAlphaComponent(0.8),
        .dateColor: .hex(0x6d6d72),
        .yColor: UIColor.hex(0x252529).withAlphaComponent(0.5),
        .chartLine: UIColor.hex(0x182d3b).withAlphaComponent(0.1),
        .maskColor: UIColor.hex(0xfefefe).withAlphaComponent(0.8)
    ]
}
