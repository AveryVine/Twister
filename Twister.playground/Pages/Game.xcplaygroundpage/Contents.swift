import SpriteKit
import PlaygroundSupport
import AVFoundation

struct Settings {
    let windowSize: CGSize
    let blockSize: CGSize
    let dotRadius: CGFloat
    let dotDistanceFromAnchor: CGFloat
    let numberOfDots: Int
    let secondsPerRotation: Double
    let colors: [UIColor]
    
    init(width: CGFloat = 500, height: CGFloat = 300, numberOfDots: Int = 2, secondsPerRotation: Double = 1.75) {
        self.windowSize = CGSize(width: width, height: height)
        self.dotRadius = height * 0.015
        self.dotDistanceFromAnchor = height * 0.25
        self.numberOfDots = numberOfDots
        self.secondsPerRotation = secondsPerRotation
        self.blockSize = CGSize(width: self.dotRadius * 2, height: height / 5)
        
        colors = [.red, .blue, .green, .purple, .cyan, .magenta, .yellow]
    }
}

enum Layer: CGFloat {
    case background = 0
    case player = 1
    case block = 2
    case text = 3
}

enum PhysicsCategory {
    static let none: UInt32 = 0
    static let dot: UInt32 = 0b1
    static let block: UInt32 = 0b10
}

class GameView: SKView {
    static var settings: Settings = Settings()
    var music: AVAudioPlayer?
    var musicMuted: AVAudioPlayer?
    
    init(settings: Settings?) {
        if let settings = settings {
            GameView.settings = settings
        }
        
        super.init(frame: CGRect(origin: .zero, size: GameView.settings.windowSize))
        showsFPS = true
        showsNodeCount = false
        showsPhysics = false
        ignoresSiblingOrder = true
        
        if let musicUrl = Bundle.main.url(forResource: "twister", withExtension: "aiff") {
            if let audioPlayer = try? AVAudioPlayer(contentsOf: musicUrl) {
                music = audioPlayer
                music?.numberOfLoops = -1
                music?.volume = 0
                music?.prepareToPlay()
                music?.play()
            }
        }
        
        if let mutedMusicUrl = Bundle.main.url(forResource: "twister_muted", withExtension: "aiff") {
            if let audioPlayer = try? AVAudioPlayer(contentsOf: mutedMusicUrl) {
                musicMuted = audioPlayer
                musicMuted?.numberOfLoops = -1
                musicMuted?.volume = 0
                musicMuted?.prepareToPlay()
                musicMuted?.play()
            }
        }
        
        let intro = IntroScene()
        presentScene(intro)
    }
    
    func toggleMusic(muted: Bool) {
        music?.setVolume(muted ? 0 : 5, fadeDuration: 2)
        musicMuted?.setVolume(muted ? 5 : 0, fadeDuration: 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class IntroScene: SKScene {
    let gameScene: GameScene
    let titleLabel: SKLabelNode
    let subtitleLabel: SKLabelNode
    let highScoreLabel: SKLabelNode
    let resetButton: SKLabelNode
    let background: Background
    
    override init() {
        gameScene = GameScene()
        titleLabel = SKLabelNode(fontNamed: "Academy Engraved LET")
        subtitleLabel = SKLabelNode(fontNamed: "Chalkboard SE")
        highScoreLabel = SKLabelNode(fontNamed: "Chalkboard SE")
        resetButton = SKLabelNode(fontNamed: "Chalkboard SE")
        background = Background()
        super.init(size: GameView.settings.windowSize)
        prepareTitleLabel()
        prepareSubtitleLabel()
        prepareHighScoreLabel()
        prepareResetHighScoreButton()
        scaleMode = .aspectFit
    }
    
    override func didMove(to view: SKView) {
        if let gameView = self.view as? GameView {
            gameView.toggleMusic(muted: true)
        }
        
        addChild(background)
        addChild(titleLabel)
        addChild(subtitleLabel)
        addChild(highScoreLabel)
        addChild(resetButton)
    }
    
    func prepareTitleLabel() {
        titleLabel.text = "Twister"
        titleLabel.fontSize = 42
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = {
            let windowSize = GameView.settings.windowSize
            let xPos = windowSize.width / 2
            let yPos = windowSize.height / 2
            return CGPoint(x: xPos, y: yPos)
        }()
        titleLabel.zPosition = Layer.text.rawValue
        
        let scaleUp = SKAction.scale(by: 1.1, duration: 2)
        scaleUp.timingMode = .easeInEaseOut
        let scaleDown = SKAction.scale(by: 10.0 / 11.0, duration: 2)
        scaleDown.timingMode = .easeInEaseOut
        let scaleSequence = SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown]))
        titleLabel.run(scaleSequence)
    }
    
