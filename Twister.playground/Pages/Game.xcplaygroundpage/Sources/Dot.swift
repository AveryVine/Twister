import SpriteKit

class Dot: SKShapeNode {
    init(color: UIColor, position: CGPoint) {
        super.init()
        self.position = position
        let radius = GameView.settings.dotRadius
        let diameter = radius * 2
        let origin = CGPoint(x: -radius, y: -radius)
        path = CGPath(ellipseIn: CGRect(origin: origin, size: CGSize(width: diameter, height: diameter)), transform: nil)
        strokeColor = color
        fillColor = color
        zPosition = Layer.player.rawValue
        
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.categoryBitMask = PhysicsCategory.dot
        physicsBody?.contactTestBitMask = PhysicsCategory.block
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.usesPreciseCollisionDetection = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
