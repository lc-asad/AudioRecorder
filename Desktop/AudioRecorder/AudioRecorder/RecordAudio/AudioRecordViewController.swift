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
    var viewModel: AudioRecordViewModel? {
        didSet {
            if isViewLoaded {
                setupBindings()
            }
        }
    }
    
    //MARK: UIViewController life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        decorateUI()
        setupBindings()
        initialSetup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        refreshVw.roundCorners(corners: [.topLeft,.topRight], radius: 12.0)
        deleteVw.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 12.0)
        
    }
    
    //MARK: Setup UI
    private func decorateUI() {
        
        lblRecording.text = ""
        bottomVw.layer.cornerRadius = 10
        bottomVw.layer.shadowColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.19).cgColor
        bottomVw.layer.shadowOpacity = 1
        bottomVw.layer.shadowOffset = .zero
        bottomVw.layer.shadowRadius = 3
        bottomVw.isHidden = true
        btnPlay.isHidden = true;
        
        // Popup container
        popupContainerVw.frame = self.view.frame
        
    }
    
    //MARK: Initial setup
    private func initialSetup() {
        
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

    //MARK: Bindings
    private func setupBindings() {
        guard let viewModel = viewModel else { return }
        
        btnMemorize.rx.tap.bind { [weak self] in
            viewModel.isRecording.asDriver().drive(onNext: { [weak self] isRecording in
                if !isRecording {
                    self?.addPupupContainerVw()
                }
            }).dispose()
            
        }.disposed(by: disposeBag)
        
        toggleOnClick(viewModel: viewModel)
        
        //MARK: Recording
        recording(with: viewModel)
        
        //MARK: Playing
        playing(with: viewModel)
        
        //MARK: Sharing
        btnShare.rx.tap.bind { [weak self] in
            
            self?.shareAudioFile(viewModel: viewModel)
            
        }.disposed(by: disposeBag)
    }
    
    
    //MARK: Recording
    private func recording(with viewModel: AudioRecordViewModel) {
        
        viewModel.isRecording.asDriver().drive(onNext: { [weak self] isRecording in
            guard let self = self else { return }
            UIView.transition(with: self.btnRecord, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                
                let url = viewModel.isFileExists.value
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
    }
    
    //MARK: Playing
    private func playing(with viewModel: AudioRecordViewModel) {
        
        viewModel.isPlaying.asDriver().drive(onNext: { [weak self] isPlaying in
            
            if isPlaying {
                
                self?.lblRecording.text = "Playing ..."
            }
            else {
                self?.lblRecording.text = ""
            }
        }).disposed(by: disposeBag)
        
    }
    
    private func playAudioFileBinding() {
        
        btnPlay.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).bind { [weak viewModel] in
            viewModel?.startPlaying()
            if viewModel!.isPlaying.value {
                self.lblRecording.text = "Playing ..."
            }
            else{
                self.lblRecording.text = ""
            }
        }.disposed(by: disposeBag)
    }
    
    
    //MARK: event binding
    private func toggleOnClick(viewModel: AudioRecordViewModel) {
        recordVoiceBinding()
        playAudioFileBinding()
        deletFileBinding()
    }
    
    
    private func recordVoiceBinding() {
        
        btnRecord.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).bind { [weak viewModel] in
            viewModel?.toggleRecord()
        }.disposed(by: disposeBag)
        
        btnAgain.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).bind { [weak viewModel] in
            viewModel?.toggleRecord()
        }.disposed(by: disposeBag)
        
        btnRecordAgain.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).bind { [weak viewModel] in
            
            self.removePupupContainer()
            self.bottomVw.isHidden = true
            viewModel?.toggleRecord()
            
        }.disposed(by: disposeBag)
    }
    
    
    //MARK: Delete file
    private func deletFileBinding() {
        btnDeleteFile.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).bind { [weak viewModel] in
            
            self.removePupupContainer()
            viewModel?.deleteAudioFile()
            self.btnPlay.isHidden = true;
            self.bottomVw.isHidden = true
            
        }.disposed(by: disposeBag)
    }
    
    //MARK: share file
    private func shareAudioFile(viewModel: AudioRecordViewModel) {
        
        viewModel.sharePersistFile(viewcontroller: self)
    }
}

