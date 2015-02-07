//
//  ViewController.swift
//  LoadingImageView
//
//  Created by Cezar Cocu on 1/2/15.
//  Copyright (c) 2015 Cezar Cocu. All rights reserved.
//

import UIKit
import LoadingImageView

class ViewController: UITableViewController {  
  let catURLs = [ NSURL(string: "http://www.mnftiu.cc/wp-content/uploads/2012/12/77669-cats-funny-cat.jpg")!,
  NSURL(string: "http://www.neighborhoodcats.org/uploads/Image/Right%20panel%20images/nycfcc%20site%201.jpg")!,
  NSURL(string: "http://images4.fanpop.com/image/photos/22000000/-_-cats-cats-22066030-1024-768.jpg")!,
  NSURL(string: "http://momusnajmi.files.wordpress.com/2014/12/cat-music.jpg")!,
  NSURL(string: "http://blogs.biomedcentral.com/bmcblog/files/2014/02/Benjamin-Blonder.png")!,
  NSURL(string: "https://catfishes.files.wordpress.com/2013/03/cat-breaded.jpg")!]
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return catURLs.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("loadingCell", forIndexPath: indexPath) as LoadingTableViewCell
    
    let imageView = LoadingImageView()
    view.addSubview(imageView)
    
    let imageURL = catURLs[indexPath.row % catURLs.count]
    cell.configure(imageURL)
    return cell
  }
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return CGFloat(200.0)
  }
}

class LoadingTableViewCell: UITableViewCell {
  
  @IBOutlet weak var loadingImageView: LoadingImageView!
  
  func configure(imageURL: NSURL) {
    loadingImageView.downloadImage(imageURL, placeholder: nil)
  }

}