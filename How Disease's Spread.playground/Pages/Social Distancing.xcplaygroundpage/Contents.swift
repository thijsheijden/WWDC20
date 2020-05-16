/*:
 # Social Distancing
 The more people someone comes into contact with, the more people they could potentially spread a disease to. By reducing the amount of people someone comes in contact with and increasing the distance between those people, disease spread can be reduced dramatically. This is called social distancing.
 
* Callout(Task):
Tweak **alpha** (α) and then execute the playground. The hospital maximum capacity is 60, you have to make sure the peak (number of people sick at the same time) is below the hospital maximum capacity.

 These are the definitions of the colors in the simulation:
![Color code for the simulation.](Guide.png)
 */
 
var α: Int = 24          // Number of daily contacts. Average is 24
var ρ: CGFloat = 0.01   // Probability of disease spread. For the flu this is 0.01
var I: Int = 3          // The number of initially infected people.
var t: Int = 100        // The length of the simulation (in days).

/*:
 After getting the peak under 60, let's continue to the [next page](@next) to learn about herd immunity!
 */

/*:
 - Note:
 If 50% of the population were to practice social distancing, alpha would go down to 12. Try it and see how effective social distancing is!
 */

import UIKit
import PlaygroundSupport

let vc = SimulationViewController()
vc.alpha = α
vc.rho = ρ
vc.I = I
vc._I = I
vc.t = t
vc._t = t
vc.preferredContentSize = CGSize(width: 500, height: 750)
PlaygroundPage.current.liveView = vc
vc.startSimulation()
