// Copyright © 2018. Notch Interfaces. All rights reserved.

import Foundation

enum ConfigurationType: String {
    case chest1 = "config_1_chest.js"
    case rightArm2 = "config_2_right_arm.js"
    case rightArm3 = "config_3_right_arm.js"
    case upperBody5 = "config_5_upper_body.js"
    case lowerBody6 = "config_6_lower_body.js"
    case upperBody6 = "config_6_upper_body.js"
    case fullBody6 = "config_6_full_body.js"
    case fullBody11 = "config_11_full_body.js"
    
    var name: String {
        switch self {
        case .chest1: return "Chest (1)"
        case .rightArm2: return "Right arm (2)"
        case .rightArm3: return "Right arm (3)"
        case .upperBody5: return "Upper body (5)"
        case .upperBody6: return "Upper body (6)"
        case .lowerBody6: return "Lower body (6)"
        case .fullBody6: return "Full body (6)"
        case .fullBody11: return "Full body (11)"
        }
    }
    
    var notchCount: Int {
        switch self {
        case .chest1: return 1
        case .rightArm2: return 2
        case .rightArm3: return 3
        case .upperBody5: return 5
        case .upperBody6: return 6
        case .lowerBody6: return 6
        case .fullBody6: return 6
        case .fullBody11: return 11
        }
    }
    
    var configurationFile: URL? {
        guard let path = Bundle.main.path(forResource: rawValue, ofType: nil) else {
            return nil
        }
        
        return URL(fileURLWithPath: path)
    }
    
    static var allItems: [ConfigurationType] {
        return [.chest1, .rightArm2, .rightArm3, .upperBody5, .upperBody6, .lowerBody6, .fullBody6, .fullBody11]
    }
}
