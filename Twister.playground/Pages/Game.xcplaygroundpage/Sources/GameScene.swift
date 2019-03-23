import AVFoundation
import SpriteKit

class GameScene: SKScene {
    weak var sceneManager: SceneManager?
    weak var musicDelegate: MusicDelegate?
    
    let player: Player
    var backgrounds: [Background]
    let alertText: SKLabelNode
    let scoreText: SKLabelNode
    
    var gameActive: Bool = false
    let increaseGameSpeedThreshhold = 20
    let increasePlayerVerticalMovementThreshhold = 50
    
    var score: Int = 0 {
        didSet {
            if score % increaseGameSpeedThreshhold == 0 {
                extraSpeed += 0.12
                alertText.text = "Score: \(score) - speeding up!"
                alertText.run(textFadeSequence)
            }
            if score % increasePlayerVerticalMovementThreshhold == 0 {
                player.action(forKey: "easeUpEaseDown")?.speed += 0.8
                if score / increasePlayerVerticalMovementThreshhold == 1 {
                    alertText.text = "Not bad... time for some up and down!"
                } else {
                    alertText.text = "Still going? Let's bounce faster!"
                }
                alertText.run(textFadeSequence)
            }
        }
    }
    var extraSpeed: CGFloat = 0 {
        didSet {
            player.adjustSpeed(to: 1 + extraSpeed, includeVertical: false)
            for node in children {
                if let block = node as? Block {
                    block.adjustSpeed(to: 1 + extraSpeed)
                }
            }
            for background in backgrounds {
                background.adjustSpeed(to: 1 + extraSpeed)
            }
            adjustSpeed(to: 1 + extraSpeed)
        }
    }
    let textFadeSequence: SKAction = {
        let wait = SKAction.wait(forDuration: 1)
        let showText = SKAction.fadeAlpha(to: 1, duration: 0.75)
        let hideText = SKAction.fadeAlpha(to: 0, duration: 0.75)
        let scaleUpText = SKAction.scale(by: 13 / 10, duration: 2.5)
        let scaleDownText = SKAction.scale(by: 10 / 13, duration: 0)
        let textFadeSequence = SKAction.sequence([showText, wait, hideText])
        let textActionGroup = SKAction.group([textFadeSequence, scaleUpText])
        let textActionSequence = SKAction.sequence([textActionGroup, scaleDownText])
        return textActionSequence
    }()
    
    override init() {
        player = Player()
        backgrounds = [Background]()
        for index in 0 ... 1 {
            let background = Background(index: index)
            backgrounds.append(background)
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
        
        super.init(size: GameView.settings.windowSize)
        scaleMode = .aspectFit
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        backgroundColor = UIColor(red: 3.0 / 255.0, green: 16.0 / 255.0, blue: 68.0 / 255.0, alpha: 1)
        
        player.animate()
        backgrounds.forEach({ $0.animate() })
        animateBlockGeneration()
    }
    
    override func didMove(to view: SKView) {
        musicDelegate?.toggleMusic(muted: false)
        
        for background in backgrounds {
            addChild(background)
        }
        addChild(player)
        addChild(scoreText)
        addChild(alertText)
        gameActive = true
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameActive {
            for child in children {
                if let block = child as? Block,
                    block.position.x < GameView.settings.windowSize.width / 5 - GameView.settings.dotDistanceFromAnchor,
                    !block.cleared {
                    block.cleared = true
                    score += 1
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameActive {
            player.toggleRotation()
        }
    }
    
    func addBlock() {
        let block = Block()
        addChild(block)
        block.animate(withSpeed: 1 + extraSpeed)
    }
    
    func animateBlockGeneration() {
        let waitDuration = (GameView.settings.secondsPerRotation / 4) * Double(GameView.settings.numberOfDots)
        let add = SKAction.run(addBlock)
        let wait = SKAction.wait(forDuration: waitDuration)
        let generateSequence = SKAction.sequence([add, wait])
        let generateLoop = SKAction.repeatForever(generateSequence)
        let initialWait = SKAction.wait(forDuration: GameView.settings.secondsPerRotation * 2.15)
        let totalSequence = SKAction.sequence([initialWait, generateLoop])
        run(totalSequence, withKey: "blockGeneration")
    }
    
    func adjustSpeed(to speed: CGFloat) {
        action(forKey: "blockGeneration")?.speed = speed
    }
    
    func showScoreAndTransition() {
        scoreText.text?.append(String(score))
        let currentHighScore = UserDefaults.standard.integer(forKey: "highscore")
        if score > currentHighScore {
            UserDefaults.standard.set(score, forKey: "highscore")
            scoreText.text?.append(" - New High Score!")
        }
        
        let wait = SKAction.wait(forDuration: 0.5)
        let scoreSequence = SKAction.sequence([wait, textFadeSequence])
        scoreText.run(scoreSequence, completion: {
            let intro = IntroScene()
            intro.sceneManager = self.sceneManager
            intro.musicDelegate = self.musicDelegate
            self.sceneManager?.transition(to: intro, withDuration: 2)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if gameActive {
            gameActive = false
            player.adjustSpeed(to: 0.25, includeVertical: (score >= increasePlayerVerticalMovementThreshhold))
            for background in backgrounds {
                background.adjustSpeed(to: 0.25)
            }
            for node in children {
                if let block = node as? Block {
                    block.adjustSpeed(to: 0.25)
                }
            }
            adjustSpeed(to: 0)
            showScoreAndTransition()
        }
    }
}
