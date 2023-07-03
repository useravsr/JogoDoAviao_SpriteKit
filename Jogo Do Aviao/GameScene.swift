//
//  GameScene.swift
//  Jogo Do Aviao
//
//  Created by Arthur Dos Reis on 02/07/23.
//

import SpriteKit
import GameplayKit

var pontos = 0 // contador de pontos
var comecou:Bool = false // começar jogo
var acabou:Bool = false // terminar jogo
var podeReiniciar:Bool = false // reiniciar jogo

var inimigos:[ObjetoAnimado] = []

// Variaveis de contato
var idFelpudo:UInt32 = 1
var idInimigo:UInt32 = 2
var IdItem:UInt32 = 3

class GameScene: SKScene, SKPhysicsContactDelegate { //SKPhysicsContactDelegate é necessario para identificar o contato entre os objetos
    
    // Efeitos especiais
    var somPick = SKAction.playSoundFileNamed("PLIN.mp3", waitForCompletion: false)
    var somHit = SKAction.playSoundFileNamed("QUEBRA.mp3", waitForCompletion: false)
    
    //Variaveis dos textos que aparecem na tela
    let textoPontos = SKLabelNode(fontNamed: "True Crimes")
    let textoGame = SKLabelNode(fontNamed: "True Crimes")
    
    // Ações para os inimigos e a pena
    let acaoMove = SKAction.moveTo(x: -100, duration: 5)
    let acaoRemove = SKAction.removeFromParent()
    
    // Personagem principal
    let felpudo:ObjetoAnimado = ObjetoAnimado("aviao")
    
    // Objeto Dummy para controlar o fundo
    let objetoDummy = SKNode()
    
    // Objeto para sortear os inimigos e a pena
    var sorteiaItens = SKAction()
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.black
        
        SKAudio.sharedInstance().backgroundMusicPlayer?.volume = 0.5
        SKAudio.sharedInstance().playBackgroundMusic("MUSICA.mp3") // Adicionar musica ao jogo
        
        self.physicsWorld.contactDelegate = self // Fisica adicionada a cena
        
    //MARK: Adicionar o limite para o tamanho da tela
        
//        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
//        borderBody.friction = 0
//        self.physicsBody = borderBody
        
    //MARK: Criar e mover o fundo em loop
        
        var imagemFundo: SKSpriteNode = SKSpriteNode()
        let moveFundo = SKAction.moveBy(x: -self.size.width, y: 0, duration: 5)
        let reposicionaFundo = SKAction.moveBy(x: self.size.width, y: 0, duration: 0)
        let repete = SKAction.repeatForever(SKAction.sequence([moveFundo, reposicionaFundo]))
        
        for i in 0..<2{
            imagemFundo = SKSpriteNode(imageNamed: "imagem_fundo")
            imagemFundo.anchorPoint = CGPoint(x: 0, y: 0)
            imagemFundo.size.width = self.size.width
            imagemFundo.size.height = self.size.height
            imagemFundo.position = CGPoint(x: self.size.width * CGFloat(i), y: 0)
            imagemFundo.zPosition = -1
            imagemFundo.run(repete)
            objetoDummy.addChild(imagemFundo) // Crio o objetoDummy e adiciono todas as propriedades do fundo a ela, isso facilita a manipulação do fundo, deixar mais rapido, lento ou até parar.
        }
        
        self.addChild(objetoDummy)
        objetoDummy.speed = 0
        
    //MARK: Propriedades do personagem principal
        
        felpudo.name = "Personagem"
        felpudo.setScale(0.8)
        felpudo.position = CGPoint(x: 150, y: 200)
        self.addChild(felpudo)
        
                
    //MARK: Configuração dos textos
        
        textoGame.text = "Toque para Iniciar"
        textoPontos.text = "Score: \(pontos)"
        
        textoPontos.horizontalAlignmentMode = .right
        textoPontos.verticalAlignmentMode = .top
        
        textoPontos.fontColor = .white
        textoGame.fontColor = .yellow
        
        textoPontos.position = CGPoint(x: frame.maxX-30, y: frame.maxY-10)
        textoGame.position = CGPoint(x: frame.midX, y: frame.midY)
        
        self.addChild(textoPontos)
        self.addChild(textoGame)
        
    //MARK: Sortear elementos na tela
        
