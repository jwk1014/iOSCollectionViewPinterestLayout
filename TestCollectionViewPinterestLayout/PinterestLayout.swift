//
//  PinterestLayout.swift
//  TestCollectionViewPinterestLayout
//
//  Created by 김정원 on 2017. 10. 4..
//  Copyright © 2017년 jwk. All rights reserved.
//

import UIKit

class PinterestLayout: UICollectionViewLayout {
    var delegate: PinterestLayoutDelegate? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(numberOfColumns: Int = 2, cellPadding: CGFloat = 6){
        super.init()
        self.numberOfColumns = numberOfColumns
        self.cellPadding = cellPadding
    }
    
    fileprivate var numberOfColumns: Int = 2
    fileprivate var cellPadding: CGFloat = 6
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    fileprivate var contentHeight: CGFloat = 0
    
    var columnWidth: CGFloat {
        return contentWidth / CGFloat(numberOfColumns)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard cache.isEmpty, let collectionView = collectionView, let delegate = delegate else {
            return
        }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        
        var column = 0
        contentHeight = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        for cellIndex in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: cellIndex, section: 0)
            
            let photoSize = delegate.pinterestLayoutCellHeight(at: indexPath)
            let photoHeight = columnWidth / photoSize.width * photoSize.height
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(
                x: CGFloat(column) * columnWidth,
                y: yOffset[column],
                width: columnWidth,
                height: cellPadding * 2 + photoHeight).insetBy(dx: cellPadding, dy: cellPadding)
            cache.append(attributes)
            
            contentHeight = max(contentHeight, attributes.frame.maxY + cellPadding)
            yOffset[column] += attributes.frame.height + cellPadding * 2
            
            if let min = yOffset.min(), let yOffsetMinIndex = yOffset.index(of: min) {
                column = yOffsetMinIndex
            } else {
                column = 0
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter{ $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    func clearCache(){
        cache.removeAll()
    }
}

protocol PinterestLayoutDelegate {
    func pinterestLayoutCellHeight(at indexPath: IndexPath) -> CGSize
}
