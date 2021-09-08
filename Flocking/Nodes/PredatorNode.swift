import SpriteKit

class PredatorNode: SKShapeNode {
    private var circleRadius: CGFloat

    init(circleOfRadius: CGFloat) {
        self.circleRadius = circleOfRadius
        super.init();

        path = CGMutablePath().then {
            $0.addArc(center: CGPoint(), radius: circleRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        }
        fillColor = .blue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func distanceTo(point: CGPoint) -> CGVector {
        let diff = point - self.position;
        let distance = diff.length()
        return CGVector(point: diff).normalized() * (distance - self.circleRadius)
    }
}
