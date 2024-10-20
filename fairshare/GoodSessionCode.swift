//
//  GoodSessionCode.swift
//  fairshare
//
//  Created by Srikar on 10/1/24.
//

import SwiftUI

struct GoodSessionCode: View {
    @StateObject var matrixState: GoodMatrix
    @State var code = ""
    @State var goods: [Good]
    @ObservedObject var globalData = GlobalData.shared
    @State private var showAlert = false
    @State private var name: String = ""
    
    @State var agent: Agent
    
    var body: some View {
        ZStack {
            VStack {
                if globalData.isAdmin {
                    Text("Your session code: \n \(code)")
                        .offset(x: UIScreen.main.bounds.width/2, y: -UIScreen.main.bounds.height/3.2)
                        .font(.system(size: 30))
                        .padding(.horizontal)
                } else {
                    Text("Your session code: \n \(code)")
                        .offset(y: -UIScreen.main.bounds.height/3.2)
                        .font(.system(size: 30))
                        .padding(.horizontal)
                }
            }
            .onAppear {
                if globalData.isAdmin {
                    code = generateRandomString(length: 10)
                }
                
                matrixState.code = code
                showAlert = true
            }
            .alert("Enter your name", isPresented: $showAlert, actions: {
                TextField("Name: ", text: $name)
                
                Button("Confirm") {
                    agent = Agent(id: UUID().uuidString, name: name)
                    matrixState.addToUsers(uuid: agent.id, value: name) { error in
                        if let error = error {
                            print("Error updating finished field: \(error)")
                        } else {
                            print("Successfully added to finished.")
                        }
                    }
                }
            })
            .padding(.bottom, 35)
            
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        PeopleView(matrixState: matrixState, goods: goods, agent: agent)
                    }) {
                        Text("People Status")
                            .padding(.trailing, 30)
                            .padding(.leading, 25)
                            .foregroundColor(.black)
                    }
                    Button(action: {
                        
                    }) {
                        Text("Details")
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10)
                            .foregroundColor(.black)
                    }
                    Button(action: {
                        CreditsInput(agent: agent, matrixState: matrixState, goods: goods)
                    }) {
                        Text("My Selection")
                            .padding(.leading, 30)
                            .padding(.trailing, 25)
                            .foregroundColor(.black)
                    }
                }
                .padding()
                .background(.thickMaterial)
                .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color(hex: 0xFBF8F0).ignoresSafeArea()
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private func generateRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }

}

#Preview {
    GoodSessionCode(matrixState: GoodMatrix(), code: "abscd", goods: [Good(name: "")], agent: Agent(id: UUID().uuidString, name: ""))
}
