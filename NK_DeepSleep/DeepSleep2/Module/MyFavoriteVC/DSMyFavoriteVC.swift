//
//  DSMyFavoriteVC.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/13.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import FlexLayout
import RxSwift
import RxCocoa
import RxDataSources
import JXPopupView
import Alertift


class DSMyFavoriteVC: UIViewController, UIGestureRecognizerDelegate {
    
    let maxLableCount: Int = 20
    
    var textF1 = UITextField()
    let disposeBag = DisposeBag()
    
    let closeBtn :UIButton = UIButton.init(type: .custom).image(UIImage.named("back_ic"), .normal)
    let topTitleLabel = UILabel.init(text: "My Favourite ").font(16, .Quicksand_Medium).color(UIColor.white)
    var colleciton = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let itemsRelay = BehaviorRelay<[DSFavoriteModel]>(value: [])
    
    let alertBgView = UIView().backgroundColor(.clear)
    let alertIconImageView = UIImageView().image("no_favourite_ic")
    let alertTitleLabel: UILabel = UILabel().text("No Favourite").color(UIColor.white.withAlphaComponent(0.5)).font(14, .Quicksand_Medium)
    
//    var settingConfigPopup: DSMyFavoriteSettingPopupView = DSMyFavoriteSettingPopupView()
    
    var currentFavoriteItem: DSFavoriteModel?
    
    var didSelectCurrentFavoriteItemBlock: ((DSFavoriteModel)->Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(hexString: "#171424")
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        setupView()
        setupData()
        setupTextViewNotification()

        
        view.flex.direction(.column).grow(1).define {
            $0.addItem().direction(.row).justifyContent(.spaceBetween).height(44).define {
                $0.addItem(closeBtn).paddingHorizontal(12).size(44)
                $0.addItem(topTitleLabel).marginHorizontal(12)
                $0.addItem().size(44)
            }
            $0.addItem(alertBgView).direction(.column).justifyContent(.center).alignItems(.center).grow(1).define {
                $0.addItem(alertIconImageView).width(44).height(44).marginBottom(20)
                $0.addItem(alertTitleLabel)
            }
            $0.addItem(colleciton).grow(1)
        }
        
        
    }
 
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension DSMyFavoriteVC {
    func setupView() {
        
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.itemSize = CGSize(width: UIScreen.width, height: 80)
//        colleciton = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
//        guard let colleciton = colleciton else { return }
        colleciton.backgroundColor = .clear
        colleciton.register(cellWithClass: MyFavoriteCell.self)
        if let layout = colleciton.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: UIScreen.width, height: 80)
            
        }
        
        view.flex.direction(.column).grow(1).define {
            $0.addItem().direction(.row).justifyContent(.spaceBetween).height(0).define {
                $0.addItem(closeBtn).paddingHorizontal(12).size(44)
                $0.addItem(topTitleLabel).marginHorizontal(12)
                $0.addItem().size(44)
            }
            $0.addItem(alertBgView).direction(.column).justifyContent(.center).alignItems(.center).grow(1).define {
                $0.addItem(alertIconImageView).width(44).height(44).marginBottom(20)
                $0.addItem(alertTitleLabel)
            }
            $0.addItem(colleciton).grow(1)
        }
        
    }
    
    @objc func closeBtnClick() {
        popVC()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.flex.padding(view.safeArea)
        view.flex.layout()
        
    }
    
    func updateUIStatus(isShowAlert: Bool) {
        alertBgView.flex.isDisplay = isShowAlert
        alertIconImageView.flex.isDisplay = isShowAlert
        alertTitleLabel.flex.isDisplay = isShowAlert
        colleciton.flex.isDisplay = !isShowAlert
        view.flex.layout()
    }
    
    func setupData() {
        
        DSDBHelper.default.loadAllFavorite { result in
            self.itemsRelay.accept(result)
            self.updateUIStatus(isShowAlert: result.count == 0)
            
        }
        
        itemsRelay
        .asObservable()
        .bind(to: colleciton.rx.items(cellIdentifier: "MyFavoriteCell", cellType: MyFavoriteCell.self)) { index, item, cell in
            //TODO: Cell for
            cell.favoriteItem = item
            cell.indexLabel.text = "\(index + 1)."
            
            cell.cellSettingClickBlock = {[weak self] favoriteItem in
                guard let `self` = self else {return}
                //TODO: click cell setting
                debugPrint("cell setting click")
                self.showSettingBottomSheetView(favoriteItem: favoriteItem)
            }
        }
        .disposed(by: disposeBag)
        
        colleciton.rx
            .modelSelected(DSFavoriteModel.self)
            .bind(onNext: {[weak self] item in
                //TODO: 点击事件
                guard let `self` = self else {return}
                self.popVC()
                self.didSelectCurrentFavoriteItemBlock?(item)
                debugPrint("cell selected \(item)")
            })
        
        
    }
    
    
}

