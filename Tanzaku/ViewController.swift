//
//  ViewController.swift
//
//  Created by usagimaru on 2016/12/14.
//  Copyright © 2016年 usagimaru. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet weak var tanzaku: Tanzaku!
	@IBOutlet weak var slider: UISlider!
	@IBOutlet weak var truncationControl: UISegmentedControl!
	@IBOutlet weak var numberOfLines: UIStepper!
	@IBOutlet weak var lineCountLabel: UILabel!
	@IBOutlet weak var sampleLabel: UILabel! {
		didSet {
			sampleLabel.layer.borderColor = UIColor.red.cgColor
			sampleLabel.layer.borderWidth = 1.0
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let size = CGFloat(20)
		slider.value = Float(size)
		
		let lineCount = 0
		
		let text = "祇園精舎の鐘の声、諸行無常の響きあり。沙羅双樹の花の色、盛者必衰のことわりをあらはす。奢れる人も久しからず、唯春の夜の夢のごとし。たけき者も遂には滅びぬ、偏に風の前の塵に同じ。"
		tanzaku.text = text
		tanzaku.font = UIFont(name: "Hiragino Sans", size: size)!
		tanzaku.textColor = UIColor.blue
		tanzaku.truncationMode = .byCharWrapping
		tanzaku.numberOfLines = UInt(lineCount)
		tanzaku.lineSpacing = 0
		tanzaku.textAlignment = .top
		
		sampleLabel.text = text
		sampleLabel.lineBreakMode = tanzaku.truncationMode.convertToNativeLineBreakMode()
		sampleLabel.numberOfLines = lineCount
		
		lineCountLabel.text = "\(lineCount)"
		numberOfLines.value = Double(lineCount)
		
		let num = 1234567890
		let str = KanjiNumerals.kanjinize(num)
		print(#function, "\(str)")
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func sliderAction(_ sender: Any) {
		if let font = UIFont(name: tanzaku.font.fontName, size: CGFloat(slider.value)) {
			tanzaku.font = font
		}
	}
	
	@IBAction func truncationAction(_ sender: Any) {
		switch truncationControl.selectedSegmentIndex {
		case 0:
			tanzaku.truncationMode = .byCharWrapping
			break
		case 1:
			tanzaku.truncationMode = .byTruncatingHead
			break
		case 2:
			tanzaku.truncationMode = .byTruncatingMiddle
			break
		case 3:
			tanzaku.truncationMode = .byTruncatingTail
			break
		case 4:
			tanzaku.truncationMode = .byJustification
			break
		default:
			break
		}
		
		sampleLabel.lineBreakMode = tanzaku.truncationMode.convertToNativeLineBreakMode()
	}
	
	@IBAction func linesAction(_ sender: Any) {
		lineCountLabel.text = "\(Int(numberOfLines.value))"
		tanzaku.numberOfLines = UInt(numberOfLines.value)
		sampleLabel.numberOfLines = Int(numberOfLines.value)
	}

}

