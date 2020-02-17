//
//  CollectionView Cell Layout.swift
//  Swift Support Codes
//
//  Created by Shyngys Kuandyk on 2/17/20.
//  Copyright © 2020 Shyngys Kuandyk. All rights reserved.
//

/*
 This class help to work with CollectionView Layout
 if you want to show 1 cell per row at CollectinView , set cellWidth to 0
 
 work with IOS 11.0 and higher 
 */

import Foundation
import UIKit
class ColumnFlowLayout: UICollectionViewFlowLayout {
    
    let cellsPerRow: Int
    let cellheight : CGFloat
    let cellwidth : CGFloat
    var width : CGFloat?
    init(cellsPerRow: Int, cellheight: CGFloat = 0 ,cellwidth:CGFloat = 0, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
        self.cellsPerRow = cellsPerRow
        self.cellheight = cellheight
        self.cellwidth = cellwidth
        super.init()
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        var marginsAndInsets : CGFloat
        if #available(iOS 11.0, *) {
            marginsAndInsets  = sectionInset.left + sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        } else {
            // Fallback on earlier versions
            marginsAndInsets = sectionInset.left + sectionInset.right + collectionView.layoutMargins.left + collectionView.layoutMargins.right + minimumLineSpacing*CGFloat(cellsPerRow - 1)
        }
        
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        
        if self.cellwidth == 0 {
            itemSize = CGSize(width: itemWidth, height: cellheight)
        }
        else {
            self.width = itemWidth
            itemSize = CGSize(width: cellwidth, height: cellheight)
        }

    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
    
}
