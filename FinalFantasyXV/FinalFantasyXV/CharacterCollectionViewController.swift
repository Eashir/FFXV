//
//  EventCollectionViewController.swift
//  KickBack
//
//  Created by Eashir Arafat on 1/11/17.
//  Copyright © 2017 Tyler Newton. All rights reserved.
//

import UIKit
import SFFocusViewLayout
import AVFoundation
import QuartzCore

class CharacterCollectionViewController: UICollectionViewController {
  let reuseIdentifier = "characterCell"
  var characters: [Character] = []
  var player: AVAudioPlayer?
  var task: URLSessionDownloadTask!
  var session: URLSession!
  var cache:NSCache<AnyObject, AnyObject>!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .blue
    //NavBar
    if let navVC = navigationController {
      navVC.navigationBar.isTranslucent = false
      navVC.navigationBar.tintColor = UIColor.white
      let fontDictionary = [ NSForegroundColorAttributeName:UIColor.white]
      navVC.navigationBar.titleTextAttributes = fontDictionary
      navVC.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
    }
    //Cache
    session = URLSession.shared
    task = URLSessionDownloadTask()
    self.cache = NSCache()
    
    //Music
    playSound()
    
    APIRequestManager.manager.getData("https://api.fieldbook.com/v1/5846eb88a785c00300a9434b/contacts") { (data: Data?) in
      if let validData = data,
        let validCharacters = Character.getCharacters(from: validData) {
        self.characters = validCharacters
        
        DispatchQueue.main.async {
          self.collectionView?.reloadData()
        }
      }
    }
    
    if #available(iOS 10.0, *) {
      collectionView?.isPrefetchingEnabled = false
    } else {
      // Fallback on earlier versions
    }
    
    //CocoaPod
    let flowVL = SFFocusViewLayout()
    flowVL.standardHeight = 140.0
    flowVL.dragOffset = 180.0
    flowVL.focusedHeight = 230.0
    
    self.edgesForExtendedLayout = []
    self.collectionView?.collectionViewLayout = flowVL
    self.collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
    self.collectionView?.backgroundColor = .black
    self.collectionView?.backgroundView = imageView
  }
  
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent
  }
  
  private func imageLayerForGradientBackground() -> UIImage {
    
    var updatedFrame = navigationController?.navigationBar.bounds
    updatedFrame?.size.height += 20
    let layer = CAGradientLayer.gradientLayerForBounds(bounds: updatedFrame!)
    UIGraphicsBeginImageContext(layer.bounds.size)
    layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
  }
  
  func playSound() {
    guard let sound = NSDataAsset(name: "Final Fantasy XV OST - Main Theme - Somnus") else {
      print("asset not found")
      return
    }
    
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
      try AVAudioSession.sharedInstance().setActive(true)
      
      player = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeMPEGLayer3)
      
      player!.play()
    } catch let error as NSError {
      print("error: \(error.localizedDescription)")
    }
  }
  
  
  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return characters.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CharacterCollectionViewCell
    let character = characters[indexPath.row]
    
    cell.characterName.text = character.name
    cell.characterImage?.image = UIImage(named: "FFXVLogoNoText.png")
    
    if (self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) != nil){
      cell.characterImage?.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
    } else {
      let imageURL = character.imageURL
      let url:URL! = URL(string: imageURL)
      task = session.downloadTask(with: url, completionHandler: { (locationURL, response, error) -> Void in
        if let data = try? Data(contentsOf: url){
          DispatchQueue.main.async(execute: { () -> Void in
            if let updateCell = collectionView.cellForItem(at: indexPath) as? CharacterCollectionViewCell {
              let img:UIImage! = UIImage(data: data)
              updateCell.characterImage?.image = img
              self.cache.setObject(img, forKey: (indexPath as NSIndexPath).row as AnyObject)
            }
          })
        }
      })
      task.resume()
    }
    
    return cell
  }
  
  // MARK: - UICollectionViewDelegate
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    guard
      let focusViewLayout = collectionView.collectionViewLayout as? SFFocusViewLayout
      else {
        fatalError("error casting focus layout from collection view")
    }
    
    let offset = focusViewLayout.dragOffset * CGFloat(indexPath.item)
    if collectionView.contentOffset.y != offset {
      collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
    }
    
  }
  
  // MARK: - Segue
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier! == "FadeSegue") {
      //with Navigation Controller
      //let navController = segue.destination as! UINavigationController
      //let detailController = ((navController.topViewController) as! SecondViewController)
      //without NavigationController:
     
    }
  }
  // MARK: - Views
  internal lazy var imageView: UIImageView = {
    let imageView: UIImageView = UIImageView()
    imageView.image = #imageLiteral(resourceName: "Final_Fantasy_XV_Logo")
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    
    return imageView
  }()
  
}

extension CAGradientLayer {
  class func gradientLayerForBounds(bounds: CGRect) -> CAGradientLayer {
    var layer = CAGradientLayer()
    layer.frame = bounds
    layer.colors = [UIColor.darkGray.cgColor, UIColor.black.cgColor]
    return layer
  }
}