        sorteiaItens = SKAction.run {
            if(comecou && !acabou){
                let sorteio = Int.random(in: 0..<20)
                
                if(sorteio < 5){
                    self.criarLesmo()
                }else if(sorteio >= 5 && sorteio < 10){
                    self.criarBugado()
                }else if(sorteio >= 16){
                    self.criarPeninha()
                }
            }
        }
        
    } //fim Did move
    
    //MARK: Criar inimigo 1
    func criarLesmo(){
        
        let py = Float.random(in: 15..<90)
        let lesmo:ObjetoAnimado = ObjetoAnimado("lesmo")
        lesmo.setScale(0.8)
        lesmo.position = CGPoint(x: self.size.width + 100, y: CGFloat(py))
        
        lesmo.name = "Inimigo"
        lesmo.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: lesmo.size.width-10, height: 30), center: CGPoint(x: 0, y: -lesmo.size.height/2+25))
        lesmo.physicsBody?.isDynamic = false
        lesmo.physicsBody?.allowsRotation = false
        lesmo.physicsBody?.categoryBitMask = idInimigo
        
        lesmo.run(SKAction.sequence([acaoMove, acaoRemove,]))
//        inimigos.append(lesmo)
        self.addChild(lesmo)
        
    }
    
    //MARK: Criar inimigo 2
    func criarBugado(){
        
        let py = Float.random(in: 120..<400)
        let bugado:ObjetoAnimado = ObjetoAnimado("bugado")
        bugado.setScale(0.8)
        bugado.position = CGPoint(x: self.size.width + 100, y: CGFloat(py))
        
        bugado.name = "Inimigo"
        bugado.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bugado.size.width-30, height: 50), center: CGPoint(x: -10, y: -bugado.size.height/2+25))
        bugado.physicsBody?.isDynamic = false
        bugado.physicsBody?.allowsRotation = false
        bugado.physicsBody?.categoryBitMask = idInimigo
        
        bugado.run(SKAction.sequence([acaoMove, acaoRemove, SKAction.run {
            inimigos.remove(at: 0)
        }]))
        inimigos.append(bugado)
        self.addChild(bugado)
        
    }
    
    //MARK: Criar penas
    func criarPeninha(){
        
        let py = Float.random(in: 50..<400)
        let peninha:ObjetoAnimado = ObjetoAnimado("pena_dourada")
        peninha.setScale(0.7)
        peninha.position = CGPoint(x: self.size.width + 100, y: CGFloat(py))
        
        peninha.name = "Item"
        peninha.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: peninha.size.width-10, height: 30), center: CGPoint(x: 0, y: -peninha.size.height/2+25))
        peninha.physicsBody?.isDynamic = false
        peninha.physicsBody?.allowsRotation = false
        peninha.physicsBody?.categoryBitMask = IdItem
        
        peninha.run(SKAction.sequence([acaoMove, acaoRemove]))
        self.addChild(peninha)
        
    }
    
    //MARK: Função fim de jogo
    
    func fimDeJogo(){
        
        print("Game Over!")
        acabou = true
        self.felpudo.physicsBody?.velocity = CGVector.zero
        self.felpudo.physicsBody?.velocity = CGVector(dx: -80, dy: 50)
        objetoDummy.speed = 0
        textoGame.isHidden = false
        textoGame.text = "Fim de Jogo!"
        self.run(somHit)
        SKAudio.sharedInstance().backgroundMusicPlayer?.volume = 0.1
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.run {
            self.textoGame.text = "Toque para Reiniciar"
            podeReiniciar = true
            
            let children = self.children // Algoritmo para remover os elementos da tela, quando o jogo for finalizado, removendo os "filhos" da cena.
            for child in children {
                if(child.name != nil){
                    if(child.name! == "Item") || (child.name! == "Inimigo"){
                        
                        self.criarExplosao(child.position)
                        
                        child.removeFromParent()
                    }
                }
            }
        }]))
        
    }
    
    //MARK: Função para empinar o aviao
    override func didSimulatePhysics() {
        if(comecou){
            self.felpudo.zRotation = (self.felpudo.physicsBody?.velocity.dy)!*0.0005
        }
    }
    
    
    //MARK: Função de toque
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(!acabou){ // encerrar o jogo
            if(!comecou){ // verificaçao para ver se o jogo começou, adicionar propriedades fisicas ao personagem, sumir com o texto
                
                comecou = true
                
                //Propriedades fisicas no personagem
                felpudo.physicsBody = SKPhysicsBody(circleOfRadius: felpudo.size.height/2.5, center: CGPoint(x:15, y: -10))
                felpudo.physicsBody?.isDynamic = true
                felpudo.physicsBody?.allowsRotation = false
                
                felpudo.physicsBody?.categoryBitMask = idFelpudo
                felpudo.physicsBody?.collisionBitMask = 0
                felpudo.physicsBody?.contactTestBitMask = idInimigo | IdItem
                
                textoGame.isHidden = true // sumir com o texto para começar o jogo
                
                objetoDummy.speed = 1 // iniciar o fundo
                
                self.run(SKAction.repeatForever(SKAction.sequence([sorteiaItens, SKAction.wait(forDuration: 2.0)]))) // controlar fluxo de inimigos
                
            }
            
            self.felpudo.physicsBody?.velocity = CGVector.zero //Zera a velocidade de queda durante o toque, para que fique mais fluida a subida do personagem
            self.felpudo.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 75))
        } else {
            
            if(podeReiniciar){ // Reiniciar o jogo e restaurar as variaveis de controle
                self.felpudo.position = CGPoint(x: 150, y: 200)
                self.felpudo.physicsBody?.velocity = CGVector.zero
                self.felpudo.physicsBody?.isDynamic = false
                self.felpudo.zRotation = 0
                comecou = false
                acabou = false
                podeReiniciar = false
                textoGame.isHidden = true
                objetoDummy.speed = 1
                pontos = 0
                textoPontos.text = "Score: \(pontos)"
                SKAudio.sharedInstance().backgroundMusicPlayer?.volume = 0.5
            }
            
        }
    }
    
    //MARK: Função para verificar se o jogo terminou
    override func update(_ currentTime: TimeInterval) {
        
        for e in inimigos{
            e.atualizaSenoide()
        }
        if(!acabou && comecou){
            if(felpudo.position.y < (felpudo.size.height/2+10)){
                fimDeJogo()
            }
            if(felpudo.position.y > (self.size.height + 10)){
                fimDeJogo()
            }
        }
    }
    
    //MARK: Função para identificar contato
    func didBegin(_ contact: SKPhysicsContact) {
        
        if(contact.bodyA.node?.name == "Inimigo"){
            fimDeJogo()
        }
        if(contact.bodyA.node?.name == "Item"){
            
            let px = CGFloat(contact.bodyA.node?.position.x ?? 0)
            let py = CGFloat(contact.bodyA.node?.position.y ?? 0)
            contact.bodyA.node?.removeFromParent()
            criarParticulaPenas(CGPoint(x: px, y: py))
            pontos += 1
            self.run(somPick)
            textoPontos.text = "Score: \(pontos)"
        }
    }
    
    //MARK: Função para criar particula
    func criarParticulaPenas(_ pos:CGPoint){
        
        let peninha:SKTexture = SKTexture(imageNamed: "estrela")
        let minhaParticula:SKEmitterNode = SKEmitterNode()
        minhaParticula.particleTexture = peninha
        minhaParticula.position = pos
        minhaParticula.particleSize = CGSize(width: 8, height: 8)
        minhaParticula.particleBirthRate = 25
        minhaParticula.numParticlesToEmit = 10
        minhaParticula.particleLifetime = 0.5
        minhaParticula.particleTexture?.filteringMode = .nearest
        minhaParticula.xAcceleration = 0
        minhaParticula.yAcceleration = 0
        minhaParticula.particleSpeed = 200
        minhaParticula.particleSpeedRange = 100
        minhaParticula.particleRotationSpeed = -3
        minhaParticula.particleRotationRange = 3
        minhaParticula.emissionAngle = CGFloat(Double.pi*2)
        minhaParticula.emissionAngleRange = CGFloat(Double.pi*2)
        minhaParticula.particleAlphaSpeed = 0.1
        minhaParticula.particleAlphaRange = 1
        minhaParticula.particleAlphaSequence = SKKeyframeSequence(keyframeValues: [1,0], times: [0,1])
        minhaParticula.particleScaleSequence = SKKeyframeSequence(keyframeValues: [3,0.5], times: [0,1])
        self.addChild(minhaParticula)
        minhaParticula.run(SKAction.move(by: CGVector(dx: -10, dy: 5), duration: 1.0))
        minhaParticula.run(SKAction.sequence([SKAction.wait(forDuration: 2), SKAction.removeFromParent()]))
        
    }
    
    //MARK: Criar efeito explosão
    
    
    func criarExplosao(_ pos:CGPoint){
        
        let explosao = ObjetoAnimado("explosao")
        explosao.position = CGPoint(x: pos.x, y: pos.y)
        explosao.run(SKAction.move(by: CGVector(dx: -10, dy: 5), duration: 1.0))
        explosao.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1.0), SKAction.removeFromParent()]))
        self.addChild(explosao)
        
    }
    
}
