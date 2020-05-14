/*:
 # Herd Immunity
 Herd immunity is when a large part of a population is immune to a disease, making it very hard for the disease to spread widely in the population.

* Callout(Task):
Tweak **alpha** (α) to make sure the hospitals don't go over capacity (60), but also try to have more than 50% of the population get the disease to obtain herd immunity.
*/

var α: Int = 10          // Number of daily contacts. Average is 24
var ρ: CGFloat = 0.01        // Probability of disease spread. For the flu this is 0.01
var I: Int = 3           // The number of initially infected people.
var t: Int = 100         // The length of the simulation (in days).

import UIKit
import PlaygroundSupport

// Present the view controller in the Live View window
let vc = HerdImmunityViewController()
vc.alpha = α
vc.rho = ρ
vc.I = I
vc._I = I
vc.t = t
vc._t = t
vc.preferredContentSize = CGSize(width: 500, height: 750)
PlaygroundPage.current.liveView = vc
vc.startSimulation()
