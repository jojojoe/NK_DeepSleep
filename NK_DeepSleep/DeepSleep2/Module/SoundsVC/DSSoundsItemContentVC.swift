//
//  DSSoundsItemContentVC.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/9.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//

import UIKit
import JXPagingView



class ItemColorManager: NSObject {
    static let color1 = UIColor.init(hexString: "#13A2A4") ?? UIColor.gray
    static let color2 = UIColor.init(hexString: "#4B51D7") ?? UIColor.gray
    static let color3 = UIColor.init(hexString: "#44B177") ?? UIColor.gray
    static let color4 = UIColor.init(hexString: "#BA56C7") ?? UIColor.gray
    static let color5 = UIColor.init(hexString: "#C7B756") ?? UIColor.gray

    
    static let colors: [UIColor] = [ItemColorManager.color1, ItemColorManager.color2, ItemColorManager.color3, ItemColorManager.color4, ItemColorManager.color5]
    static func randomeItemColor(itemIndex: Int) -> UIColor {
//        let index = arc4random() % UInt32(colors.count)
        let index = itemIndex % Int(colors.count)
        
        return colors[Int(index)]
    }
    
    static var deSelectedColor: UIColor = UIColor.init(hexString: "#231F32") ?? UIColor.gray
}


class DSSoundsItemContentVC: UIViewController {

    let collectionView: UICollectionView
    var listViewDidScrollCallback: ((UIScrollView) -> ())?
    
    var currentBundle: SoundBundle?
    var currentContentList: [MusicItem] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var didSelectContentItemBlock: ((MusicItem, UIImage?)->Void)?
    var didDeSelectContentItemBlock: ((MusicItem)->Void)?
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let itemMargin: CGFloat = 10
        let widthCount: CGFloat = 4
        let itemWidth = floor((UIScreen.main.bounds.size.width - itemMargin*(widthCount + 1))/widthCount)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumLineSpacing = 30
        layout.sectionInset = UIEdgeInsets.init(top: itemMargin, left: itemMargin, bottom: 40, right: itemMargin)
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        
        collectionView.alwaysBounceHorizontal = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DSSoundsItemContentVCCell.self, forCellWithReuseIdentifier: "DSSoundsItemContentVCCell")
        
        //列表的contentInsetAdjustmentBehavior失效，需要自己设置底部inset
        if #available(iOS 13, *) {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.additionalSafeAreaInsets.bottom, right: 0)
        } else {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIApplication.shared.keyWindow!.jx_layoutInsets().bottom, right: 0)
        }
        
        view.addSubview(collectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.frame = view.bounds
    }

    
  

}

extension DSSoundsItemContentVC {
    func updateCellStatus(itemList: [ContentPlayerItem] = DSMPPlayerManager.default.audioItemList) {
//        DSMPPlayerManager.default.audioItemList
        DispatchQueue.main.async {
            [weak self] in
            guard let `self` = self else {return}
            self.collectionView.reloadData()
        }
    }
}

 

extension DSSoundsItemContentVC: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentContentList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DSSoundsItemContentVCCell", for: indexPath) as! DSSoundsItemContentVCCell
        cell.contentView.backgroundColor = .clear
        let item = currentContentList[indexPath.item]
        
        cell.titleLabel.text = item.name?.replacingOccurrences(of: ".mp3", with: "")

        
        if let buildinName = DSBuildinManager.default.buildinResourceName(remoteName: item.icon_url)  {
            cell.iconImageView.image = UIImage.init(named: buildinName)
            
        } else {
            cell.iconImageView.url(item.icon_url)
        }
        
        
        
        cell.iconImageView.backgroundColor = .clear
        cell.bgColorView.backgroundColor = ItemColorManager.deSelectedColor
         
        //TODO: Bg Color Status
        let playingAudioItem = DSMPPlayerManager.default.audioItemList.first {
            $0.audioItem?.name == item.name
        }
        
        if let playingAudioItem_t = playingAudioItem {
            switch playingAudioItem_t.itemStatus {
            case .playing:
                cell.downloadCircularSlider.isHidden = true
                
                cell.bgColorView.backgroundColor = ItemColorManager.randomeItemColor(itemIndex: indexPath.item)
                
            case .pause:
                cell.downloadCircularSlider.isHidden = true
                cell.bgColorView.backgroundColor = ItemColorManager.randomeItemColor(itemIndex: indexPath.item).withAlphaComponent(0.3)
                
            default:
                break
            }
            if
               playingAudioItem_t.isDownloaingProgress == 0 || playingAudioItem_t.isDownloaingProgress >= 1 {
                cell.downloadCircularSlider.isHidden = true
//                playingAudioItem?.itemStatus = .playing
            } else {
                cell.downloadCircularSlider.isHidden = false
                cell.downloadCircularSlider.endPointValue = CGFloat(playingAudioItem_t.isDownloaingProgress)
            }
            
            debugPrint("*** playingAudioItem_t.isDownloaingProgress = \(CGFloat(playingAudioItem_t.isDownloaingProgress))")
            
            
        } else {
            cell.downloadCircularSlider.isHidden = true
        }
        
