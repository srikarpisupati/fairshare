//
//  CreditsInput.swift
//  fairshare
//
//  Created by Srikar on 10/1/24.
//



import SwiftUI
import FirebaseFirestore

struct CreditsInput: View {
    var agent: Agent
    @ObservedObject var matrixState: GoodMatrix
    @State private var stepperValue: Int = 0
    @State var goods: [Good]
    
    var body: some View {
        NavigationView {
            ZStack{
                ScrollView {
                    Spacer().frame(height: UIScreen.main.bounds.height/6.5)
                    ForEach(Array(goods.enumerated()), id: \.offset) { i, good in
                        HStack {
                            Text(good.name)
                                .font(.system(size: 24))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 30)
                            
                            HStack {
                                Button(action: {
                                    decreaseStepper(i: i)
                                }) {
                                    ZStack {
                                        Image(systemName: "circle.fill")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.white)
                                            .shadow(radius: 5)
                                        Text("-")
                                            .foregroundColor(.black)
                                    }
                                }
                                
                                TextField("---", text: Binding(
                                    get: {
                                        "\(matrixState.getValue(goodIndex: i))"
                                    },
                                    set: { newValue in
                                        if let intValue = Int(newValue) {
                                            matrixState.setValue(goodIndex: i, value: intValue)
                                        }
                                    }
                                ))
                                    .foregroundColor(.black)
                                    .padding(.horizontal)
                                    .frame(maxWidth: 90)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    increaseStepper(i: i)
                                }) {
                                    ZStack {
                                        Image(systemName: "circle.fill")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.white)
                                            .shadow(radius: 5)
                                        Text("+")
                                            .foregroundColor(.black)
                                    }
                                }
                                .padding(.trailing)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                }
                
                ZStack {
                    VStack {
                        Text(agent.name)
                            .font(.system(size: 40))
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Input values for each good")
                            .foregroundColor(Color(hex: 0x707070))
                            .font(.system(size: 20))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .offset(y: 12)
                    
                    Text("Credits: \(matrixState.getRemainingCredits())")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing)
                }
                .offset(y: -UIScreen.main.bounds.height/2.7)
                
                
                
                VStack {
                    ZStack {
                        if (matrixState.getRemainingCredits() == 0) {
                            HStack {
                                ZStack {
                                    Rectangle()
                                        .frame(width: 147, height: 54)
                                        .foregroundColor(Color(hex: 0x7CB8FF))
                                        .border(Color(hex: 0x669EE0))
                                        .cornerRadius(20)
                                    
                                    Text("Upload")
                                        .foregroundColor(.black)
                                        .font(.system(size: 24))
                                }
                                .simultaneousGesture(TapGesture().onEnded {
//                                    var valuationArray: [String: Int] = [:]
//                                    matrixState.addToFinished(uuid: agent.id, value: agent.name) { completion in
//                                        if (completion != nil) {
//                                            ForEach(Array(goods.enumerated()), id: \.offset) { i, good in
//                                                valuationArray[good.name] = matrixState.getValue(goodIndex: i)
//                                            }
//                                        }
//                                    }
//
//                                    matrixState.addToValuations(uuid: agent.id, value: valuationArray) { completion in
//                                        
//                                    }
                                })
                            }
                        } else {
                            Rectangle()
                                .frame(width: 147, height: 54)
                                .foregroundColor(Color(hex: 0xBED5F0))
                                .cornerRadius(20)
                            
                            Text("Upload")
                                .foregroundColor(.gray)
                                .font(.system(size: 24))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing)
                    .padding(.bottom, 25)
                    HStack {
                        NavigationLink(destination: PeopleView(matrixState: matrixState, goods: goods, agent: agent))  {
                                Text("People Status")
                                    .padding(.trailing, 30)
                                    .padding(.leading, 25)
                                    .foregroundColor(.black)
                        }
                        
                        NavigationLink(destination: GoodSessionCode(matrixState: matrixState, code: matrixState.code, goods: goods, agent: agent))  {
                                Text("Details")
                                .padding(.leading, 30)
                                .padding(.trailing, 25)
                                .foregroundColor(.black)
                        }
                        
                        Text("My Selection")
                            .padding(.leading, 30)
                            .padding(.trailing, 25)
                            .foregroundColor(.black)
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
            matrixState.getItems() { gs, error  in
                if let gs = gs {
                    for g in gs {
                        goods.append(Good(name: g))
                    }
                } else {
                    print("Failed to fetch the goods list.")
                }
            }
        }
    }
    
    private func increaseStepper(i: Int) {
        matrixState.setValue(goodIndex: i, value: matrixState.getValue(goodIndex: i) + 1)
    }
    
    private func decreaseStepper(i: Int) {
        matrixState.setValue(goodIndex: i, value: matrixState.getValue(goodIndex: i) - 1)
    }
}

#Preview {
    CreditsInput(agent: Agent(id: UUID().uuidString, name: "Hello"), matrixState: GoodMatrix(), goods: [
        Good(name: "Good 1"),
        Good(name: "Good 2"),
        Good(name: "Good 3")
    ])
}
