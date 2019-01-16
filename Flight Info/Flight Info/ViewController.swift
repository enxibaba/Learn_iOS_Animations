/*
* Copyright (c) 2014-present Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import QuartzCore

// A delay function
func delay(seconds: Double, completion: @escaping ()-> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

class ViewController: UIViewController {

  //在y轴变换时的方向
  enum AnimationDirection: Int {
    case positive = 1
    case negative = -1
  }
  
  @IBOutlet var bgImageView: UIImageView!
  
  @IBOutlet var summaryIcon: UIImageView!
  @IBOutlet var summary: UILabel!
  
  @IBOutlet var flightNr: UILabel!
  @IBOutlet var gateNr: UILabel!
  @IBOutlet var departingFrom: UILabel!
  @IBOutlet var arrivingTo: UILabel!
  @IBOutlet var planeImage: UIImageView!
  
  @IBOutlet var flightStatus: UILabel!
  @IBOutlet var statusBanner: UIImageView!
  
  var snowView: SnowView!
  
  //MARK: view controller methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //adjust ui
    summary.addSubview(summaryIcon)
    summaryIcon.center.y = summary.frame.size.height/2
    
    //add the snow effect layer
    snowView = SnowView(frame: CGRect(x: -150, y:-100, width: 300, height: 50))
    let snowClipView = UIView(frame: view.frame.offsetBy(dx: 0, dy: 50))
    snowClipView.clipsToBounds = true
    snowClipView.addSubview(snowView)
    view.addSubview(snowClipView)
    
    //start rotating the flights
    changeFlight(to: londonToParis)
  }
  
  //MARK: custom methods

  func changeFlight(to data: FlightData, animate: Bool = false) {
    
    // populate the UI with the next flight's data
    summary.text = data.summary


    if animate {
      fade(imageView: bgImageView, toImage: UIImage(named: data.weatherImageName)!, showEffects: data.showWeatherEffects)

      let direction: AnimationDirection = data.isTakingOff ? .positive : .negative
      cubeTransition(label: flightNr, text: data.flightNr, direction: direction)
      cubeTransition(label: gateNr, text: data.gateNr, direction: direction)

      // 启程地和目的地Label动画
      let offsetDeparting = CGPoint(x: CGFloat(direction.rawValue * 80), y: 0.0)
      moveLabel(label: departingFrom, text: data.departingFrom, offset: offsetDeparting)
      let offsetArriving = CGPoint(x: 0.0, y: CGFloat(direction.rawValue * 50))
      moveLabel(label: arrivingTo, text: data.arrivingTo, offset: offsetArriving)

      cubeTransition(label: flightStatus, text: data.flightStatus, direction: direction)

    } else {
      bgImageView.image = UIImage(named: data.weatherImageName)!
      snowView.isHidden = !data.showWeatherEffects

      flightNr.text = data.flightNr
      gateNr.text = data.gateNr
      departingFrom.text = data.departingFrom
      arrivingTo.text = data.arrivingTo
      flightStatus.text = data.flightStatus

    }
    
    // schedule next flight
    delay(seconds: 3.0) {
      self.changeFlight(to: data.isTakingOff ? parisToRome : londonToParis, animate: true)
    }
  }
  //Transition imageView
  func fade(imageView: UIImageView, toImage: UIImage, showEffects: Bool) {
    UIView.transition(with: imageView, duration: 1.0, options: .transitionCrossDissolve, animations: {
      imageView.image = toImage
    })

    UIView.animate(withDuration: 1.0, animations: {
      self.snowView.alpha = showEffects ? 1.0 : 0.0
    })
  }


  func cubeTransition(label: UILabel, text: String, direction: AnimationDirection) {
    //创建一个临时的辅助Label,把原来的Label属性复制给这个临时的Label,使用text的新值。
    let auxLabel = UILabel(frame: label.frame)
    auxLabel.text = text
    auxLabel.font = label.font
    auxLabel.textAlignment = label.textAlignment
    auxLabel.textColor = label.textColor
    auxLabel.backgroundColor = label.backgroundColor

    let auxLabelOffset = CGFloat(direction.rawValue) * label.frame.size.height/2.0
    auxLabel.transform = CGAffineTransform(translationX: 0.0, y: auxLabelOffset).scaledBy(x: 1.0, y: 0.1)
    label.superview?.addSubview(auxLabel)

    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {

      auxLabel.transform = .identity
      //原来的label在Y轴上反向转换
      label.transform = CGAffineTransform(translationX: 0.0, y: -auxLabelOffset).scaledBy(x: 1.0, y: 0.1)


    }, completion: { _ in
      //将辅助label的text赋值给label；恢复label的状态；把赋值label移除
      label.text = auxLabel.text
      label.transform = .identity
      auxLabel.removeFromSuperview()
    })


  }

  func moveLabel(label: UILabel, text: String, offset: CGPoint) {
    let auxLabel = UILabel(frame: label.frame)
    auxLabel.text = text
    auxLabel.font = label.font
    auxLabel.textAlignment = label.textAlignment
    auxLabel.textColor = label.textColor
    auxLabel.backgroundColor = label.backgroundColor

    auxLabel.transform = CGAffineTransform(translationX: offset.x, y: offset.y)
    auxLabel.alpha = 0.0
    label.superview?.addSubview(auxLabel)
    //为label添加偏移量转换，和透明度变换
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
      label.transform = CGAffineTransform(translationX: offset.x, y: offset.y)
      label.alpha = 0.0
    })

    //为辅助label添加动画，并在动画结束后删除
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
      auxLabel.transform = .identity
      auxLabel.alpha = 1.0
    }, completion: { _ in
      auxLabel.removeFromSuperview()
      label.text = text
      label.transform = .identity
      label.alpha = 1.0
    })
  }

}
