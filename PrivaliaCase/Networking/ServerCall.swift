//
//  ServerCall.swift
//  PrivaliaCase
//
//  Created by Marisa on 23/3/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import Foundation

public enum RequestType: String, Codable {case DISCOVER, SEARCH}
enum Result<T, U: Error> {
    case success(T)
    case failure(U)
}

final class ServerCall {
    private lazy var discoverBaseURL: URL = {
        return URL(string: "https://api.themoviedb.org/4/discover/movie")!
    }()
    
    private lazy var searchBaseURL: URL = {
        return URL(string: "https://api.themoviedb.org/4/search/movie")!
    }()
    
    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func fetchMovies(requestType: RequestType, searchQuery: String?,
                         completion: @escaping (Result<MoviePage, DataResponseError>) -> Void) {
        
        var baseURL = URL(string: "base")!
        var parameters = [URLQueryItem]()
        if requestType == RequestType.SEARCH{
            baseURL = searchBaseURL
            parameters = [
                URLQueryItem(name: "api_key", value: "93aea0c77bc168d8bbce3918cefefa45"),
                URLQueryItem(name: "query", value: searchQuery!)]
        }else{
            baseURL = discoverBaseURL
            parameters = [
                URLQueryItem(name: "api_key", value: "93aea0c77bc168d8bbce3918cefefa45"),
                URLQueryItem(name: "sort_by", value: "popularity.desc")]
        }
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = parameters

        session.dataTask(with: urlComponents!.url!, completionHandler: { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                200...299 ~= httpResponse.statusCode,
                let data = data
                else {
                    completion(Result.failure(DataResponseError.network))
                    return
            }

            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            guard let decodedResponse = try? decoder.decode(MoviePage.self, from: data) else {
                completion(Result.failure(DataResponseError.decoding))
                return
            }

            completion(Result.success(decodedResponse))
        }).resume()
    }
    
}

