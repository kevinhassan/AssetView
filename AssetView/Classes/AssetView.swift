import FLAnimatedImage
import Lottie
import SDWebImage
import UIKit

@IBDesignable
public class AssetView: UIView {
    private var lottieView: AnimationView?
    private var imageView: UIImageView?
    private var gifImageView: FLAnimatedImageView?

    private var assetType: AssetType? {
        didSet {
            for view in subviews {
                view.removeFromSuperview()
            }
        }
    }

    @IBInspectable
    public var activityIndicatorStyle: UIActivityIndicatorView.Style = .whiteLarge

    public var assetContentMode: UIView.ContentMode? {
        didSet {
            guard let contentMode = assetContentMode, let assetType = assetType else {
                return
            }
            switch assetType {
            case .lottie:
                lottieView?.contentMode = contentMode
            case .image:
                imageView?.contentMode = contentMode
            case .gif:
                gifImageView?.contentMode = contentMode
            }
        }
    }

    public func configure(with type: AssetType, contentMode: ContentMode?) {
        assetContentMode = contentMode
        assetType = type
        switch type {
        case let .lottie(resource: url,
                         loopMode: loopMode,
                         closure: closure,
                         _):
            setupLottie(with: url,
                        loopMode: loopMode,
                        closure: closure)
        case let .image(resource: url, tintColor: tintColor, completion):
            setupImage(with: url, tintColor: tintColor, completion: completion)
        case let .gif(resource: url, completion: completion):
            setupGif(with: url, completion: completion)
        }
    }
}

// MARK: Setup content
fileprivate extension AssetView {
    func setupLottie(with url: URL,
                     loopMode: LottieLoopMode?,
                     closure: (() -> Void)?) {
        lottieView = AnimationView(url: url, closure: { error in
            if let anError = error {
                print("Animation file couldn't be load")
                print(anError.localizedDescription)
            } else {
                closure?()
            }
        })

        lottieView?.loopMode = loopMode ?? .playOnce
        lottieView?.contentMode = assetContentMode ?? .scaleToFill
        addSubview(lottieView!)
        lottieView?.translatesAutoresizingMaskIntoConstraints = false
        lottieView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        lottieView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        lottieView?.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        lottieView?.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    func setupImage(with url: URL, tintColor: UIColor?, completion: (() -> Void)?) {
        imageView = UIImageView()
        if let tintColor = tintColor {
            imageView?.tintColor = tintColor
        }

        imageView?.contentMode = assetContentMode ?? .scaleToFill
        addSubview(imageView!)
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        imageView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView?.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView?.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageView?.sd_addActivityIndicator()
        imageView?.sd_setIndicatorStyle(activityIndicatorStyle)
        imageView?.sd_setImage(with: url) { [weak self] _, _, _, _  in
            self?.gifImageView?.sd_removeActivityIndicator()
            completion?()
        }
    }

    func setupGif(with url: URL, completion: (() -> Void)?) {
        gifImageView = FLAnimatedImageView()
        gifImageView?.contentMode = assetContentMode ?? .scaleToFill
        gifImageView?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gifImageView!)
        gifImageView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        gifImageView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        gifImageView?.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        gifImageView?.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        gifImageView?.sd_addActivityIndicator()
        gifImageView?.sd_setIndicatorStyle(activityIndicatorStyle)
        gifImageView?.sd_setImage(with: url) { [weak self] _, _, _, _ in
            self?.gifImageView?.sd_removeActivityIndicator()
            completion?()
        }
    }
}

// MARK: Animation functions
public extension AssetView {
    func play() {
        DispatchQueue.main.async {[weak self] in
            self?.lottieView?.currentProgress = 0
            if case let .lottie(_, _, _, completion)? = self?.assetType {
                self?.lottieView?.play(completion: completion)
            } else {
                self?.lottieView?.play()
            }
        }
    }

    func play(between interval: FrameInterval?, loopMode: LottieLoopMode?, completion: LottieCompletionBlock?) {
        guard let lottieView = lottieView, let interval = interval else {
            return
        }

        let loopMode = loopMode ?? lottieView.loopMode
        let begin = AnimationFrameTime(integerLiteral: interval.begin)
        let end = AnimationFrameTime(integerLiteral: interval.end)

        lottieView.play(fromFrame: begin,
                        toFrame: end,
                        loopMode: loopMode,
                        completion: completion)
    }

    func stop() {
        guard let lottieView = lottieView else {
            return
        }
        lottieView.currentProgress = 0
        lottieView.stop()
    }
}

public extension AssetView {
    struct FrameInterval {
        let begin: Int
        let end: Int

        init?(begin: Int, end: Int) {
            guard begin < end && begin >= 0, end > 0 else {
                return nil
            }
            self.begin = begin
            self.end = end
        }
    }
    enum AssetType {
        case lottie(resource: URL,
            loopMode: LottieLoopMode?,
            closure: (() -> Void)?,
            completion: LottieCompletionBlock?
        )
        case image(resource: URL,
            tintColor: UIColor?,
            completion: (() -> Void)?
        )
        case gif(resource: URL,
            completion: (() -> Void)?
        )
    }
}
