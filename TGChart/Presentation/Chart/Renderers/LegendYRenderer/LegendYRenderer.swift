import UIKit

protocol LegendYRenderer: Renderer {

    var colors: [UIColor]  { get set }

    func chartWillTransition(to toIntervals: [IntervalY])
}
