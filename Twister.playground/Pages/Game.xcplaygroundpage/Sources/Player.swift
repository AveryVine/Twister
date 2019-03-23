import SpriteKit

class Player: SKShapeNode {
    let anchorDot: Dot
    var outerDots: [Dot]
    var isClockwiseRotation: Bool = true
    var distanceFromAnchor: CGFloat = GameView.settings.dotDistanceFromAnchor
    
    override init() {
        let anchorDotPosition = CGPoint.zero
        anchorDot = Dot(color: .white, position: anchorDotPosition)
        
        outerDots = [Dot]()
        for index in 0 ..< GameView.settings.numberOfDots {
            let angle = CGFloat.pi * CGFloat(2) / CGFloat(GameView.settings.numberOfDots) * CGFloat(index)
            let xPos = distanceFromAnchor * sin(angle)
            let yPos = distanceFromAnchor * cos(angle)
            let outerDotPosition = CGPoint(x: xPos + anchorDotPosition.x, y: yPos + anchorDotPosition.y)
            outerDots.append(Dot(color: .orange, position: outerDotPosition))
        }
        
        super.init()
        path = CGPath(rect: CGRect(x: -distanceFromAnchor,
                                   y: -distanceFromAnchor,
                                   width: distanceFromAnchor * 2,
                                   height: distanceFromAnchor * 2),
                      transform: nil)
        position = CGPoint(x: -GameView.settings.windowSize.width / 2, y: GameView.settings.windowSize.height / 2)
        strokeColor = .clear
        
        addChild(anchorDot)
        for dot in outerDots {
            addChild(dot)
        }
    }
    
    func animate() {
        let rotationDuration = (GameView.settings.secondsPerRotation / 2) * Double(GameView.settings.numberOfDots)
        let clockwiseRotation = SKAction.repeatForever(SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: rotationDuration))
        let counterclockwiseRotation = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi * 2, duration: rotationDuration))
        run(clockwiseRotation, withKey: "clockwise")
        run(counterclockwiseRotation, withKey: "counterclockwise")
        
        let centerY = position.y
        let dy = GameView.settings.windowSize.height / 20
        let easeUp = SKAction.moveTo(y: centerY + dy, duration: 2)
        let easeDown = SKAction.moveTo(y: centerY - dy, duration: 2)
        easeUp.timingMode = .easeInEaseOut
        easeDown.timingMode = .easeInEaseOut
        let easeSequence = SKAction.sequence([easeUp, easeDown])
        run(SKAction.repeatForever(easeSequence), withKey: "easeUpEaseDown")
        
        let moveInFromLeft = SKAction.move(to: CGPoint(x: GameView.settings.windowSize.width / 5, y: GameView.settings.windowSize.height / 2), duration: 4)
        moveInFromLeft.timingMode = .easeOut
        run(moveInFromLeft)
        
        action(forKey: "counterclockwise")?.speed = 0
        action(forKey: "easeUpEaseDown")?.speed = 0
    }
    
    func adjustSpeed(to speed: CGFloat, includeVertical: Bool) {
        action(forKey: isClockwiseRotation ? "clockwise" : "counterclockwise")?.speed = speed
        if includeVertical {
            action(forKey: "easeUpEaseDown")?.speed = speed
        }
    }
    
    func toggleRotation() {
        isClockwiseRotation = !isClockwiseRotation
        if let clockwise = action(forKey: "clockwise"), let counterclockwise = action(forKey: "counterclockwise") {
            let speed = max(clockwise.speed, counterclockwise.speed)
            clockwise.speed = isClockwiseRotation ? speed : 0
            counterclockwise.speed = isClockwiseRotation ? 0 : speed
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
