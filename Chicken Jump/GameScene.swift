//
//  GameScene.swift
//  Chicken Jump
//
//  Created by Charlos Purba on 01/07/24.
//

import UIKit
import SpriteKit
import SwiftUI


class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var pijakan: SKSpriteNode?
    var isGestureRunning = false
    var obstacle1: SKSpriteNode?
    var obstacle2: SKSpriteNode?
    var veryFirstObstacle: SKSpriteNode?
    var hpLabel: SKLabelNode?
    var steps: [SKSpriteNode] = []
    var xPosition = [-150, 150]
    var hp = "❤️❤️❤️"
    var obstacle1Exist = false
    var obstacles: [SKSpriteNode?] = []
    var jagung: SKSpriteNode?
    var cornIcon = "🌽"
    var playPauseButton: UIButton!
    var isPausedGame: Bool = false
    let jagungCategory: UInt32 = 0x1 << 1
    let ayamCategory: UInt32 = 0x1 << 0
    var chicken: SKSpriteNode?
    var chickenPosition = 0 // Start at step1 (index 0)
    var actionChicken: SKSpriteNode?
    var score: SKLabelNode?
    var oil: SKSpriteNode?
    let stepCategory: UInt32 = 0x1 << 2
    let obstacleCategory: UInt32 = 0x1 << 3
    let oilCategory: UInt = 0x1 << 4
    let jumpSound = SKAction.playSoundFileNamed("jump.mpeg", waitForCompletion: false)
    let jagungSound = SKAction.playSoundFileNamed("jagung.mp3", waitForCompletion: false)
    var startTime: TimeInterval?  // Menyimpan waktu saat scene mulai ditampilkan
    var initialDuration: TimeInterval = 15  // Durasi awal
    var minimumDuration: TimeInterval = 1  // Durasi minimum
    var initialWaitDuration: TimeInterval = 2.5  // Durasi tunggu awal
    var minimumWaitDuration: TimeInterval = 0.5  // Durasi tunggu minimum

    
    var poin = 0 {
        didSet {
            score?.text = "\(cornIcon) \(poin)"
        }
    }
    
    
    weak var gameViewController: GameViewController?
    
    
    override func didMove(to view: SKView) {
        startTime = CACurrentMediaTime()  // Menginisialisasi startTime ketika scene pertama kali ditampilkan
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        chicken = self.childNode(withName: "//Chicken") as? SKSpriteNode
        pijakan = childNode(withName: "//Step1") as? SKSpriteNode
        obstacle1 = childNode(withName: "//Step2") as? SKSpriteNode
        jagung = childNode(withName: "//Jagung") as? SKSpriteNode
        oil = childNode(withName: "//Oil") as? SKSpriteNode
        oil?.physicsBody?.isDynamic = false
        oil?.physicsBody?.affectedByGravity = false
        oil?.physicsBody?.allowsRotation = false
        
        
        for step in steps {
            step.physicsBody = SKPhysicsBody(rectangleOf: step.size)
            step.physicsBody?.isDynamic = false
            step.physicsBody?.categoryBitMask = stepCategory
            step.physicsBody?.collisionBitMask = ayamCategory
            step.physicsBody?.contactTestBitMask = ayamCategory
        }
        
        // Add swipe gestures
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
//        jagung?.name = "Jagung1"
        
        obstacles.append(pijakan)
        obstacles.append(pijakan)
        obstacles.append(obstacle1)
        
        hpLabel  = SKLabelNode(text: "\(hp)")
        hpLabel?.zPosition = 15
        hpLabel?.fontSize = 40
        hpLabel?.position = CGPoint(x: 200, y: size.height/2 - 100)
        
        
        playPauseButton = UIButton(type: .custom)
        playPauseButton.frame = CGRect(x: 20, y: 20, width: 75, height: 75) // Sesuaikan ukuran tombol
        playPauseButton.imageView?.contentMode = .scaleAspectFit
        // Mengatur gambar untuk tombol play
        playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        // Menambahkan aksi untuk tombol
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped(_:)), for: .touchUpInside)
        // Menambahkan tombol ke view
        view.addSubview(playPauseButton)
        
        addChild(hpLabel!)
        repeatedlySpawnObstacle()
        repeatedlySpawnJagung1()
