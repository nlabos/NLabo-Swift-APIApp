//
//  OkashiViewController.swift
//  NewsSweets
//
//  Created by 髙津悠樹 on 2022/09/25.
//

import UIKit
import SafariServices

class OkashiViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate {
    
    //JSONを取得する
    struct ItemJson: Codable {
        let name: String?
        let url: URL?
        let image: URL?
    }
    
    struct ResultJson: Codable {
        let item: [ItemJson]?
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        tableView.delegate = self
        
        SearchText.delegate = self
        SearchText.placeholder = "お菓子の名前を入力してください"

        // Do any additional setup after loading the view.
    }
    
    //UIの作成
    @IBOutlet weak var SearchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var okashiList: [(name: String, url: URL, image: URL)] = []
    
    
    //入力したテキストを取得する
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        view.endEditing(true)
        
        if let searchWord = searchBar.text {
            print(searchWord)
            SearchOkashi(keyword: searchWord)
        }
    }
    
    //リクエストURLの作成
    func SearchOkashi(keyword: String) {
        guard let  keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        guard let req_url = URL(string: "https://www.sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r") else {
            return
        }
        print(req_url)
        
        let req = URLRequest(url: req_url)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: req, completionHandler: {
            (data, response, error) in
            session.finishTasksAndInvalidate()
            
            do {
                let decoder = JSONDecoder()
                
                let json = try decoder.decode(ResultJson.self, from: data!)
                
                if let items = json.item{
                    self.okashiList.removeAll()
                    for item in items {
                        if let name = item.name, let url = item.url, let image = item.image {
                            let okashi = (name, url, image)
                            self.okashiList.append(okashi)
                        }
                    }
                    if let okashidbg = self.okashiList.first {
                        print("--------------------")
                        print("okashiList[0] = \(okashidbg)")
                        
                        self.tableView.reloadData()
                    }
                }
                
                print(json)
                
            }catch{
                print("エラーが出ました")
            }
        })
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return okashiList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
        cell.textLabel?.text = okashiList[indexPath.row].name
        
        //実行すると紫色のエラーが発生するけど問題ないです
        if let imageData = try? Data(contentsOf: okashiList[indexPath.row].image) {
            cell.imageView?.image = UIImage(data: imageData)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let safariViewController = SFSafariViewController(url: okashiList[indexPath.row].url)
        safariViewController.delegate = self
        present(safariViewController, animated: true, completion: nil)
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true, completion: nil)
    }

}
