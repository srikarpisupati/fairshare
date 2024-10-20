//
//  PeopleInput.swift
//  fairshare
//
//  Created by Srikar on 10/1/24.
//



import SwiftUI
import FirebaseFirestore

struct PeopleView: View {
    @StateObject var matrixState: GoodMatrix
    @State private var people: [Agent] = []
    @State var goods: [Good]
    @State var agent: Agent
    @ObservedObject var globalData = GlobalData.shared
    
    var body: some View {
        NavigationView {
            ZStack{
                ScrollView {
                    Spacer().frame(height: UIScreen.main.bounds.height/9)
                    ForEach(people) { agent in
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                                .cornerRadius(20)
                                .shadow(radius: 7)
                                .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height/14)
                            Text(agent.name)
                                .font(.system(size: 24))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)
                                .frame(width: UIScreen.main.bounds.width - 40)
                            if globalData.isAdmin {
                                Button(action: {
                                    if let index = people.firstIndex(where: { $0.id == agent.id }) {
                                        people.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "x.circle")
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: UIScreen.main.bounds.width - 50, alignment: .trailing)
                                .padding(.trailing)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity)
                
                ZStack {
                    Text("People")
                        .font(.system(size: 40))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .offset(y: -UIScreen.main.bounds.height/2.7)
                VStack {
                    ZStack {
                        if (people.count >= 2 && globalData.isAdmin) {
                            HStack {
                                ZStack {
                                    Rectangle()
                                        .frame(width: 147, height: 54)
                                        .foregroundColor(Color(hex: 0x7CB8FF))
                                        .border(Color(hex: 0x669EE0))
                                        .cornerRadius(20)
                                    
                                    Text("Allocate")
                                        .foregroundColor(.black)
                                        .font(.system(size: 24))
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    matrixState.getUsers() { persons, error  in
                                        if let agents = persons {
                                            for (i, n) in agents {
                                                people.append(Agent(id: i, name: n))
                                            }
                                        } else {
                                            print("Failed to fetch the users list.")
                                        }
                                    }
                                    matrixState.getItems() { gs, error  in
                                        if let gs = gs {
                                            for n in gs {
                                                goods.append(Good(name: n))
                                            }
                                        } else {
                                            print("Failed to fetch the goods list.")
                                        }
                                    }
                                    
                                    matrixState.getMaxNashWelfare(agents: people, items: goods)
                                    
                                    Allocation(matrixState: matrixState, goods: $goods, people: $people)
                                })
                            }
                        } else {
                            Rectangle()
                                .frame(width: 147, height: 54)
                                .foregroundColor(Color(hex: 0xBED5F0))
                                .cornerRadius(20)
                            
                            Text("Allocate")
                                .foregroundColor(.gray)
                                .font(.system(size: 24))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing)
                    .padding(.bottom, 25)
                    HStack {
                        Button(action: {
                            //do nothing
                        }) {
                            Text("People Status")
                                .padding(.trailing, 30)
                                .padding(.leading, 25)
                                .foregroundColor(.black)
                        }
                        Button(action: {
                            GoodSessionCode(matrixState: matrixState, goods: goods, agent: agent)
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
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color(hex: 0xFBF8F0).ignoresSafeArea()
            }
            .ignoresSafeArea(.keyboard)
            
        }
        .onAppear {
            matrixState.getUsers() { persons, error in
                if let error = error {
                    print("Error updating finished field: \(error)")
                } else {
                    for (i, n) in persons! {
                        people.append(Agent(id: i, name: n))
                    }
                    print("Successfully added to finished.")
                }
            }
        }
    }
}

#Preview {
    PeopleView(matrixState: GoodMatrix(), goods: [Good(name: "")], agent: Agent(id: UUID().uuidString, name: ""))
}
