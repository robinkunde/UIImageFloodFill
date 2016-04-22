//
//  UIImage+Floodfill.swift
//  UIImageFloodFill
//
//  Created by Kunde, Robin - Robin on 4/22/16.
//  Copyright © 2016 Recoursive. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func ff_floodFill(startPoint: CGPoint, newColor: UIColor) -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let imageRef = CGImage else {
            return nil
        }

        let width = CGImageGetWidth(imageRef)
        let height = CGImageGetHeight(imageRef)
        let bytesPerRow = CGImageGetBytesPerRow(imageRef)
        let bitsPerComponent = CGImageGetBitsPerComponent(imageRef)
        guard bitsPerComponent == 8 else {
            return nil
        }

        var bitmapInfo = CGImageGetBitmapInfo(imageRef)
        let alphaInfo = CGImageGetAlphaInfo(imageRef)
        if alphaInfo == CGImageAlphaInfo.First || alphaInfo == CGImageAlphaInfo.Last {
            let rawBitmapInfoWithoutAlpha = bitmapInfo.rawValue & ~CGBitmapInfo.AlphaInfoMask.rawValue
            let rawBitmapInfo = rawBitmapInfoWithoutAlpha | CGImageAlphaInfo.PremultipliedLast.rawValue
            bitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)
        }

        let context = CGBitmapContextCreate(
            nil,
            width,
            height,
            bitsPerComponent,
            bytesPerRow,
            colorSpace,
            bitmapInfo.rawValue
        )
        guard context != nil else {
            return nil
        }

        CGContextDrawImage(context, CGRect(x: 0, y: 0, width: width, height: height), imageRef)

        let imageData = UnsafeMutablePointer<UInt32>(CGBitmapContextGetData(context))

        let startX = min(max(Int(startPoint.x), 0), width)
        let startY = min(max(Int(startPoint.y), 0), height)
        let oldColorValue = imageData.advancedBy(width * startY + startX).memory

        // Convert newColor to an RGBA value adjust for endieness
        let newRed, newGreen, newBlue, newAlpha: UInt32
        let components = CGColorGetComponents(newColor.CGColor)
        let numberOfComponents = CGColorGetNumberOfComponents(newColor.CGColor)
        if numberOfComponents == 2 {
            newRed = UInt32(components[0] * CGFloat(255))
            newGreen = newRed
            newBlue = newRed
            newAlpha = UInt32(components[1] * CGFloat(255))
        } else if numberOfComponents == 4 {
            if bitmapInfo.contains(CGBitmapInfo.ByteOrder32Little) {
                newRed   = UInt32(components[2] * CGFloat(255))
                newGreen = UInt32(components[1] * CGFloat(255))
                newBlue  = UInt32(components[0] * CGFloat(255))
                newAlpha = UInt32(components[3] * CGFloat(255))
            } else {
                newRed   = UInt32(components[0] * CGFloat(255))
                newGreen = UInt32(components[1] * CGFloat(255))
                newBlue  = UInt32(components[2] * CGFloat(255))
                newAlpha = UInt32(components[3] * CGFloat(255))
            }
        } else {
            return nil
        }
        let newColorValue = CFSwapInt32BigToHost((newRed << 24) | (newGreen << 16) | (newBlue << 8) | newAlpha)

        guard newColorValue != oldColorValue else {
            return self
        }

        var stack = Array<(x: Int, y: Int)>()
        stack.append((startX, startY))

        var spanAbove, spanBelow: Bool
        while let (x, y) = stack.popLast() {
            var x = x
            while x >= 0 && imageData[width * y + x] == oldColorValue {
                x -= 1
            }
            x += 1

            spanAbove = false
            spanBelow = false
            while x < width && imageData[width * y + x] == oldColorValue {
                imageData[width * y + x] = newColorValue

                if y > 0 {
                    if !spanAbove && imageData[width * (y - 1) + x] == oldColorValue {
                        stack.append((x, y - 1))
                        spanAbove = true
                    } else if spanAbove && imageData[width * (y - 1) + x] != oldColorValue {
                        spanAbove = false
                    }
                }

                if y < (height - 1) {
                    if !spanBelow && imageData[width * (y + 1) + x] == oldColorValue {
                        stack.append((x, y + 1))
                        spanBelow = true
                    } else if spanBelow && imageData[width * (y + 1) + x] != oldColorValue {
                        spanBelow = false
                    }
                }

                x += 1
            }
        }

        if let cgImage = CGBitmapContextCreateImage(context) {
            return UIImage(CGImage: cgImage, scale: self.scale, orientation: .Up)
        }

        return nil
    }
}
