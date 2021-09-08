//
//  Int+Extensions.swift
//  Flocking
//
//  Created by Kurt Lee on 9/5/21.
//

import Foundation

import SpriteKit
import Then

extension CGPath: Then {}
extension CGPoint {
    init(size: CGSize) {
        self.init(x: size.width, y: size.height)
    }
}

extension Int {
    func times<T>(_ fn: (Int) -> T) -> [T] {
        var result: [T] = []
        for i in (1...self) {
            result.append(fn(i))
        }

        return result
    }
}
