import SpriteKit
import GameplayKit
import Then

protocol Updatable {
    func update(elapsedTime: CGFloat)
}

class FishNode: SKSpriteNode, Updatable {
    static private let texture: SKTexture = .init(imageNamed: "fish_icon")
    static private let textureSize: CGSize = texture.size().with {
        $0.width *= 0.25
        $0.height *= 0.25
    }

    private var velocityShapeNode: SKShapeNode
    public var velocity: CGVector = .init() {
        didSet {
            velocityShapeNode.xScale = velocity.length()
            zRotation = CGFloat(atan2(velocity.dy, velocity.dx))
        }
    }

    private var visibleAreaShapeNode: SKShapeNode
    public var visibleDistance: CGFloat {
        didSet {
            visibleAreaShapeNode.path = CGMutablePath().then {
                $0.addArc(center: CGPoint(), radius: visibleDistance, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            }
        }
    }

    init() {
        velocityShapeNode = .init().then {
            $0.strokeColor = .red
            $0.lineWidth = 1
            $0.path = CGMutablePath().then {
                $0.move(to: CGPoint(x: 0, y: 0))
                $0.addLine(to: CGPoint(x: 4.0, y: 0))
            }
            $0.zPosition = 2
            $0.isHidden = true
        }
        visibleAreaShapeNode = .init().then {
            $0.strokeColor = .init(red: 0.5, green: 0, blue: 0, alpha: 1.0)
            $0.lineWidth = 1
            $0.zPosition = 3
            $0.path = CGMutablePath().then {
                $0.addArc(center: CGPoint(), radius: 250, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            }
            $0.isHidden = true
        }
        visibleDistance = 250

        super.init(texture: Self.texture, color: .clear, size: Self.textureSize)
        super.addChild(velocityShapeNode)
        super.addChild(visibleAreaShapeNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(elapsedTime: CGFloat) {
        position += velocity * elapsedTime
    }

//    var velocity: CGPoint = .init(
//        x: 20 * CGFloat.random(in: (-0.5...0.5)),
//        y: 20 * CGFloat.random(in: (-0.5...0.5))
//    )
//
//    func randomizePosition(range: CGSize) {
//        node.position = CGPoint(
//            x: range.width * CGFloat.random(in: (-0.3...0.3)),
//            y: range.height * CGFloat.random(in: (-0.3...0.3))
//        )
//    }
//
//    func rorateVelocity(angleRadian: CGFloat) {
//        self.updateVelocity(newVelocity: CGPoint(
//            x: cos(angleRadian) * velocity.x - sin(angleRadian) * velocity.y,
//            y: sin(angleRadian) * velocity.x + cos(angleRadian) * velocity.y
//        ))
//    }
}
