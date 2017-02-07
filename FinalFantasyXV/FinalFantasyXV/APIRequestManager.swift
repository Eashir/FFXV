//
//  APIRequestManager.swift
//  LocalContacts
//
//  Created by Eashir Arafat on 12/6/16.
//  Copyright © 2016 Evan. All rights reserved.
//

import Foundation

class APIRequestManager {
    static let manager = APIRequestManager()
    
    private init () {}
    
    
    func getData(_ endPoint: String, completion: @escaping (Data) -> Void) {
        guard let url = URL(string: endPoint) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic a2V5LTc6UlBtMERkQTExWS1OWjZoQXduTGI=", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("Error encountered at get request: \(error)")
            }
            guard let validData = data else { return }
            DispatchQueue.main.async {
                completion(validData)
            }
            }.resume()
    }
    
    func postu(name: String, email: String) {
        var request: URLRequest = URLRequest(url: URL(string: "https://api.fieldbook.com/v1/5846eb88a785c00300a9434b/contacts")!)
        
        request.httpMethod = "POST"
        
        let headers = [
            "content-type": "application/json",
            "authorization": "Basic a2V5LTc6UlBtMERkQTExWS1OWjZoQXduTGI="
            
        ]
        /*
         [
         "my_name": "Eashir Arafat",
         "favorite_element": "\(element.symbol)"
         
         ]
         */
        let parameters = [
            "name": "\(name)",
            "email": "\(email)",
            "role": "Fighter",
            "company": "Riot Games",
            
            "image": "http://pre08.deviantart.net/cb66/th/pre/f/2016/282/0/a/yasuo_by_saya94-dakdrqi.png"
        ]
        request.allHTTPHeaderFields = headers
        
        do {
            let postData: Data = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = postData
        }
        catch {
            print("Error converting to data")
        }
        
        let session: URLSession = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
            }
            }.resume()
    }
    
}
