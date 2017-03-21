//
//  Tanzaku
//
//  Created by usagimaru on 2016.12.14.
//  Copyright © 2016 usagimaru. All rights reserved.
//

import UIKit

/// 縦書き和文を描画する短冊
class Tanzaku: UIView {
	
	/// 文字列
	@IBInspectable var text: String? {
		didSet {
			update()
		}
	}
	
	/// フォント名
	@IBInspectable var fontFamily: String = UIFont.systemFont(ofSize: 0).familyName {
		didSet {
			if let f = UIFont(name: fontFamily, size: fontSize) {
				font = f
			}
			else {
				update()
			}
		}
	}
	
	/// フォントサイズ
	@IBInspectable var fontSize: CGFloat = kDefaultFontSize {
		didSet {
			if let f = UIFont(name: fontFamily, size: fontSize) {
				font = f
			}
			else {
				update()
			}
		}
	}
	
	/// フォント
	var font: UIFont = UIFont.systemFont(ofSize: kDefaultFontSize) {
		didSet {
			update()
		}
	}
	
	/// 文字色
	@IBInspectable var textColor: UIColor = UIColor.black {
		didSet {
			update()
		}
	}
	
	/// 行数
	@IBInspectable var numberOfLines: UInt = 0 {
		didSet {
			update()
		}
	}
	
	/// 行間
	@IBInspectable var lineSpacing: CGFloat = 0 {
		didSet {
			update()
		}
	}
	
	/// 配置方法
	enum TextAlignment: Int {
		/// 上配置
		case top
		/// 中央配置
		case center
		/// 下配置
		case bottom
		
		static func convert(from nativeTextAlignment: NSTextAlignment) -> TextAlignment {
			switch nativeTextAlignment {
			case .center:
				return TextAlignment.center
			case .right:
				return TextAlignment.bottom
			default:
				return TextAlignment.top
			}
		}
		
		func convertToNativeTextAlignment() -> NSTextAlignment {
			switch self {
			case .top:
				return .left
			case .center:
				return .center
			case .bottom:
				return .right
			}
		}
	}
	
	var textAlignment: TextAlignment = .top {
		didSet {
			update()
		}
	}
	
	/// 省略方法
	enum TruncationMode: Int {
		/// 文字単位折り返し
		case byCharWrapping
		/// 上略
		case byTruncatingHead
		/// 中略
		case byTruncatingMiddle
		/// 下略
		case byTruncatingTail
		/// 均等割付
		case byJustification
		
		/// NSLineBreakMode -> TruncationMode
		static func convert(from nativeLineBreakMode: NSLineBreakMode) -> TruncationMode {
			switch nativeLineBreakMode {
			case .byTruncatingHead:
				return TruncationMode.byTruncatingHead
			case .byTruncatingMiddle:
				return TruncationMode.byTruncatingMiddle
			case .byTruncatingTail:
				return TruncationMode.byTruncatingTail
			default:
				return TruncationMode.byCharWrapping
			}
		}
		
		/// TruncationMode -> NSLineBreakMode
		func convertToNativeLineBreakMode() -> NSLineBreakMode {
			switch self {
			case .byTruncatingHead:
				return NSLineBreakMode.byTruncatingHead
			case .byTruncatingMiddle:
				return NSLineBreakMode.byTruncatingMiddle
			case .byTruncatingTail:
				return NSLineBreakMode.byTruncatingTail
			default:
				return NSLineBreakMode.byCharWrapping
			}
		}
		
		/// TruncationMode -> CTLineBreakMode
		func convertToCoreTextLineBreakMode() -> CTLineBreakMode {
			switch self {
			case .byTruncatingHead:
				return CTLineBreakMode.byTruncatingHead
			case .byTruncatingMiddle:
				return CTLineBreakMode.byTruncatingMiddle
			case .byTruncatingTail:
				return CTLineBreakMode.byTruncatingTail
			default:
				return CTLineBreakMode.byCharWrapping
			}
		}
		
		/// TruncationMode -> CTLineTruncationType
		func lineTruncationType() -> CTLineTruncationType? {
			switch self {
			case .byTruncatingHead:
				return CTLineTruncationType.start
			case .byTruncatingMiddle:
				return CTLineTruncationType.middle
			case .byTruncatingTail:
				return CTLineTruncationType.end
			default:
				return nil
			}
		}
		
