import SpriteKit

class Background: SKSpriteNode {
    static let texture = SKTexture(imageNamed: "background")
    
    init(index: Int = 0) {
        super.init(texture: Background.texture, color: .white, size: GameView.settings.windowSize)
        zPosition = Layer.background.rawValue
        anchorPoint = .zero
        position = CGPoint(x: (size.width * CGFloat(index)) - CGFloat(index), y: 0)
    }
    
    func animate() {
        let moveLeft = SKAction.moveBy(x: -size.width, y: 0, duration: GameView.settings.secondsPerRotation * 2)
        let fadeOut = SKAction.fadeOut(withDuration: 0)
        let moveReset = SKAction.moveBy(x: size.width, y: 0, duration: 0)
        let fadeIn = SKAction.fadeIn(withDuration: 0)
        let moveLoop = SKAction.repeatForever(SKAction.sequence([moveLeft, fadeOut, moveReset, fadeIn]))
        run(moveLoop, withKey: "backgroundMovement")
    }
    
    func adjustSpeed(to speed: CGFloat) {
        action(forKey: "backgroundMovement")?.speed = speed
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
