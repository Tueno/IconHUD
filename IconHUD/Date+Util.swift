//
//  Date+Util.swift
//  iconhud
//
//  Created by Tomonori on 2018/08/12.
//  Copyright © 2018年 Tomonori Ueno. All rights reserved.
//

import Foundation

extension Date {

    func hourMinuteMonthDayYearString() -> String {
        let cal = Calendar(identifier: .gregorian)
        let dateComp = cal.dateComponents([.year, .month, .day, .minute, .hour],
                                          from: self)
        return String(format: "%02d:%02d %02d/%02d %04d",
                      dateComp.hour!,
                      dateComp.minute!,
                      dateComp.month!,
                      dateComp.day!,
                      dateComp.year!)
    }

}
