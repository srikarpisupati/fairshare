//
//  GoodSessionCode.swift
//  fairshare
//
//  Created by Srikar on 10/1/24.
//

import SwiftUI

struct GoodSessionCode: View {
    @StateObject var matrixState: GoodMatrix
    @State var code: String
    @State var goods: [Good]
    @ObservedObject var globalData = GlobalData.shared
    @State private var showAlert = false
    @State private var name: String = ""
    
    @State var agent: Agent
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("Your session code: \n \(code)")
                        .offset(y: -UIScreen.main.bounds.height/3.2)
                        .font(.system(size: 30))
                        .padding(.horizontal)
                }
                .onAppear {
                    showAlert = true
                }
                .alert("Enter your name", isPresented: $showAlert, actions: {
                    TextField("Name: ", text: $name)
                    
                    Button("Confirm") {
                        agent = Agent(id: UUID().uuidString, name: name)
                        matrixState.addToUsers(uuid: agent.id, value: name) { error in
                            if let error = error {
                                print("Error updating users: \(error)")
                            } else {
                                print("Successfully added to users.")
                            }
                        }
                    }
                })
                .padding(.bottom, 35)
                
                VStack {
                    Spacer()
                    HStack {
                        NavigationLink(destination: PeopleView(matrixState: matrixState, goods: goods, agent: agent))  {
                                Text("People Status")
                                    .padding(.trailing, 30)
                                    .padding(.leading, 25)
                                    .foregroundColor(.black)
                        }
                        
                        Text("Details")
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10)
                            .foregroundColor(.black)
                        
                        NavigationLink(destination: CreditsInput(agent: agent, matrixState: matrixState, goods: goods))  {
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
    }
}

#Preview {
    GoodSessionCode(matrixState: GoodMatrix(), code: "abscd", goods: [Good(name: "")], agent: Agent(id: UUID().uuidString, name: ""))
}
