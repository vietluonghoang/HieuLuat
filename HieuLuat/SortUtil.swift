//
//  SortUtil.swift
//  HieuLuat
//
//  Created by VietLH on 10/5/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import Foundation
class SortUtil {
    let countLimit = 100
    
    func sortBySortPoint(listDieukhoan: [Dieukhoan], isAscending: Bool) -> [Dieukhoan]{
        if isAscending {
            return listDieukhoan.sorted(by: { $0.getSortPoint() < $1.getSortPoint() })
        }else{
            return listDieukhoan.sorted(by: { $0.getSortPoint() > $1.getSortPoint() })
        }
    }
    
    
    func sortByRelevent(listDieukhoan: [Dieukhoan], keyword:String) -> [Dieukhoan]{
        if listDieukhoan.isEmpty || keyword.characters.count < 1 || listDieukhoan.count > countLimit {
            return listDieukhoan
        }
        
        var splittedKeyword = keyword.lowercased().components(separatedBy: " ")
        let splittedKeywordCount = splittedKeyword.count
        
        for dieukhoan in listDieukhoan {
            
            var minhhoa = ""
            
            for mh in dieukhoan.getMinhhoa() {
                minhhoa += mh + " "
            }
            
            let searchDetails = (dieukhoan.getSo() + " " + dieukhoan.getTieude() + " " + dieukhoan.getNoidung() + " " + minhhoa).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            var doneSet = false
            
            for length in stride(from: splittedKeywordCount, to: 0, by: -1) {
                
                let end = (splittedKeywordCount - length)
                for start in 0...end {
                    var key = ""
                    for i in start...((start + length) - 1) {
                        key += splittedKeyword[i] + " "
                    }
                    if searchDetails.contains(key.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        dieukhoan.setSortPoint(sortPoint: Int16(length))
                        doneSet = true
                        break
                    }
                }
                if doneSet {
                    break
                }
            }
        }
        return sortBySortPoint(listDieukhoan: listDieukhoan, isAscending: false)
    }
    
    func sortByEarlyMatch(listDieukhoan: [Dieukhoan], keyword:String) -> [Dieukhoan] {
        if listDieukhoan.isEmpty || keyword.characters.count < 1 || listDieukhoan.count > countLimit {
            return listDieukhoan
        }
        
        var splittedKeyword = keyword.lowercased().components(separatedBy: " ")
        let splittedKeywordCount = splittedKeyword.count
        
        for dk in listDieukhoan {
            var minhhoa = ""
            for mh in dk.getMinhhoa() {
                minhhoa += mh + " "
            }
            let searchDetails = (dk.getSo() + " " + dk.getTieude() + " " + dk.getNoidung() + " " + minhhoa).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            var doneSet = false
            
            for length in stride(from: splittedKeywordCount, to: 0, by: -1) {
                
                let end = (splittedKeywordCount - length)
                for start in 0...end {
                    var key = ""
                    for i in start...((start + length) - 1) {
                        key += splittedKeyword[i] + " "
                    }
                    if searchDetails.contains(key.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        let range = searchDetails.range(of: key.trimmingCharacters(in: .whitespacesAndNewlines))
                        let startIndex = searchDetails.distance(from: searchDetails.startIndex, to: (range?.upperBound)!)
//                        let startIndex = searchDetails.components(separatedBy: key.trimmingCharacters(in: .whitespacesAndNewlines))[0].characters.count
                        dk.setSortPoint(sortPoint: Int16(startIndex))
                        doneSet = true
                        break
                    }
                }
                if doneSet {
                    break
                }
            }
        }
        return sortBySortPoint(listDieukhoan: listDieukhoan, isAscending: true)
    }
    
    func sortByBestMatch(listDieukhoan: [Dieukhoan], keyword:String) -> [Dieukhoan]{
        var rawSorted = sortByRelevent(listDieukhoan: listDieukhoan, keyword: keyword.lowercased())
        var sortedList = [Dieukhoan]()
        if !rawSorted.isEmpty {
            var baselinePoint = rawSorted[0].getSortPoint()
            
            var dkGroup = [Dieukhoan]()
            
            for dieukhoan in rawSorted {
                if dieukhoan.getSortPoint() == baselinePoint {
                    dkGroup.append(dieukhoan)
                }else{
                    sortedList.append(contentsOf: sortByEarlyMatch(listDieukhoan: dkGroup, keyword: keyword))
                    dkGroup = [Dieukhoan]()
                    baselinePoint = dieukhoan.getSortPoint()
                    dkGroup.append(dieukhoan)
                }
            }
            sortedList.append(contentsOf: sortByEarlyMatch(listDieukhoan: dkGroup, keyword: keyword))
        }
        return sortedList
    }
    
//    func sortByBestMatch(listDieukhoan: [Dieukhoan], keyword:String) -> [Dieukhoan]{
//        if listDieukhoan.isEmpty || keyword.characters.count < 1 || listDieukhoan.count > countLimit {
//            return listDieukhoan
//        }
//        var sortedList = [Dieukhoan]()
//        for dieukhoan in listDieukhoan {
//            var splittedKeyword = keyword.components(separatedBy: " ")
//            let splittedKeywordCount = splittedKeyword.count
//            var minhhoa = ""
//            for mh in dieukhoan.getMinhhoa() {
//                minhhoa += mh + " "
//            }
//            let searchDetails = (dieukhoan.getTieude() + " " + dieukhoan.getNoidung() + " " + minhhoa).trimmingCharacters(in: .whitespacesAndNewlines)
//            
//            for length in stride(from: splittedKeywordCount, to: 0, by: -1) {
//                for start in 0...(splittedKeywordCount - length) {
//                    var key = ""
//                    for i in start...((start + length) - 1) {
//                        key += splittedKeyword[i] + " "
//                    }
//                    if searchDetails.contains(key.trimmingCharacters(in: .whitespacesAndNewlines)) {
//                        dieukhoan.setSortPoint(sortPoint: Int8(splittedKeywordCount))
//                    }
//                }
//            }
//        }
//        sortedList.append(contentsOf: sortBySortPoint(listDieukhoan: listDieukhoan, isAscending: false))
//        
//    }
}
