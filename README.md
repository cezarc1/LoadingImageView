LoadingImageView
================

Loading Indicator for UIImageView written in Swift.

Handles network calls and background image decoding.

Handles Error states and retrying download.

![demo](https://raw.githubusercontent.com/ggamecrazy/LoadingImageView/master/Screenshots/LoadingImageShowcase.gif)

Code:
```
let imageURL = NSURL(string: "https://catfishes.files.wordpress.com/2013/03/cat-breaded.jpg")
imageView.downloadImage(imageURL, placeholder: nil)
```