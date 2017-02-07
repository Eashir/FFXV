//
//  Character.swift
//  LocalCharacters
//
//  Created by Eashir Arafat on 12/6/16.
//  Copyright © 2016 Evan. All rights reserved.
//

import Foundation
import UIKit

enum CharacterParseError: Error {
    case response, name, image
}

class Character {
    let name: String
    let imageURL: String
    
    init(name: String, imageURL: String) {
        self.name = name
        self.imageURL = imageURL
    }
    
    static func getCharacters(from data: Data?) -> [Character]? {
        var characters: [Character]? = []
        
        do {
            
            // 6. serialize and make object
            let jsonData = try JSONSerialization.jsonObject(with: data!, options: [])
            
            guard let response = jsonData as? [[String: Any]]
                else { throw CharacterParseError.response }
            
            for character in response {
                
                guard let name = character["name"] as? String
                    else { throw CharacterParseError.name }
                guard let imageURL = character["image"] as? String
                    else { throw CharacterParseError.image }
                
                let validCharacter = Character(name: name, imageURL: imageURL)
                characters?.append(validCharacter)
            }
            
            return characters
            
        }
        catch {
            print("Problem casting json: \(error)")
        }
        
        
        return nil
    }
    
    
}