    func prepareSubtitleLabel() {
        subtitleLabel.text = "Tap anywhere to begin."
        subtitleLabel.fontSize = 14
        subtitleLabel.horizontalAlignmentMode = .center
        subtitleLabel.position = {
            let windowSize = GameView.settings.windowSize
            let xPos = windowSize.width / 2
            let yPos = windowSize.height / 3
            return CGPoint(x: xPos, y: yPos)
        }()
        subtitleLabel.zPosition = Layer.text.rawValue
    }
    
    func prepareHighScoreLabel() {
        updateHighScoreText()
        highScoreLabel.fontSize = 12
        highScoreLabel.horizontalAlignmentMode = .center
        highScoreLabel.position = {
            let windowSize = GameView.settings.windowSize
            let xPos = windowSize.width / 2
            let yPos = windowSize.height / 4
            return CGPoint(x: xPos, y: yPos)
        }()
        highScoreLabel.zPosition = Layer.text.rawValue
    }
    
    func prepareResetHighScoreButton() {
        resetButton.text = "Reset High Score?"
        resetButton.color = .cyan
        resetButton.fontSize = 10
        resetButton.horizontalAlignmentMode = .left
        resetButton.position = {
            let xPos = 5
            let yPos = 5
            return CGPoint(x: xPos, y: yPos)
        }()
        resetButton.zPosition = Layer.text.rawValue
    }
    
    func updateHighScoreText() {
        let highScore = UserDefaults.standard.integer(forKey: "highscore")
        highScoreLabel.text = "High Score: \(highScore)"
    }
    
