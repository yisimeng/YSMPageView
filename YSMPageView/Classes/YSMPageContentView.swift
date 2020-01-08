//
//  YSMPageContentView.swift
//  YSMPageView
//
//  Created by duanzengguang on 2020/1/6.
//

import UIKit

class YSMPageContentView: UICollectionView {
    
    init(frame: CGRect) {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = frame.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        super.init(frame: frame, collectionViewLayout: layout)
        
        delegate = self
        dataSource = self
        isPagingEnabled = true
        bounces = false
        backgroundColor = .white
        showsHorizontalScrollIndicator = false
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: YSMPageCollectionCellReuseID)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension YSMPageContentView: UICollectionViewDelegate {
    
}

extension YSMPageContentView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
    }
    
    
}
