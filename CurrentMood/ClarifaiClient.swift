//
//  ClarifaiClient.swift
//  CurrentMood
//
//  Created by Cristian Duica on 1/21/17.
//  Copyright © 2017 Cristian Duica. All rights reserved.
//

import Foundation
import UIKit

class ClarifaiClient {
    
    let urlpath = "https://api.clarifai.com/v1/"
    let client_id = "mfl85kbebImBqQBm4b0JgFJRokklYpgEAwsZFO6V"
    let client_secret = "8iZBzG5OUvXZu-W-1Mnklmsz_cnX8p6UdqTn6ysa"
    var oauthtoken: String!
    
    func refreshToken(){
        let url = URL(string: urlpath + "token/")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        let authdetails: String = "client_id=" + client_id + "&client_secret=" + client_secret + "&grant_type=client_credentials"
        let auth: Data
        
        auth = authdetails.data(using: .utf8)!
        urlRequest.httpBody = auth
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest){
            (data, response, error) in
            guard error == nil else {
                print("error calling POST on /token")
                print(error ?? "error")
                return
            }
            
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            do {
                guard let receivedToken = try JSONSerialization.jsonObject(with: responseData,
                    options: []) as? [String: Any] else {
                    print("Could not get JSON from responseData as dictionary")
                    return
                }
                print("The token is: " + receivedToken.description)
                
                guard let token = receivedToken["access_token"] as? String else {
                    print("Could not get token from JSON")
                    return
                }
                print("The ID is: \(token)")
                self.oauthtoken = token
            } catch  {
                print("error parsing response from POST on /token")
                return
            }
        }
        task.resume()
        
    }
    
    func postImage(image: UIImage, callback: @escaping ([String])->Void){
        let url = URL(string: urlpath + "tag/")
        var urlRequest = URLRequest(url: url!)
        let boundary = generateBoundaryString();
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer " + oauthtoken, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //do {
        let data = UIImageJPEGRepresentation(image, 1.0)
        let encData = data?.base64EncodedData()
        let mimetype = "image/jpeg"
        let body = NSMutableData()

        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"encoded_data\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(encData!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)

        urlRequest.httpBody = body as Data
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest){
            (data, response, error) in
            guard error == nil else {
                print("error calling POST on /tag")
                print(error ?? "error")
                return
            }
            
            guard let responseData = data else {
                print("did not recieve data")
                return
            }
            
            do {
                let receivedTags = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                let results = receivedTags["results"] as? [Any]
                let firstResult = results?.first as? [String: Any]
                let result = firstResult?["result"] as? [String: Any]
                let tag = result?["tag"] as? [String: Any]
                let classes = tag?["classes"] as! [String]
                callback(classes);
                //print("Tags: \(classes.first ?? "fuck")")
                
            } catch {
                print("error parsing response from /tag")
                return
            }
        }
        task.resume()
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
}
