//
//  ViewController.swift
//  AssetView
//
//  Created by kevinhassan on 02/02/2020.
//  Copyright (c) 2020 kevinhassan. All rights reserved.
//

import AssetView
import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var assetView: AssetView!
    private lazy var image: AssetView.AssetType = {
        return .image(resource: URL(string: "https://picsum.photos/200/300")!,
                      tintColor: nil,
                      completion: nil)
    }()
    private lazy var gif: AssetView.AssetType = {
        return .gif(resource: URL(string: "https://storage.googleapis.com/chydlx/codepen/random-gif-generator/giphy-logo.gif")!,
                    completion: nil)
        
    }()
    
    private lazy var lottie: AssetView.AssetType = {
        return .lottie(resource: URL(string: "https://assets2.lottiefiles.com/packages/lf20_htEgHu.json")!,
                       loopMode: .loop,
                       closure: {[weak self] in
                        self?.assetView.play()
            },
                       completion: nil)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func imageTapped(_ sender: Any) {
        configureAsset(image)
    }
    @IBAction func gifTapped(_ sender: Any) {
        configureAsset(gif)
    }
    @IBAction func lottieTapped(_ sender: Any) {
        configureAsset(lottie)
    }
}

// MARK: - Configure Asset
fileprivate extension ViewController {
    func configureAsset(_ assetType: AssetView.AssetType) {
        assetView.configure(with: assetType, contentMode: .scaleToFill)
    }
}
