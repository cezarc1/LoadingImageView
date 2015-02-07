//
//  LoadingImageView.swift
//  LoadingImageView
//
//  Created by Cezar Cocu on 1/2/15.
//  Copyright (c) 2015 Cezar Cocu. All rights reserved.
//

import UIKit
import QuartzCore

public enum LoadingImageState {
  case Idle
  case Downloading(NSURLSessionDownloadTask)
  case Errored(NSURLSessionDownloadTask, NSError)
}

public final class LoadingImageView : UIView, NSURLSessionDownloadDelegate {
  
  public var state: LoadingImageState = .Idle {
    didSet {
      updateUI()
      delegate?.loadingImageViewStateChanged(self, state: self.state)
      
      switch state {
      case .Downloading(_):
        reloadImageView.removeFromSuperview()
        displayLink.paused = false
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
      case .Errored(_, _):
        displayLink.paused = true
        progressLayer.hidden = true
        addSubview(reloadImageView)
        if let image = delegate?.imageForReloadState(self) {
          reloadImage = image
        }
      case .Idle:
        reloadImageView.removeFromSuperview()
        displayLink.paused = true
      }
    }
  }
  
  public weak var delegate: LoadingImageViewDelegate?
  
  public var operationQueue : NSOperationQueue  = LoadingImageView.operationQueue
  
  public let imageView: UIImageView = UIImageView()
  
  public var tapGestureRecognizer: UITapGestureRecognizer {
    return UITapGestureRecognizer(target: self, action: "tapOccured:")
  }
  
  @IBInspectable public var inset: Float = 10.0
  
  @IBInspectable public var lineWidth: Float = 10.0
  
  @IBInspectable public var lineColor: UIColor = UIColor.grayColor()
  
  @IBInspectable public var reloadImage: UIImage = UIImage() {
    didSet {
      self.reloadImageView.image = reloadImage
    }
  }
  
  public var progress: Float = 0.0
  
  private lazy var progressLayer: CAShapeLayer = {
    let shape = CAShapeLayer()
    shape.strokeStart = CGFloat(0.0)
    shape.strokeEnd = CGFloat(0.0)
    shape.fillColor = UIColor.clearColor().CGColor
    return shape
  }()
  
  private lazy var reloadImageView: UIImageView = {
    let image = UIImageView()
    image.contentMode = .ScaleAspectFit
    return image
  }()
  
  private lazy var displayLink: CADisplayLink = {
    let link = CADisplayLink(target: self, selector: "updateUI")
    link.frameInterval = 30 // twice every second
    return link
    }()

  
  private class var operationQueue : NSOperationQueue {
    struct Static {
      static let instance : NSOperationQueue = {
       let queue = NSOperationQueue()
        queue.qualityOfService = .UserInitiated
        queue.name = "LoadingImageViewQueue"
        return queue
      }()
    }
    return Static.instance
  }
  
  public override init() {
    super.init()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
  }
  