extension DSMyFavoriteVC {
    func showSettingBottomSheetView(favoriteItem: DSFavoriteModel) {
        currentFavoriteItem = favoriteItem
        DispatchQueue.main.async {
            [weak self] in
            guard let `self` = self else {return}

            let settingVC = DSMyFavoriteSettingPopubVC()
            self.presentOnBottom(settingVC, inset: 10, corner: 20)
            
             
            settingVC.renameActionBlock = {
                [weak self] in
                guard let `self` = self else {return}
//                self.settingRenameAction()
                self.showRenameFavoriteInputNameAlert()
            }
            settingVC.deleteActionBlock = {
                [weak self] in
                guard let `self` = self else {return}
                self.settingDeleteAction()
            }
            
        }
    }
    
  
    
    func settingRenameAction(name: String) {
        guard let currentFavoriteItem = currentFavoriteItem else { return }
        DSDBHelper.default.rename(favoriteId: currentFavoriteItem.id, name: name)
        HUD.show()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) {
            [weak self] in
            guard let `self` = self else {return}
            HUD.hide()
            self.reloadFavoriteData()
        }
        
        HUD.success("Rename Success!")
    }
    func settingDeleteAction() {
        guard let currentFavoriteItem = currentFavoriteItem else { return }
        DSDBHelper.default.deleteFavoirte(currentFavoriteItem.id)
        reloadFavoriteData()
        HUD.success("Delete Success!")
    }
    
    func reloadFavoriteData() {
        
        DSDBHelper.default.loadAllFavorite { result in
            DispatchQueue.main.async {
                self.itemsRelay.accept(result)
                self.updateUIStatus(isShowAlert: result.count == 0)
            }
            
        }
    }
}

extension DSMyFavoriteVC {
    
//    showAddToFavoriteInputNameAlert
    func showRenameFavoriteInputNameAlert() {
//        var textF1 = UITextField()    //设置中间变量textF1
        let alertC = UIAlertController(title: "", message: "Please Input a name of the sounds", preferredStyle: UIAlertController.Style.alert)
        let alertA = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (act) -> Void in
//            debugPrint(textF1.text ?? "cancel")
        }
        let alertB = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {[weak self] (act) -> Void in
//            debugPrint(textF1.text ?? "ok")
            guard let `self` = self else {return}
            self.settingRenameAction(name: self.textF1.text ?? "name")
            
        }
        alertC.addTextField {[weak self] (textField1) -> Void in
            
            guard let `self` = self else {return}
            self.textF1 = textField1
            self.textF1.delegate = self
            self.textF1.placeholder = "Please input name"
        }
        alertC.addAction(alertA)
        alertC.addAction(alertB)
        self.present(alertC)
    }
    
    func showHasNoPlayingAudioItemAlert() {
        Alertift.alert(title: "No music", message: "Please add music").action(.cancel("Ok")).show()
    }
    
    func showAddToMyFavoriteSuccessAlert() {
        Alertift.alert(title: "Add Favorite Success", message: "").action(.cancel("Ok")).show()
    }
    
    
    func showDeleteFavoriteAlert() {
        Alertift.alert(title: "", message: "Are you sure delete this favorite sounds").action(.cancel("Cancel")).action(.default("Ok"), handler: {[weak self] in
            guard let `self` = self else {return}
            self.settingDeleteAction()
        }).show()
    }
    
}

class MyFavoriteCell: UICollectionViewCell {
     
    let nameLabel:UILabel = UILabel.init()
    let indexLabel:UILabel = UILabel.init()
    let settingBtn:UIButton = UIButton.init(type: .custom)
    let icon1: UIImageView = UIImageView()
    let icon2: UIImageView = UIImageView()
    let icon3: UIImageView = UIImageView()
    var iconImageViewList: [UIImageView] = []
    
    var favoriteItem: DSFavoriteModel? {
        didSet {
            setupCell()
        }
    }
    
