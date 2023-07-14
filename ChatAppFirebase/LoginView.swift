//
//  ContentView.swift
//  ChatAppFirebase
//
//  Created by Tareq Yassin on 08/07/2023.
//

import SwiftUI

struct LoginView: View {
    
    let didCompleteLoginProccess: () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var loginStatusMsg = ""
    @State private var shouldshowImagePicker = false
    @State private var image: UIImage?
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack(spacing: 16){
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                        .padding()
                    if !isLoginMode {
                        Button {
                            // load image action
                            shouldshowImagePicker.toggle()
                        }label:{
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 128, height: 128)
                                        .scaledToFill()
                                        .cornerRadius(64)
                                }else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64).stroke(.black, lineWidth:3))
                            
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("password", text: $password)
                        
                    }
                    .padding(12)
                    .background(.white)
                    
                    
                    Button {
                        // create account action
                        handleAction()
                    }label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Login" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)
                    }
                    
                    Text(self.loginStatusMsg)
                        .foregroundColor(.red)
                }
                .padding()
                
            }
            .navigationTitle( isLoginMode ? "Login" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
            
        }
        .fullScreenCover(isPresented: $shouldshowImagePicker, onDismiss: nil) {
            Text("Example")
            ImagePicker(image: $image)
        }
        
    }
    
    private func handleAction() {
        if isLoginMode {
            loginUser()
        }else {
            createNewAccount()
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) {
            result, err in
            if let err = err {
                self.loginStatusMsg = "Failed to login user: \(err)"
                print(self.loginStatusMsg)
                return
            }
            
            self.loginStatusMsg = "Successfully login user: \(result?.user.uid ?? "")"
            print(self.loginStatusMsg)
            
            self.didCompleteLoginProccess()
        }
    }
    
    private func createNewAccount() {
        if self.image == nil {
            self.loginStatusMsg = "You must select profile image!"
            return
        }
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password){
            result, err in
            if let err = err {
                self.loginStatusMsg = "Failed to create user: \(err)"
                print(self.loginStatusMsg)
                return
            }
            
            
            self.loginStatusMsg = "Successfully created user: \(result?.user.uid ?? "")"
            print(self.loginStatusMsg)
            
            self.persistImageToStorage()
            
        }
    }
    
    private func persistImageToStorage () {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {return}
        ref.putData(imageData, metadata: nil) { metadata, err in
            
            if let err = err {
                self.loginStatusMsg = "Failed to push image to Storage: \(err)"
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    self.loginStatusMsg = "Failed to retrieve downloadURL \(err)"
                    return
                }
                
                self.loginStatusMsg = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                guard let url = url else {return}
                self.storeUserInformation(imageProfileUrl: url)
                self.didCompleteLoginProccess()
            }
        }
        
    }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
        
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    self.loginStatusMsg = "\(err)"
                    return
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(didCompleteLoginProccess: {})
    }
}
