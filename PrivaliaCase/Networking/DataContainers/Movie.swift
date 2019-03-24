//
//  MovieContainer.swift
//  PrivaliaCase
//
//  Created by Marisa on 23/3/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import Foundation
import UIKit

struct Movie: Decodable {
    let title: String?
    let releaseDate: Date?
    let overview: String?
    let imageString: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case releaseDate = "release_date"
        case overview = "overview"
        case imageString = "poster_path"
    }
    
    init(title: String?, releaseDate: Date?, overview: String?, imageString: String?) {
        self.title = title
        self.releaseDate = releaseDate
        self.overview = overview
        self.imageString = imageString
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let title = try? container.decode(String.self, forKey: .title)
        let releaseDate = try? container.decode(Date.self, forKey: .releaseDate)
        let overview = try? container.decode(String.self, forKey: .overview)
        let imageString = try? container.decode(String.self, forKey: .imageString)
        self.init(title: title, releaseDate: releaseDate, overview: overview, imageString: imageString)
    }
    
}
