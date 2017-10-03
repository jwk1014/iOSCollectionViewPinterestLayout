//
//  ViewController.swift
//  TestCollectionViewPinterestLayout
//
//  Created by 김정원 on 2017. 10. 4..
//  Copyright © 2017년 jwk. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PinterestLayoutDelegate, HeroViewControllerDelegate {
    
    var collectionView: UICollectionView!
    var pinterestLayout: PinterestLayout!
    var refreshControl: UIRefreshControl!
    var images: [UIImage] = []
    var heroClosure: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var rect = CGRect(origin: view.bounds.origin, size: view.bounds.size)
        rect.origin.y += 20
        rect.size.height -= 20
        pinterestLayout = PinterestLayout()
        pinterestLayout.delegate = self
        collectionView = UICollectionView(frame: rect, collectionViewLayout: pinterestLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.lightGray
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        self.view.addSubview(collectionView)
        
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        refreshControl.beginRefreshing()
        handleRefresh(nil)
        
        isHeroEnabled = true
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        if let collectionViewCell = cell as? CollectionViewCell {
            let image = images[indexPath.row]
            collectionViewCell.imageView.image = image
        }
        
        return cell
    }
    
    func pinterestLayoutCellHeight(at indexPath: IndexPath) -> CGSize {
        return images[indexPath.row].size
    }
    
    func fillImages(){
        var tmpImageNames: [String] = []
        for i in 1...17 { tmpImageNames.append("img_\(i).jpg") }
        while tmpImageNames.count > 0 {
            let index: Int = Int(arc4random_uniform(UInt32(tmpImageNames.count)))
            images.append( UIImage(named: tmpImageNames.remove(at: index))! )
        }
    }
    
    @objc func handleRefresh(_ sender: UIRefreshControl?){
        DispatchQueue.global().asyncAfter(deadline: .now() + 1){
            self.images.removeAll()
            self.fillImages()
            DispatchQueue.main.sync {
                self.pinterestLayout.clearCache()
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let cell = collectionView.cellForItem(at: indexPath) {
            if let collectionViewCell = cell as? CollectionViewCell {
                collectionViewCell.imageView.heroID = "zoomImage"
                heroClosure = { collectionViewCell.imageView.heroID = nil }
                performSegue(withIdentifier: "segueViewToImageView", sender: collectionViewCell.imageView.image)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let image = sender as? UIImage {
            if let imageVC = segue.destination as? ImageViewController {
                imageVC.image = image
            }
        }
    }
    
    @IBAction func unwindToView(segue: UIStoryboardSegue){
    }
    
    func heroDidEndTransition() {
        print("heroDidEndTransition")
    }
    
    func heroDidEndAnimatingFrom(viewController: UIViewController) {
        print("heroDidEndAnimatingFrom")
        heroClosure?()
        heroClosure = nil
    }
    
    func heroDidEndAnimatingTo(viewController: UIViewController) {
        print("heroDidEndAnimatingTo")
    }
}

class CollectionViewCell : UICollectionViewCell {
    var imageView: UIImageView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    func initView(){
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        self.addSubview(imageView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame.size = bounds.size
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 10)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        imageView.layer.mask = mask
    }
}

