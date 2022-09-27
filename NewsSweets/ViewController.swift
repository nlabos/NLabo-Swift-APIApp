//
//  ViewController.swift
//  NewsSweets
//
// f7c46a254bc04e2f945d28ff807477af

import UIKit
import SafariServices

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate {
    
    //JSONのarticle内のデータ構造
    struct ArticleJson: Codable {
        //ニュースのタイトル
        let title: String?
        
        //掲載URL
        let url: URL?
        
        //著者の部分は終わったらコメントアウト
        //著者
        //let author: URL?
        
        //画像URL
        let urlToImage: URL?
    }
    
    //JSONのデータ構造
    struct ResultJson: Codable {
        //複数の記事を配列で管理する
        let articles: [ArticleJson]?
        
        //リクエストの成功件数(終わったらコメント)
        //let status: String?
        
        //取得したレスポンス(終わったらコメント)
        //let totalResults: Int?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //SearchBarのdelegate通知先を設定
        searchBar.delegate = self
        //入力のヒントになるプレースホルダーを設定する
        searchBar.placeholder = "知りたいニュースを検索"
        //tableviewのdatasourceを設定
        tableView.dataSource = self
        //tableViewのDelageteを設定
        tableView.delegate = self
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //ニュースのリスト
    var newsList: [(title: String, url: URL, urlToImage: URL)] = []
    
    //検索ボタンをクリックした時の処理
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる
        view.endEditing(true)
        
        if let searchword = searchBar.text {
            //デバッグエリアに表示
            print(searchword)
            
            //入力されていたらニュースを検索する
            searchNews(keyword: searchword)
        }
    }
    
    //ニュースを検索
    func searchNews(keyword: String){
        //ニュース検索のURLをエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        //リクエストURLの組み立て
        guard let req_url = URL(string: "https://newsapi.org/v2/everything?q=\(keyword_encode)&apikey=f7c46a254bc04e2f945d28ff807477af")
        else{
            return
        }
        print(req_url)
        
        //リクエストに必要な情報を生成する
        let req = URLRequest(url: req_url)
        
        //データ転送を管理するためのセッションを開始する
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        //リクエストをタスクとして登録する
        let task = session.dataTask(with: req, completionHandler: { (data, response, error) in
            //セッションを終了
            session.finishTasksAndInvalidate()
            
            //do try catch エラーハンドリング
            do {
                //JSONDecoderのインスタンスを取得する
                let decoder = JSONDecoder()
                
                //受け取ったJSONをパースする
                let json = try decoder.decode(ResultJson.self, from: data!)
                
                //ここは第3回でコメントアウト
                //print(json)
                
                //ニュースの情報が取得できているか確認
                if let articles = json.articles {
                    //ニュースのリストを初期化
                    self.newsList.removeAll()
                    //取得しているニュースの数だけ処理をする
                    for article in articles {
                        //ニュースのタイトル・詳細・掲載URL・画像URLをアンラップ
                        if let title  = article.title, let url = article.url, let urlToImage = article.urlToImage {
                            //一つのニュースをタプルでまとめて管理
                            let news = (title, url, urlToImage)
                            
                            //ニュースの配列への追加
                            self.newsList.append(news)
                        }
                    }
                    
                    //TableViewを更新する
                    self.tableView.reloadData()
                    
                    //デバッグ用
                    if let newsdbg = self.newsList.first {
                        print("----------------------")
                        print("newsList[0] = \(newsdbg)")
                    }
                }
                
            } catch {
                //エラー処理
                print("エラーが出ました")
            }
        })
        //ダウンロード開始
        task.resume()
        
    }
    //Cellの総数を返すdatasourceメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //ニュースリストの総数
        return newsList.count
    }
    //Cellに値を設定するdatasourceメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Cellオブジェクト(一行)を取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)
        
        //ニュースのタイトル設定
        cell.textLabel?.text = newsList[indexPath.row].title
        
        //テキストの折り返し
        cell.textLabel?.numberOfLines = 0
        
        //ニュースの画像を取得
        DispatchQueue.global().async {
            let image_url = self.newsList[indexPath.row].urlToImage
            if let imageData = try? Data(contentsOf: image_url) {
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    cell.imageView?.image = image
                    cell.setNeedsLayout()
                }
            }
            
        }
        //設定済みのCellオブジェクトを反映
        return cell
    }
    //セルの高さ上限
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //Cellが選択された時に呼び出されるdelegateメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //ハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        //SFSafariViewを開く
        let safariViewController = SFSafariViewController(url: newsList[indexPath.row].url)
        //delegateの通知先を自分自身にする
        safariViewController.delegate = self
        //safariViewを開く
        present(safariViewController, animated: true, completion: nil)
    }
    
    //safariViewが閉じられた時に呼ばれるdelageteメソッド
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        //safariviewを閉じる
        dismiss(animated: true, completion: nil)
    }
    
}

