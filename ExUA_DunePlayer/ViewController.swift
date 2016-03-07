//
//  ViewController.swift
//  ExUA_DunePlayer
//
//  Created by atMamont on 05.03.16.
//  Copyright © 2016 Andrey Mamchenko. All rights reserved.
//

import UIKit
import WebKit

class NotificationScriptMessageHandler: NSObject, WKScriptMessageHandler {
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        print(message.body)
    }
}

class Favorite: NSObject, NSCoding {
    var url: NSURL?
    var title: String?
    
    required init(url: NSURL?, title: String?){
        self.url = url
        self.title = title
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let urlString = aDecoder.decodeObjectForKey("url") as? String
        let url = NSURL(string: urlString!)
        self.init(url: url, title: aDecoder.decodeObjectForKey("title") as? String)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(url?.absoluteString, forKey: "url")
        aCoder.encodeObject(title, forKey: "title")
    }
}

class Settings {
    
    static let sharedInstance = Settings()
    

    var baseURL: String = "http://www.ex.ua/ru/video"
    var duneIP: String = "192.168.0.101"
    var favorites = [Favorite]()
    
    init(){
        loadSettings()
    }

    func loadSettings(){
        let defaults = NSUserDefaults.standardUserDefaults()
        if let url = defaults.objectForKey("baseURL") as? String {
            baseURL = url
        }
        if let ip = defaults.objectForKey("duneIP") as? String{
            duneIP = ip
        }
//        if let fav = defaults.objectForKey("favorites") as? [Favorite] {
//            favorites = fav
//        }
        if let favs = defaults.objectForKey("favorites") as? NSData{
            favorites = (NSKeyedUnarchiver.unarchiveObjectWithData(favs) as? [Favorite])!
        }
        
        
    }
    
    func saveSettngs(){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(baseURL, forKey: "baseURL")
        defaults.setObject(duneIP, forKey: "duneIP")
        
        //        defaults.setObject(favorites, forKey: "favorites")
        let favs: NSData = NSKeyedArchiver.archivedDataWithRootObject(favorites)
        defaults.setObject(favs, forKey:"favorites")
       
    }
}

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var webView: WKWebView?
    
    @IBOutlet weak var mainView: UIView!
    
    override func loadView() {
        super.loadView()
        
        let scriptURL = NSBundle.mainBundle().pathForResource("dune", ofType: "js")
        guard let scriptContent = try? String(contentsOfFile: scriptURL!) else {return}
        
        let scriptContentFinal = scriptContent.stringByReplacingOccurrencesOfString("[DUNE_IP]", withString: Settings.sharedInstance.duneIP)
        
        let userScript = WKUserScript(source: scriptContentFinal, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        self.webView = WKWebView(frame: self.mainView.bounds, configuration: configuration)
        self.webView?.allowsBackForwardNavigationGestures = true
        self.mainView.addSubview(self.webView!)
        
        let handler = NotificationScriptMessageHandler()
        userContentController.addScriptMessageHandler(handler, name: "notification")  // writes to console
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadMainURL()
        
//        webView!.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
    }
    
    @IBAction func homeTapped(sender: UIBarButtonItem) {
        loadMainURL()
    }
    
    
    // MARK: - WebView
    
    // resetting webview to default URL (RU - Video)
    func loadMainURL(){
        if let url = NSURL(string:Settings.sharedInstance.baseURL){
            loadURL(url)
        }
    }

    func loadURL(url: NSURL){
        let req = NSURLRequest(URL:url)
        self.webView!.loadRequest(req)
    }
    
    /* Start the network activity indicator when the web view is loading */
    func webView(webView: WKWebView,didStartProvisionalNavigation navigation: WKNavigation){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    /* Stop the network activity indicator when the loading finishes */
    func webView(webView: WKWebView,didFinishNavigation navigation: WKNavigation){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse,
        decisionHandler: ((WKNavigationResponsePolicy) -> Void)) {
            print(navigationResponse.response.MIMEType)
            decisionHandler(.Allow)
    }

    // MARK: - Toolbar actions
    @IBAction func addFavPressed(sender: AnyObject){
        let url = webView!.URL!
        let title = webView!.title
        
        print("Added: "+url.absoluteString)
        let newFav = Favorite(url: url, title: title)
        Settings.sharedInstance.favorites.append(newFav)
        Settings.sharedInstance.saveSettngs()
    }
    
    // MARK: - Navigation
    @IBAction func unwindToMain(segue: UIStoryboardSegue){
        if let sourceVC = segue.sourceViewController as? FavoritesTableViewController {
            if let selected = sourceVC.selectedItem {
                loadURL(selected.url!)
            }
        }
    }
}

