import UIKit
import SpriteKit

class GameOverScene: SKScene {
    var backHomeLabel: SKLabelNode?
    var backHomeLabel2: SKLabelNode?
    var playAgainLabel: SKLabelNode?
    var playAgainLabel2: SKLabelNode?
    var scoreGame  : GameScene!
    var finalScore: Int = 0
    var cornIcon = "🌽"
    
    override func didMove(to view: SKView) {
        print(finalScore) // Ini akan mencetak nilai finalScore yang dioper dari GameScene
        
        let scoreButton = SKLabelNode(fontNamed: "FredokaCondensed-SemiBold")
        scoreButton.text = "Score: \(finalScore) \(cornIcon)"
        scoreButton.fontSize = 50
        scoreButton.fontColor =  SKColor(red: 101/255, green: 67/255, blue: 33/255, alpha: 1.0)
        self.addChild(scoreButton)
        scoreButton.zPosition = 1
        scoreButton.position = CGPoint(x: self.frame.midX, y: -150)
        
        backHomeLabel = self.childNode(withName: "//backHomeLabel") as? SKLabelNode
        backHomeLabel2 = self.childNode(withName: "//backHomeLabel2") as? SKLabelNode
        
        if let backHomeLabel = backHomeLabel {
            backHomeLabel.fontName = "FredokaCondensed-SemiBold"
            backHomeLabel.fontSize = 50
            backHomeLabel.fontColor = SKColor(red: 101/255, green: 67/255, blue: 33/255, alpha: 1.0)
        }
        if let backHomeLabel2 = backHomeLabel2 {
            backHomeLabel2.fontName = "FredokaCondensed-SemiBold"
            backHomeLabel2.fontSize = 50
            backHomeLabel2.fontColor = SKColor(red: 240/255, green: 230/255, blue: 200/255, alpha: 1.0)
        }

        playAgainLabel = self.childNode(withName: "//playAgainLabel") as? SKLabelNode
        playAgainLabel2 = self.childNode(withName: "//playAgainLabel2") as? SKLabelNode
        
        if let playAgainLabel = playAgainLabel {
            playAgainLabel.fontName = "FredokaCondensed-SemiBold"
//            playAgainLabel.fontSize = 50
            playAgainLabel.fontColor = SKColor(red: 101/255, green: 67/255, blue: 33/255, alpha: 1.0)
        }
        
        if let playAgainLabel2 = playAgainLabel2 {
            playAgainLabel2.fontName = "FredokaCondensed-SemiBold"
//            playAgainLabel.fontSize = 50
            playAgainLabel2.fontColor = SKColor(red: 240/255, green: 230/255, blue: 200/255, alpha: 1.0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let playAgainLabel = playAgainLabel, self.atPoint(location) == playAgainLabel {
            playAgain()
        } else if let backHomeLabel = backHomeLabel, self.atPoint(location) == backHomeLabel {
            print("Back Home Label Touched") // Debug log
            backToMainMenu()
        }
    }
    

    
    func playAgain() {
        if let scene = SKScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            let transition = SKTransition.push(with: .left, duration: 1)
            view?.presentScene(scene, transition: transition)
        }
    }
    
    func backToMainMenu() {
        print("Posting Notification to go back to Main Menu") // Debug log
        NotificationCenter.default.post(name: Notification.Name("BackToMainMenu"), object: nil)
    }
    
}
