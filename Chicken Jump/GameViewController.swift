import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var skView: SKView!
    
    override func loadView() {
        self.skView = SKView()
        self.view = skView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                scene.gameViewController = self  // Set reference to GameViewController
                view.presentScene(scene)
            }
        }
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
    
//    func endGame() {
//        NotificationCenter.default.post(name: Notification.Name("BackToMainMenu"), object: nil)
//    }
//    
//    @IBAction func endGameButtonTapped(_ sender: UIButton) {
//        endGame()
//    }
//    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
