//
//  PhotoCell.swift
//  TransiPhoto
//
//  Created by Ryan Tsang on 7/11/16.
//  Copyright © 2016 Ryan Tsang. All rights reserved.
//

import UIKit
import CoreData

@available(iOS 9.0, *)
class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var checkmarkImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
        self.autoLayoutSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupSubviews()
        self.autoLayoutSubviews()
    }
    
    // function that helps resize an image passed
    func imageWithImage(_ image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height ))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
        
        // TODO somehow anchor size and position to proper placement
        // size needs to be a percentage of the width
        // position needs to be center... probably the easiest option here. Could do upper right hand corner but that sounds like work lmao
        // NOTE: This is not the function to be writing it in
        
    }
    
    func setupSubviews() {
        self.checkmarkImageView = UIImageView()
        self.checkmarkImageView!.translatesAutoresizingMaskIntoConstraints = false
        self.checkmarkImageView!.contentMode = .scaleAspectFit
        self.checkmarkImageView!.clipsToBounds = true
        self.checkmarkImageView!.isHidden = true
        //self.checkmarkImageView!.image = UIImage(named: "checked.png")
        self.checkmarkImageView!.image = imageWithImage(UIImage(named: "checked.png")!, scaledToSize: CGSize(width: 30, height: 30))
        self.contentView.addSubview(self.checkmarkImageView!)
    }
    
    func checked(_ checked: Bool) {
        self.checkmarkImageView?.isHidden = !checked
        if (checked) {
            print("checked")
        } else {
            print("unchecked")
        }
    }
    
    func autoLayoutSubviews() {
        // TODO move checkmark to one side
        self.checkmarkImageView!.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        self.checkmarkImageView!.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)

    }
    
    
}