//        spawnChicken()
        setupScore()

    }
    
    @objc func swipeRight() {
            // Cek apakah ada gesture yang sedang berjalan
            guard !isGestureRunning else { return }
            isGestureRunning = true
            
            guard let chicken = actionChicken else { return }
            chicken.physicsBody = nil
            
            chicken.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(to: CGPoint(x: 300, y: 150), controlPoint: CGPoint(x: 0, y: 100))
            
            let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: false, speed: 500)
            move.timingMode = .easeInEaseOut
            
            let activatePhysics = SKAction.run {
                chicken.physicsBody = SKPhysicsBody(rectangleOf: chicken.size)
                chicken.physicsBody?.isDynamic = true
                chicken.physicsBody?.allowsRotation = false
                chicken.physicsBody?.affectedByGravity = true
                chicken.physicsBody?.categoryBitMask = self.ayamCategory
                chicken.physicsBody?.collisionBitMask = self.stepCategory | self.obstacleCategory
                chicken.physicsBody?.contactTestBitMask = self.jagungCategory | self.stepCategory | self.obstacleCategory
            }
            
            // Reset flag setelah aksi selesai
            let resetFlag = SKAction.run {
                self.isGestureRunning = false
            }
            
            chicken.run(SKAction.sequence([jumpSound, move, activatePhysics, resetFlag]))
        }

        @objc func swipeLeft() {
            // Cek apakah ada gesture yang sedang berjalan
            guard !isGestureRunning else { return }
            isGestureRunning = true
            
            guard let chicken = actionChicken else { return }
            chicken.physicsBody = nil
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(to: CGPoint(x: -300, y: 200), controlPoint: CGPoint(x: 0, y: 100))
            
            let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: false, speed: 500)
            move.timingMode = .easeInEaseOut
            
            let activatePhysics = SKAction.run {
                chicken.physicsBody = SKPhysicsBody(rectangleOf: chicken.size)
                chicken.physicsBody?.isDynamic = true
                chicken.physicsBody?.allowsRotation = false
                chicken.physicsBody?.affectedByGravity = true
                chicken.physicsBody?.categoryBitMask = self.ayamCategory
                chicken.physicsBody?.collisionBitMask = self.stepCategory | self.obstacleCategory
                chicken.physicsBody?.contactTestBitMask = self.jagungCategory | self.stepCategory | self.obstacleCategory
            }
            
            // Reset flag setelah aksi selesai
            let resetFlag = SKAction.run {
                self.isGestureRunning = false
            }
            
            chicken.run(SKAction.sequence([jumpSound, move, activatePhysics, resetFlag]))
        }

        @objc func swipeUp() {
            // Cek apakah ada gesture yang sedang berjalan
            guard !isGestureRunning else { return }
            isGestureRunning = true
            
            guard let chicken = actionChicken else { return }
            chicken.physicsBody = nil
            
            chicken.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(to: CGPoint(x: 0, y: 500), controlPoint: CGPoint(x: 0, y: 0))
            
            let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: false, speed: 700)
            move.timingMode = .easeInEaseOut
            
            let activatePhysics = SKAction.run {
                chicken.physicsBody = SKPhysicsBody(rectangleOf: chicken.size)
                chicken.physicsBody?.isDynamic = true
                chicken.physicsBody?.allowsRotation = false
                chicken.physicsBody?.affectedByGravity = true
                chicken.physicsBody?.categoryBitMask = self.ayamCategory
                chicken.physicsBody?.collisionBitMask = self.stepCategory | self.obstacleCategory
                chicken.physicsBody?.contactTestBitMask = self.jagungCategory | self.stepCategory | self.obstacleCategory
            }
            
            // Reset flag setelah aksi selesai
            let resetFlag = SKAction.run {
                self.isGestureRunning = false
            }
            
            chicken.run(SKAction.sequence([jumpSound, move, activatePhysics, resetFlag]))
        }
    
    enum Direction {
        case left
        case right
        case up
        
    }
    
    func setupScore() {
        let backgroundImage = UIImage(named: "empty") // Ganti "backgroundImageName" dengan nama gambar Anda
        let texture = SKTexture(image: backgroundImage!)
        let background = SKSpriteNode(texture: texture)
        
        background.size = CGSize(width: 150, height: 250) // Mengatur ukuran background
        background.position = CGPoint(x: frame.midX, y: frame.maxY - 130) // Mengatur posisi di tengah layar
        background.zPosition = 90 // Mengatur zPosition di bawah label skor
        background.alpha = 1.0 // Mengatur opasitas ke 70%
        addChild(background)
        
        score = SKLabelNode(fontNamed: "Lemonada")
        score?.text = "0"
        score?.fontSize = 30
        score?.fontColor = .white
        score?.position = CGPoint(x: 0.5, y: frame.maxY - 140   )
        score?.zPosition = 100
        addChild(score!)
    }
    
    func repeatedlySpawnJagung1() {
        let spawnAction = SKAction.run {
            self.spawnJagung1()
        }
        let waitAction = SKAction.wait(forDuration: 4)
        let spawnAndWaitAction = SKAction.sequence([waitAction, spawnAction])
        run(SKAction.repeatForever(spawnAndWaitAction))
    }
    
    func spawnJagung1() {
        if let newJagung1 = jagung?.copy() as? SKSpriteNode {
            let randomX = xPosition[Int.random(in: 0...1)]
            newJagung1.position = CGPoint(x: randomX, y: 2000)
            newJagung1.physicsBody = SKPhysicsBody(rectangleOf: newJagung1.size)
            newJagung1.physicsBody?.isDynamic = false
            newJagung1.physicsBody?.allowsRotation = false
            newJagung1.physicsBody?.categoryBitMask = jagungCategory
            newJagung1.physicsBody?.contactTestBitMask = ayamCategory
            newJagung1.name = "Jagung"
            addChild(newJagung1)
            moveJagung1(node: newJagung1)
        }
    }
    
    func moveJagung1(node: SKNode) {
        let moveDownAction = SKAction.moveTo(y: -800, duration: 5)
        let removeNodeAction = SKAction.removeFromParent()
        node.run(SKAction.sequence([moveDownAction, removeNodeAction]))
    }
    
    func addPlayPauseButton() {
            playPauseButton = UIButton(type: .system)
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            playPauseButton.frame = CGRect(x: 20, y: 20, width: 100, height: 50)
            playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped(_:)), for: .touchUpInside)
            view?.addSubview(playPauseButton)
        }
        
        @objc func playPauseButtonTapped(_ sender: UIButton) {
            if isPausedGame {
                // Resume game
                isPausedGame = false
                playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
                self.isPaused = false
            } else {
                // Pause game
                isPausedGame = true
                playPauseButton.setImage(UIImage(named: "play1"), for: .normal)
                self.isPaused = true
                
                // Optionally, show pause menu or dialog
                showPauseMenu()
            }
        }
