//
//  GoodMatrix.swift
//  fairshare
//
//  Created by Srikar on 10/1/24.
//



import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFunctions

class GoodMatrix: ObservableObject {
    @Published var matrix: [[Int]] = []
    @Published var row: [Int] = []
    
    @Published var totalCredits: [Int] = []
    @Published var totalCreditsIndividual: Int = 100
    
    @Published var optAlloc: [[Int]] = []
    @Published var optNashWelfare: Double = -1.0
    
    @Published var isAdmin: Bool = false
    var code: String = ""
    
    private var db = Firestore.firestore()
    
    func setSize(peopleCount: Int, goodsCount: Int) {
        self.matrix = Array(repeating: Array(repeating: 0, count: goodsCount), count: peopleCount)
        self.totalCredits = Array(repeating: 100, count: peopleCount)
    }
    func setSize(goodsCount: Int) {
        self.row = Array(repeating: 0, count: goodsCount)
        self.totalCreditsIndividual = 100
    }
    
    func setValue(rowIndex: Int, columnIndex: Int, value: Int) {
        // Check if rowIndex and columnIndex are within bounds
        guard rowIndex >= 0 && rowIndex < matrix.count && columnIndex >= 0 && columnIndex < matrix[rowIndex].count else {
            return
        }
        let maxVal = totalCredits[rowIndex] + matrix[rowIndex][columnIndex]
        if (value < 0 || (rowIsComplete(rowIndex: rowIndex) && value > matrix[rowIndex][columnIndex]) || value > maxVal) {
            return
        }
        if (matrix[rowIndex][columnIndex] == 0 && columnIndex == (matrix.first?.count ?? 0) - 1) {
            matrix[rowIndex][columnIndex] = maxVal
            totalCredits[rowIndex] = 0
        } else {
            totalCredits[rowIndex] -= value - matrix[rowIndex][columnIndex]
            matrix[rowIndex][columnIndex] = value
        }
    }
    func setValue(goodIndex: Int, value: Int) {
        guard goodIndex >= 0 && goodIndex < row.count else {
            return
        }
        let maxVal = totalCreditsIndividual + row[goodIndex]
        if (value < 0 || totalCreditsIndividual == 0 && value > row[goodIndex] || value > maxVal) {
            return
        }
        if (row[goodIndex] == 0 && goodIndex == (matrix.first?.count ?? 0) - 1) {
            row[goodIndex] = maxVal
            totalCreditsIndividual = 0
        } else {
            totalCreditsIndividual -= value - row[goodIndex]
            row[goodIndex] = value
        }
    }
    
    func getValue(rowIndex: Int, columnIndex: Int) -> Int {
        // Check if rowIndex and columnIndex are within bounds
        guard rowIndex >= 0 && rowIndex < matrix.count && columnIndex >= 0 && columnIndex < matrix[rowIndex].count else {
            print("Out of bounds: Matrix length is ", matrix.count)
            print("Passed in values are ", rowIndex, ", ", columnIndex)
            return 0 // Return a default value if index is out of bounds
        }
        return matrix[rowIndex][columnIndex]
    }
    func getValue(goodIndex: Int) -> Int {
        // Check if rowIndex and columnIndex are within bounds
        guard goodIndex >= 0 && goodIndex < row.count else {
            print("Out of bounds")
            return 0 // Return a default value if index is out of bounds
        }
        return row[goodIndex]
    }
    
    func isComplete() -> Bool {
        for row in matrix {
            if row.reduce(0, +) != 100 {
                return false
            }
        }
        return true
    }
    func isCompleteRow() -> Bool {
        if row.reduce(0, +) != 100 {
            return false
        }
        return true
    }
    
    func rowIsComplete(rowIndex: Int) -> Bool {
        if (rowIndex < 0 || rowIndex >= totalCredits.count) {
            return true
        }
        return (matrix[rowIndex].reduce(0, +) == 100)
    }
    
