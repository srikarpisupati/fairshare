//
//  GlobalData.swift
//  fairshare
//
//  Created by Srikar on 10/1/24.
//

import Foundation
import SwiftUI

class GlobalData: ObservableObject {
    static let shared = GlobalData()
    @Published var isAdmin: Bool = false
}
