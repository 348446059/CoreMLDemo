//
//  ObjectRecongationController.swift
//  CoreMLDemo
//
//  Created by libo on 2017/11/27.
//  Copyright © 2017年 libo. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision
class ObjectRecongationController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
 
    
    //拿到训练模型
    var resentModel = Resnet50()
    
    //点击屏幕之后的结果
    var hitTestResult:ARHitTestResult!
    
    //分析结果
    var visionRequests = [VNRequest]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        let scene = SCNScene()
        sceneView.scene = scene
        registerGestureRecognizer()
      
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
   

}

extension ObjectRecongationController{
    
    //在sceneView上添加一个手势
    func registerGestureRecognizer()  {
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapped(recongnizer:)))
        
        self.sceneView.addGestureRecognizer(tapGes)
    }
    
  @objc  func tapped(recongnizer:UITapGestureRecognizer)  {
    
    let sceneView = recongnizer.view as! ARSCNView
      // sceneView = 截图
    let touchLocation = self.sceneView.center
    
    guard let currentFrame = sceneView.session.currentFrame else {
        return
    } //判断当前是否有像素
    
    //识别到的物件特征点
    let hitTestresults = sceneView.hitTest(touchLocation, types: .featurePoint)
    
    if hitTestresults.isEmpty {
        return
    }
    
    guard let hitTestResult = hitTestresults.first else {
        return
    }//是否为第一个物件
    
    self.hitTestResult = hitTestResult  //获取到点击的结果
    
    let pixeBuffer = currentFrame.capturedImage //拿到图片 转为像素
    
     perfomVisionRequest(pixelBuffer: pixeBuffer)
    }
    
    
    func perfomVisionRequest(pixelBuffer:CVPixelBuffer)  {
        let visionModel = try! VNCoreMLModel(for: self.resentModel.model)
        
        let request = VNCoreMLRequest(model: visionModel) { (response, error) in
            
            if error != nil{return}

            guard let observations = response.results else{return}
            
            //把結果中的第一位拿出來進行分析
            let observation = observations.first as! VNClassificationObservation
           
            print("name \(observation.identifier) and confidence is \(observation.confidence)")
            DispatchQueue.main.async {
                self.displayPredictions(text: observation.identifier)
            }
            
        }
        
        request.imageCropAndScaleOption  = .centerCrop //开始识别
        self.visionRequests = [request]
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .upMirrored, options: [:]) //将拿到的结果左右翻转
        DispatchQueue.global().async {
            try! imageRequestHandler.perform(self.visionRequests) //处理所有的结果
        }
        
        
    }
    
    //展示预测的结果
    func displayPredictions(text:String)  {
        let node = createText(text: text)
        node.position = SCNVector3(self.hitTestResult.worldTransform.columns.3.x,
                                   self.hitTestResult.worldTransform.columns.3.y,
                                   self.hitTestResult.worldTransform.columns.3.z)//当前视野的中央
        self.sceneView.scene.rootNode.addChildNode(node)
        
        
        
    }
    
    func createText(text:String) -> SCNNode {
        let parentNode = SCNNode()
        
        //圆点
        let sphere = SCNSphere(radius: 0.01)
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIColor.orange
        sphere.firstMaterial = sphereMaterial
        let sphereNode = SCNNode(geometry: sphere)
        
        //文字
        let textGeo = SCNText(string: text, extrusionDepth: 0)
        textGeo.alignmentMode = kCAAlignmentCenter
        textGeo.firstMaterial?.diffuse.contents = UIColor.orange
        textGeo.firstMaterial?.specular.contents = UIColor.white
        textGeo.firstMaterial?.isDoubleSided = true
        textGeo.font = UIFont(name: "Futura", size: 0.15)
        let textNode = SCNNode(geometry: textGeo)
        textNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        
        parentNode.addChildNode(sphereNode)
        parentNode.addChildNode(textNode)
        
        
        
        return parentNode
    }
}


extension ObjectRecongationController:ARSCNViewDelegate{
    
    
    
    
}






























