import SpriteKit
import GameplayKit
import Then

class FishNode: DynamicNode {
    static private let texture: SKTexture = .init(imageNamed: "fish_icon")
    static private let textureSize: CGSize = texture.size().with {
        $0.width *= 0.25
        $0.height *= 0.25
    }

    private let visibleAreaShapeNode: SKShapeNode
    public var visibleDistance: CGFloat {
        didSet {
            visibleAreaShapeNode.path = CGMutablePath().then {
                $0.addArc(center: CGPoint(), radius: visibleDistance, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            }
        }
    }
    private let spriteNode: SKSpriteNode

    public var level: CGFloat = 1.0 {
        didSet {
            self.spriteNode.setScale(self.level)
        }
    }

    override init() {
        visibleAreaShapeNode = .init().then {
            $0.strokeColor = .init(red: 1.0, green: 0, blue: 0, alpha: 0.6)
            $0.lineWidth = 1
            $0.zPosition = 3
            $0.path = CGMutablePath().then {
                $0.addArc(center: CGPoint(), radius: 250, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            }
            $0.isHidden = true
        }
        visibleDistance = 250;
        spriteNode = SKSpriteNode(texture: Self.texture, size: Self.textureSize)

        defer {
            addChild(visibleAreaShapeNode)
            addChild(spriteNode)
            self.level = CGFloat.random(min: 0.5, max: 1.5)
        }

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