//    @objc func playPauseButtonTapped(_ sender: UIButton) {
//        if isGamePaused {
//            // Jika permainan sedang dijeda, lanjutkan permainan
//            self.isPaused = false
//            isGamePaused = false
//            playPauseButton.setImage(UIImage(named: "pause"), for: .normal) // Ubah gambar ke pause
//        } else {
//            // Jika permainan sedang berjalan, jeda permainan
//            self.isPaused = true
//            isGamePaused = true
//            playPauseButton.setImage(UIImage(named: "play"), for: .normal) // Ubah gambar ke play
//        }
//    }


    override func willMove(from view: SKView) {
        // Menghapus tombol saat scene berganti
        playPauseButton?.removeFromSuperview()
    }
    
    func showPauseMenu() {
        // Implement pause menu or dialog here
        let alertController = UIAlertController(title: "Game Paused", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Resume", style: .default, handler: { (_) in self.resumeGame() }))
//        alertController.addAction(UIAlertAction(title: "End Game", style: .destructive, handler: { (_) in self.endGame() }))
        if let viewController = view?.window?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
//        playPauseButton?.removeFromSuperview()
    }
    
    func resumeGame() {
        // Resume game logic
        startTime = CACurrentMediaTime()
        repeatedlySpawnObstacle()
        isPausedGame = false
        playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        self.isPaused = false
    }
    
//    func endGame() {
//        // End game logic
//        gameViewController?.endGame()
//    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    func repeatedlySpawnObstacle() {
        guard let startTime = startTime, !isPausedGame else { return }  // Memastikan startTime tidak nil dan game tidak ter-pause

        // Menghitung waktu yang telah berlalu sejak startTime
        let elapsedTime = CACurrentMediaTime() - startTime

        // Menghitung durasi tunggu baru berdasarkan waktu yang telah berlalu
        let currentWaitDuration = max(initialWaitDuration - (elapsedTime / 60), minimumWaitDuration)

        let spawnAction = SKAction.run {
            self.spawnObstacles()
        }

        let waitAction = SKAction.wait(forDuration: currentWaitDuration)
        let spawnAndWaitAction = SKAction.sequence([spawnAction, waitAction])
        run(spawnAndWaitAction) {
            // Panggil repeatedlySpawnObstacle lagi untuk terus menyesuaikan waitDuration
            self.repeatedlySpawnObstacle()
        }
    }
    
    var lastXPositionOfObstacle = 150
    var firstObstaclePosition: CGPoint?
    
    func spawnObstacles() {
            var randomObstacle: SKSpriteNode?

            // Ensure the first obstacle is "pijakan"
            if veryFirstObstacle == nil {
                randomObstacle = pijakan!.copy() as? SKSpriteNode
                veryFirstObstacle = randomObstacle
                
                if let newObstacle = randomObstacle {
                    // Alternate the X position to avoid overlap
                    if lastXPositionOfObstacle == 150 {
                        lastXPositionOfObstacle = -150
                    } else {
                        lastXPositionOfObstacle = 150
                    }

                    // Ensure the first obstacle is far enough from the chicken's initial position
                    newObstacle.position = CGPoint(x: lastXPositionOfObstacle, y: 1000)
                    newObstacle.physicsBody = SKPhysicsBody(rectangleOf: newObstacle.size)
                    newObstacle.physicsBody?.isDynamic = false
                    newObstacle.physicsBody?.affectedByGravity = false
                    newObstacle.physicsBody?.allowsRotation = false
                    newObstacle.physicsBody?.restitution = 0.0
                    
                    addChild(newObstacle)

                    moveObstacle(node: newObstacle)

                    // Spawn the chicken on the first obstacle
                    spawnChicken()
                }
            } else {
                // Pick a random obstacle
                randomObstacle = obstacles.randomElement() ?? obstacle1

                while obstacle1Exist {
                    randomObstacle = obstacles.randomElement() ?? obstacle1
                    
                    if randomObstacle != obstacle1 {
                        obstacle1Exist = false
                    }
                }

                if let newObstacle = randomObstacle?.copy() as? SKSpriteNode {
                    // Alternate the X position to avoid overlap
                    if lastXPositionOfObstacle == 150 {
                        lastXPositionOfObstacle = -150
                    } else {
                        lastXPositionOfObstacle = 150
                    }

                    // Ensure the first obstacle is far enough from the chicken's initial position
                    newObstacle.position = CGPoint(x: lastXPositionOfObstacle, y: 1000)
                    newObstacle.physicsBody = SKPhysicsBody(rectangleOf: newObstacle.size)
                    newObstacle.physicsBody?.isDynamic = false
                    newObstacle.physicsBody?.affectedByGravity = false
                    newObstacle.physicsBody?.allowsRotation = false
                    newObstacle.physicsBody?.restitution = 0.0
                    
                    addChild(newObstacle)

                    moveObstacle(node: newObstacle)
                }

                if randomObstacle == obstacle1 {
                    obstacle1Exist = true
                }
            }
        }
    
    func spawnChicken() {
        
        
        if let chicken1 = chicken?.copy() as? SKSpriteNode {
            chicken1.size = CGSize(width: 150, height: 150)
            chicken1.position =   veryFirstObstacle!.position // CGPoint(x: 270, y: -370)
            print(veryFirstObstacle)
            chicken1.position.y = chicken1.position.y + 100
            chicken1.zPosition = 9

            chicken1.physicsBody = SKPhysicsBody(rectangleOf: chicken1.size)
            chicken1.physicsBody?.isDynamic = true
            chicken1.physicsBody?.allowsRotation = false
            chicken1.physicsBody?.affectedByGravity = true
//            chicken1.physicsBody?.friction = 0.0
            chicken1.physicsBody?.restitution = -1.0
//            chicken1.physicsBody?.linearDamping = 0.0
//            chicken1.physicsBody?.angularDamping = 0.0
            
            addChild(chicken1)
            
            actionChicken = chicken1

            //chicken1.run(SKAction.moveTo(y: -800, duration: 15))
        }
    }
    

    func moveObstacle(node: SKNode, initialDuration: TimeInterval = 15, minimumDuration: TimeInterval = 1) {
        guard let startTime = startTime else { return }  // Memastikan startTime tidak nil

        // Menghitung waktu yang telah berlalu sejak startTime
        let elapsedTime = CACurrentMediaTime() - startTime

        // Menghitung durasi baru berdasarkan waktu yang telah berlalu, dengan durasi minimum
        let currentDuration = max(initialDuration - (elapsedTime / 10), minimumDuration)

        // Membuat aksi untuk menggerakkan node ke bawah dengan durasi yang dihitung
        let moveDownAction = SKAction.moveTo(y: -800, duration: currentDuration)
        // Membuat aksi untuk menghapus node dari parent setelah aksi moveDownAction selesai
        let removeNodeAction = SKAction.removeFromParent()
        // Menggabungkan kedua aksi menjadi satu sequence
        let sequenceAction = SKAction.sequence([moveDownAction, removeNodeAction])

        // Menjalankan sequenceAction pada node
        node.run(sequenceAction) {
            // Jika node masih ada di parent setelah aksi selesai, panggil moveObstacle lagi dengan durasi yang diperbarui
            if node.parent != nil {
                self.moveObstacle(node: node, initialDuration: initialDuration, minimumDuration: minimumDuration)
            }
        }
    }
    
    func changeObstacleTexture(_ obstacle: SKNode) {
        let changeTexture = SKAction.setTexture(SKTexture(imageNamed: "pijakan"))
        obstacle.run(changeTexture)
        obstacle.name = "pijakan"
    }
    
    
    
    @objc func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        print("Node A \(nodeA.name)")
        print("Node B \(nodeB.name)")
        
        // Kondisi untuk memastikan collision terjadi antara Chicken dan Step2
        if (nodeA.name == "Chicken" && nodeB.name == "Jagung") || (nodeA.name == "Jagung" && nodeB.name == "Chicken") {
            // Mengubah tekstur Step2 menjadi "pijakan" sekali saja
            if nodeA.name == "Jagung" {
                handleJagungCollision(jagung: nodeA)
            } else if nodeB.name == "Jagung" {
                handleJagungCollision(jagung: nodeB)
            }
        }
        
        if (nodeA.name == "Chicken" && nodeB.name == "Step2") || (nodeA.name == "Step2" && nodeB.name == "Chicken") {
            // Mengubah tekstur Step2 menjadi "pijakan" sekali saja
            if nodeA.name == "Step2" {
                changeObstacleTexture(nodeA)
            } else if nodeB.name == "Step2" {
                changeObstacleTexture(nodeB)
            }

            // Kurangi HP hanya sekali per collision
            if hp.count > 0 {
                hp.removeLast()
                hpLabel?.text = "\(hp)" // Update label HP
            }

            // Cek jika HP habis
            if hp.isEmpty {
                showGameOver()
            }
        }
        
        if (nodeA.name == "Chicken" && nodeB.name == "Oil") || (nodeA.name == "Oil" && nodeB.name == "Chicken") {
            print("posisi node A",nodeA.position)
            print("posisi node B\(nodeB.position)")
            
            // Mengubah tekstur Step2 menjadi "pijakan" sekali saja
            if nodeA.name == "Oil" {
                showGameOver()
                print("collision")
                // doing something
            } else if nodeB.name == "Oil" {
                showGameOver()
                print("collision")
            }
        }
    }
    func handleJagungCollision(jagung: SKNode) {
        self.run(jagungSound)
        jagung.removeFromParent()
        poin += 5
        

    }

    func showGameOver() {
        // transition to GameOverScene
        if let scene = SKScene(fileNamed: "GameOverScene") as? GameOverScene {
            scene.scaleMode = .aspectFill
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            // Set nilai finalScore
            scene.finalScore = self.poin
            
            let transition = SKTransition.reveal(with: .down, duration: 1)
            view?.presentScene(scene, transition: transition)
        }
    }
    
    
    
}



struct SceneKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        let scene = GameScene(size: uiView.bounds.size)
        scene.scaleMode = .aspectFill
        uiView.presentScene(scene)
    }
}
