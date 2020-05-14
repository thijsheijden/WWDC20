//
//  DiseaseSpreadViewController.swift
//  WWDC Testing
//
//  Created by Thijs van der Heijden on 12/05/2020.
//  Copyright © 2020 Thijs van der Heijden. All rights reserved.
//

import UIKit
import PlaygroundSupport

public class DiseaseSpreadViewController: UIViewController {
    
    // MARK: UIViews
    var emojiView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var explanationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    // MARK: Variables and constants
    public var alpha: Int = 24
    public var rho: CGFloat = 0.01
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillLayoutSubviews() {
        setupView()
    }
    
    public override func viewDidLayoutSubviews() {
        setupEmojiView()
        setupLabel()
    }
    
    func setupView() {
        view.addSubview(emojiView)
        NSLayoutConstraint.activate([
            emojiView.heightAnchor.constraint(equalToConstant: view.bounds.height / 2),
            emojiView.widthAnchor.constraint(equalToConstant: view.bounds.width),
            emojiView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height / 8),
            emojiView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        view.addSubview(explanationLabel)
        NSLayoutConstraint.activate([
            explanationLabel.topAnchor.constraint(equalTo: emojiView.bottomAnchor, constant: 16),
            explanationLabel.widthAnchor.constraint(equalToConstant: view.bounds.width / 1.5),
            explanationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            explanationLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupEmojiView() {
        
        emojiView.subviews.forEach({ subview in
            subview.removeFromSuperview()
        })
        
        let center = CGPoint(x: view.bounds.midX - 25, y: emojiView.bounds.midY)
        let radius : CGFloat = emojiView.bounds.height / 2
                
        let centerEmoji = UILabel()
        centerEmoji.text = ["👩🏾","👱🏻‍♀️","👱🏼‍♂️","👨🏾"].randomElement()
        centerEmoji.textAlignment = .center
        centerEmoji.font = UIFont.systemFont(ofSize: view.bounds.width / 8)
        centerEmoji.sizeToFit()
        centerEmoji.center = CGPoint(x: center.x + 25, y: center.y)
        emojiView.addSubview(centerEmoji)
        
        var angle = CGFloat(2 * Double.pi)
        let step = CGFloat(2 * Double.pi) / CGFloat(alpha)

        let emojis: [String] = ["👨🏻","👨🏼","👨🏽","👨🏾","👨🏿","👱🏻‍♀️","👱🏾‍♀️","👩🏻","👩🏽","👩🏾"]

        // set objects around circle
        for _ in 0...alpha {
            let x = cos(angle) * radius + center.x
            let y = sin(angle) * radius + center.y

            let emoji = UILabel()
            emoji.text = emojis.randomElement()
            emoji.font = UIFont.systemFont(ofSize: view.bounds.width / (CGFloat(alpha) / 2) > 40 ? 40 : view.bounds.width / (CGFloat(alpha) / 2))
            emoji.center = CGPoint(x: x, y: y)
            emoji.textAlignment = .center
            emoji.sizeToFit()
            emojiView.addSubview(emoji)
            
            angle += step
        }
    }
    
    func setupLabel() {
        let total = CGFloat(round(100 * (CGFloat(alpha) * rho) * 4) / 100)
        explanationLabel.attributedText = NSMutableAttributedString()
            .bold("With these parameters, a single person could theoretically infect \(alpha) * \(rho) = \(total) people within four days, these people could then infect others, causing exponential growth...", 24)
    }
    
}
