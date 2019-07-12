//
//  UIImage+Extensions.swift
//  Sprint13
//
//  Created by Alex on 7/12/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit

extension UIImage {
    func getCIImage() -> CIImage? {
        if let ciImage = self.ciImage {
            return ciImage
        } else if let cgImage = self.cgImage {
            return CIImage(cgImage: cgImage)
        } else {
            return nil
        }
    }
}
