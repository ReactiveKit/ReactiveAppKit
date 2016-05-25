//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Tony Arnold (@tonyarnold)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import ReactiveKit
import Cocoa

@objc class RKNSControlHelper: NSObject
{
  weak var control: NSControl?
  let pushStream = PushStream<AnyObject?>()
  
  init(control: NSControl) {
    self.control = control
    super.init()

    control.target = self
    control.action = #selector(eventHandler)
  }

  func eventHandler(sender: NSControl?) {
    pushStream.next(sender!.objectValue)
  }

  deinit {
    control?.target = nil
    control?.action = nil
    pushStream.completed()
  }
}

extension NSControl {

  private struct AssociatedKeys {
    static var ControlHelperKey = "r_ControlHelperKey"
  }

  public var rControlEvent: Stream<AnyObject?> {
    if let controlHelper: AnyObject = objc_getAssociatedObject(self, &AssociatedKeys.ControlHelperKey) {
      return (controlHelper as! RKNSControlHelper).pushStream.toStream()
    } else {
      let controlHelper = RKNSControlHelper(control: self)
      objc_setAssociatedObject(self, &AssociatedKeys.ControlHelperKey, controlHelper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return controlHelper.pushStream.toStream()
    }
  }
  
  public var rEnabled: Property<Bool> {
    return rAssociatedPropertyForValueForKey("enabled")
  }

  public var rObjectValue: Property<AnyObject?> {
    return rAssociatedPropertyForValueForKey("objectValue")
  }

  public var rStringleValue: Property<String> {
    return rAssociatedPropertyForValueForKey("stringValue")
  }

  public var rAttributedStringleValue: Property<NSAttributedString> {
    return rAssociatedPropertyForValueForKey("attributedStringValue")
  }

  public var rIntegerValue: Property<Int> {
    return rAssociatedPropertyForValueForKey("integerValue")
  }

  public var rFloatValue: Property<Float> {
    return rAssociatedPropertyForValueForKey("floatValue")
  }

  public var rDoubleValue: Property<Double> {
    return rAssociatedPropertyForValueForKey("doubleValue")
  }
}
