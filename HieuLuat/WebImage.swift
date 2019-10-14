//
//  WebImage.swift
//  HieuLuat
//
//  Created by VietLH on 10/11/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import UIKit

class WebImage: UIImageView {
    func load(target: String) {
        clipsToBounds = true
        contentMode = .scaleAspectFit
        autoresizesSubviews = true
        let url = URL(string: target)
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    
    func downloadImageFrom(url: URL, mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    func downloadImageFrom(link: String, mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadImageFrom(url: url, mode: mode)
    }
    
    /*
     The image view's content mode is Aspect Fit.

     My problem is the same as the one stated in this post. Inside my prototype TableViewCell's ContentView, I have a vertical StackView constrained to each edge. Inside the StackView there was a Label, ImageView and another Label. Having the ImageView set to AspectFit was not enough. The image would be the proper size and proportions but the ImageView didn't wrap the actual image leaving a bunch of extra space between the image and label (just like in the image above). The ImageView height seemed to match height of the original image rather than the height of the resized image (after aspectFit did it's job). Other solutions I found didn't completely resolve the problem for various reasons. I hope this helps someone.
     
     source: https://stackoverflow.com/questions/41154784/how-to-resize-uiimageview-based-on-uiimages-size-ratio-in-swift-3
     */
    override var intrinsicContentSize: CGSize {
        print("Populating size")

        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width

            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio

            return CGSize(width: myViewWidth, height: scaledHeight)
        }

        return CGSize(width: -1.0, height: -1.0)
    }
}

