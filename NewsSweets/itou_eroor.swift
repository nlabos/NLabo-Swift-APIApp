//
//  itou_erorr.swift
//  NewsSweets
//
//  Created by 髙津悠樹 on 2022/10/06.
//

import UIKit
import SafariServices

class testViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //SearchBarのdelegata通知先を設定
        searchBar.delegate = self
        //入力のヒントになるよう、プレースホルダーを設定
        searchBar.placeholder = "お菓子を検索"
        tableView.dataSource = self
        tableView.delegate = self
    }
    struct ItemJson: Codable {
        let name : String?
        let url: URL?
        let image: URL?
    }
    
    struct ResultJson: Codable {
        let item: [ItemJson]?
    }
    
    
    //お菓子を検索
    func searchSnack(keyword : String) {
        //お菓子の検索コードをURLエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        //リクエストのURLの組み立て
        guard let req_url = URL(string: "https://www.sysbird.jp/toriko/api/?apikey=guest&format=json&keywood=\(keyword_encode)&max=10&order=r")
                //
        else {
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
                    for item in items{
                        if let name = item.name, let url = item.url, let image = item.image{
                            let okashi = (name,url,image)
                            self.okashiList.append(okashi)
                        }
                    }
                    if let okashidbg = self.okashiList.first{
                        print("---------")
                        print("okashiList[0] = \(okashidbg)")
                        self.tableView.reloadData()
                    }
                }
            } catch {
                print("エラーが出ました")
            }
            
        })
        task.resume()
        
    }
    var okashiList: [(name:String, url:URL,image:URL)] = []
    //検索ボタンをクリックした時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる
        view.endEditing(true)
        
        if let searchWord = searchBar.text {
            
            //デバックエリアに出力
            print(searchWord)
            //入力されていたらお菓子を検索
            searchSnack(keyword: searchWord)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return okashiList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
        cell.textLabel?.text = okashiList[indexPath.row].name
        if let imageData = try? Data(contentsOf: okashiList[indexPath.row].image){
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