//        cell.downloadCircularSlider.isHidden = false
//        cell.downloadCircularSlider.endPointValue = 0.5
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.listViewDidScrollCallback?(scrollView)
    }
    
    func selectContentItem(indexPath: IndexPath) {
        var iconImage: UIImage?
        if let cell = collectionView.cellForItem(at: indexPath) as? DSSoundsItemContentVCCell {
            iconImage = cell.iconImageView.image
        }
        let contentItem = currentContentList[indexPath.item]
        didSelectContentItemBlock?(contentItem, iconImage)

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectContentItem(indexPath: indexPath)
        collectionView.reloadData()
         
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

    }
    
    
    
}

 
 

extension DSSoundsItemContentVC: JXPagingViewListViewDelegate {
    public func listView() -> UIView {
        return view
    }

    public func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.listViewDidScrollCallback = callback
    }

    public func listScrollView() -> UIScrollView {
        return self.collectionView
    }
}

class DSSoundsItemContentVCCell: UICollectionViewCell {
    lazy var titleLabel: UILabel = UILabel()
    lazy var topContentBgView: UIView = UIView()
    lazy var bgColorView: UIView = UIView()
    var downloadCircularSlider: CircularSlider = CircularSlider()
    lazy var iconImageView: UIImageView = UIImageView()
    var cellBgHilightColor: UIColor?
    var isSelectedStatus: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(topContentBgView)
        topContentBgView.addSubview(bgColorView)
        topContentBgView.addSubview(downloadCircularSlider)
        topContentBgView.addSubview(iconImageView)
        iconImageView.contentMode = .center
        iconImageView.backgroundColor = .clear
        titleLabel.numberOfLines = 2
        titleLabel.color(UIColor.white.withAlphaComponent(0.8)).font(12, .AvenirMedium).textAlignment(.center)
        titleLabel.font = UIFont.custom(11, name: .Quicksand_Regular)
        addSubview(titleLabel)
        
        setupDownloadCircularSlider()
        
        
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        let topPadding: CGFloat = 5
        let contentBgViewWidth: CGFloat = 50
        topContentBgView.frame = CGRect.init(x: (contentView.bounds.width - contentBgViewWidth) / 2, y: topPadding, width: contentBgViewWidth, height: contentBgViewWidth)
        titleLabel.frame = CGRect.init(x: 0, y: topContentBgView.frame.maxY + 4, width: contentView.bounds.width, height: 34)
        
        bgColorView.frame = topContentBgView.bounds
//        downloadCircularSlider.frame = topContentBgView.bounds
        downloadCircularSlider.frame = topContentBgView.bounds.inset(by: UIEdgeInsets.init(top: -2, left: -2, bottom: -2, right: -2))
        iconImageView.contentMode = .scaleAspectFit
        let iconWidth: CGFloat = 20
        iconImageView.frame = CGRect.init(x: (topContentBgView.width - iconWidth) / 2, y: (topContentBgView.height - iconWidth) / 2, width: iconWidth, height: iconWidth)
        
        self.topContentBgView.layer.masksToBounds = true
        self.topContentBgView.layer.cornerRadius = topContentBgView.bounds.width / 2
        
    }
     
}

extension DSSoundsItemContentVCCell {
    func setupDownloadCircularSlider() {
          
        downloadCircularSlider.isHidden = true
        
        downloadCircularSlider.backgroundColor = .clear
        downloadCircularSlider.thumbRadius = 2
        downloadCircularSlider.backtrackLineWidth = 0
        downloadCircularSlider.lineWidth = 2
        downloadCircularSlider.trackFillColor = .white
        downloadCircularSlider.trackColor = UIColor.white.withAlphaComponent(0.3)
        downloadCircularSlider.numberOfRounds = 1
        downloadCircularSlider.minimumValue = 0
        downloadCircularSlider.maximumValue = 1
        downloadCircularSlider.stopThumbAtMinMax = true
        downloadCircularSlider.diskFillColor = .clear
        downloadCircularSlider.diskColor = .clear
        downloadCircularSlider.endPointValue = 0
        downloadCircularSlider.thumbLineWidth = 2
        downloadCircularSlider.endThumbTintColor = .white
        downloadCircularSlider.endThumbStrokeColor = .clear
        
        
    }
}

extension DSSoundsItemContentVCCell {
    func setupBgColor(color: UIColor) {
        bgColorView.backgroundColor = color
    }
    
    func updateDownloadCircular(value: CGFloat) {
        downloadCircularSlider.endPointValue = value
        
        if value == 1 {
            downloadCircularSlider.isHidden = true
        } else {
            downloadCircularSlider.isHidden = false
        }
    }
    
  
}





