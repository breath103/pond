import SpriteKit

class PredatorNode: DynamicNode {
    static private let texture: SKTexture = .init(imageNamed: "shark_icon")
    static private let textureSize: CGSize = texture.size().with {
        $0.width *= 0.25
        $0.height *= 0.25
    }
    private var circleRadius: CGFloat
    private let spriteNode: SKSpriteNode
    
    init(circleOfRadius: CGFloat) {
        self.circleRadius = circleOfRadius
        spriteNode = SKSpriteNode(texture: Self.texture, size: Self.textureSize)
        defer {
            addChild(spriteNode)
        }

        super.init();
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