  required public init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.commonInit()
  }
  
  private func commonInit() {
    clipsToBounds = true
    backgroundColor = UIColor.whiteColor()
    addGestureRecognizer(tapGestureRecognizer)
    
    addSubview(imageView)
    imageView.contentMode = .ScaleAspectFill
    layer.addSublayer(progressLayer)
  }
  
  //MARK: AutoLayout
  
  public override func intrinsicContentSize()->CGSize {
   return imageView.intrinsicContentSize()
  }
  
  //MARK: Lifecycle
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    imageView.frame = bounds
    reloadImageView.frame = bounds
  }
  
  override public func didMoveToSuperview() {
    super.didMoveToSuperview()
    
    if let view = superview {
      displayLink.paused = false
    } else {
      displayLink.paused = true
    }
  }
  
  //MARK: UI Sync
  func updateUI() {
    dispatch_async(dispatch_get_main_queue()) {
      self.updateProgressLayer(forState: self.state, progress: self.progress)
      
      println("\(self.progress * 100)%")
    }
  }
  
  func updateProgressLayer(forState state: LoadingImageState, progress: Float) {
    switch state {
    case .Downloading(_):
      progressLayer.hidden = false
      progressLayer.path = UIBezierPath(semiCircleInRect: bounds, inset: CGFloat(inset)).CGPath
      progressLayer.strokeColor = lineColor.CGColor
      progressLayer.lineWidth = CGFloat(lineWidth)
      progressLayer.strokeEnd = max(CGFloat(progress), CGFloat(0.05))
    default:
      break
    }
  }
  
  //MARK: Network Calls
  public func downloadImage(URL: NSURL, placeholder:UIImage?)->NSURLSessionDownloadTask {
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    var session = NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue())
    return downloadImage(URL, placeholder: placeholder, session: session)
  }
  
  public func downloadImage(URL: NSURL, placeholder:UIImage?, session: NSURLSession)->NSURLSessionDownloadTask {
    switch state {
    case .Downloading(let task):
      task.cancel()
    default:
      break
    }
    
    self.imageView.image = placeholder ?? nil
    let request = NSMutableURLRequest(URL: URL)
    request.timeoutInterval = 20.0
    let downloadTask = session.downloadTaskWithRequest(request)
    progress = 0.0
    state = .Downloading(downloadTask)
    downloadTask.resume()
    return downloadTask
  }
  
  //MARK: - Actions
  
  func tapOccured(sender: AnyObject) {
    switch state {
    case .Errored(let task, _):
      let maybeAttemptReload = delegate?.shouldAttemptRetry(self)
      if let attemptReload = maybeAttemptReload {
        if attemptReload {
          self.downloadImage(task.originalRequest.URL, placeholder: nil)
        }
      } else {
        self.downloadImage(task.originalRequest.URL, placeholder: nil)
      }
      fallthrough
    default:
      #if DEBUG
        println("tap occured")
      #endif
      break
    }
  }
  
  deinit {
   displayLink.invalidate()
  }
}

extension LoadingImageView : NSURLSessionDownloadDelegate {
  
  public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    dispatch_async(dispatch_get_main_queue()) {
      if let err = error {
        println("error: \(err)")
        self.state = .Errored(task as NSURLSessionDownloadTask, err)
      } else {
        self.progress = 1.0
        self.state = .Idle
      }
    }
  }
  
  public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
    if let image = UIImage.decompressedImage(location) {
      dispatch_async(dispatch_get_main_queue()) {
        if downloadTask.state == .Canceling {
          return
        }
        let delay = 0.20
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
          self.progressLayer.hidden = true
          self.imageView.image = image
          self.invalidateIntrinsicContentSize()
          let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
          fadeInAnimation.fromValue = 0.0
          fadeInAnimation.toValue = self.imageView.layer.opacity
          fadeInAnimation.duration = delay
          self.imageView.layer.addAnimation(fadeInAnimation, forKey: "fadeIn")
        }
        self.updateProgressLayer(forState: self.state, progress: 1.0)
        
      }
    } else {
      dispatch_async(dispatch_get_main_queue()) {
        let err = NSError(domain: "Invalid Image", code: 400, userInfo: nil)
        self.state = .Errored(downloadTask, err)
      }
    }
  }
  
  public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    dispatch_async(dispatch_get_main_queue()) {
      let progress:Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
      self.progress = progress
    }
  }
}

public protocol LoadingImageViewDelegate : NSObjectProtocol {
  func loadingImageViewStateChanged(imageView: LoadingImageView, state: LoadingImageState)
  func shouldAttemptRetry(imageView: LoadingImageView)->Bool
  func imageForReloadState(imageView: LoadingImageView)->UIImage
}

extension UIImage {
  
  class func decompressedImage(imageURL: NSURL)->UIImage? {
    if let data = NSData(contentsOfURL: imageURL) {
      if let image = UIImage(data: data) {
        UIGraphicsBeginImageContext(image.size)
        image.drawAtPoint(CGPointZero)
        let decompressedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return decompressedImage
      }
    }
    return nil
  }
}