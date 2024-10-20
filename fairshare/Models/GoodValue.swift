//
//  GoodValue.swift
//  fairshare
//
//  Created by Srikar on 10/1/24.
//



import Foundation

// Model for holding value for each good by an agent
struct GoodValue: Identifiable {
    let id = UUID()
    let good: Good
    var value: Int
}
