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
    private var nodes: [FishNode] = [];
    private var wallNodes: [WallNode] = [];
    private var predatorNodes: [PredatorNode] = [];

    private var boundingRect: CGRect {
        get {
            return CGRect(
                x: -0.5 * size.width,
                y: -0.5 * size.height,
                width: size.width,
                height: size.height
            )
        }
    }

    override func didMove(to view: SKView) {
        // initialize fish nodes
        30.times { index in
            FishNode().then {
                nodes.append($0)
                addChild($0)
            }
        }
        randomizeNodes()

        // initialize wall and boundaries
        let wallDepth = 25;

        // Screen
        let xRange = (Int(-0.5 * size.width), Int(0.5 * size.width))
        let yRange = (Int(-0.5 * size.height), Int(0.5 * size.height))

        wallNodes = [
            .init(.init(x: xRange.0, y: yRange.1 - Int(wallDepth), width: Int(size.width), height: Int(wallDepth))),
            .init(.init(x: xRange.0, y: yRange.0, width: Int(size.width), height: Int(wallDepth))),
            .init(.init(x: xRange.0, y: yRange.0, width: Int(wallDepth), height: Int(size.height))),
            .init(.init(x: xRange.1 - Int(wallDepth), y: yRange.0, width: Int(wallDepth), height: Int(size.height))),
        ]
        wallNodes.forEach { addChild($0) }

        predatorNodes = 1.times { _ in
            let node: PredatorNode = .init(circleOfRadius: CGFloat.random(min: 5, max: 20))
            node.position = CGPoint(size: self.size) * CGPoint(
                x: CGFloat.random(in: (-0.5...0.5)),
                y: CGFloat.random(in: (-0.5...0.5))
            )
            self.addChild(node)
            return node
        }
    }

    func randomizeNodes() {
        nodes.forEach {
            $0.velocity = CGVector(angle: CGFloat.random(min: 0, max: 2 * CGFloat.pi))
            $0.position = CGPoint(size: self.size) * CGPoint(
                x: CGFloat.random(in: (-0.5...0.5)),
                y: CGFloat.random(in: (-0.5...0.5))
            )
        }
        predatorNodes.forEach {
            $0.velocity = CGVector(angle: CGFloat.random(min: 0, max: 2 * CGFloat.pi)) * 20
            $0.position = CGPoint(size: self.size) * CGPoint(
                x: CGFloat.random(in: (-0.5...0.5)),
                y: CGFloat.random(in: (-0.5...0.5))
            )
        }
    }

    private var lastUpdateTime: TimeInterval?

    var disableUpdate: Bool = false

    override func update(_ currentTime: TimeInterval) {
        if (disableUpdate) {
            return
        }

        if let lastUpdateTime = lastUpdateTime {
            let elapsedTime = CGFloat(currentTime - lastUpdateTime)
            nodes.forEach {
                $0.update(elapsedTime: elapsedTime * 2)
            }
            predatorNodes.forEach {
                $0.update(elapsedTime: elapsedTime * 2)
            }

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
                    neighbourNodes.forEach { (node: FishNode, direction: CGVector, distance: CGFloat) in
                        // If it's close, seperation has to be strong
                        if distance < (node.visibleDistance * 0.30) {
                            force += direction
                        }
                    }

                    return force.normalized()
                }()

                let alignment: CGVector = {
                    let averageVelocity = neighbourNodes.reduce(CGVector()) { $0 + $1.node.velocity.normalized() } / CGFloat(neighbourNodes.count)
                    return (averageVelocity - node.velocity.normalized())
                }()

                let boundaryPush: CGVector = {
                    var sumVector: CGVector = .init();

                    let wallDistanceThread: CGFloat = 80.0;
                    wallNodes.forEach { wallNode in
                        let direction = wallNode.distanceTo(point: node.position)

                        let distance = direction.length()
                        if (distance < wallDistanceThread) {
                            sumVector += direction.normalized() * (wallDistanceThread - distance)
                        }
                    }

                    let predatorDistanceThread : CGFloat = 200;
                    predatorNodes.forEach { predatorNode in
                        let direction = predatorNode.distanceTo(point: node.position)
                        let distance = direction.length()
                        if (distance < predatorDistanceThread) {
                            sumVector += direction.normalized() * (predatorDistanceThread - distance) * 0.8
                        }
                    }

                    return sumVector;
                }()

                node.velocity += (
                    cohension * 1.0 +
                    seperation * 1.5 +
                    alignment * 1.2 +
                    boundaryPush * 0.5
                );
                node.velocity *= maxSpeed / node.velocity.length()
                
            }

            predatorNodes.forEach { predator in
                let closestFish = nodes.min { fishA, fishB in
                    let distanceToA = fishA.position.distanceTo(predator.position)
                    let distanceToB = fishB.position.distanceTo(predator.position)
                    return distanceToA < distanceToB
                }!

                let directionToFish = CGVector(point: closestFish.position - predator.position)
                predator.velocity = (predator.velocity + directionToFish.normalized() * 1.0).normalized() * 20
            }


            // Screen
            let xRange = (-0.5 * size.width, 0.5 * size.width)
            let yRange = (-0.5 * size.height, 0.5 * size.height)

            nodes.forEach {
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
            predatorNodes.forEach {
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

        self.lastUpdateTime = currentTime
    }

    override func mouseDown(with event: NSEvent) {
//        self.touchDown(atPoint: event.location(in: self))
    }

    override func mouseDragged(with event: NSEvent) {
//        self.touchMoved(toPoint: event.location(in: self))
    }

    override func rightMouseUp(with event: NSEvent) {
        let position = event.location(in: self)

        PredatorNode(circleOfRadius: CGFloat.random(min: 5, max: 20)).then {
            $0.position = position
            predatorNodes.append($0)
            self.addChild($0)
        }
    }

    override func mouseUp(with event: NSEvent) {
        let position = event.location(in: self)

        FishNode().then {
            $0.position = position
            nodes.append($0)
            self.addChild($0)
        }
    }

    override func keyDown(with event: NSEvent) {
        if (event.keyCode == 49) {
            randomizeNodes()
        } else if (event.keyCode == 0) { // "a"
            disableUpdate.toggle()
        }
    }
}
