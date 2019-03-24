import AVFoundation
import SpriteKit

protocol MusicDelegate: AnyObject {
    func toggleMusic(muted: Bool)
}

protocol SceneManager: AnyObject {
    func transition(to scene: SKScene, withDuration duration: Double)
}

public class GameView: SKView {
    static var settings: Settings = Settings()
    var music: AVAudioPlayer?
    var musicMuted: AVAudioPlayer?
    
    public init(settings: Settings = Settings()) {
        GameView.settings = settings
        
        super.init(frame: CGRect(origin: .zero, size: GameView.settings.windowSize))
        showsFPS = false
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
        intro.sceneManager = self
        intro.musicDelegate = self
        presentScene(intro)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GameView: SceneManager {
    func transition(to scene: SKScene, withDuration duration: Double = 2) {
        let transition = SKTransition.crossFade(withDuration: duration)
        transition.pausesIncomingScene = false
        transition.pausesOutgoingScene = false
        presentScene(scene, transition: transition)
    }
}

extension GameView: MusicDelegate {
    func toggleMusic(muted: Bool) {
        music?.setVolume(muted ? 0 : 5, fadeDuration: 2)
        musicMuted?.setVolume(muted ? 5 : 0, fadeDuration: 2)
    }
}
