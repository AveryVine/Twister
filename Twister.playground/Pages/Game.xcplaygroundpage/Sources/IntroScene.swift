import AVFoundation
import SpriteKit

class IntroScene: SKScene {
    weak var sceneManager: SceneManager?
    weak var musicDelegate: MusicDelegate?
    
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
        musicDelegate?.toggleMusic(muted: true)
        
        addChild(background)
        addChild(titleLabel)
        addChild(subtitleLabel)
        addChild(highScoreLabel)
        addChild(resetButton)
        
        let scaleUp = SKAction.scale(by: 1.1, duration: 2)
        scaleUp.timingMode = .easeInEaseOut
        let scaleDown = SKAction.scale(by: 10.0 / 11.0, duration: 2)
        scaleDown.timingMode = .easeInEaseOut
        let scaleSequence = SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown]))
        titleLabel.run(scaleSequence)
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
            gameScene.musicDelegate = musicDelegate
            gameScene.sceneManager = sceneManager
            sceneManager?.transition(to: gameScene, withDuration: 2)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
