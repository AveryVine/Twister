import SpriteKit

class Background: SKSpriteNode {
    static let texture = SKTexture(imageNamed: "background")
    let index: Int
    
    init(index: Int = 0) {
        self.index = index
        let windowSize = GameView.settings.windowSize
        let backgroundSize = CGSize(width: windowSize.width + 2, height: windowSize.height)
        super.init(texture: Background.texture, color: .white, size: backgroundSize)
        zPosition = Layer.background.rawValue
        anchorPoint = .zero
        position = CGPoint(x: (size.width * CGFloat(index)) - CGFloat(index), y: 0)
        
        if let sparkle = SKEmitterNode(fileNamed: "sparkle") {
            sparkle.position = CGPoint(x: size.width / 2, y: size.height / 2)
            sparkle.zPosition = Layer.particles.rawValue
            sparkle.particlePositionRange = CGVector(dx: size.width, dy: size.height)
            addChild(sparkle)
        }
    }
    
    func animate() {
        let windowSize = GameView.settings.windowSize
        
        let fadeOut = SKAction.fadeOut(withDuration: 0)
        let fadeIn = SKAction.fadeIn(withDuration: 0)
        let moveBackwards = SKAction.run { self.zPosition -= 1 }
        let moveForwards = SKAction.run { self.zPosition += 1 }
        let moveLeft = SKAction.moveBy(x: -(windowSize.width - 1), y: 0, duration: GameView.settings.secondsPerRotation * 2)
        let moveReset = SKAction.moveTo(x: windowSize.width, duration: 0)
        let resetSequence = SKAction.sequence([fadeOut, moveReset, fadeIn])
        let shortSequence = SKAction.sequence([moveLeft, moveForwards, resetSequence])
        let longSequence = SKAction.sequence([moveLeft, moveBackwards, moveLeft, moveForwards, resetSequence])
        let movementSequence: SKAction
        if index == 0 {
            movementSequence = SKAction.sequence([
                shortSequence,
                SKAction.repeatForever(longSequence)
            ])
        } else {
            movementSequence = SKAction.repeatForever(longSequence)
        }
        run(movementSequence, withKey: "backgroundMovement")
    }
    
    func adjustSpeed(to speed: CGFloat) {
        action(forKey: "backgroundMovement")?.speed = speed
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
