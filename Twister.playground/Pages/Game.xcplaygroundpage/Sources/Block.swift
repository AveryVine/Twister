import SpriteKit

class Block: SKSpriteNode {
    var cleared: Bool = false
    
    init() {
        let windowSize = GameView.settings.windowSize
        let blockSize = GameView.settings.blockSize
        let color = GameView.settings.colors.randomElement() ?? .red
        super.init(texture: nil, color: color, size: blockSize)
        
        let xPos: CGFloat = windowSize.width
        let yPos: CGFloat
        let useSecondaryHeight = Bool.random()
        if !useSecondaryHeight {
            yPos = blockSize.height * 1.5
        } else {
            yPos = windowSize.height - (2 * blockSize.height) + (blockSize.height / 2)
        }
        position = CGPoint(x: xPos, y: yPos)
        zPosition = Layer.block.rawValue
        
        physicsBody = SKPhysicsBody(rectangleOf: blockSize)
        physicsBody?.categoryBitMask = PhysicsCategory.block
        physicsBody?.contactTestBitMask = PhysicsCategory.dot
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.usesPreciseCollisionDetection = true
    }
    
    func animate(withSpeed speed: CGFloat) {
        let windowSize = GameView.settings.windowSize
        let blockSize = GameView.settings.blockSize
        let moveLeft = SKAction.moveBy(x: -(windowSize.width + blockSize.width),
                                       y: 0,
                                       duration: GameView.settings.secondsPerRotation * 2)
        let removeBlock = SKAction.removeFromParent()
        let movementSequence = SKAction.sequence([moveLeft, removeBlock])
        movementSequence.speed = speed
        run(movementSequence, withKey: "blockMovement")
    }
    
    func adjustSpeed(to speed: CGFloat) {
        action(forKey: "blockMovement")?.speed = speed
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
