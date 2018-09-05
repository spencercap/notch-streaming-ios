
import UIKit
import QuartzCore
import SceneKit
import SpriteKit
import WearnotchSDK

// OSC
import SwiftOSC
//var server = OSCServer(address: "", port: 8080)
var client  = OSCClient(address: "10.17.31.188", port: 8080)
var address = OSCAddressPattern("/")
var message = OSCMessage(
    OSCAddressPattern("/"),
    100,
    5.0,
    "Hello World"
)

class VisualiserViewController: WorkoutAnimationViewController, AnimationProgressDelegate {
    
    var measurementURL: URL?
    var isExampleMeasurement: Bool = false
    var currentCancellable: NotchCancellable? = nil
    
    var sceneProvider: NotchSceneProvider!
    
    var visualiserData: NotchVisualiserData!
    var droidAvatarSource: AvatarVisualizationSource!
    var avatarAnimation: AvatarAnimation!
    var notchAnimation: NotchAnimation!
    
    var sceneOverlay: AnimationControlsOverlay!
    
    var progress: Float = 0.0
    
    override func viewDidLoad() {
        // set up scene
        super.viewDidLoad()
        
        // add static elements to scene:
        addFloor()
        
        if let workout = AppDelegate.service.getNetwork()?.workout {
            self.sceneProvider = workout
            if workout.isRealTime {
                self.startRealTimeCapture()
            } else {
                configureReplayMeasurement()
            }
        } else if self.isExampleMeasurement {
            configureReplayMeasurement()
        }
    }
    
    private func createFile() -> String {
        let dateString = createCurrentDateString()
        let fileName = "\(dateString).zip"
        
        let captureDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        let measurementURL = URL(fileURLWithPath: "\(captureDirectory)/\(fileName)")
        
        return measurementURL.path
    }
    