    func resetHighScore() {
        UserDefaults.standard.set(0, forKey: "highscore")
        updateHighScoreText()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if resetButton.contains(touch.location(in: self)) {
            resetHighScore()
        } else {
            let transition = SKTransition.crossFade(withDuration: 2)
            transition.pausesOutgoingScene = false
            transition.pausesIncomingScene = false
            self.view?.presentScene(gameScene, transition: transition)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameScene: SKScene {
    let textFadeSequence: SKAction = {
        let wait = SKAction.wait(forDuration: 1)
        let showText = SKAction.fadeAlpha(to: 1, duration: 0.75)
        let hideText = SKAction.fadeAlpha(to: 0, duration: 0.75)
        let scaleUpText = SKAction.scale(by: 1.3, duration: 3)
        let scaleDownText = SKAction.scale(by: 10 / 12, duration: 0)
        let textFadeSequence = SKAction.sequence([showText, wait, hideText])
        let textActionGroup = SKAction.group([textFadeSequence, scaleUpText])
        let textActionSequence = SKAction.sequence([textActionGroup, scaleDownText])
        return textActionSequence
    }()
    let fadeOut: SKAction = SKAction.fadeOut(withDuration: 0.5)
    let wait = SKAction.wait(forDuration: 0.5)
    
    let player: RotationLayer
    var reservedBlocks: SKNode
    var backgrounds: [Background]
    let alertText: SKLabelNode
    let scoreText: SKLabelNode
    var score: Int {
        didSet {
            if score % 20 == 0 {
                extraSpeed += 0.1
                alertText.text = "Score: \(score) - speeding up!"
                alertText.run(textFadeSequence)
            }
        }
    }
    var extraSpeed: CGFloat {
        didSet {
            player.extraSpeed = extraSpeed
            if player.isClockwiseRotation {
                player.action(forKey: "clockwise")?.speed = 1 + extraSpeed
            } else {
                player.action(forKey: "counterclockwise")?.speed = 1 + extraSpeed
            }
            
            for child in children {
                if child.name == "block" {
                    child.action(forKey: "blockMovement")?.speed = 1 + extraSpeed
                }
            }
            for child in reservedBlocks.children {
                if child.name == "block" {
                    child.action(forKey: "blockMovement")?.speed = 1 + extraSpeed
                }
            }
            
            for background in backgrounds {
                background.action(forKey: "backgroundMovement")?.speed = 1 + extraSpeed
            }
            
            action(forKey: "blockGeneration")?.speed = 1 + extraSpeed
        }
    }
    var gameActive: Bool
    
    override init() {
        gameActive = false
        
        player = RotationLayer()
        player.animate()
        
        reservedBlocks = SKNode()
        backgrounds = [Background]()
        for index in 0 ... 1 {
            let background = Background(index: index)
            backgrounds.append(background)
            background.animate()
        }
        
        alertText = {
            let alert = SKLabelNode(fontNamed: "Chalkboard SE")
            alert.fontSize = 14
            alert.horizontalAlignmentMode = .center
            alert.position = {
                let windowSize = GameView.settings.windowSize
                let xPos = windowSize.width / 2
                let yPos = windowSize.height / 3 * 2
                return CGPoint(x: xPos, y: yPos)
            }()
            alert.zPosition = Layer.text.rawValue
            alert.alpha = 0
            return alert
        }()
        
        scoreText = {
            let score = SKLabelNode(fontNamed: "Chalkboard SE")
            score.text = "Blocks cleared: "
            score.fontSize = 14
            score.horizontalAlignmentMode = .center
            score.position = {
                let windowSize = GameView.settings.windowSize
                let xPos = windowSize.width / 2
                let yPos = (windowSize.height / 2) - (score.frame.height / 2)
                return CGPoint(x: xPos, y: yPos)
            }()
            score.zPosition = Layer.text.rawValue
            score.alpha = 0
            return score
        }()
        score = 0
        extraSpeed = 0
        
        super.init(size: settings.windowSize)
        scaleMode = .aspectFit
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        backgroundColor = UIColor(red: 3.0 / 255.0, green: 16.0 / 255.0, blue: 68.0 / 255.0, alpha: 1)
        animateBlockGeneration()
    }
    
    override func didMove(to view: SKView) {
        if let gameView = self.view as? GameView {
            gameView.toggleMusic(muted: false)
        }
        
        for background in backgrounds {
            addChild(background)
        }
        addChild(player)
        addChild(scoreText)
        addChild(alertText)
        gameActive = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameActive {
            player.isClockwiseRotation = !player.isClockwiseRotation
            player.action(forKey: "clockwise")?.speed = player.isClockwiseRotation ? 1 + extraSpeed : 0
            player.action(forKey: "counterclockwise")?.speed = player.isClockwiseRotation ? 0 : 1 + extraSpeed
        }
    }
    
    func spawnBlock() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            let block = Block()
            let sequence = Block.movementSequence
            sequence.speed = 1 + strongSelf.extraSpeed
            block.run(sequence, withKey: "blockMovement")
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.reservedBlocks.addChild(block)
            }
        }
    }
    
    func addBlock() {
        reservedBlocks.children.first?.move(toParent: self)
    }
    
