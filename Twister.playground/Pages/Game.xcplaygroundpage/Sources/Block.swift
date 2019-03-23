import SpriteKit

class Block: SKSpriteNode {
    var cleared: Bool = false
    var secondaryHeight: CGFloat = 0
    
    init(allowSecondaryHeights: Bool) {
        let windowSize = GameView.settings.windowSize
        let blockSize = GameView.settings.blockSize
        let color = GameView.settings.colors.randomElement() ?? .red
        super.init(texture: nil, color: color, size: blockSize)
        
        let heightOne = blockSize.height * 1.5
        let heightTwo = windowSize.height - (2 * blockSize.height) + (blockSize.height / 2)
        let useHeightOne = Bool.random()
        let useDifferentSecondaryHeight = Bool.random(withFalseWeight: 0.7)
        position = CGPoint(x: windowSize.width, y: useHeightOne ? heightOne : heightTwo)
        if useDifferentSecondaryHeight && allowSecondaryHeights {
            secondaryHeight = useHeightOne ? heightTwo : heightOne
        } else {
            secondaryHeight = position.y
        }
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
        let totalDistance = -(windowSize.width + blockSize.width)
        let totalDuration = GameView.settings.secondsPerRotation * 2
        
        let moveLeft = SKAction.moveBy(x: totalDistance, y: 0, duration: totalDuration)
        let removeBlock = SKAction.removeFromParent()
        let movementSequence = SKAction.sequence([moveLeft, removeBlock])
        movementSequence.speed = speed
        run(movementSequence, withKey: "blockMovement")
        
        let wait = SKAction.wait(forDuration: totalDuration / 6 * 1.5)
        let heightChange = SKAction.moveTo(y: secondaryHeight, duration: totalDuration / 6)
        let heightAdjustSequence = SKAction.sequence([wait, heightChange])
        run(heightAdjustSequence)
    }
    
    func adjustSpeed(to speed: CGFloat) {
        action(forKey: "blockMovement")?.speed = speed
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Bool {
    static func random(withFalseWeight weight: Double) -> Bool {
        guard weight >= 0 && weight <= 1 else { return random() }
        return Double(arc4random()) / Double(UINT32_MAX) > weight
    }
}
