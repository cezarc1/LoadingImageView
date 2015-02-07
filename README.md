LoadingImageView
================

Loading Indicator for UIImageView written in Swift.

- [x] Simple to use
- [x] Handles network calls and background image decoding.
- [x] Background decoding of Images
- [x] Handles Error states and retrying download.
- [ ] Handles offline caching. Coming soon.

![demo](https://raw.githubusercontent.com/ggamecrazy/LoadingImageView/master/Screenshots/LoadingImageShowcase.gif)

###Cocoapod

``` ruby
pod 'LoadingImageView'

```

###USAGE

As simple as
``` swift
import LoadingImageView

let imageView = LoadingImageView()
view.addSubview(imageView)
let imageURL = NSURL(string: "https://catfishes.files.wordpress.com/2013/03/cat-breaded.jpg")
imageView.downloadImage(imageURL, placeholder: nil)
```
####API
``` swift
var state: LoadingImageState 
weak var delegate: LoadingImageViewDelegate?
var inset: Float
var lineWidth: Float
var lineColor: UIColor    
var reloadImage: UIImage 

func downloadImage(URL: NSURL, placeholder:UIImage?)->NSURLSessionDownloadTask
```

####Delegate and State
``` swift
enum LoadingImageState {
  case Idle
  case Downloading(NSURLSessionDownloadTask)
  case Errored(NSURLSessionDownloadTask, NSError)
}

protocol LoadingImageViewDelegate : NSObjectProtocol {
  func loadingImageViewStateChanged(imageView: LoadingImageView, state: LoadingImageState)
  func shouldAttemptRetry(imageView: LoadingImageView)->Bool
  func imageForReloadState(imageView: LoadingImageView)->UIImage
}
```
####Storyboard, Support for IBInspectable


<a href="url"><img src="https://raw.githubusercontent.com/ggamecrazy/LoadingImageView/master/Screenshots/IBInspectableSupport.jpg" width=“80” ></a>
