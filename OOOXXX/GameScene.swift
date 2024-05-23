import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // 定義棋盤節點
    var boardNode: SKSpriteNode!
    var numberOfTouches = 0
    var helloLabel: SKLabelNode!
    var background: SKSpriteNode!
    var column=0
    var row=0
    var oCount=0
    var xCount=0
    var gameIsOver = false
    var oPositions: [[Bool]] = Array(repeating: Array(repeating: false, count: 3), count: 3)
    var xPositions: [[Bool]] = Array(repeating: Array(repeating: false, count: 3), count: 3)

    let boardWidth: CGFloat = 720 // 棋盤寬度
    let boardHeight: CGFloat = 724 // 棋盤高度
    let numberOfRows = 3 // 棋盤行數
    let numberOfColumns = 3 // 棋盤列數
    


    override func didMove(to view: SKView) {
        // 設置背景
        setupGameBoard()
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if gameIsOver
        {
            let newScene = GameScene(size: self.size)
            newScene.scaleMode = .fill
            view?.presentScene(newScene,transition:SKTransition.flipHorizontal(withDuration: 0.5))
            resetGameState()
            
            return
        }
        let location = touch.location(in: boardNode)  // 計算觸摸位置相對於 boardNode

        print("Touch location in boardNode: \(location)")
        if 0 <= location.x && location.x < boardNode.size.width && 0 <= location.y && location.y < boardNode.size.height {
            let column = Int(location.x / 222)
            let row = Int(location.y / 222)
            let centerX = CGFloat(column) * 222 + 111
            let centerY = CGFloat(row) * 222 + 111
            if(oPositions[row][column] == true||xPositions[row][column] == true)
            {//如果那格已經有棋子了
                return
            }

            let imageName = (numberOfTouches % 2 == 0) ? "X.png" : "O.png"
            //用第幾次碰觸來判斷是Ｘ回合還是Ｏ回合
            let sprite = SKSpriteNode(imageNamed: imageName)
            sprite.position = CGPoint(x: centerX, y: centerY)
            sprite.zPosition = CGFloat(numberOfTouches)
            boardNode.addChild(sprite)//放棋子
            if(numberOfTouches%2 == 0)
            {
                xPositions[row][column] = true
            }
            else
            {
                oPositions[row][column] = true
            }
            numberOfTouches += 1
        }
        if checkForWin(xPositions)||checkForWin(oPositions) {
            print("\(((numberOfTouches % 2) == 0) ? "O" : "X") wins!")
            self.isPaused = true;
            endGame(winner: numberOfTouches%2 == 0 ?"O":"X")
            
            // 可以在这里执行一些游戏结束的逻辑，比如显示胜利信息，禁止进一步触摸等
        }
    }
    func checkForWin(_ positions: [[Bool]]) -> Bool {
        // 检查行
        for row in positions {
            if row.allSatisfy({ $0 == true }) {
                print("game over橫線")
                return true
            }
        }

        // 检查列
        for col in 0..<3 {
            if positions[0][col] && positions[1][col] && positions[2][col] {
                print("game over直線")

                return true

            }
        }

        // 检查对角线
        if (positions[0][0] && positions[1][1] && positions[2][2]) || (positions[0][2] && positions[1][1] && positions[2][0]) {
            print("game over斜線")
            return true
        }

        return false
    }

    func endGame(winner: String) {
        //gameIsOver = true  // 停止接收触摸事件
        self.isPaused = true  // 暂停场景
        //stopTimer()  // 停止所有计时器
        gameIsOver = true

        // 显示胜利者信息
        let winLabel = SKLabelNode(text: "\(winner) wins!")
        winLabel.fontColor = SKColor.red
        
        winLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        winLabel.fontSize = 40
        winLabel.zPosition = CGFloat(numberOfTouches+1)
        addChild(winLabel)
    }
    func resetGameState() {
        // 清除棋子
        self.removeAllChildren()

        // 重置游戏相关的变量
        numberOfTouches = 0
        gameIsOver = false
        self.isPaused = false

        // 重新设置棋盘
        setupGameBoard()
    }


    func checkForWin(_ positions: [CGPoint]) -> Bool {
        // 實現勝利條件判斷的邏輯（需要詳細規劃）
        return false
    }
    func setupGameBoard()
        {
            background = SKSpriteNode(imageNamed: "OOXXbg")
            background.position = CGPoint(x: 0, y: 0)
            background.zPosition = -1 // 確保背景在最底層
            addChild(background)
            // 創建棋盤節點
            let boardSize = CGSize(width: 666, height: 666) // 棋盤大小
            boardNode = SKSpriteNode(color: .clear, size: boardSize)
            boardNode.anchorPoint = CGPoint(x:0,y:0)
            
            boardNode.position = CGPoint(x: -333, y: -333)  // 调整Y坐标以适应视图顶部
            addChild(boardNode)
            // 確保遊戲場景可以接收觸摸事件
            isUserInteractionEnabled = true
            /*print("View size: \(view.frame.size)")
            print("Board position: \(boardNode.position)")
            print("Board size: \(boardNode.size)")*/
        }

    func touchDown(atPoint pos : CGPoint) {
        // 當觸摸按下時觸發
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        // 當觸摸移動時觸發
    }
    
    func touchUp(atPoint pos : CGPoint) {
        // 當觸摸抬起時觸發
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 當觸摸移動時觸發
        /*
        guard let touch = touches.first else { return }
            
            // 獲取觸摸點的位置
            let location = touch.location(in: self)
            
        print("Touch moved to \(location)")*/

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 當觸摸結束時觸發
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 當觸摸取消時觸發
    }
}
