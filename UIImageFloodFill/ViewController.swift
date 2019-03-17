//
//  ViewController.swift
//  UIImageFloodFill
//
//  Created by Kunde, Robin - Robin on 4/22/16.
//  Copyright © 2016 Recoursive. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    var tapGestureRecognizer: UITapGestureRecognizer!
    var fillColor = UIColor.redColor()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("tap:"))
        tapGestureRecognizer.delegate = self
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }

    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func redButtonTapped(sender: AnyObject) {
        fillColor = UIColor.redColor()
    }
    @IBAction func greenButtonTapped(sender: AnyObject) {
        fillColor = UIColor.greenColor()
    }
    @IBAction func blueButtonTapped(sender: AnyObject) {
        fillColor = UIColor.blueColor()
    }
    @IBAction func blackButtonTapped(sender: AnyObject) {
        fillColor = UIColor.blackColor()
    }
    @IBAction func whiteButtonTapped(sender: AnyObject) {
        fillColor = UIColor.whiteColor()
    }

    @objc func tap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .Ended {
            let image = imageView.image!

            var targetPoint = recognizer.locationInView(recognizer.view)
            let sourceSize = image.size
            let targetSize = imageView.bounds.size

            let ratioX = targetSize.width / sourceSize.width
            let ratioY = targetSize.height / sourceSize.height

            let scale = min(ratioX, ratioY)
            let scaledSize = CGSize(width: sourceSize.width * scale, height: sourceSize.height * scale)

            targetPoint.x -= (targetSize.width - scaledSize.width) / 2
            targetPoint.y -= (targetSize.height - scaledSize.height) / 2

            if targetPoint.x < 0 || targetPoint.y < 0 || targetPoint.x > scaledSize.width || targetPoint.y > scaledSize.height {
                return
            }

            targetPoint.x /= scale
            targetPoint.y /= scale

            if let newImage = image.ff_floodFill(targetPoint, newColor: fillColor) {
                imageView.image = newImage
            }
        }
    }
}

