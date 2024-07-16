import UIKit
import SpriteKit

class MainMenuViewController: UIViewController {


    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(backToMainMenu), name: Notification.Name("BackToMainMenu"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BackToMainMenu"), object: nil)
    }

    func presentGameOverScene() {
        if let skView = self.view as? SKView, let scene = SKScene(fileNamed: "GameOverScene") {
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
            
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
    }
    
    @objc func backToMainMenu() {
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
