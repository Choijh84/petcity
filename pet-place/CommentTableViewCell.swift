//
//  CommentTableViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 17..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView

protocol CommentTableViewCellProtocol: class {
    func actionTapped(row: Int)
}

class CommentTableViewCell: UITableViewCell {

    weak var delegate: CommentTableViewCellProtocol?
    var row: Int?
    
    // 리뷰인지 스토리인지 저장하는 변수
    var style: String = "story"
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    // 생략하자
    @IBOutlet weak var likeButton: UIButton!
    
    // 편집과 삭제 버튼은 본인의 스토리에만 노출되게
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func editComment(_ sender: Any) {
        // 해당되는 코멘트의 데이터를 가지고 수정할 수 있게 해야 하나?
    }
    
    @IBAction func deleteComment(_ sender: UIButton) {
        // 삭제할까요? 물어보고 그냥 바로 삭제 
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("삭제") { 
            print("This is deleteButton tag: \(self.deleteButton.tag)")
            self.delegate?.actionTapped(row: self.deleteButton.tag)
            
            // 스토리디테일뷰에 Notification 주기
            if self.style == "story" {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "StoryCommentDeleted"), object: nil)
            } else if self.style == "review" {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ReviewCommentDeleted"), object: nil)
            }
            
        }
        alertView.addButton("취소") { 
            print("취소되었습니다")
        }
        alertView.showNotice("댓글 삭제", subTitle: "지우시겠습니까?")
    }
    
    
    // 라이크버튼 눌렀을 때 - 생략하자, 현재 숨김 상태
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        // print("Like Button Clicked: \(likeButton.tag)")
        
        // 좋아하는 스토리인지 아닌지를 구분
        // 버튼의 이미지 변경 - 클릭하면 이미지 바뀌게
        // 좋아요를 눌렀을 때
        if sender.image(for: .normal) == #imageLiteral(resourceName: "like_bw") {
            UIView.transition(with: sender, duration: 0.5, options: .transitionCrossDissolve, animations: {
                sender.setImage(#imageLiteral(resourceName: "like_red"), for: .normal)
            }, completion: nil)
        } else {
            // 좋아요를 취소할 때
            UIView.transition(with: sender, duration: 0.5, options: .transitionCrossDissolve, animations: {
                sender.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
            }, completion: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImage.layer.cornerRadius = profileImage.layer.frame.width/2
    }

}
