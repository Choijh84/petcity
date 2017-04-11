//
//  PetProfileEditViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 27..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import Eureka
import SCLAlertView
import AlamofireImage

class PetProfileEditViewController: FormViewController {
    
    var selectedPetProfile: PetProfile!
    
    /// Initial Value of the species
    var petSpecies = "Dog"
    /// Array of Dog Breed List
    var dogBreed = [String]()
    /// Array of Cat Breed List
    var catBreed = [String]()
    /// value of all rows in the form
    var valueDictionary = [String: AnyObject]()
    
    
    @IBAction func petProfileSave(_ sender: Any) {
        
        // form에서 value 형성
        valueDictionary = form.values(includeHidden: false) as [String : AnyObject]
        dump(valueDictionary)
        /// 데이터 입력 여부 체크
        /// 필수 입력: 이름, 성별, 종, 품종 등
        if valueDictionary["species"] is NSNull || valueDictionary["name"] is NSNull || valueDictionary["breed"] is NSNull || valueDictionary["gender"] is NSNull {
            SCLAlertView().showError("입력 에러", subTitle: "필수 값을 입력해주세요")
        } else {
            /// To ask user to save or not
            /// close 버튼 숨기기
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("Yes") {
                /// setup pet profile
                self.updatePetProfile { (success) in
                    if success {
                        /// show alarm and dismiss
                        SCLAlertView().showSuccess("프로필 변경 완료", subTitle: "저장되었습니다")
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        /// show error
                        SCLAlertView().showError("에러 발생", subTitle: "다시 시도해주세요")
                    }
                }
            }
            alertView.addButton("No") {
                print("User says no")
                SCLAlertView().showInfo("취소", subTitle: "저장이 취소되었습니다")
            }
            alertView.showInfo("펫 프로필 저장", subTitle: "저장이 완료되면 알려드립니다")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("This is Pet Profile Edit Page: \(selectedPetProfile)")
        readPetBreedList()
        petSpecies = selectedPetProfile.species
        
        form =
            
            Section("필수 정보")
            //            {
            //                $0.header = HeaderFooterView<HeaderImageView>(.class)
            //            }
            
            <<< TextRow("name") {
                $0.title = NSLocalizedString("Pet name", comment: "")
                $0.add(rule: RuleRequired())
                $0.value = selectedPetProfile.name
                $0.validationOptions = .validatesOnChange
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            
            <<< SwitchRow("gender") {
                
                if selectedPetProfile.gender == "Male" {
                    $0.value = true
                    $0.title = NSLocalizedString("Male", comment: "")
                } else {
                    $0.value = false
                    $0.title = NSLocalizedString("Female", comment: "")
                }
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .onChange({ row in
                    if row.value == true {
                        row.cell.textLabel?.text = NSLocalizedString("Female", comment: "")
                    }
                    else {
                        row.cell.textLabel?.text = NSLocalizedString("Male", comment: "")
                    }
                })
            
            <<< ActionSheetRow<String>("species") {
                $0.title = NSLocalizedString("Species", comment: "")
                $0.selectorTitle = "Your Pet? "
                $0.options = ["강아지", "고양이", "기타"]
                $0.value = petSpecies
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.onChange({ (row) in
                    self.petSpecies = row.value!
                    print("This is pet species: \(self.petSpecies)")
                })
            
            <<< PushRow<String>("breed") {
                $0.title = NSLocalizedString("Breed", comment: "")
                $0.value = selectedPetProfile.breed
                if petSpecies == "강아지" {
                    $0.options = dogBreed
                } else if petSpecies == "고양이" {
                    $0.options = catBreed
                } else {
                    $0.options = dogBreed
                }
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.onCellSelection({ (cell, row) in
                    if self.petSpecies == "강아지" {
                        row.options = self.dogBreed
                    } else if self.petSpecies == "고양이" {
                        row.options = self.catBreed
                    } else {
                        row.options = self.dogBreed
                    }
                })
            
            
            +++ Section("추가 정보 1")
            
            <<< DecimalRow("weight") {
                $0.title = NSLocalizedString("Weight", comment: "")
                $0.value = selectedPetProfile.weight
                $0.formatter = DecimalFormatter()
                $0.useFormatterDuringInput = true
                //$0.useFormatterOnDidBeginEditing = true
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.cellSetup { cell, _  in
                    cell.textField.keyboardType = .numberPad
            }
            
            <<< CheckRow("neutralized") {
                $0.title = NSLocalizedString("Neutralized", comment: "")
                $0.value = selectedPetProfile.neutralized
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            
            <<< AccountRow("registration") {
                $0.title = NSLocalizedString("Registration", comment: "")
                $0.placeholder = selectedPetProfile.registration
            }
            
            <<< ImageRow("imagePic"){ row in
                row.title = NSLocalizedString("Pet Photo", comment: "")
                
                let imageUrl = selectedPetProfile.imagePic
                if imageUrl != "" {
                    let url = URL(string: imageUrl!)
                    let data = try? Data(contentsOf: url!)
                    let image = UIImage(data: data!)
                    
                    row.value = image
                }
                
            }
            
            <<< DateRow("birthday"){
                $0.title = NSLocalizedString("Birthday", comment: "")
                $0.value = selectedPetProfile.birthday
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .long
                $0.dateFormatter = formatter
            }
            
            +++ Section("추가 정보 2")
            
            <<< TextAreaRow() {
                print("백신: \(String(describing: selectedPetProfile.vaccination))")
                if selectedPetProfile.vaccination == nil {
                    $0.placeholder = "백신 접종 현황"
                } else {
                    $0.value = selectedPetProfile.vaccination
                }
                
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            }
            
            <<< TextAreaRow("sickHistory") {
                print("병력: \(String(describing: selectedPetProfile.sickHistory))")
                if selectedPetProfile.sickHistory == nil {
                    $0.placeholder = "병력"
                } else {
                    $0.value = selectedPetProfile.sickHistory
                }
                
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            }
    }
    
    /**
     Pet List Read - from the property list: PetBreedList.plist
     - current: dogBreed(강아지 종류 - alphabetically sort), catBreed(고양이 종류)
     */
    func readPetBreedList() {
        let pathList = Bundle.main.path(forResource: "PetBreedList", ofType: "plist")
        let data: NSData? = NSData(contentsOfFile: pathList!)
        let datasourceDictionary = try! PropertyListSerialization.propertyList(from: data! as Data, options: [], format: nil) as! [String:Any]
        
        var temps = datasourceDictionary["Dog"] as! [NSArray]
        
        for temp in temps {
            dogBreed.append(temp[0] as! String)
        }
        
        dogBreed = dogBreed.sorted()
        
        temps = datasourceDictionary["Cat"] as! [NSArray]
        
        for temp in temps {
            catBreed.append(temp[0] as! String)
        }
        catBreed = catBreed.sorted()
    }
    
    /**
     펫 프로필을 업데이트 시키는 함수
    */
    
    func updatePetProfile(completionHandler: @escaping (_ success: Bool) -> ()) {
        
        var name: String?
        
        if let species = valueDictionary["species"] as? String {
            selectedPetProfile.species = species
        }
        if let tempname = valueDictionary["name"] as? String {
            selectedPetProfile.name = tempname
            name = tempname
        }
        if let breed = valueDictionary["breed"] as? String {
            selectedPetProfile.breed = breed
        }
        if let vaccination = valueDictionary["vaccination"] as? String {
            selectedPetProfile.vaccination = vaccination
        }
        if let sickHistory = valueDictionary["sickHistory"] as? String {
            selectedPetProfile.sickHistory = sickHistory
        }
        if let neutralized = valueDictionary["neutralized"] as? Bool {
            print("This is neutralized: \(neutralized)")
            selectedPetProfile.neutralized = neutralized
        }
        if let gender = valueDictionary["gender"] as? Bool {
            if gender == true {
                selectedPetProfile.gender = "Male"
            } else {
                selectedPetProfile.gender = "Female"
            }
        }
        if let weight = valueDictionary["weight"] as? Double {
            selectedPetProfile.weight = weight
        }
        if let birthday = valueDictionary["birthday"] as? Date {
            selectedPetProfile.birthday = birthday
        }
        if let registration = valueDictionary["registration"] as? String {
            selectedPetProfile.registration = registration
        }
        if let image = valueDictionary["imagePic"] as? UIImage {
            uploadPhoto(image: image, name: name, completionHandler: { (success, fileUrl) in
                if success == true {
                    print("This is pet profile url: \(fileUrl)")
                    self.selectedPetProfile.imagePic = fileUrl
                 
                    self.uploadPetProfile(profile: self.selectedPetProfile, completionHandler: { (success) in
                        if success {
                            completionHandler(true)
                        } else {
                            completionHandler(false)
                        }
                    })
                } else {
                    print("Failure in upload")
                }
            })
        } else {
            self.uploadPetProfile(profile: selectedPetProfile, completionHandler: { (success) in
                if success {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            })
        }
    }
    
    func uploadPetProfile(profile: PetProfile, completionHandler: @escaping (_ success: Bool) -> ()) {
        
        let dataStore = Backendless.sharedInstance().data.of(PetProfile.ofClass())
        
        dataStore?.save(profile, response: { (response) in
            SCLAlertView().showSuccess("변경 완료", subTitle: "완료되었습니다")
            completionHandler(true)
        }, error: { (Fault) in
            print("Server reported an error on saving pet profile: \(Fault?.description)")
            completionHandler(false)
        })
    }
    
    /**
     Upload photo, compressImage를 활용해서 압축해서 저장할 예정임
     :param: image
     :param: name, 파일네임이 name+time 형태로 저장될 예정, 저장 루트: petProfileImages/
     */
    func uploadPhoto(image: UIImage!, name: String!, completionHandler: @escaping (_ success: Bool, _ url: String) -> ())   {
        
        let compressed = image.compressImage(image)
        
        let fileName = String(format: "\(name!)%0.0f.jpeg", Date().timeIntervalSince1970)
        let filePath = "petProfileImages/\(fileName)"
        print("This is filePath:\(filePath)")
        let content = UIImageJPEGRepresentation(compressed, 1.0)
        
        Backendless.sharedInstance().fileService.saveFile(filePath, content: content, response: { (uploadedFile) in
            let fileURL = uploadedFile?.fileURL
            print("This is fileURL:\(fileURL!)")
            completionHandler(true, fileURL!)
        }, error: { (fault) in
            print(fault?.description ?? "There is an error in uploading pet profile photo")
            completionHandler(false, (fault?.description)!)
        })
    }

}


