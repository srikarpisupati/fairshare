//
//  LandingChoice.swift
//  fairshare
//
//  Created by Srikar on 9/30/24.
//

import SwiftUI

// Allow use of hex colors
extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
    }
}

struct LandingChoice: View {
    @State private var showSelection = false
    @State private var showGoodsInput = false
    @State private var showGoodSessionCode = false
    @State private var showText = false
    @State private var code: String = ""
    @State private var confirmClicked = false
    @ObservedObject var globalData = GlobalData.shared
    @StateObject var matrixState: GoodMatrix = GoodMatrix()

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("Welcome to FairShare!")
                        .offset(y: -30)
                        .font(.system(size: 30))
                        .padding(.horizontal)
                    Text("This experimental app is meant to help you divide goods and tasks among participants.")
                        .padding(.bottom)
                        .padding(.horizontal)
                    
                    ZStack {
                        VStack {
                            Button(action: {
                                showText = true
                                globalData.isAdmin = false
                            }) {
                                ZStack {
                                    Rectangle()
                                        .fill(Color(hex: 0x7CB8FF))
                                        .frame(width: 255, height: 150)
                                        .cornerRadius(20)
                                        .shadow(color: .gray, radius: 3, x: 0, y: 3)
                                    Text("Join existing session")
                                        .foregroundColor(.white)
                                        .font(.system(size: 24))
                                }
                            }
                            .alert("Enter join code", isPresented: $showText) {
                                TextField("Enter the code: ", text: $code)
                                Button("Confirm") {
                                    matrixState.checkIfDocumentExists(documentID: code) { exists in
                                        if exists {
                                            showGoodSessionCode = true
                                        } else {
                                            print("Code is wrong")
                                        }
                                    }
                                }
                            }
                            .sheet(isPresented: $showGoodSessionCode) {
                                GoodSessionCode(matrixState: matrixState, code: code,  goods: [Good(name: "")], agent: Agent(id: UUID().uuidString, name: ""))
                            }
                            .padding(.bottom, 35)
                            
                            
                            Button(action: {
                                showSelection = true
                                globalData.isAdmin = true
                            }) {
                                ZStack {
                                    Rectangle()
                                        .fill(Color(hex: 0x7CB8FF))
                                        .frame(width: 255, height: 150)
                                        .cornerRadius(20)
                                        .shadow(color: .gray, radius: 3, x: 0, y: 3)
                                    Text("Create new session")
                                        .foregroundColor(.white)
                                        .font(.system(size: 24))
                                }
                            }
                            .actionSheet(isPresented: $showSelection) {
                                ActionSheet(
                                    title: Text("Create new session"),
                                    buttons: [
                                        .default(Text("Allocate Goods")) {
                                            showGoodsInput = true
                                        },
                                        .default(Text("Allocate Chores")) {
                                            
                                        },
                                        .cancel()
                                    ]
                                )
                            }
                            .sheet(isPresented: $showGoodsInput) {
                                GoodsInput(matrixState: matrixState)
                            }
                            .padding(.bottom, 35)
                            
                            
                            Button(action: {
                                
                            }) {
                                ZStack {
                                    Rectangle()
                                        .fill(Color(hex: 0x7CB8FF))
                                        .frame(width: 255, height: 150)
                                        .cornerRadius(20)
                                        .shadow(color: .gray, radius: 3, x: 0, y: 3)
                                    Text("Create local session")
                                        .foregroundColor(.white)
                                        .font(.system(size: 24))
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    Color(hex: 0xFBF8F0).ignoresSafeArea()
                }
            }
        }
    }
}

#Preview {
    LandingChoice(globalData: GlobalData(), matrixState: GoodMatrix())
}