    func getRemainingCredits(rowIndex: Int) -> Int {
        guard rowIndex >= 0 && rowIndex < totalCredits.count else {
            print("Out of bounds: Credits array length is ", totalCredits.count)
            print("Passed in values is ", rowIndex)
            return 0
        }
        return totalCredits[rowIndex]
    }
    func getRemainingCredits() -> Int {
        return totalCreditsIndividual
    }
    
    func generateOwnerVectors(numAgents: Int, numItems: Int) -> [[Int]] {
        let maxAllocNum = Int(pow(Double(numAgents), Double(numItems)))
        var ownerVectors = [[Int]]()
        
        for allocNum in 0..<maxAllocNum {
            var ownerVector = [Int]()
            var remainingAllocNum = allocNum
            
            for _ in 0..<numItems {
                ownerVector.append(remainingAllocNum % numAgents)
                remainingAllocNum /= numAgents
            }
            
            ownerVectors.append(ownerVector)
        }
        
        return ownerVectors
    }
    
    func generateAllAllocations(numAgents: Int, numItems: Int) -> [[[Int]]] {
        let ownerVectors = generateOwnerVectors(numAgents: numAgents, numItems: numItems)
        var allocations = [[[Int]]]()
        
        for ownerVector in ownerVectors {
            var alloc = Array(repeating: [Int](), count: numAgents)
            
            for j in 0..<numItems {
                alloc[ownerVector[j]].append(j)
            }
            
            allocations.append(alloc)
        }
        
        return allocations
    }
    
    func getMaxNashWelfare(agents: [Agent], items: [Good]) {
        //addSession(people: agents, goods: items)
        
        let functions = Functions.functions()
        
        var myDict: [String: Any] = [String: Any]()
        myDict["agents"] = agents.count
        myDict["items"] = items.count
        myDict["values"] = matrix
        
        var allocation: [[Int]]?
        callCloudFunction(dict: myDict) { result in
            allocation = result
        }
        
        if let allocation = allocation {
            self.optAlloc = allocation
            print("Received allocations")
        } else {
            print("Error retrieving allocations from Cloud Function")
        }
        
        
        let numAgents = agents.count
        let numItems = items.count
        for alloc in generateAllAllocations(numAgents: numAgents, numItems: numItems) {
            var values = [Double]()
            for i in 0..<numAgents {
                let sumValue = alloc[i].reduce(0.0) { $0 + Double(matrix[i][$1]) }
                values.append(sumValue)
            }
            let nashWelfare = values.reduce(1.0, *)
            
            let urlString = "https://us-central1-fairdivision-dc6c7.cloudfunctions.net/mnw"
            
            guard let url = URL(string: urlString) else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let allocationRequest: [String : [String : Any]] = [
                "data" : [
                    "agents": agents.count,
                    "items": items.count,
                    "values": matrix
                ]
            ]
            
            do {
                let requestBody = try JSONSerialization.data(withJSONObject: allocationRequest, options: [])
                request.httpBody = requestBody
            } catch {
                print("Error encoding request body: \(error)")
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                print("Inside task")
                if let error = error {
                    print("Error making request: \(error)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw Response: \(rawResponse)")
                }
                
                do {
                    let allocationResponse = try JSONDecoder().decode(AllocationResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.optAlloc = allocationResponse.result.alloc
                        print("Allocation Response: \(self.optAlloc)")
                    }
                } catch {
                    print("Error decoding response: \(error)")
                }
            }
            
            task.resume()
        }
    }

    func callCloudFunction(dict: [String: Any], completion: @escaping ([[Int]]?) -> Void) {
        let queue = DispatchQueue(label: "cloudFunctionCallQueue")
        
        queue.async {
            Functions.functions().httpsCallable("mnw").call(dict) { result, error in
                if let error = error {
                    print("Error calling Cloud Function:", error.localizedDescription)
                    completion(nil)
                    return
                }
                
                guard let data = result?.data as? [String: Any] else {
                    print("Unexpected response format from Cloud Function")
                    completion(nil)
                    return
                }
                
                guard let allocations = data["alloc"] as? [[Int]] else {
                    print("Missing 'alloc' key in Cloud Function response")
                    completion(nil)
                    return
                }
                
                completion(allocations)
            }
        }
    }

