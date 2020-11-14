//
//  ViewController.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 04/11/2020.
//

import UIKit
import RxSwift

class AudioRecordViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet private weak var bottomVw: UIView!
    @IBOutlet private weak var popupContainerVw: UIView!
    @IBOutlet private weak var popupInternalVw: UIView!
    @IBOutlet private weak var refreshVw: UIView!
    @IBOutlet private weak var deleteVw: UIView!
    @IBOutlet private weak var btnDeleteFile: UIButton!
    @IBOutlet private weak var btnRecord: UIButton!
    @IBOutlet private weak var btnPlay: UIButton!
    @IBOutlet private weak var btnMemorize: UIButton!
    @IBOutlet private weak var btnShare: UIButton!
    @IBOutlet private weak var btnAgain: UIButton!
    @IBOutlet private weak var btnRecordAgain: UIButton!
    @IBOutlet private weak var btnCancel: UIButton!
    @IBOutlet private weak var btnClosePopup: UIButton!
    @IBOutlet private weak var btnCancelPopup: UIButton!
    @IBOutlet private weak var lblRecording: UILabel!
    
    //MARK: variables
    private let disposeBag = DisposeBag()
    let viewModel = AudioRecordViewModel()
    
    //MARK: UIViewController life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        decorateUI()
        initialSetup()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        refreshVw.setCustomCornerRadius(corners: [.topLeft,.topRight], radius: 12.0)
        deleteVw.setCustomCornerRadius(corners: [.bottomLeft,.bottomRight], radius: 12.0)
        
    }
    
    //MARK: Setup UI
    private func decorateUI() {
        
        lblRecording.text = ""
        bottomVw.setCornerRadius(radius: 10.0);
        bottomVw.setShadow(shadowColor: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.19), shadowOpacity: 1.0, shadowRadius: 3, offset: .zero)
        bottomVw.isHidden = true
        btnPlay.isHidden = true;
        
        // Popup container
        popupContainerVw.frame = self.view.frame
        
    }
    
    //MARK: Initial setup
    private func initialSetup() {
        
        bindButtons()
        configureBindings()
        setupBindings()
    }
    
    // MARK: Bind to  buttons
    func bindButtons() {
        
        btnCancel.rx.tap.bind{ [weak self] in
            self?.bottomVw.isHidden = true
        }.disposed(by: disposeBag)
        
        btnAgain.rx.tap.bind{ [weak self] in
            self?.bottomVw.isHidden = true
        }.disposed(by: disposeBag)

        btnClosePopup.rx.tap.bind { [weak self] in
            self?.removePupupContainer()
        }.disposed(by: disposeBag)
        
        btnCancelPopup.rx.tap.bind { [weak self] in
            self?.removePupupContainer()
        }.disposed(by: disposeBag)
        
        //MARK: Sharing
        btnShare.rx.tap.bind { [weak self] in
            
            self?.shareAudioFile(viewModel: self!.viewModel)
            
        }.disposed(by: disposeBag)
    }
    
    //MARK: Bindings
    func configureBindings() {
        
        // Recording
        viewModel.isRecording.asDriver().drive(onNext: { [weak self] isRecording in
            guard let self = self else { return }
            
            UIView.transition(with: self.btnRecord, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                
                let url = self.viewModel.isFileExists.value
                
                if(url == "") {
                    self.bottomVw.isHidden = true
                    self.btnPlay.isHidden  = true
                }
                else {
                    self.bottomVw.isHidden = false
                    self.btnPlay.isHidden  = false
                }
                if isRecording {
                    self.lblRecording.text = "Recording ..."
                    self.btnRecord.setImage(UIImage(imageLiteralResourceName: "barRecordPlaying"), for: .normal)
                } else {
                    
                    self.lblRecording.text = ""
                    self.btnRecord.setImage(UIImage(imageLiteralResourceName: "barRecord"), for: .normal)
                }
                
    
            })
        }).disposed(by: disposeBag)
        
        // Play
        viewModel.isPlaying.asDriver().drive(onNext: { [weak self] isPlaying in
            
            if isPlaying {
                
                self?.lblRecording.text = "Playing ..."
            }
            else {
                self?.lblRecording.text = ""
            }
        }).disposed(by: disposeBag)
    }
    

    
    private func setupBindings() {
        
        // Memorize button
        btnMemorize.rx.tap.bind { [weak self] in
            self?.viewModel.isRecording.asDriver().drive(onNext: { [weak self] isRecording in
                if !isRecording {
                    self?.addPupupContainerVw()
                }
            }).dispose()
            
        }.disposed(by: disposeBag)
        
       
        // Play button
        btnPlay.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).bind { _ in
            
            self.viewModel.startPlaying()
            
        }.disposed(by: disposeBag)
        
        // Record buttons
        btnRecord.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).bind { [self] _ in
            self.viewModel.toggleRecord()
        }.disposed(by: disposeBag)
        
        btnAgain.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).bind { [self] _ in
            viewModel.toggleRecord()
        }.disposed(by: disposeBag)
        
        btnRecordAgain.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).bind { [self] in
            
            self.removePupupContainer()
            self.bottomVw.isHidden = true
            viewModel.toggleRecord()
            
        }.disposed(by: disposeBag)
        
        
        // Delet button
        btnDeleteFile.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).bind { [self] in
            
            viewModel.deleteAudioFile()
            self.removePupupContainer()
            self.btnPlay.isHidden = true;
            self.bottomVw.isHidden = true
            
        }.disposed(by: disposeBag)
        
    }

    //MARK: Add container on memorized
    private func addPupupContainerVw() {
        
        self.view.addSubview(popupContainerVw)
        popupContainerVw.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
            self.popupContainerVw.transform = CGAffineTransform.identity
        } completion: { (Bool) in
            // do something once the animation finishes, put it here
        }
    }
    
    //MARK: Remove container
    private func removePupupContainer() {
        popupContainerVw.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
            self.popupContainerVw.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
        } completion: { (Bool) in
            self.popupContainerVw.removeFromSuperview()
        }
        
    }
    
    //MARK: share file
    private func shareAudioFile(viewModel: AudioRecordViewModel) {
        
        viewModel.shareFile(viewcontroller: self)
    }
    
}

