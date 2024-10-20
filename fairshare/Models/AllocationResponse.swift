//
//  AllocationResponse.swift
//  fairshare
//
//  Created by Srikar on 10/1/24.
//


//
//  RRAllocation.swift
//  FairDivision
//
//  Created by Anushka Sankaran on 7/16/24.
//

import Foundation

struct AllocationResponse: Codable {
    let result: AllocationResult

    struct AllocationResult: Codable {
        let alloc: [[Int]]
    }
}
