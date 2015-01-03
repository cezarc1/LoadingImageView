LoadingImageView
================

Loading Indicator for UIImageView written in Swift.

Handles network calls and background image decoding.

Handles Error states and retrying download.

![demo](http://i.imgur.com/SpE2BQv.gif)

Code:
``` swift
  let imageURL = NSURL(string: "https://catfishes.files.wordpress.com/2013/03/cat-breaded.jpg")
imageView.downloadImage(imageURL, placeholder: nil)
```