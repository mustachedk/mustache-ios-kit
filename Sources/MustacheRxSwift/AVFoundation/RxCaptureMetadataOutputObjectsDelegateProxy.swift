#if canImport(RxCocoa)

import AVFoundation
import RxSwift
import RxCocoa

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
extension AVCaptureMetadataOutput: HasDelegate {

    public var delegate: AVCaptureMetadataOutputObjectsDelegate? {
        get {
            return self.metadataObjectsDelegate
        }
        set(newValue) {
            self.setMetadataObjectsDelegate(newValue!, queue: DispatchQueue.main)
        }
    }

    public typealias Delegate = AVCaptureMetadataOutputObjectsDelegate

}

@available(macOS 13.0, *)
public class RxCaptureMetadataOutputObjectsDelegateProxy: DelegateProxy<AVCaptureMetadataOutput, AVCaptureMetadataOutputObjectsDelegate>, DelegateProxyType, AVCaptureMetadataOutputObjectsDelegate {

    /// Typed parent object.
    public weak fileprivate(set) var metaDataOutput: AVCaptureMetadataOutput?

    /// - parameter scrollView: Parent object for delegate proxy.
    public init(metaDataOutput: ParentObject) {
        self.metaDataOutput = metaDataOutput
        super.init(parentObject: metaDataOutput, delegateProxy: RxCaptureMetadataOutputObjectsDelegateProxy.self)
    }

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxCaptureMetadataOutputObjectsDelegateProxy(metaDataOutput: $0) }
    }

    public static func currentDelegate(for object: AVCaptureMetadataOutput) -> AVCaptureMetadataOutputObjectsDelegate? {
        return object.metadataObjectsDelegate
    }

    public static func setCurrentDelegate(_ delegate: AVCaptureMetadataOutputObjectsDelegate?, to object: AVCaptureMetadataOutput) {
        object.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
    }

}

@available(macOS 13.0, *)
public extension Reactive where Base: AVCaptureMetadataOutput {

    var delegate: DelegateProxy<AVCaptureMetadataOutput, AVCaptureMetadataOutputObjectsDelegate> {
        return RxCaptureMetadataOutputObjectsDelegateProxy.proxy(for: base)
    }

    var didOutput: RxObservable<[AVMetadataObject]> {
        return delegate.methodInvoked(#selector(AVCaptureMetadataOutputObjectsDelegate.metadataOutput(_:didOutput:from:)))
                .map { a in
                    let metadataObjects = a[1] as? [AVMetadataObject]
                    return metadataObjects ?? []
                }
    }
}

#endif
