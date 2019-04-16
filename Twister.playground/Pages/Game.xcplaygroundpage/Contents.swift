import PlaygroundSupport
/*:
 ![Twister](title.png)
 ## Running Twister 🌪
 Make sure you've got the Assistant Editor open if you're running this in Xcode. If you're running this in Swift Playgrounds on iPad, drag the split window to make the game fullscreen for the best experience!
 */
let gameView = GameView() //default is 2 dots, 1.75 seconds per rotation
//let gameView = GameView(settings: Settings(numberOfDots: 3, initialSecondsPerRotation: 2.5))
/*:
 For an extra challenge, try with different settings (for example, one of the ones commented out above)!
 */
PlaygroundPage.current.liveView = gameView
