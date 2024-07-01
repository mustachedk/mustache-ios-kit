
import AVFoundation

#if canImport(RxSwift)
import RxSwift

/*:
 
 class ScannerViewController: UIViewController {
 
 fileprivate var captureSession = AVCaptureSession()
 fileprivate var captureMetadataOutput = AVCaptureMetadataOutput()
 fileprivate var videoPreviewLayer: AVCaptureVideoPreviewLayer?
 fileprivate var qrCodeFrameView = UIView()
 
 fileprivate let disposeBag = DisposeBag()
 
 init() {
 super.init(nibName: nil, bundle: nil)
 self.configureView()
 self.configureBindings()
 }
 
 override func viewDidAppear(_ animated: Bool) {
 super.viewDidAppear(animated)
 self.configureScanner()
 captureSession.startRunning()
 }
 
 override func viewWillDisappear(_ animated: Bool) {
 super.viewWillDisappear(animated)
 captureSession.stopRunning()
 }
 
 fileprivate func configureView() {
 
 self.qrCodeFrameView.backgroundColor = .red
 self.view.addSubview(self.qrCodeFrameView)
 self.view.setNeedsUpdateConstraints()
 }
 
 fileprivate func configureScanner() {
 
 let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
 
 guard let captureDevice = deviceDiscoverySession.devices.first else {
 //Alert user
 return
 }
 
 do {
 let input = try AVCaptureDeviceInput(device: captureDevice)
 self.captureSession.addInput(input)
 self.captureSession.addOutput(captureMetadataOutput)
 self.captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.interleaved2of5]
 
 } catch {
 //Alert user
 return
 }
 
 self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
 self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
 self.videoPreviewLayer?.frame = view.layer.bounds
 self.view.layer.addSublayer(videoPreviewLayer!)
 
 self.view.bringSubview(toFront: self.qrCodeFrameView)
 
 }
 
 fileprivate func configureBindings() {
 
 self.captureMetadataOutput.rx.didOutput
 .map({ [weak self] (objects: [AVMetadataObject]) -> String? in
 guard let `self` = self else { return nil }
 
 guard let first = objects.first as? AVMetadataMachineReadableCodeObject else {
 self.qrCodeFrameView.backgroundColor = .red
 return nil
 }
 
 if first.type != .interleaved2of5 {
 return nil
 }
 
 guard let barCodeObject = self.videoPreviewLayer?.transformedMetadataObject(for: first) else {
 return nil
 }
 
 self.qrCodeFrameView.frame = CGRect(x: barCodeObject.bounds.minX, y: barCodeObject.bounds.minY, width: barCodeObject.bounds.width, height: 10)
 self.qrCodeFrameView.backgroundColor = .green
 
 guard let barCode = first.stringValue else {
 return nil
 }
 
 return barCode
 })
 .unwrap()
 .throttle(1, latest: true, scheduler: MainScheduler.instance)
 .subscribe(onNext: { [weak self] _ in //Do what ever })
 .disposed(by: self.disposeBag)
 
 }
 
 required init?(coder aDecoder: NSCoder) { fatalError("\(#line) not implemented") }
 
 }
 
 */

@available(macOS 13.0, *)
class RxAVCaptureMetadataOutputObjectsDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    /// Typed parent object.
    weak fileprivate(set) var metaDataOutput: AVCaptureMetadataOutput?
    
    /// - parameter scrollView: Parent object for delegate proxy.
    init(metaDataOutput: AVCaptureMetadataOutput) {
        super.init()
        self.metaDataOutput = metaDataOutput
        self.metaDataOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    }
    
    fileprivate let metadataOutput = ReplaySubject<[AVMetadataObject]>.create(bufferSize: 1)
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        self.metadataOutput.onNext(metadataObjects)
    }
    
    deinit {
        self.metadataOutput.onCompleted()
    }
}

@available(macOS 13.0, *)
public extension Reactive where Base: AVCaptureMetadataOutput {
    
    internal var delegate: RxAVCaptureMetadataOutputObjectsDelegate {
        return RxAVCaptureMetadataOutputObjectsDelegate(metaDataOutput: self.base)
    }
    
    var didOutput: RxObservable<[AVMetadataObject]> {
        return self.delegate.metadataOutput.asObservable()
    }
}

#endif
