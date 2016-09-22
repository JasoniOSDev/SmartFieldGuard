//
//  String+BinaryCode.swift
//  智慧田园
//
//  Created by jason on 2016/9/21.
//  Copyright © 2016年 jason. All rights reserved.
//

import Foundation
import CoreImage
extension String{
    func binaryCodeCreate() -> UIImage{
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        filter?.setValue(data, forKey: "inputMessage")
        let image = filter?.outputImage
        return UIImage.createNonInterpolatedUIImageFormCIImage(image!, withSize: ScreenWidth)
    }
}
