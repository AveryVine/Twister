import UIKit

public struct Settings {
    let windowSize: CGSize
    let blockSize: CGSize
    let dotRadius: CGFloat
    let dotDistanceFromAnchor: CGFloat
    let numberOfDots: Int
    let secondsPerRotation: Double
    let colors: [UIColor]
    
    public init(windowWidth: CGFloat = 500, windowHeight: CGFloat = 300, numberOfDots: Int = 2, initialSecondsPerRotation: Double = 1.75) {
        self.windowSize = CGSize(width: windowWidth, height: windowHeight)
        self.dotRadius = windowHeight * 0.015
        self.dotDistanceFromAnchor = windowHeight * 0.25
        self.numberOfDots = numberOfDots
        self.secondsPerRotation = initialSecondsPerRotation
        self.blockSize = CGSize(width: self.dotRadius * 2, height: windowHeight / 5)
        
        colors = [.red, .blue, .green, .purple, .cyan, .magenta, .yellow]
    }
}

enum Layer: CGFloat {
    case background = 0
    case particles = 10
    case player = 20
    case block = 30
    case text = 40
}

enum PhysicsCategory {
    static let none: UInt32 = 0
    static let dot: UInt32 = 0b1
    static let block: UInt32 = 0b10
}