		/// Head OR Middle OR Tail
		func isTruncation() -> Bool {
			switch self {
			case .byTruncatingHead, .byTruncatingMiddle, .byTruncatingTail:
				return true
			default:
				return false
			}
		}
	}
	
	/// 省略方法
	var truncationMode: TruncationMode = .byCharWrapping {
		didSet {
			update()
		}
	}
	
	
	// MARK: - Private Properties
	
	private static let kDefaultFontSize = CGFloat(17.0)
	
	private var truncationToken: CTLine?
	private var textInfo: TextInfo?
	
	
	// MARK: -
	
	/// 属性付き文字列を作る
	private class func createAttributedString(_ text: String,
	                                    font: UIFont,
	                                    lineSpacing: CGFloat = 0,
	                                    textAlignment: TextAlignment,
	                                    textColor: UIColor? = nil) -> NSAttributedString {
		let lineHeight = (font.lineHeight - font.descender)
		
		let paragraph = NSMutableParagraphStyle()
		paragraph.lineSpacing = lineSpacing
		paragraph.minimumLineHeight = lineHeight
		paragraph.maximumLineHeight = lineHeight
		paragraph.lineBreakMode = .byCharWrapping
		paragraph.alignment = textAlignment.convertToNativeTextAlignment()
		
		var attributes = [
			NSFontAttributeName : font,
			NSParagraphStyleAttributeName : paragraph,
			kCTVerticalFormsAttributeName as String : true ,
			] as [String : Any]
		if let textColor = textColor {
			attributes[NSForegroundColorAttributeName] = textColor
		}
		
		let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
		
		return attributedText as NSAttributedString
	}
	
	/// テキスト情報
	private struct TextInfo {
		let framesetter: CTFramesetter
		let frameSize: CGSize
		let fitRange: CFRange
		let lineHeight: CGFloat
		let lineSpacing: CGFloat
		let textLength: Int
		let fullLine: CTLine?
		let attributedString: NSAttributedString?
		
		var NSFitRange: NSRange {
			return NSRange(location: fitRange.location, length: fitRange.length)
		}
	}
	
	/// テキスト情報を取得
	private class func textInfo(_ text: String,
	                            rect: CGRect,
	                            font: UIFont,
	                            numberOfLines: UInt,
	                            lineSpacing: CGFloat,
	                            textAlignment: TextAlignment,
	                            textColor: UIColor? = nil,
	                            containsFullLine: Bool = false) -> TextInfo? {
		let attributedString = createAttributedString(text,
		                                              font: font,
		                                              lineSpacing: lineSpacing,
		                                              textAlignment: textAlignment,
		                                              textColor: textColor)
		let length = attributedString.length
		let framesetter = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
		
		// サイズ情報を取得
		var fitRange = CFRange()
		var size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
		                                                        CFRange(location: 0, length: 0),
		                                                        Tanzaku.framesetterOptions(),
		                                                        rect.size,
		                                                        &fitRange)
		// 正しい縦幅に補正
		size.width = ceil(size.width + font.leading) + 1
		