    func checkIfDocumentExists(documentID: String, completion: @escaping (Bool) -> Void) {
        let collection = db.collection("sessions")  // Specify your collection name
        
        // Get the document with the specified document ID
        collection.document(documentID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error)")
                completion(false)
                return
            }
            
            // Check if the document exists
            if let document = document, document.exists {
                print("Document with ID '\(documentID)' exists.")
                completion(true)
            } else {
                print("Document with ID '\(documentID)' does not exist.")
                completion(false)
            }
        }
    }
    
    func getItems(completion: @escaping ([String]?, Error?) -> Void) {
        let documentRef = db.collection("sessions").document(code)
        
        documentRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let finishedData = data?["items"] as? [String] {
                    completion(finishedData, nil)
                } else {
                    completion(nil, nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func addToItems(value: String, completion: @escaping (Error?) -> Void) {
        let documentRef = db.collection("sessions").document(code)
        
        documentRef.updateData([
            "items" : value
        ]) { error in
            completion(error)
        }
    }
    
    func addToFinished(uuid: String, value: String, completion: @escaping (Error?) -> Void) {
        let documentRef = db.collection("sessions").document(code)
        
        documentRef.updateData([
            "finished.\(uuid)": value
        ]) { error in
            completion(error)
        }
    }
    
    func getFinished(completion: @escaping ([String: String]?, Error?) -> Void) {
        let documentRef = db.collection("sessions").document(code)
        
        documentRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let finishedData = data?["finished"] as? [String: String] {
                    completion(finishedData, nil)
                } else {
                    completion(nil, nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func addToUsers(uuid: String, value: String, completion: @escaping (Error?) -> Void) {
        let documentRef = db.collection("sessions").document(code)
        
        documentRef.updateData([
            "users.\(uuid)": value
        ]) { error in
            completion(error)
        }
    }
    
    func getUsers(completion: @escaping ([String: String]?, Error?) -> Void) {
        let documentRef = db.collection("sessions").document(code)
        
        documentRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let finishedData = data?["users"] as? [String: String] {
                    completion(finishedData, nil)
                } else {
                    completion(nil, nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    
    func addToValuations(uuid: String, value: [String:Int], completion: @escaping (Error?) -> Void) {
        let documentRef = db.collection("sessions").document(code)
        
        documentRef.updateData([
            "valuations.\(uuid)": value
        ]) { error in
            completion(error)
        }
    }
    
    

    //
    //        func addSession(people: [Agent], goods: [Good]) {
    //
    //            // Used to set value for "isGood"
    //            let type = true
    //
    //            if isAdmin {
    //                db.collection("sessions").document(doc).setData([
    //                    UUID().uuidString : myName,
    //                ])
    //
    //                var dict: [String: [String: Int]] = [String: [String: Int]]()
    //                for i in 0..<matrix.count {
    //                    let person = people[i]
    //                    var insideDict: [String: Int] = [String: Int]()
    //                    for j in 0..<matrix[i].count {
    //                        insideDict[goods[j].name] = matrix[i][j]
    //                    }
    //                    dict[person.name] = insideDict
    //                }
    //
    //                for (key, value) in dict {
    //                    db.collection("allocations").document(doc).setData([
    //                        key: value
    //                    ], merge: true)
    //                }
    //                db.collection("finished").document(doc).setData([
    //                    UUID().uuidString : myName,
    //                ])
    //            } else {
    //                let doc = code
    //
    //                db.collection("users").document(doc).updateData([
    //                    UUID().uuidString : myName,
    //                ])
    //
    //                db.collection("finished").addSnapshotListener { (snapshot, error) in
    //                    guard let documents = snapshot?.documents, !documents.isEmpty else {
    //                        print("Collection is still empty.")
    //                        return
    //                    }
    //                    db.collection("finished").document(doc).updateData([
    //                        UUID().uuidString : self.myName,
    //                    ])
    //                    db.collection("users").document(doc).setData([
    //                        "" : ""
    //                    ])
    //                }
    //            }
    //
    //        }
    //
}
