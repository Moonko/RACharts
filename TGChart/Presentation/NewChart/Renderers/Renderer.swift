import UIKit

protocol Renderer: UIView {

    var needsRendering: Bool { get set }

    var viewport: Viewport! { get set }
}

extension Renderer {

    func renderIfNeeded() {
        guard needsRendering else { return }
        needsRendering = false

        setNeedsDisplay()
    }
}
