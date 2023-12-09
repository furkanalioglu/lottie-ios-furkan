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

        // Iterate through each image layer
        for imageLayer in imageLayers {
            let assetID = imageLayer.imageReferenceID

            // First, check for a replacement image
            if let asset = imageAssets[assetID],
               let newImageName = replacementImages[asset.name],
               let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
               let image = UIImage(contentsOfFile: URL(fileURLWithPath: dirPath).appendingPathComponent(newImageName).path) {
                imagesDict[assetID] = image
                continue
            }

            // If no replacement image, use the default provider
            if let asset = imageAssets[assetID],
               let cgImage = imageProvider.imageForAsset(asset: asset) {
                imagesDict[assetID] = UIImage(cgImage: cgImage)
            }
        }
        return imagesDict
    }
}