		// 行高
		let lineHeight = (font.lineHeight - font.descender)
		// MEMO:
		// LINE HEIGHT = font.lineHeight - font.descender
		// font.lineHeight == leading * 2
		// font.descender * 2 == (font.ascender - font.lineHeight + font.descender)
		
		
		// 最大行数に合わせた横幅
		if numberOfLines > 0 {
			let suggestedWidth = lineHeight * CGFloat(numberOfLines) + lineSpacing * CGFloat(numberOfLines - 1)
			if size.width > suggestedWidth {
				size.width = suggestedWidth + 1
			}
		}
		
		
		// 全体の CTLine オブジェクトが必要なら用意
		let fullLine: CTLine? = containsFullLine ? CTLineCreateWithAttributedString(attributedString) : nil
		
		
		return TextInfo(framesetter: framesetter,
		                frameSize: size,
		                fitRange: fitRange,
		                lineHeight: lineHeight,
		                lineSpacing: lineSpacing,
		                textLength: length,
		                fullLine: fullLine,
		                attributedString: attributedString)
	}
	
	
	// MARK: - 描画
	
	/// 再描画
	private func update() {
		// Intrinsic Content Size をリセット
		invalidateIntrinsicContentSize()
		
		// 省略文字を準備
		// 縦書きでも U+2026 で問題なさそう
		// U+2026…（HORIZONTAL ELLIPSIS）
		// U+FE19︙（PRESENTATION FORM FOR VERTICAL HORIZONTAL ELLIPSIS）
		let token = "…"
		let tokenText = Tanzaku.createAttributedString(
			token,
			font: font,
			lineSpacing: lineSpacing,
			textAlignment: textAlignment,
			textColor: textColor) as CFAttributedString
		truncationToken = CTLineCreateWithAttributedString(tokenText)
		
		// 再描画
		setNeedsDisplay()
	}
	
	/// 行を描画
	private func drawLines(in rect: CGRect, context: CGContext) {
		guard let text = text else {
			context.clear(rect)
			return
		}
		guard let textInfo = Tanzaku.textInfo(
			text,
			rect: rect,
			font: font,
			numberOfLines: numberOfLines,
			lineSpacing: lineSpacing,
			textAlignment: textAlignment,
			textColor: textColor,
			containsFullLine: true)
			else {return}
		self.textInfo = textInfo
		
		#if DEBUG_LINES
		print("\n\nLine Height\(font.lineHeight - font.descender), lineHeight: \(font.lineHeight), pointSize: \(font.pointSize), lineSpacing: \(textInfo.lineSpacing),\nascender: \(font.ascender), descender: \(font.descender), leading: \(font.leading)")
		#endif
		
		let framesetter = textInfo.framesetter
		let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), CGPath(rect: rect, transform: nil), Tanzaku.framesetterOptions())
		let lines = CTFrameGetLines(frame) as! [CTLine]
		let maxLineCount = numberOfLines > 0 ? min(Int(numberOfLines), lines.count) : lines.count
		var translate_x = (rect.width - textInfo.lineHeight * CGFloat(maxLineCount)) / 2.0 // 行全体をビューの横中央配置にするための調整
		if maxLineCount > 1 {
			translate_x -= (textInfo.lineSpacing * CGFloat(maxLineCount - 1)) / 2
		}
		
		context.saveGState()
		
		context.scaleBy(x: 1.0, y: -1.0)
		context.translateBy(x: font.descender * 2 - translate_x,
		                    y: -rect.height - font.descender / 2)
		context.rotate(by: CGFloat(-M_PI_2))
		
		
		// 各行を描画
		for (i, line) in lines.enumerated() {
			var thisLine: CTLine = line
			
			// 行数制限を考慮
			if numberOfLines != 0 && i >= Int(numberOfLines) {
				break
			}
			
			// 行の縦幅
			let lineWidth = CTLineGetBoundsWithOptions(thisLine, Tanzaku.lineBoundsOptions()).width
			
			// 均等割付
			if truncationMode == .byJustification {
				let justificationWidth = Double(bounds.height) // 行の幅
				if let justifiedLine = justifiedLine(thisLine, justificationWidth: justificationWidth) {
					thisLine = justifiedLine
				}
			}
			
			// 省略処理：上略・中略・下略
			// 条件：最大行数目に到達 AND 行の終端部分の文字インデックスが文字数未満
			if truncationMode.isTruncation() &&
				i >= Int(maxLineCount) - 1 &&
				CTLineGetStringIndexForPosition(thisLine, CGPoint(x: lineWidth, y: 0)) < textInfo.textLength {
				if let truncatedLine = truncatedLine(thisLine, truncationType: truncationMode.lineTruncationType()!) {
					thisLine = truncatedLine
				}
			}
			
			// 行を描画
			drawLine(thisLine, atIndex: i, withLineHeight: textInfo.lineHeight, inRect: rect, toContext: context)
		}
		
		context.restoreGState()
	}
	
	
	// 行を描画
	private func drawLine(_ line: CTLine,
	                      atIndex lineIndex: CFIndex,
	                      withLineHeight lineHeight: CGFloat,
	                      inRect rect: CGRect,
	                      toContext context: CGContext) {
		// MEMO:
		//   lineRect.y == -lineHeight
		//   lineRect.width == lineRect.height * 2
		//   font.descender == lineRect.y + font.ascender
		
		let lineBounds = CTLineGetBoundsWithOptions(line, Tanzaku.lineBoundsOptions())
		let lineSpacing = self.lineSpacing * CGFloat(lineIndex)
		let x = rect.width - lineHeight * CGFloat(lineIndex) + font.descender * 2 + font.descender / 2 - lineSpacing
		var y = -rect.height - font.descender / 2
		
		// 配置
		switch textAlignment {
		case .center:
			y += (rect.height - lineBounds.width) / 2
			break
		case .bottom:
			y += (rect.height - lineBounds.width)
			break
		default:
			break
		}
		
		context.textPosition = CGPoint(x: y, y: x)
		CTLineDraw(line, context)
		
		#if DEBUG_LINES
			// 行の枠線を描画
			context.saveGState()
			
			let fx = rect.width - lineHeight * CGFloat(lineIndex + 1) - font.descender * 2 - lineSpacing
			let fw = lineHeight
			let fh = lineBounds.width
			let frameRect = CGRect(x: y, y: fx, width: fh, height: fw)
			
			context.addRect(frameRect)
			context.setStrokeColor(UIColor.orange.cgColor)
			context.setLineWidth(1.0)
			context.strokePath()
			
			context.restoreGState()
		#endif
	}
	
	/// 省略処理
	private func truncatedLine(_ targetLine: CTLine, truncationType: CTLineTruncationType) -> CTLine? {
		// 行の縦幅
		let lineWidth = CTLineGetBoundsWithOptions(targetLine, Tanzaku.lineBoundsOptions()).width
		
		switch truncationMode {
		case .byTruncatingHead:
			// 上略
			
			if let fullLine = textInfo?.fullLine,
				let truncatedLine = CTLineCreateTruncatedLine(fullLine, Double(lineWidth), .start, truncationToken) {
				return truncatedLine
			}
		case .byTruncatingMiddle, .byTruncatingTail:
			// 中略・下略
			
			guard let attributedString = textInfo?.attributedString else {break}
			let truncation = truncationMode.lineTruncationType()! // CTLineTruncationType
			let startIndex = CTLineGetStringIndexForPosition(targetLine, CGPoint(x: 0, y: 0))
			let substring = attributedString.attributedSubstring(from: NSRange(location: startIndex, length: attributedString.length - startIndex))
			let recreatedLine = CTLineCreateWithAttributedString(substring)
			
			if let truncatedLine = CTLineCreateTruncatedLine(recreatedLine, Double(lineWidth), truncation, truncationToken) {
				return truncatedLine
			}
		default:
			return nil
		}
		return nil
	}
	
	/// 均等割付
	private func justifiedLine(_ targetLine: CTLine, justificationWidth: Double) -> CTLine? {
		let justificationFactor = CGFloat(1.0) // 割付率：1.0以上なら完全な均等割付、未満なら部分的な均等割付処理を適用する。0.0以下は何もしない
		return CTLineCreateJustifiedLine(targetLine, justificationFactor, justificationWidth)
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		guard let context = UIGraphicsGetCurrentContext() else {return}
		
		drawLines(in: rect, context: context)
	}
	
	
	// MARK: - サイズ計算
	
	override public var intrinsicContentSize: CGSize {
		return prefferedTextSize(bounds.height)
	}
	
	override func sizeThatFits(_ size: CGSize) -> CGSize {
		return prefferedTextSize(size.height)
	}
		
	class func prefferedTextSize(_ text: String,
	                             font: UIFont,
	                             numberOfLines: UInt = 0,
	                             lineSpacing: CGFloat,
	                             textAlignment: TextAlignment,
	                             constraintHeight: CGFloat) -> CGSize {
		let rect = CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: constraintHeight)
		if let size = textInfo(text,
		                       rect: rect,
		                       font: font,
		                       numberOfLines: numberOfLines,
		                       lineSpacing: lineSpacing,
		                       textAlignment: textAlignment)?.frameSize {
			return size
		}
		
		return CGSize.zero
	}
	
	func prefferedTextSize(_ constraintHeight: CGFloat) -> CGSize {
		if let text = text {
			let size = Tanzaku.prefferedTextSize(
				text,
				font: font,
				numberOfLines: numberOfLines,
				lineSpacing: lineSpacing,
				textAlignment: textAlignment,
				constraintHeight: constraintHeight)
			return size
		}
		
		return CGSize.zero
	}

}


// MARK: - 共通のオプション

extension Tanzaku {
	
	fileprivate static func framesetterOptions() -> CFDictionary {
		return [
			kCTFrameProgressionAttributeName as String : CTFrameProgression.rightToLeft.rawValue,
			] as CFDictionary
	}
	
	fileprivate static func lineBoundsOptions() -> CTLineBoundsOptions {
		return [.useOpticalBounds]
	}
	
}
