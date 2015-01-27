//
//  ViewController.swift
//  weather_swift
//
//  Created by wangxiaoliang on 15-1-26.
//  Copyright (c) 2015年 wangxiaoliang. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request(.GET, "", parameters: <#[String : AnyObject]?#>, encoding: <#ParameterEncoding#>)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

