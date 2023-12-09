//
//  LayerImageProvider.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import Foundation
import UIKit

/// Connects a LottieImageProvider to a group of image layers
final class LayerImageProvider {

  // MARK: Lifecycle

    init(imageProvider: AnimationImageProvider, assets: [String: ImageAsset]?, replacementImages: [String: String]?) {
    self.imageProvider = imageProvider
    self.imageLayers = [ImageCompositionLayer]()
    self.imageAssets = assets ?? [:]
    self.replacementImages = replacementImages ?? [:]
    reloadImages()
  }

  // MARK: Internal

  private(set) var imageLayers: [ImageCompositionLayer]
    private(set) var replacementImages: [String: String]
  let imageAssets: [String: ImageAsset]

  var imageProvider: AnimationImageProvider {
    didSet {
      reloadImages()
    }
  }

  func addImageLayers(_ layers: [ImageCompositionLayer]) {
    for layer in layers {
      if imageAssets[layer.imageReferenceID] != nil {
        /// Found a linking asset in our asset library. Add layer
        imageLayers.append(layer)
      }
    }
  }

    func reloadImages() {
        for imageLayer in imageLayers {
            print("reloading images...... \(imageLayers.count)")
            if let asset = imageAssets[imageLayer.imageReferenceID] {
                if let newImageName = replacementImages[asset.name],
                   let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                    let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(newImageName)
                    if let image = UIImage(contentsOfFile: imageURL.path)?.cgImage {
                        imageLayer.image = image
                    }
                } else {
                    // If the asset's name is not in imageReplacementMap, use the default provider
                    imageLayer.image = imageProvider.imageForAsset(asset: asset)
                }
            }
        }
    }
}

extension LayerImageProvider {
    func getImages() -> [String: UIImage] {
        var imagesDict = [String: UIImage]()
        for imageLayer in imageLayers {
            let assetID = imageLayer.imageReferenceID
            var image: UIImage?

            // Check if there's a replacement image
            if let asset = imageAssets[assetID],
               let newImageName = replacementImages[asset.name],
               let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(newImageName)
                image = UIImage(contentsOfFile: imageURL.path)
            }

            // If no replacement image, use the default provider
            if image == nil, let asset = imageAssets[assetID],
               let cgImage = imageProvider.imageForAsset(asset: asset) {
                image = UIImage(cgImage: cgImage)
            }

            // Add the image to the dictionary if it exists
            if let finalImage = image {
                imagesDict[assetID] = finalImage
            }
        }
        return imagesDict
    }
}



