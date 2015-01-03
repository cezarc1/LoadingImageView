LoadingImageView
================

Loading Indicator for UIImageView written in Swift.

- [x] Handles network calls and background image decoding.
- [x] Background decoding of Images
- [x] Handles Error states and retrying download.
- [ ] Handles offline caching

![demo](https://raw.githubusercontent.com/ggamecrazy/LoadingImageView/master/Screenshots/LoadingImageShowcase.gif)

Code:
```
let imageURL = NSURL(string: "https://catfishes.files.wordpress.com/2013/03/cat-breaded.jpg")
imageView.downloadImage(imageURL, placeholder: nil)
```

###USAGE

``` swift
var state: LoadingImageState 
weak var delegate: LoadingImageViewDelegate?
var inset: Float
var lineWidth: Float
var lineColor: UIColor    
var reloadImage: UIImage 
```
...
``` swift
func downloadImage(URL: NSURL, placeholder:UIImage?)->NSURLSessionDownloadTask
```
####Storyboard, Support for IBInspectable


<a href="url"><img src="https://raw.githubusercontent.com/ggamecrazy/LoadingImageView/master/Screenshots/IBInspectableSupport.jpg" width=“100” ></a>