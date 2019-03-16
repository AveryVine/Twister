import SpriteKit
import PlaygroundSupport

struct Settings {
    enum Layer: CGFloat {
        case background = 0
        case player = 1
        case block = 2
    }
    
    let windowSize: CGSize
    let blockSize: CGSize
    let dotRadius: CGFloat
    let dotDistanceFromAnchor: CGFloat
    let numberOfDots: Int
    let secondsPerRotation: Double
    let colors: [UIColor]
    
    init(width: CGFloat = 300, height: CGFloat = 200, numberOfDots: Int = 2, secondsPerRotation: Double = 1.5) {
        self.windowSize = CGSize(width: width, height: height)
        self.dotRadius = height * 0.015
        self.dotDistanceFromAnchor = height * 0.25
        self.numberOfDots = numberOfDots
        self.secondsPerRotation = secondsPerRotation
        self.blockSize = CGSize(width: self.dotRadius * 2, height: height / 5)
        
        colors = [.red, .blue, .green, .purple, .cyan, .magenta, .yellow]
    }
}

class GameView: SKView {
    static var settings: Settings = Settings()
    
    init(settings: Settings) {
        GameView.settings = settings
        
        super.init(frame: CGRect(origin: .zero, size: settings.windowSize))
        showsFPS = true
        showsNodeCount = true
        ignoresSiblingOrder = true
        
        let scene = GameScene()
        scene.scaleMode = .fill
        presentScene(scene)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameScene: SKScene {
    let player: RotationLayer
    var reservedBlocks: SKNode
    
    override init() {
        player = RotationLayer()
        reservedBlocks = SKNode()
        super.init(size: settings.windowSize)
    }
    
    override func didMove(to view: SKView) {
        for index in 0 ... 1 {
            let background = Background(index: index)
            addChild(background)
            background.animate()
        }
        addChild(player)
        player.animate()
        
        let add = SKAction.run(addBlock)
        let spawn = SKAction.run(spawnReserves)
        let wait = SKAction.wait(forDuration: GameView.settings.secondsPerRotation / 2)
        let generateSequence = SKAction.sequence([add, spawn, wait])
        let generateLoop = SKAction.repeatForever(generateSequence)
        let initialWait = SKAction.wait(forDuration: GameView.settings.secondsPerRotation * 2.15)
        let totalSequence = SKAction.sequence([initialWait, generateLoop])
        run(totalSequence)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.isClockwiseRotation = !player.isClockwiseRotation
    }
    
    func spawnReserves() {
        if reservedBlocks.children.count < 5 {
            DispatchQueue.global(qos: .background).async { [weak self] in
                let block = Block()
                let sequence = Block.movementSequence
                block.run(sequence)
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.reservedBlocks.addChild(block)
                }
            }
        }
    }
    
    func addBlock() {
        if let block = reservedBlocks.children.first as? Block {
            block.move(toParent: self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Background: SKSpriteNode {
    static let texture = SKTexture(imageNamed: "background")
    init(index: Int) {
        super.init(texture: Background.texture, color: .white, size: GameView.settings.windowSize)
        zPosition = Settings.Layer.background.rawValue
        anchorPoint = .zero
        position = CGPoint(x: (size.width * CGFloat(index)) - CGFloat(index), y: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate() {
        let moveLeft = SKAction.moveBy(x: -size.width, y: 0, duration: GameView.settings.secondsPerRotation * 2)
        let moveReset = SKAction.moveBy(x: size.width, y: 0, duration: 0)
        let moveLoop = SKAction.repeatForever(SKAction.sequence([moveLeft, moveReset]))
        run(moveLoop)
    }
}

class Block: SKSpriteNode {
    static var movementSequence: SKAction = {
        let windowSize = GameView.settings.windowSize
        let blockSize = GameView.settings.blockSize
        let moveLeft = SKAction.moveBy(x: -(windowSize.width + blockSize.width),
                                       y: 0,
                                       duration: GameView.settings.secondsPerRotation * 2)
        let removeBlock = SKAction.removeFromParent()
        return SKAction.sequence([moveLeft, removeBlock])
    }()
    
    init() {
        let color = GameView.settings.colors.randomElement() ?? .red
        super.init(texture: nil, color: color, size: GameView.settings.blockSize)
        
        let windowSize = GameView.settings.windowSize
        let blockSize = GameView.settings.blockSize
        let xPos: CGFloat = windowSize.width + (blockSize.width / 2)
        let yPos: CGFloat
        let useSecondaryHeight = Bool.random()
        if !useSecondaryHeight {
            yPos = blockSize.height * 1.5
        } else {
            yPos = windowSize.height - (2 * blockSize.height) + (blockSize.height / 2)
        }
        position = CGPoint(x: xPos, y: yPos)
        zPosition = Settings.Layer.block.rawValue
    }
    
    func animate() {
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RotationLayer: SKShapeNode {
    let anchorDot: Dot
    var outerDots: [Dot]
    var rotationAngle: CGFloat = 0
    var isClockwiseRotation: Bool = true {
        didSet {
            animate()
        }
    }
    var distanceFromAnchor: CGFloat = GameView.settings.dotDistanceFromAnchor
    
    override init() {
        let anchorDotPosition = CGPoint(x: -GameView.settings.dotRadius, y: -GameView.settings.dotRadius)
        anchorDot = Dot(color: .white, position: anchorDotPosition)
        
        outerDots = [Dot]()
        for index in 0 ..< GameView.settings.numberOfDots {
            let angle = CGFloat.pi * CGFloat(2 / GameView.settings.numberOfDots * index)
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
        position = CGPoint(x: GameView.settings.windowSize.width / 5, y: GameView.settings.windowSize.height / 2)
        strokeColor = .clear
        
        addChild(anchorDot)
        for dot in outerDots {
            addChild(dot)
        }
    }
    
    func animate() {
        if !hasActions() {
            let clockwiseRotation = SKAction.repeatForever(SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: GameView.settings.secondsPerRotation))
            let counterclockwiseRotation = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi * 2, duration: GameView.settings.secondsPerRotation))
            run(clockwiseRotation, withKey: "clockwise")
            run(counterclockwiseRotation, withKey: "counterclockwise")
        }
        action(forKey: "clockwise")?.speed = isClockwiseRotation ? 1 : 0
        action(forKey: "counterclockwise")?.speed = isClockwiseRotation ? 0 : 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Dot: SKShapeNode {
    init(color: UIColor, position: CGPoint) {
        super.init()
        self.position = position
        let diameter = GameView.settings.dotRadius * 2
        path = CGPath(ellipseIn: CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter)), transform: nil)
        strokeColor = color
        fillColor = color
        zPosition = Settings.Layer.player.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

let settings = Settings(width: 500, height: 300, numberOfDots: 2)
PlaygroundPage.current.liveView = GameView(settings: settings)
PlaygroundPage.current.needsIndefiniteExecution = true
