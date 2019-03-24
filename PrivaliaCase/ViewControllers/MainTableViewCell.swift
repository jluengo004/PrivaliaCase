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
            releaseDateLabel.text = dateFormatter.string(from: movie.releaseDate)
            overviewLabel.text = movie.overview
            overviewLabel.sizeToFit()
            
            if let imageData = try? Data(contentsOf: URL(string: ("https://image.tmdb.org/t/p/w58_and_h87_face" + movie.imageString!))!){
                posterImageView.image = UIImage(data: imageData)
            }
//            posterImageView.sizeToFit()

//            indicatorView.stopAnimating()
        } else {
//            displayNameLabel.alpha = 0
//            reputationContainerView.alpha = 0
//            indicatorView.startAnimating()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
}
