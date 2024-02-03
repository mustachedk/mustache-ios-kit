
#if os(iOS)
import Foundation
import AVFAudio

public protocol AudioSessionDelegate: NSObjectProtocol {
    
    func pause()
    
    func resume()
    
    func updated(with: AVAudioSession.InterruptionType)
    
}

public protocol AudioSessionServiceType {
    
    var delegate: AudioSessionDelegate? { get set }
    
}

public class AudioSessionService: AudioSessionServiceType {
    
    public weak var delegate: AudioSessionDelegate?
    
    public init() {
        self.configure()
    }
    
    private func configure() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance())
    }
    
    @objc
    func handleInterruption(notification: Notification) {
        
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        // Switch over the interruption type.
        switch type {
                
            case .began:
                // An interruption began. Update the UI as necessary.
                self.delegate?.pause()
                
            case .ended:
                // An interruption ended. Resume playback, if appropriate.
                
                guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // An interruption ended. Resume playback.
                    self.delegate?.resume()
                } else {
                    // An interruption ended. Don't resume playback.
                }
                
            default:
                
                self.delegate?.updated(with: type)
                
        }
    }
    
}
#endif
