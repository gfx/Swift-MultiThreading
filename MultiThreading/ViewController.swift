//
//  ViewController.swift
//  MultiThreading
//
//  Created by Fuji Goro on 2014/07/23.
//  Copyright (c) 2014年 FUJI Goro. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let N = 100_000
    
    var c1 = dispatch_queue_create("concurrent.1", DISPATCH_QUEUE_CONCURRENT)
    var c2 = dispatch_queue_create("concurrent.2", DISPATCH_QUEUE_CONCURRENT)
    var sync = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL)
    
    var value : Int = 0;
    
    var t0 = NSDate().timeIntervalSince1970
                            
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        
        let interval = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC))
        dispatch_after(interval, dispatch_get_main_queue()) {
            NSLog("start")
            self.useObjcSync()
        }
    }
    
    func useObjcSync() {
        t0 = NSDate().timeIntervalSince1970

        dispatch_async(c1) {
            for  i in 0 ..< self.N {
                self.incrementWithObjcSync()
            }
            
            self.next()
        }
        
        dispatch_async(c2) {
            for  i in 0 ..< self.N {
                self.incrementWithObjcSync()
            }
            
            self.next()
        }
    }
    
    func useSerialQueue() {
        t0 = NSDate().timeIntervalSince1970
        
        dispatch_async(c1) {
            for  i in 0 ..< self.N {
                self.incrementWithSerialQueue()
            }
            
            self.finished()
        }
        
        dispatch_async(c2) {
            for  i in 0 ..< self.N {
                self.incrementWithSerialQueue()
            }
            
            self.finished()
        }
    }
    
    func incrementWithObjcSync() {
        objc_sync_enter(self)
        self.value += 1
        objc_sync_exit(self)
    }
    
    func incrementWithSerialQueue() {
        struct _IncrementWithSyncQueue {
            static var s = dispatch_queue_create("incrementWithSyncQueue", DISPATCH_QUEUE_SERIAL)
        }
        
        dispatch_sync(_IncrementWithSyncQueue.s) {
            self.value += 1
        }
    }
    
    func next() {
        struct _Next {
            static var count = 0
        }
        
        if ++_Next.count >= 2 {
            NSLog("elapsed: %.03f sec.", NSDate().timeIntervalSince1970 - t0)
            useSerialQueue()
        }
    }
    
    func finished() {
        struct _Finished {
            static var count = 0
        }
        
        if ++_Finished.count >= 2 {
            NSLog("elapsed: %.03f sec.", NSDate().timeIntervalSince1970 - t0)
            
            let interval = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC))
            dispatch_after(interval, dispatch_get_main_queue()) {
                self.show(String(format: "value = %d", self.value))
            }
        }
    }
    
    func show(message : String) {
        let alert = UIAlertView(title: "Finished", message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
}

