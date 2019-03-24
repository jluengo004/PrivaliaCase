//
//  MainTableViewCell.swift
//  PrivaliaCase
//
//  Created by Marisa on 23/3/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var releaseDateLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var posterImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        configure(with: .none)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with movie: Movie?) {
        if let movie = movie {
            titleLabel?.text = movie.title
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            if let releaseDate = movie.releaseDate{
                releaseDateLabel.text = dateFormatter.string(from: releaseDate)
            }
            overviewLabel.text = movie.overview
            overviewLabel.sizeToFit()
            self.posterImageView.image = nil
            
            DispatchQueue.global().async {
                if let imageString = movie.imageString{
                    var imageData = try? Data(contentsOf: URL(string: ("https://image.tmdb.org/t/p/w154" + imageString))!)
                    DispatchQueue.main.async {
                        if imageData?.count != 0 && imageData != nil {
                            self.posterImageView.image = UIImage(data: imageData!)
                        }else{
                            self.posterImageView.image = UIImage(named: "imageNotFound")
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.posterImageView.image = UIImage(named: "imageNotFound")
                    }
                }
            }
        }
    }
}
