//
//  TestViewController.swift
//  citizencloud
//
//  Created by kerapok on 2018/4/24.
//  Copyright © 2018年 linewell. All rights reserved.
//

import Foundation
import WebKit

class TestViewController : INNOBaseViewController {
    
    /// 下载session
    fileprivate lazy var session:URLSession = {
        //只执行一次
        let config = URLSessionConfiguration.default
        let currentSession = URLSession(configuration: config, delegate: self,
                                        delegateQueue: nil)
        return currentSession
        
    }()
    
    /// webview页面
    fileprivate lazy var wkView: WKWebView = {
        let configuration: WKWebViewConfiguration = WKWebViewConfiguration()
        //        configuration.userContentController.addUserScript(wkUserScript)
        let view = WKWebView(frame: CGRect.zero, configuration: configuration)
        view.isOpaque = false
        view.backgroundColor = UIColor.white
        view.scrollView.showsVerticalScrollIndicator = false
        view.scrollView.showsHorizontalScrollIndicator = false
        
        if #available(iOS 11.0, *) {
            view.scrollView.contentInsetAdjustmentBehavior = .automatic
        }
        view.scrollView.contentInset = UIEdgeInsets.zero
        view.scrollView.scrollIndicatorInsets = view.scrollView.contentInset
        
        return view
    }()
    
    lazy var label : UILabel = {
        let label = UILabel(frame: CGRect(x: 100, y: 200, width: 300, height: 100))
        label.textColor = RGBA(r: 20, g: 20, b: 20, a: 1)
        label.text = "下载进度0"
    
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initNavBar(delegate: self)
        
        sessionDowload()
        self.view.addSubview(label)
    }
    
    func sessionDowload(){
        //下载地址
        let url = URL(string: "http://file3.data.weipan.cn.wscdns.com/38098941/6ee04bede01dd41125cb1eb55bf60377db6f48cc?ip=1524561141,59.61.216.124&ssig=HE59c8mNd%2B&Expires=1524561741&KID=sae,l30zoo1wmz&fn=%5B%E7%88%B1%EF%BC%8C%E5%B0%B1%E6%B3%A8%E5%AE%9A%E4%BA%86%E4%B8%80%E7%94%9F%E7%9A%84%E6%BC%82%E6%B3%8A%5D.%E5%88%98%E5%A2%89.%E6%89%AB%E6%8F%8F%E7%89%88.pdf&skiprd=2&se_ip_debug=59.61.216.124&corp=2&from=1221134")
        //请求
        let request = URLRequest(url: url!)

        //下载任务
        let downloadTask = session.downloadTask(with: request)

        //使用resume方法启动任务
        downloadTask.resume()
        
    }
}

// MARK:- 代理
extension TestViewController : URLSessionDownloadDelegate {
    //下载代理方法，下载结束
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        //下载结束
        print("下载结束")
        
        //创建文件管理器
        let fileManager = FileManager.default
        
        //location位置转换
        let locationPath = location.path
        //拷贝到用户目录
        
        let home = NSHomeDirectory()
        var fountName = "2"
        var documnets:String = home + "/Documents/"+fountName+".pdf"
        
        /// 防止同名
        for i in 1...999 {
            
            /// 遍历到同名的继续循环
            if checkExist(path: documnets) {
                /// 重新命名
                fountName = "2(\(i))"
                documnets = home + "/Documents/"+fountName+".pdf"
                continue
            }else {         /// 没有循环的直接跳出循环
                break
            }
        }
        
        try! fileManager.moveItem(atPath: locationPath, toPath: documnets)
        print("new location:\(documnets)")
        DispatchQueue.main.async {
            self.label.text = "下载完成" // 重新加载某个cell
            
            let url = URL(fileURLWithPath: documnets)
            let require = URLRequest(url: url)
            self.wkView.load(require)
            self.view.addSubview(self.wkView)
            self.wkView.snp.makeConstraints({ (make) in
                make.edges.equalTo(0)
            })
            
        }
        
    }
    
    /// 检查文件目录下是否有存在相同名称的文件
    func checkExist(path:String)->Bool{
        //创建文件管理器
        let fileManager = FileManager.default
        
        return fileManager.fileExists(atPath: path)
    }
    
    //下载代理方法，监听下载进度
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        //获取进度
        let written:CGFloat = (CGFloat)(totalBytesWritten)
        let total:CGFloat = (CGFloat)(totalBytesExpectedToWrite)
        let pro:CGFloat = written/total
        
        DispatchQueue.main.async {
            self.label.text = "下载进度\(Int(pro*100))%" // 重新加载某个cell
        }
        
    }
}

// MARK:- 导航栏代理
extension TestViewController : INNONavigationControllerDelegate {
    
    /// 初始化导航栏
    ///
    /// - Parameter controller: <#controller description#>
    func initNavBar(_ controller: INNOBaseViewController) {
        self.navigationItem.title = "测试下载"
    }
}
