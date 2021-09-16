import SpriteKit
import GameplayKit
import Then

/**
 1) DynamicNode can move with velocity.
 2) DynamicNode can rotate with velocity arc tangent angle
 */
class DynamicNode: SKNode {
    private var velocityShapeNode: SKShapeNode
    public var velocity: CGVector = .init() {
        didSet {
            velocityShapeNode.xScale = velocity.length()
            zRotation = CGFloat(atan2(velocity.dy, velocity.dx))
        }
    }

    override init() {
        velocityShapeNode = .init().then {
            $0.strokeColor = .init(red: 0, green: 1.0, blue: 0, alpha: 0.6)
            $0.lineWidth = 1
            $0.path = CGMutablePath().then {
                $0.move(to: CGPoint(x: 0, y: 0))
                $0.addLine(to: CGPoint(x: 4.0, y: 0))
            }
            $0.zPosition = 2
            $0.isHidden = true
        }

        super.init()

        self.addChild(velocityShapeNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(elapsedTime: CGFloat) {
        position += velocity * elapsedTime
    }
}
