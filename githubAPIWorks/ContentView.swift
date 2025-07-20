
import SwiftUI

struct ContentView: View {
    
    @State private var user: GithubUser?
    
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
              
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width: 180, height: 180)
            
            Text(user?.login ?? "Kullanıcı Adı")
                .bold()
                .font(.title)
            
            Text(user?.bio ?? "Bio Placeholder")
                .padding()
                .italic()
                .font(.title2)
            
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch GHError.invalidURL {
                print("error invalidURL")
            } catch GHError.invalidResponse {
                print("error invalidResponse")
            } catch GHError.invalidData {
                print("error invalidData")
            } catch {
                print("Beklenmedik bir hata oluştu")
            }
        }
    }
    
    func getUser() async throws -> GithubUser {
        let endpoint = "https://api.github.com/users/atalaycitak"
        
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GithubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

#Preview {
    ContentView()
}


struct GithubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String?
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
