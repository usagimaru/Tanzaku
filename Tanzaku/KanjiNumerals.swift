//
//  KanjiNumerals.swift
//  Tanzaku
//
//  Created by usagimaru on 2017.03.22.
//  Copyright © 2017 usagimaru. All rights reserved.
//

import Foundation

class KanjiNumerals: NSObject {
	
	private static let cal = Calendar(identifier: .japanese) // japanese 固定
	private static let locale = Locale.init(identifier: "ja") // ja 固定
	static let firstYear = "元"
	static let zero = "零"
	static let minus = "負"
	static let plus = "正"
	static let period = "・"
	static let yen = "円"
	static let traditionalYen = "圓"
	static let year = "年"
	static let month = "月"
	static let day = "日"
	static let dayOfWeek = "曜日"
	
	private static func standardNumeralCharacters() -> [Int : String] {
		return [
			0 : "〇",
			1 : "一",
			2 : "二",
			3 : "三",
			4 : "四",
			5 : "五",
			6 : "六",
			7 : "七",
			8 : "八",
			9 : "九",
			10 : "十",
			100 : "百",
			1000 : "千",
			10000 : "万",
			100000000 : "億",
			1000000000000 : "兆",
			10000000000000000 : "京"
		]
	}
	
	private static func japaneseDaijiCharacters() -> [Int : String] {
		return [
			0 : "〇",
			1 : "壱",
			2 : "弐",
			3 : "参",
			4 : "四",
			5 : "五",
			6 : "六",
			7 : "七",
			8 : "八",
			9 : "九",
			10 : "拾",
			100 : "百",
			1000 : "千",
			10000 : "万",
			100000000 : "億",
			1000000000000 : "兆",
			10000000000000000 : "京"
		]
	}
	
	private static func japaneseTraditionalDaijiCharacters() -> [Int : String] {
		return [
			0 : "零",
			1 : "壱",
			2 : "弐",
			3 : "参",
			4 : "肆",
			5 : "伍",
			6 : "陸",
			7 : "漆",
			8 : "捌",
			9 : "玖",
			10 : "拾",
			100 : "陌",
			1000 : "阡",
			10000 : "萬",
			100000000 : "億",
			1000000000000 : "兆",
			10000000000000000 : "京"
		]
	}
	
	/// 12594: Integer -> "一万二千五百九十四"
	static func kanjinize(_ number: Int?) -> String {
		guard let number = number else {return ""}
		
		let nf = NumberFormatter()
		nf.locale = KanjiNumerals.locale
		nf.numberStyle = .spellOut
		return nf.string(from: NSNumber(value: number)) ?? ""
	}
	
	/// Date -> "平成元年十二月二十三日"
	static func kanjinizedDateString(from date: Date) -> String {
		let df = DateFormatter()
		df.locale = KanjiNumerals.locale
		df.calendar = KanjiNumerals.cal
		df.dateFormat = "G" // 元号
		let era = df.string(from: date)
		
		let comps = KanjiNumerals.cal.dateComponents([.year, .month, .day], from: date)
		let yearStr = (comps.year ?? 0) > 1 ? kanjinize(comps.year) : KanjiNumerals.firstYear
		let monthStr = kanjinize(comps.month)
		let dayStr = kanjinize(comps.day)
		
		return era + yearStr + KanjiNumerals.year + monthStr + KanjiNumerals.month + dayStr + KanjiNumerals.day
	}
	
}
