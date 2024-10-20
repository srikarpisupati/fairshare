//
//  Agent.swift
//  fairshare
//
//  Created by Srikar on 10/1/24.
//



import Foundation

struct Agent: Identifiable {
    let id: String
    let name: String
    var goods: [GoodValue] = []
}
