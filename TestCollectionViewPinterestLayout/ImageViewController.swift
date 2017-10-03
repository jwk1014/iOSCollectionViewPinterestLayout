//
//  ImageViewController.swift
//  TestCollectionViewPinterestLayout
//
//  Created by 김정원 on 2017. 10. 4..
//  Copyright © 2017년 jwk. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var image: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let staticWidth: CGFloat = (view.bounds.width - 16)
        let staticHeight:CGFloat = (view.bounds.height - 16 - 20)
        var width: CGFloat = staticWidth
        var height: CGFloat = width / image.size.width * image.size.height
        if height > staticHeight {
            height = staticHeight
            width = height / image.size.height * image.size.width
        }
        
        var x = (staticWidth - width) / 2
        if x < 0 { x *= -1 }
        x += 8
        
        var y = (staticHeight - height) / 2
        if y < 0 { y *= -1 }
        y += 20 + 8
        
        let imageView = UIImageView(frame: CGRect(x: x , y: y, width: width, height: height))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.view.addSubview(imageView)
        
        isHeroEnabled = true
        imageView.heroID = "zoomImage"
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
    }
    
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer){
        view.removeGestureRecognizer(sender)
        performSegue(withIdentifier: "unwindSegue", sender: self)
    }

}
