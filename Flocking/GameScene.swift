import SpriteKit
import GameplayKit

class ConfigValue {
    let value: CGFloat
    let min: CGFloat
    let max: CGFloat

    init(value: CGFloat, min: CGFloat, max: CGFloat) {
        self.value = value
        self.min = min
        self.max = max
    }
}

class GameScene: SKScene {
    private var debugLabel : SKLabelNode!
    private var nodes: [FishNode] = [];

    override func didMove(to view: SKView) {
        debugLabel = SKLabelNode.init()
        debugLabel.text = "Cohesion Point"
        self.addChild(debugLabel);

        60.times { index in
            FishNode().then {
                nodes.append($0)
                addChild($0)
            }
        }

        randomizeNodes()
    }

    func randomizeNodes() {
        nodes.forEach {
            $0.velocity = CGVector(angle: CGFloat.random(min: 0, max: 2 * CGFloat.pi))
            $0.position = CGPoint(size: self.size) * CGPoint(
                x: CGFloat.random(in: (-0.5...0.5)),
                y: CGFloat.random(in: (-0.5...0.5))
            )
        }
    }

    private var lastUpdateTime: TimeInterval?

    override func update(_ currentTime: TimeInterval) {
        if let lastUpdateTime = lastUpdateTime {
            let elapsedTime = CGFloat(currentTime - lastUpdateTime)
            nodes.forEach {
                $0.update(elapsedTime: elapsedTime)
            }

            // self.debugLabel.position = averagePosition

            // Change velocity based on Flocking algorithm
            let maxSpeed: CGFloat = 50

            nodes.forEach { node in
                let neighbourNodes: [(node: FishNode, direction: CGVector, distance: CGFloat)] = nodes
                    .compactMap { otherNode in
                        guard node !== otherNode else {
                            return nil
                        }

                        let direction = CGVector(point: node.position - otherNode.position)
                        let distance = direction.length()
                        return (otherNode, direction.normalized(), distance)
                    }
                
                let cohension: CGVector = {
                    let averagePosition: CGPoint = .init().with { averagePosition in
                        neighbourNodes.forEach { (node: FishNode, direction: CGVector, distance: CGFloat) in
                            averagePosition += node.position
                        }
                        averagePosition /= CGFloat(neighbourNodes.count)
                    }

                    return CGVector(point: averagePosition - node.position).normalized()
                }()

                let seperation: CGVector = {
                    var force = CGVector()
//                    let desiredDistance: CGFloat = 50
                    neighbourNodes.forEach { (node: FishNode, direction: CGVector, distance: CGFloat) in
                        // If it's close, seperation has to be strong
                        if distance < (node.visibleDistance * 0.40) {
                            force += (direction / pow(distance, 2))
                        }

//                        if (distance < desiredDistance) {
//
//                            // (direction / pow(distance, 3)) * desiredDistance
//                        }
                    }

                    return force.normalized()
                }()

                let alignment: CGVector = {
                    let averageVelocity = neighbourNodes.reduce(CGVector()) { $0 + $1.node.velocity.normalized() } / CGFloat(neighbourNodes.count)
                    return (averageVelocity - node.velocity.normalized())
                }()

                node.velocity += (
                    cohension * 1.2 +
                    seperation * 1.0 +
                    alignment * 1.3
                );
                node.velocity *= maxSpeed / node.velocity.length()
            }

            // Screen
            let xRange = (-0.5 * size.width, 0.5 * size.width)
            let yRange = (-0.5 * size.height, 0.5 * size.height)

            self.nodes.forEach {
                if ($0.position.x < xRange.0) {
                    $0.position.x = xRange.1
                }
                if ($0.position.x > xRange.1) {
                    $0.position.x = xRange.0
                }

                if ($0.position.y < yRange.0) {
                    $0.position.y = yRange.1
                }
                if ($0.position.y > yRange.1) {
                    $0.position.y = yRange.0
                }
            }
        }

//        self.updateConfigLabel()
        self.lastUpdateTime = currentTime
    }

//
//    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
//    }
//
//    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
//    }
//
//    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
//    }
//
//    override func mouseDown(with event: NSEvent) {
//        self.touchDown(atPoint: event.location(in: self))
//    }
//
//    override func mouseDragged(with event: NSEvent) {
//        self.touchMoved(toPoint: event.location(in: self))
//    }
//
//    override func mouseUp(with event: NSEvent) {
//        self.touchUp(atPoint: event.location(in: self))
//    }
//
    override func keyDown(with event: NSEvent) {
        if (event.keyCode == 49) {
            randomizeNodes()
        }
    }
}