    private func createCurrentDateString() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        dateFormatter.locale = Locale.init(identifier: "en_US")
        return dateFormatter.string(from: Date())
    }
    
    private func startRealTimeCapture() {
        self.currentCancellable = AppDelegate.service.capture(
            outputFilePath: createFile(),
            success: { },
            failure: { result in
                self.showFailure(notchError: result)
                self.currentCancellable = nil
        },
            progress: { progress in
                
                if self.notchAnimation == nil {
                    
                    self.notchAnimation = NotchAnimation()
                    self.notchAnimation!.delegate = NotchRealTimeAnimationDelegate()
                    self.notchAnimation!.offset  = GLKVector3Make(0.0, 0.9585, 0.0)  // app-dependant (where the floor is)
                    self.addAvatarAnimations()
                    
                    self.addWorkoutAnimation(self.notchAnimation!)
                    
                    (self.view as! SCNView).isPlaying = true
                }
                
                (self.notchAnimation!.delegate as! NotchRealTimeAnimationDelegate).visualiserData = progress.realtimeData
                
                
                
                
                // get some bones
                let RightUpperArm = (self.sceneProvider.skeleton.bone("RightUpperArm"))
//                print( RightUpperArm )
                let RightForeArm = (self.sceneProvider.skeleton.bone("RightForeArm"))
                let ChestBottom = (self.sceneProvider.skeleton.bone("ChestBottom"))
                let Hip = (self.sceneProvider.skeleton.bone("Hip"))
                
                

                
                // TODO: iterate through the 'getWorkout' function for each bone 
                if (RightForeArm != nil) {
                    let pos = progress.realtimeData?.getPosition(bone: RightForeArm!, frameIndex: 0)! // positions measured in meters
                    let posX = pos?[0]
                    let posY = pos?[1]
                    let posZ = pos?[2]
//                    print( posX, posY, posZ )
                    
                    
                    let ori = progress.realtimeData?.calculateRelativeAngle(bone: RightForeArm!, frameIndex: 0)! // frameIndex: 0 is a hack for realtime
                    let oriX = ori?[0]
                    let oriY = ori?[1]
                    let oriZ = ori?[2]
//                    print(oriX, oriY, oriZ)
                    
                    
                    let quat = progress.realtimeData?.orientation(bone: RightForeArm!, frameIndex: 0)!
                    let quatX = GLKQuaternionAxis(quat!)[0]
                    let quatY = GLKQuaternionAxis(quat!)[1]
                    let quatZ = GLKQuaternionAxis(quat!)[2]
                    let quatW = GLKQuaternionAngle(quat!)
//                    print(quatX, quatY, quatZ, quatW)
                    

                    let RightForeArmMessage = OSCMessage(
                        OSCAddressPattern("/RightForeArmMessage/"),
                        "RightForeArmMessage",
                        posX,
                        posY,
                        posZ,
                        oriX,
                        oriY,
                        oriZ,
                        quatX,
                        quatY,
                        quatZ,
                        quatW
                    )
                    
                    client.send(RightForeArmMessage)
                    
                }
                
                
                
                
                if (ChestBottom != nil) {
                    let ori = progress.realtimeData?.calculateRelativeAngle(bone: ChestBottom!, frameIndex: 0)!
                    let oriX = ori?[1]
//                    print(oriX)
                    
                    let posMess = OSCMessage(
                        OSCAddressPattern("/"),
                        "oriX",
                        oriX
                    )
                    client.send(posMess)

                }
                
                
        },
            cancelled: { })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "NOTCH VISUALIZER"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentCancellable?.cancel()
    }
    
    private func configureReplayMeasurement() {
        
        if (self.isExampleMeasurement) {
            do {
                let measurementAsset = NSDataAsset(name: "cartwheel_11notches", bundle: Bundle.main)
                self.visualiserData = try NotchVisualiserData.fromData(data: measurementAsset!.data)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            do {
                self.visualiserData = try NotchVisualiserData.fromURL(url: (self.measurementURL)!)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        self.sceneProvider = self.visualiserData.config
        self.notchAnimation = NotchAnimation(visualiserData)
        self.notchAnimation!.offset  = GLKVector3Make(0.0, 0.9585, 0.0)  // app-dependant (where the floor is)
        (self.notchAnimation!.delegate as! NotchWorkoutAnimationDelegate).progress.delegate = self
        
        addAvatarAnimations()
        
        // add overlay:
        sceneOverlay = AnimationControlsOverlay(size: self.view.bounds.size)
        sceneOverlay.topPadding = 64.0 / sceneOverlay.dpi // navigation bar + status bar
        sceneOverlay.cameraController = self
        sceneOverlay.animationController = self
        
        sceneOverlay.scnView = (self.view as! SCNView)
        (self.view as! SCNView).overlaySKScene = sceneOverlay
        
        sceneOverlay.resize(self.view.bounds.size)
        
        
        if notchAnimation.delegate is NotchWorkoutAnimationDelegate {
            sceneOverlay.animationProgress = (notchAnimation.delegate as! NotchWorkoutAnimationDelegate).progress
        }
        
        // add animation & start it
        addWorkoutAnimation(self.notchAnimation!)
        
        /// CONTROLLER DEMO - custom top view angle
        self.cameraTopYAngle = Float(Double.pi)
        
        (notchAnimation.delegate as! NotchWorkoutAnimationDelegate).progress.rewindAtEnd = true
        (notchAnimation.delegate as! NotchWorkoutAnimationDelegate).progress.isLooping = true
        
        (notchAnimation.delegate as! NotchWorkoutAnimationDelegate).progress.play()
    }
    
    func addAvatarAnimations() {
        // add avatar visualization
        let avatarModelRoot = VisualizationSourceLoadDefaultDroidRoot(modelName: "notch_male")  // default model (as SCNNode)
        let avatarNodesPivoter = AvatarNodesPivoterCreateDefault(modelName: "notch_male")  // use built-in model's sizes
        let avatarBoneNodes = avatarNodesPivoter.getScaledBones(avatarModelRoot, sceneProvider: self.sceneProvider) // pivot & scale bones
        droidAvatarSource = AvatarVisualizationSource(targetScene: self.scene!, nodes: avatarBoneNodes)  // source
        
        self.avatarAnimation = AvatarAnimation(skeleton: sceneProvider.skeleton, source: droidAvatarSource)
        
        if visualiserData?.config.disabledBones != nil {
            for bone in visualiserData.config.disabledBones {
                self.avatarAnimation.disableBone(bone.boneName)
            }
        }
        
        self.notchAnimation!.addVisualisation(avatarAnimation)
    }
    
    func addFloor() {
        // add floor color
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor(red: 140/255.0, green: 142/255.0, blue: 145/255.0, alpha: 1.0)
        let floor = SCNPlane(width: 37, height: 37)
        let floorNode = SCNNode()
        floorNode.geometry = floor
        floorNode.geometry?.materials = [floorMaterial]
        floorNode.transform = SCNMatrix4Mult(floorNode.transform, SCNMatrix4MakeRotation(Float(Double.pi / -2.0), 1, 0, 0))
        floorNode.position = SCNVector3Make(0.0, -0.02, 0.0)
        self.scene?.rootNode.addChildNode(floorNode)
    }
    
    func animationProgressDidUpdate(_ animationProgress: AnimationProgress) {
        let frameIndex = Int32(animationProgress.progress*Float(visualiserData.frameCount))
        let rootbone = (sceneProvider.skeleton.bone("Root"))
        var centerpos = GLKVector3.init(v: (0.0, 0.0, 0.0))
        if (rootbone != nil) {
            centerpos = visualiserData.getPosition(bone: rootbone!, frameIndex: frameIndex)!
        }
        self.cameraCenter = centerpos
    }
    
    
    func animationProgressDidStartPlaying(_ animationProgress: AnimationProgress) {
        (self.view as! SCNView).isPlaying = true
        sceneOverlay.animationPaused = false
    }
    
    func animationProgressDidPause(_ animationProgress: AnimationProgress) {
        (self.view as! SCNView).isPlaying = false
        sceneOverlay.animationPaused = true
    }
    
    func animationProgressDidStartSeeking(_ animationProgress: AnimationProgress) {
        (self.view as! SCNView).isPlaying = true
    }
    
    func animationProgressDidStopSeeking(_ animationProgress: AnimationProgress) {
    }
    
    func animationProgressDidStop(_ animationProgress: AnimationProgress) {
        (self.view as! SCNView).isPlaying = false
        sceneOverlay.animationPaused = true
    }
}

