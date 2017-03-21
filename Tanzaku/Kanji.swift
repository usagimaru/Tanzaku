//
//  Kanji.swift
//  Tanzaku
//
//  Created by usagimaru on 2017.03.22.
//  Copyright © 2017年 usagimaru. All rights reserved.
//

import Foundation

class KanjiNumerals {
	
	enum KanjiNumeralType: Int {
		case standard
		case japaneseDaiji
		case japaneseTraditionalDaiji
	}
	
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
	
	static func kanjiNumeralSymbols(_ type: KanjiNumeralType) -> [Int : String] {
		switch type {
		case .standard:
			return standardNumeralCharacters()
		case .japaneseDaiji:
			return japaneseDaijiCharacters()
		case .japaneseTraditionalDaiji:
			return japaneseTraditionalDaijiCharacters()
		}
	}
	
	static func zero() -> String {
		return "零"
	}
	
	static func minus() -> String {
		return "負"
	}
	
	static func period() -> String {
		return "・"
	}
	
	static func yen(isTraditional: Bool = false) -> String {
		return isTraditional ? "圓" : "円"
	}
	
	private static func one(_ numChar: Int, type: KanjiNumeralType) -> String? {
		switch type {
		case .standard:
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
				9 : "九"
			][numChar]
			
		case .japaneseDaiji:
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
				9 : "九"
			][numChar]
			
		case .japaneseTraditionalDaiji:
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
				9 : "玖"
			][numChar]
		}
	}
	
	private static func middleUnit(_ index: Int, type: KanjiNumeralType) -> String? {
		switch type {
		case .standard:
			return [
				0 : "",
				1 : "十",
				2 : "百",
				3 : "千",
				][index]
			
		case .japaneseDaiji:
			return [
				0 : "",
				1 : "拾",
				2 : "百",
				3 : "千",
				][index]
			
		case .japaneseTraditionalDaiji:
			return [
				0 : "",
				1 : "拾",
				2 : "陌",
				3 : "阡",
				][index]
		}
	}
	
	private static func largeUnit(_ index: Int, type: KanjiNumeralType) -> String? {
		switch type {
		case .standard, .japaneseDaiji:
			return [
				0 : "",
				1 : "万",
				2 : "億",
				3 : "兆",
				4 : "京"
				][index]
			
		case .japaneseTraditionalDaiji:
			return [
				0 : "",
				1 : "萬",
				2 : "億",
				3 : "兆",
				4 : "京"
				][index]
		}
	}
	
	enum KanjiConversionMethod: Int {
		case standard
		case positional
		case japaneseDaiji
		case japaneseTraditionalDaiji
		
		func kanjiNumeralType() -> KanjiNumeralType {
			switch self {
			case .standard, .positional:
				return KanjiNumeralType.standard
			case .japaneseDaiji:
				return KanjiNumeralType.japaneseDaiji
			case .japaneseTraditionalDaiji:
				return KanjiNumeralType.japaneseTraditionalDaiji
			}
		}
	}
	
	static func arabicToKanjiNumerals(_ source: Int, method: KanjiConversionMethod) -> String {
		func standardKanjiNumerals() -> String {
			let str = "\(source)"
			let characters = str.characters.map {String($0)} // 文字単位で分割: ["1","2","3"]
			let kanjiCharacters = standardNumeralCharacters()
			var kanjiNumerals = ""
			
			for numChar in characters {
				kanjiNumerals += kanjiCharacters[Int(numChar)!]!
			}
			
			return kanjiNumerals
		}
		
		func positionalKanjiNumerals() -> String {
			let instr = "\(source)"
			let length = instr.characters.count
			let man = Int(length / 4)
			let type = method.kanjiNumeralType()
			
			var result = ""
			
			for i in 0 ..< man {
				var kanjiNumerals = ""
				
				for j in 0 ..< 4 {
					let p = length - i * 4 - j - 1
					if p >= 0 {
						let substr = (instr as NSString).substring(with: NSRange(location: p, length: 1))
						let num = Int(substr)!
						
						let one = self.one(num, type: type) ?? ""
						let mid = middleUnit(j, type: type) ?? ""
						
						if one != "" {
							if one == "一" && mid != "" {
								kanjiNumerals = mid + kanjiNumerals
							}
							else {
								kanjiNumerals = one + mid + kanjiNumerals
							}
						}
					}
				}
				
				if kanjiNumerals != "" {
					result = kanjiNumerals + (largeUnit(i, type: type) ?? "") + kanjiNumerals
				}
			}
			
			return result
		}
		
		switch method {
		case .standard:
			return standardKanjiNumerals()
		case .positional, .japaneseDaiji, .japaneseTraditionalDaiji:
			return positionalKanjiNumerals()
		}
	}
	
}
