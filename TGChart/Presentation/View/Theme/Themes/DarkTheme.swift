import UIKit

struct DarkTheme: Theme {

    let name = "Night"

    let statusBarStyle: UIStatusBarStyle = .lightContent

    let barStyle: UIBarStyle = .black

    let effect: UIVisualEffect = UIBlurEffect(style: .dark)

    let colors: [ColorKey : UIColor] = [
        .backgroundPage: .hex(0x1a222c),
        .backgroundContent: .hex(0x242f3e),
        .tint: .white,
        .separator: .hex(0x131a23),
        .backgroundHighlight: .hex(0x222222),
        .headerColor: .hex(0x5e6b7d),
        .actionColor: .hex(0x448ff7),
        .captionColor: .hex(0x8596ab),
        .arrowColor: UIColor.hex(0x384657),
        .deselectedColor: UIColor.hex(0x1f2a39).withAlphaComponent(0.8),
        .dateColor: .hex(0xf7f7f7),
        .chartLine: UIColor.hex(0xffffff).withAlphaComponent(0.1),
        .maskColor: UIColor.hex(0x242f3e).withAlphaComponent(0.5),
        .yColor: UIColor.hex(0xf7f7f7).withAlphaComponent(0.9)
    ]
}
