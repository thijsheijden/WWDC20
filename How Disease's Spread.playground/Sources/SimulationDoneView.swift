//
//  SimulationDoneView.swift
//  WWDC Testing
//
//  Created by Thijs van der Heijden on 13/05/2020.
//  Copyright © 2020 Thijs van der Heijden. All rights reserved.
//

import UIKit

public enum mode {
    case socialDistancing
    case herdImmunity
}

public protocol SimulationDoneDelegate {
    func rerunSimulationPressed()
    func closePressed()
}

public class SimulationDoneView: UIView {
    
    // MARK: UIViews
    var successLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    var explanationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    var rerunSimulationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Run Again", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.00)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(rerunTapped), for: .touchUpInside)
        return button
    }()
    
    var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.00)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: Variables and constants
    var simulationMode: mode!
    var peak: Int!
    var immunity: CGFloat?
    var beforeTimeUp: Bool!
    
    public var delegate: SimulationDoneDelegate?
    
    
    public convenience init(simulationMode: mode, peak: Int, immunity: CGFloat?, beforeTimeUp: Bool = false) {
        self.init()
        self.simulationMode = simulationMode
        self.peak = peak
        self.beforeTimeUp = beforeTimeUp
        
        if immunity != nil {
            self.immunity = immunity
        }
        
        backgroundColor = .white
        
        layer.cornerRadius = 15
        
        setupView()
    }
    
    public override func layoutSubviews() {
        // MARK: All constraints
        NSLayoutConstraint.activate([
            successLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            successLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            successLabel.widthAnchor.constraint(equalTo: widthAnchor)
        ])

        NSLayoutConstraint.activate([
            explanationLabel.topAnchor.constraint(equalTo: successLabel.bottomAnchor, constant: 16),
            explanationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            explanationLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75)
        ])
        
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            buttonStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75)
        ])

        NSLayoutConstraint.activate([
            rerunSimulationButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func setupView() {
        
        // Add all the subviews
        addSubview(successLabel)
        successLabel.font = UIFont.boldSystemFont(ofSize: 40)
        
        addSubview(explanationLabel)
        
        addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(rerunSimulationButton)
        buttonStackView.addArrangedSubview(closeButton)
        
        // Setup all the subviews
        if beforeTimeUp {
            if simulationMode == .socialDistancing {
                if peak <= 60 {
                    successLabel.text = "Success!"
                    explanationLabel.attributedText = NSMutableAttributedString()
                    .normal("You got the peak down to", 16)
                    .bold(" \(String(describing: peak!)), ", 16)
                    .normal("nice job! Now the hospitals could help everyone!", 16)
                } else {
                    successLabel.text = "Uh-Oh!"
                    explanationLabel.attributedText = NSMutableAttributedString()
                    .normal("You got the peak down to", 16)
                    .bold(" \(String(describing: peak!)), ", 16)
                    .normal("however, this was still too much for the hospitals. Try lowering the number of contacts.", 16)
                }
            } else {
                if peak <= 60 && immunity! >= 50.0 {
                    successLabel.text = "Success!"
                    explanationLabel.attributedText = NSMutableAttributedString()
                    .normal("You got the peak down to", 16)
                    .bold(" \(String(describing: peak!)), ", 16)
                    .normal("and", 16)
                        .bold(" \(String(describing: immunity!))", 16)
                    .normal("% of the population has immunity, enough for basic herd immunity! Good job!", 16)
                } else {
                    successLabel.text = "Uh-Oh!"
                    explanationLabel.attributedText = NSMutableAttributedString()
                        .normal(peak > 60 ? "The peak was too high for the hospitals at" : "Nice, you got the peak down to", 16)
                    .bold(" \(String(describing: peak!)).\n\n", 16)
                       .bold(" \(String(describing: immunity!))", 16)
                        .normal(immunity! < 50.0 ? "% of the population has immunity, try getting that number higher. This could also be because the simulation ended permaturely. Perhaps try running the simulation again." : "% of the population has immunity, nice job!", 16)
                }
            }
            // The simulation did end prematurely, rerun simulation?
        } else if simulationMode == .socialDistancing && !beforeTimeUp {
            // Make sure the peak was under 60
            if peak <= 60 {
                successLabel.text = "Success!"
                explanationLabel.attributedText = NSMutableAttributedString()
                .normal("You got the peak down to", 16)
                .bold(" \(String(describing: peak!)), ", 16)
                .normal("nice job! Now the hospitals could help everyone!", 16)
            } else {
                successLabel.text = "Uh-Oh!"
                explanationLabel.attributedText = NSMutableAttributedString()
                .normal("You got the peak down to", 16)
                .bold(" \(String(describing: peak!)), ", 16)
                .normal("however, this was still too much for the hospitals. Try lowering the number of contacts.", 16)
            }
        } else if !beforeTimeUp {
            if peak <= 60 && immunity! >= 50.0 {
                successLabel.text = "Success!"
                explanationLabel.attributedText = NSMutableAttributedString()
                .normal("You got the peak down to", 16)
                .bold(" \(String(describing: peak!)), ", 16)
                .normal("and", 16)
                    .bold(" \(String(describing: immunity!))", 16)
                .normal("% of the population has immunity, enough for basic herd immunity! Good job!", 16)
            } else {
                successLabel.text = "Uh-Oh!"
                explanationLabel.attributedText = NSMutableAttributedString()
                .normal("You got the peak down to", 16)
                .bold(" \(String(describing: peak!)), ", 16)
                .normal("and", 16)
                   .bold(" \(String(describing: immunity!))", 16)
                .normal("% of the population has immunity, however, it was not enough!\n\nTry tweaking the number of contacts.", 16)
            }
        }
    }
    
    @objc func closeTapped() {
        delegate?.closePressed()
    }
    
    @objc func rerunTapped() {
        delegate?.rerunSimulationPressed()
    }
}