    func animateBlockGeneration() {
        let add = SKAction.run(addBlock)
        let spawn = SKAction.run(spawnBlock)
        let wait = SKAction.wait(forDuration: GameView.settings.secondsPerRotation / 2)
        let generateSequence = SKAction.sequence([add, spawn, wait])
        let generateLoop = SKAction.repeatForever(generateSequence)
        let initialWait = SKAction.wait(forDuration: GameView.settings.secondsPerRotation * 2.15)
        let totalSequence = SKAction.sequence([initialWait, generateLoop])
        run(totalSequence, withKey: "blockGeneration")
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameActive {
            for child in children {
                if let block = child as? Block,
                    block.position.x < GameView.settings.windowSize.width / 5 - player.distanceFromAnchor,
                    !block.cleared {
                    block.cleared = true
                    score += 1
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if gameActive {
            gameActive = false
            player.action(forKey: player.isClockwiseRotation ? "clockwise" : "counterclockwise")?.speed = 0.25
            for background in backgrounds {
                background.action(forKey: "backgroundMovement")?.speed = 0.25
            }
            for child in children {
                if let block = child as? Block {
                    block.action(forKey: "blockMovement")?.speed = 0.25
                }
            }
            action(forKey: "blockGeneration")?.speed = 0
            
            scoreText.text?.append(String(score))
            let currentHighScore = UserDefaults.standard.integer(forKey: "highscore")
            if score > currentHighScore {
                UserDefaults.standard.set(score, forKey: "highscore")
                scoreText.text?.append(" - New High Score!")
            }
            
            let scoreSequence = SKAction.sequence([wait, textFadeSequence])
            scoreText.run(scoreSequence, completion: {
                self.run(self.fadeOut, completion: {
                    DispatchQueue.global(qos: .default).async {
                        let intro = IntroScene()
                        DispatchQueue.main.async {
                            self.view?.presentScene(intro)
                        }
                    }
                })
            })
        }
    }
}

class Background: SKSpriteNode {
    static let texture = SKTexture(imageNamed: "blue_background")
    
    init(index: Int = 0) {
        super.init(texture: Background.texture, color: .white, size: GameView.settings.windowSize)
        zPosition = Layer.background.rawValue
        anchorPoint = .zero
        position = CGPoint(x: (size.width * CGFloat(index)) - CGFloat(index), y: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate() {
        let moveLeft = SKAction.moveBy(x: -size.width, y: 0, duration: GameView.settings.secondsPerRotation * 2)
        let fadeOut = SKAction.fadeOut(withDuration: 0)
        let moveReset = SKAction.moveBy(x: size.width, y: 0, duration: 0)
        let fadeIn = SKAction.fadeIn(withDuration: 0)
        let moveLoop = SKAction.repeatForever(SKAction.sequence([moveLeft, fadeOut, moveReset, fadeIn]))
        run(moveLoop, withKey: "backgroundMovement")
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
    var cleared: Bool
    
    init() {
        let windowSize = GameView.settings.windowSize
        let blockSize = GameView.settings.blockSize
        let color = GameView.settings.colors.randomElement() ?? .red
        cleared = false
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
        name = "block"
        
        physicsBody = SKPhysicsBody(rectangleOf: blockSize)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.block
        physicsBody?.contactTestBitMask = PhysicsCategory.dot
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.usesPreciseCollisionDetection = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RotationLayer: SKShapeNode {
    let anchorDot: Dot
    var outerDots: [Dot]
    var extraSpeed: CGFloat
    var isClockwiseRotation: Bool = true
    var distanceFromAnchor: CGFloat = GameView.settings.dotDistanceFromAnchor
    
    override init() {
        let anchorDotPosition = CGPoint.zero
        anchorDot = Dot(color: .white, position: anchorDotPosition)
        extraSpeed = 0
        
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
        position = CGPoint(x: -GameView.settings.windowSize.width / 2, y: GameView.settings.windowSize.height / 2)
        strokeColor = .clear
        
        addChild(anchorDot)
        for dot in outerDots {
            addChild(dot)
        }
    }
    
    func animate() {
        let clockwiseRotation = SKAction.repeatForever(SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: GameView.settings.secondsPerRotation))
        let counterclockwiseRotation = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi * 2, duration: GameView.settings.secondsPerRotation))
        run(clockwiseRotation, withKey: "clockwise")
        run(counterclockwiseRotation, withKey: "counterclockwise")
        
        let moveInFromLeft = SKAction.move(to: CGPoint(x: GameView.settings.windowSize.width / 5, y: GameView.settings.windowSize.height / 2), duration: 4)
        moveInFromLeft.timingMode = .easeOut
        run(moveInFromLeft)
        
        action(forKey: "counterclockwise")?.speed = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.dot
        physicsBody?.contactTestBitMask = PhysicsCategory.block
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.usesPreciseCollisionDetection = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

let settings = Settings(width: 500, height: 300, numberOfDots: 2)
PlaygroundPage.current.liveView = GameView(settings: settings)
PlaygroundPage.current.needsIndefiniteExecution = true
