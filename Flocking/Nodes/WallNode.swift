import SpriteKit
import Foundation

class WallNode: SKShapeNode {
    private var rect: CGRect

    init(_ rect: CGRect) {
        self.rect = rect

        super.init();
        path = CGPath.init(rect: rect, transform: nil)
        fillColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func distanceTo(point: CGPoint) -> CGVector {
        var direction: CGVector = .init();

        let xRange = (rect.origin.x, rect.origin.x + rect.size.width)
        let yRange = (rect.origin.y, rect.origin.y + rect.size.height)

        if (point.x < xRange.0) {
            direction.dx = point.x - xRange.0;
        } else if (xRange.1 < point.x) {
            direction.dx = point.x - xRange.1;
        }

        if (point.y < yRange.0) {
            direction.dy = point.y - yRange.0;
        } else if (yRange.1 < point.y) {
            direction.dy = point.y - yRange.1;
        }


        if (direction == CGVector.zero) {
            // @TODO - 박스 안에 들어갔을때 상황 처리
        }

        return direction;
    }
}
