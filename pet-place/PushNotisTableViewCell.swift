//
//  PushNotisTableViewCell.swiftimageLoadingHolder
//  pet-place
//
//  Created by Ken Choi on 2017. 5. 3..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class PushNotisTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var targetImageView: UIImageView!
    
    @IBOutlet weak var bodyText: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        profileImageView.layer.cornerRadius = profileImageView.layer.frame.width/2
        
        targetImageView.layer.cornerRadius = 3.0
    }

    /// 로딩 중에
    override func prepareForReuse() {
        profileImageView.image = #imageLiteral(resourceName: "imageLoadingHolder")
        targetImageView.image = #imageLiteral(resourceName: "imageLoadingHolder")
        bodyText.text = ""
        timeLabel.text = ""
    }
}