    var cellSettingClickBlock: ((DSFavoriteModel)->Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        indexLabel.backgroundColor = .clear
        indexLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        indexLabel.textAlignment = .center
        //背景设为橙色
        self.backgroundColor = UIColor.init(hexString: "#171424")
        icon1.image = UIImage.named("cloud_ic")
        icon2.image = UIImage.named("cloud_ic")
        icon3.image = UIImage.named("cloud_ic")
        icon1.contentMode = .scaleAspectFit
        icon2.contentMode = .scaleAspectFit
        icon3.contentMode = .scaleAspectFit
        iconImageViewList = [icon1, icon2, icon3]
        indexLabel.text = "1."
        nameLabel.text = "Name1"
        nameLabel.font = UIFont.custom(14, name: .Quicksand_Regular)
        nameLabel.textColor = .white
        settingBtn.setImage(UIImage.named("more_icon_w"), for: .normal)
        settingBtn.backgroundColor = .clear
        settingBtn.addTarget(self, action: #selector(settingBtnClick), for: .touchUpInside)
        
        
        icon1.flex.isDisplay = false
        icon2.flex.isDisplay = false
        icon3.flex.isDisplay = false
        
        contentView.flex.direction(.row).alignItems(.center).define {
            $0.addItem(indexLabel).left(12).size(44)
            $0.addItem().direction(.column).grow(1).marginLeft(12).paddingLeft(0).paddingRight(10).justifyContent(.spaceBetween).define {
                $0.addItem(nameLabel).maxWidth(200).height(16)
                $0.addItem().direction(.row).paddingTop(8).justifyContent(.start).define {
                    $0.addItem(icon1).size(20)
                    $0.addItem(icon2).size(20).marginLeft(10)
                    $0.addItem(icon3).size(20).marginLeft(10)
                }
            }
            $0.addItem(settingBtn).size(40).paddingHorizontal(10)
        }
        
    }
     
    override func layoutSubviews() {
        super.layoutSubviews()
//        label.frame = bounds
        contentView.flex.layout()
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell() {
        guard let favoriteItem = favoriteItem else { return }
        
        nameLabel.text = favoriteItem.name
        guard let soundsList = favoriteItem.sounds else { return }
        
        
        
        
        for (index, sound) in soundsList.enumerated() {
            let imageView = iconImageViewList[index]
            
            
            if let buildinName = DSBuildinManager.default.buildinResourceName(remoteName: sound.icon)  {
                imageView.image = UIImage.init(named: buildinName)
            } else {
                imageView.url(sound.icon)
            }
            imageView.backgroundColor = .clear
            
//            imageView.flex.isDisplay = true
        }
        
        for index in 0...2 {
            if let _ = soundsList[safe: index] {
                let imageV = iconImageViewList[index]
                imageV.flex.isDisplay = true
            } else {
                let imageV = iconImageViewList[index]
                imageV.flex.isDisplay = false
            }
        }
        contentView.flex.layout()
        
    }
    
    
    @objc func settingBtnClick() {
        guard let favoriteItem = favoriteItem else { return }
        cellSettingClickBlock?(favoriteItem)
    }
    
}

extension DSMyFavoriteVC: UITextFieldDelegate {
    
    func setupTextViewNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(textViewNotifitionAction), name: UITextField.textDidChangeNotification, object: nil);
    }
    @objc
    func textViewNotifitionAction(userInfo:NSNotification){
        guard let textView = userInfo.object as? UITextView else { return }
        if textView.text.count >= maxLableCount {
            let selectRange = textView.markedTextRange
            if let selectRange = selectRange {
                let position =  textView.position(from: (selectRange.start), offset: 0)
                if (position != nil) {
                    // 高亮部分不进行截取，否则中文输入会把高亮区域的拼音强制截取为字母，等高亮取消后再计算字符总数并截取
                    return
                }
                
            }
            textView.text = String(textView.text[..<String.Index(encodedOffset: maxLableCount)])
            
            // 对于粘贴文字的case，粘贴结束后若超出字数限制，则让光标移动到末尾处
            textView.selectedRange = NSRange(location: textView.text.count, length: 0)
        }
        
        //        contentText = textView.text
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        debugPrint("textFieldDidBeginEditing")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let selectedRange = textField.markedTextRange
        if let selectedRange = selectedRange {
            let position =  textField.position(from: (selectedRange.start), offset: 0)
            if position != nil {
                let startOffset = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
                let endOffset = textField.offset(from: textField.beginningOfDocument, to: selectedRange.end)
                let offsetRange = NSMakeRange(startOffset, endOffset - startOffset) // 高亮部分起始位置
                if offsetRange.location < maxLableCount {
                    // 高亮部分先不进行字数统计
                    return true
                } else {
                    debugPrint("字数已达上限")
                    return false
                }
            }
        }
        
        // 在最末添加
        if range.location >= maxLableCount {
            debugPrint("字数已达上限")
            return false
        }
        
        // 在其他位置添加
        if textField.text?.count ?? 0 >= maxLableCount && range.length <  string.count {
            debugPrint("字数已达上限")
            return false
        }
        
        if (textField.text ?? "" + string).count > maxLableCount {
            
            let finalString = string.prefix(maxLableCount - (textField.text?.count ?? 0))
            textField.text = (textField.text ?? "" + finalString)
        }
        
        return true
    }
    
}










