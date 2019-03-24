//
//  PageContainer.swift
//  PrivaliaCase
//
//  Created by Marisa on 23/3/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import Foundation

struct MoviePage: Decodable {
    let movies: [Movie]
    let page: Int
    let total_results: Int
    let total_pages: Int
    
    
    enum CodingKeys: String, CodingKey {
        case movies = "results"
        case page = "page"
        case total_results = "total_results"
        case total_pages = "total_pages"
    }
}
