//
//  MotionManager.swift
//  DoodleJump
//
//  Created by Sheren Emanuela on 15/06/23.
//

import Foundation
import CoreMotion

public class Motion {
    var motion = CMMotionManager()
    
    func stopAccelerometerUpdate() {
        motion.stopAccelerometerUpdates()
    }
    
    func startAccelorometerUpdate() {
        motion.startAccelerometerUpdates()
    }
    
    func getAccelerometerDataX() -> Double {
        if let data = self.motion.accelerometerData {
            return data.acceleration.x * 30
        }
        return 0
    }
}
