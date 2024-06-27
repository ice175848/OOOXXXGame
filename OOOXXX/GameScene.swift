import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // 定義棋盤節點
    var boardNode: SKSpriteNode!
    var numberOfTouches = 0
    var helloLabel: SKLabelNode!
    var background: SKSpriteNode!
    var column = 0
    var row = 0
    var oCount = 0
    var xCount = 0
    var gameIsOver = false
    var oPositions: [[Bool]] = Array(repeating: Array(repeating: false, count: 3), count: 3)
    var xPositions: [[Bool]] = Array(repeating: Array(repeating: false, count: 3), count: 3)

    let boardWidth: CGFloat = 720 // 棋盤寬度
    let boardHeight: CGFloat = 724 // 棋盤高度
    let numberOfRows = 3 // 棋盤行數
    let numberOfColumns = 3 // 棋盤列數
    var oQueue: [(node: SKSpriteNode, row: Int, col: Int)] = []
    var xQueue: [(node: SKSpriteNode, row: Int, col: Int)] = []

    override func didMove(to view: SKView) {
        // 設置背景
        setupGameBoard()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        if gameIsOver {
            resetGameState()
            setupGameBoard()
            return
        }

        let location = touch.location(in: boardNode)
        if 0 <= location.x && location.x < boardNode.size.width && 0 <= location.y && location.y < boardNode.size.height {
            let column = Int(location.x / 222)
            let row = Int(location.y / 222)

            if oPositions[row][column] || xPositions[row][column] {
                return  // 如果该位置已经有棋子，则不进行任何操作
            }

            let imageName = (numberOfTouches % 2 == 0) ? "X.png" : "O.png"
            let sprite = SKSpriteNode(imageNamed: imageName)
            sprite.position = CGPoint(x: CGFloat(column) * 222 + 111, y: CGFloat(row) * 222 + 111)
            boardNode.addChild(sprite)

            // 添加标签
            let label = SKLabelNode(text: "\(1)")
            label.fontSize = 15
            label.fontColor = .black
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .top
            label.position = CGPoint(x: -sprite.size.width / 2 + 105, y: sprite.size.height / 2 - 1)
            label.zPosition = CGFloat(numberOfTouches+1)
            sprite.addChild(label)

            if imageName == "X.png" {
                xPositions[row][column] = true
                xQueue.append((node: sprite, row: row, col: column))
                xCount += 1
                if xQueue.count > 3 {
                    erase(for: "X")  // 删除最早的棋子
                }
            } else {
                oPositions[row][column] = true
                oQueue.append((node: sprite, row: row, col: column))
                oCount += 1
                if oQueue.count > 3 {
                    erase(for: "O")  // 删除最早的棋子
                }
            }

            updateLabels()

            numberOfTouches += 1

            if checkForWin(xPositions) {
                endGame(winner: "X")
            } else if checkForWin(oPositions) {
                endGame(winner: "O")
            }
        }
    }

    func updateLabels() {
        for (index, element) in xQueue.enumerated() {
            if let label = element.node.children.first as? SKLabelNode {
                label.text = "\(index + 1)"
            }
        }
        
        for (index, element) in oQueue.enumerated() {
            if let label = element.node.children.first as? SKLabelNode {
                label.text = "\(index + 1)"
            }
        }
    }

    func erase(for player: String) {
        var queue = player == "O" ? oQueue : xQueue
        var positions = player == "O" ? oPositions : xPositions

        if queue.count > 3 {
            let oldest = queue.removeFirst()  // 移除并获取最早的棋子位置
            
            positions[oldest.row][oldest.col] = false  // 在棋盘上标记为未占据
            oldest.node.removeFromParent()
        }

        if player == "O" {
            oQueue = queue
            oPositions = positions
        } else {
            xQueue = queue
            xPositions = positions
        }
        
        updateLabels()
    }

    func checkForWin(_ positions: [[Bool]]) -> Bool {
        // 检查行
        for row in positions {
            if row.allSatisfy({ $0 == true }) {
                return true
            }
        }

        // 检查列
        for col in 0..<3 {
            if (positions[0][col] && positions[1][col] && positions[2][col]) {
                return true
            }
        }

        // 检查对角线
        if (positions[0][0] && positions[1][1] && positions[2][2]) || (positions[0][2] && positions[1][1] && positions[2][0]) {
            return true
        }
        return false
    }

    func endGame(winner: String) {
        gameIsOver = true
        self.isPaused = true

        let winLabel = SKLabelNode(text: "\(winner) wins!")
        winLabel.fontColor = SKColor.red
        winLabel.fontSize = 40
        winLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        winLabel.zPosition = CGFloat(numberOfTouches + 1)
        addChild(winLabel)
    }
    func resetGameState() {
        // 清除所有子节点
        self.removeAllChildren()

        // 重置游戏相关的变量
        numberOfTouches = 0
        gameIsOver = false
        self.isPaused = false
        oCount = 0
        xCount = 0
        oQueue.removeAll()
        xQueue.removeAll()
        oPositions = Array(repeating: Array(repeating: false, count: numberOfRows), count: numberOfColumns)
        xPositions = Array(repeating: Array(repeating: false, count: numberOfRows), count: numberOfColumns)
    }

    func setupGameBoard() {
        background = SKSpriteNode(imageNamed: "OOXXbg")
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = -1 // 確保背景在最底層
        addChild(background)

        // 創建棋盤節點
        let boardSize = CGSize(width: 666, height: 666) // 棋盤大小
        boardNode = SKSpriteNode(color: .clear, size: boardSize)
        boardNode.anchorPoint = CGPoint(x: 0, y: 0)
        boardNode.position = CGPoint(x: -333, y: -333)  // 调整Y坐标以适应视图顶部
        addChild(boardNode)

        // 確保遊戲場景可以接收觸摸事件
        isUserInteractionEnabled = true
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 當觸摸移動時觸發
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 當觸摸結束時觸發
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 當觸摸取消時觸發
    }
}
