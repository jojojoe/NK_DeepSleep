//
//  ZJTimer.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/10.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import Foundation
import UIKit

class ZJTimer: NSObject {
   private(set) var _timer: Timer!
   fileprivate weak var _aTarget: AnyObject!
   fileprivate var _aSelector: Selector!
   var fireDate: Date {
       get{
           return _timer.fireDate
       }
       set{
           _timer.fireDate = newValue
       }
   }
   
   class func scheduledTimer(timeInterval ti: TimeInterval, target aTarget: AnyObject, selector aSelector: Selector, userInfo: Any?, repeats yesOrNo: Bool) -> ZJTimer {
       let timer = ZJTimer()
       
       timer._aTarget = aTarget
       timer._aSelector = aSelector
       timer._timer = Timer.scheduledTimer(timeInterval: ti, target: timer, selector: #selector(ZJTimer.zj_timerRun), userInfo: userInfo, repeats: yesOrNo)
       return timer
   }
   
   func fire() {
       _timer.fire()
   }
   
   func invalidate() {
       _timer.invalidate()
   }
   
   @objc func zj_timerRun() {
       //如果崩在这里，说明你没有在使用Timer的VC里面的deinit方法里调用invalidate()方法
       _ = _aTarget.perform(_aSelector)
   }
   
   deinit {
       print("计时器已销毁")
   }
}


class ZJKillTimer {
    /// 活动结束秒数
    var secondsToEnd: Int = 0
    var myTimer: ZJTimer!
    var callBack: ((Int,String)->())?
    
    init(seconds: Int, callBack: ((Int,String)->())?) {
        self.secondsToEnd = seconds
        myTimer = ZJTimer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerRun), userInfo: nil, repeats: true)
        //如果希望对Timer做自定义的操作，使用_Timer属性
        RunLoop.current.add(myTimer._timer, forMode: RunLoop.Mode.common)
        myTimer.fire()
        self.callBack = callBack
    }
    
    deinit {
        myTimer.invalidate()
    }
    
    @objc func timerRun() {
        secondsToEnd -= 1
        if secondsToEnd <= 0 {
            pauseTimer()
        }
        callBack?(secondsToEnd ,secondsToTimeString(seconds: secondsToEnd))
        
    }
    
    func starTimer(fireDateValue: Date = Date.distantPast) {
        myTimer.fireDate = fireDateValue
        myTimer.fire()
    }
    
    func pauseTimer() {
        myTimer.fireDate = Date.distantFuture
    }
    
  
      
    func invalidate() {
        myTimer.invalidate()
    }
    
    
    func updateCountDownValue(value: Int) {
        secondsToEnd = value
//        starTimer()
    }
    
    func resetupCountDownValue(value: Int) {
        secondsToEnd = value
        starTimer()
    }
    
    /// 秒数转化为时间字符串
    func secondsToTimeString(seconds: Int) -> String {
        //天数计算
//        let days = (seconds)/(24*3600);
//        
//        //小时计算
//        let hours = (seconds)%(24*3600)/3600;
        
        //分钟计算
        let minutes = (seconds)%3600/60;
        
        //秒计算
        let second = (seconds)%60;
        
        let timeString  = String(format: "%02lu:%02lu", minutes, second)
        return timeString
    }

}



