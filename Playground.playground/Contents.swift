import UIKit
import FriendTabFramework
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let bundle = Bundle(for: MainViewController.self)
let storyboard = UIStoryboard(name: "Main", bundle: bundle)
let vc = storyboard.instantiateInitialViewController()!

PlaygroundPage.current.liveView = vc
