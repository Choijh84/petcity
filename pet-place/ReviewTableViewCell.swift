//
//  ReviewTableViewCell.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 4..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import HCSStarRatingView

protocol ReviewTableViewCellProtocol: class {
    func actionTapped(tag: Int)
}

/// TableViewCell that displays all the reviews
class ReviewTableViewCell: UITableViewCell {

    /// 프로필 이미지뷰
    @IBOutlet weak var profileImageView: UIImageView!
    /// 이름 라벨
    @IBOutlet weak var nameLabel: UILabel!
    /// 리뷰 본문 선택하는 곳
    @IBOutlet weak var reviewTextLabel: UILabel!
    /// 날짜 라벨
    @IBOutlet weak var dateLabel: UILabel!
    /// 평점 보여주는 뷰
    @IBOutlet weak var ratingView: HCSStarRatingView!
    /// 사진 보여주는 뷰
    @IBOutlet weak var reviewImageView: UIImageView!
    
    /// 좋아요 개수 보여주는 라벨
    @IBOutlet weak var likeLabel: UILabel!
    
    /// 댓글 개수 보여주는 라벨
    @IBOutlet weak var commentLabel: UILabel!
    
    /// 라이크 버튼
    @IBOutlet weak var likeButton: UIButton!
    /// 댓글 보여주는 버튼
    @IBOutlet weak var commentButton: UIButton!
    /// 공유 버튼
    @IBOutlet weak var shareButton: UIButton!
    
    weak var delegate: ReviewTableViewCellProtocol?
    var row: Int?
    
    var likeNumbers: Int?
    
    /// Width constraint for the reviewImageView so it can be adjusted according to the review's image. If there isn't any, than we hide the imageView completely, by setting the constraint to be 0
    @IBOutlet weak var reviewImageViewWidthConstraint: NSLayoutConstraint!
    
    // 라이크 버튼 눌렀을 때
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        
        delegate?.actionTapped(tag: likeButton.tag)
        
        if sender.image(for: .normal) == #imageLiteral(resourceName: "like_bw") {
            UIView.transition(with: sender, duration: 0.5, options: .transitionCrossDissolve, animations: {
                sender.setImage(#imageLiteral(resourceName: "like_red"), for: .normal)
            }, completion: nil)
        } else {
            UIView.transition(with: sender, duration: 0.5, options: .transitionCrossDissolve, animations: {
                sender.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
            }, completion: nil)
        }
    }

    // 댓글 버튼 눌렀을 때
    @IBAction func commentButtonClicked(_ sender: Any) {
        
        delegate?.actionTapped(tag: commentButton.tag)
    }
    
    // 공유 버튼 눌렀을 때
    @IBAction func shareButtonClicked(_ sender: Any) {
        
        delegate?.actionTapped(tag: shareButton.tag)
    }
    

    /**
     Set the separator to be full width
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutMargins = UIEdgeInsets.zero
        separatorInset = UIEdgeInsets.zero
        
        // 뷰 세팅
        profileImageView.layer.cornerRadius = profileImageView.layer.frame.width/2
        reviewImageView.layer.cornerRadius = 5.0
        
        // 별점 0.5점도 가능하게
        ratingView.allowsHalfStars = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        reviewImageView.image = nil
        likeLabel.text = "좋아요"
        commentLabel.text = "댓글"
        likeButton.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
    }
    
    /**
     Sets the review's rating to the ratingView
     - parameter rating: the rating to display
     */
    func setRating(_ rating: NSNumber) {
        ratingView.value = CGFloat(rating.floatValue)
    }

    /**
     Hides the reviewImageView if the value is true. Setting the reviewImageViewWidthConstraint to be zero

     - parameter hidden: if true, it hides the reviewImageView
     */
    func setReviewImageViewHidden(_ hidden: Bool) {
        if hidden == true {
            reviewImageViewWidthConstraint.constant = 0
            layoutIfNeeded()
        } else {
            reviewImageViewWidthConstraint.constant = 75.0
            layoutIfNeeded()
        }
    }

    /**
    Set the separator to be full width as the layout size changes
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets.zero
    }
}
