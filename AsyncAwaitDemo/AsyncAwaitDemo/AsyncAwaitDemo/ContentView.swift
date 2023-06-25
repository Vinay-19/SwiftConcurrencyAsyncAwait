//
//  ContentView.swift
//  AsyncAwaitDemo
//
//  Created by Vinay Kumar Thapa on 2023-05-31.
//

import SwiftUI

struct ContentView: View {
    
    @State var user: GitHubUser?
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.white,.cyan], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 20) {
                AsyncImage(url: URL(string: user?.avatar_url ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                } placeholder: {
                    
                    Circle()
                        .foregroundColor(Color.secondary)
                        
                        
                }.frame(width: 120, height: 120)

               
                
                Text(user?.login ?? "")
                    .bold()
                    .font(.title3)
                
                Text(user?.bio ?? "")
                    
                
                Spacer()
            }
            .padding()
            .task {
                do{
                     user = try await getUser()
                }catch GHError.invalidURL{
                    print("Invalid Url")
                }catch GHError.invalidResponse{
                    print("Invalid Response")
                }catch GHError.decodingError{
                    print("Decoding Error")
                } catch {
                    print("Oops something went wrong")
                }
        }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        let endPoint = "https://api.github.com/users/twostraws"
       
        guard let url = URL(string: endPoint) else{
            throw GHError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do{
            let jsonDecoder = JSONDecoder()
            
            return try jsonDecoder.decode(GitHubUser.self, from: data)
            
        }catch{
            throw GHError.decodingError
        }
    
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(user: GitHubUser(login: "Vinay", avatar_url: "", bio: "iOS Dev"))
    }
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

struct GitHubUser: Codable{
    let login: String
    let avatar_url: String
    let bio: String
}
