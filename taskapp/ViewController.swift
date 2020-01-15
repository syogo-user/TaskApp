//
//  ViewController.swift
//  taskapp
//
//  Created by 小野寺祥吾 on 2020/01/03.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import IBAnimatable

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {

    
    @IBOutlet weak var tableView:UITableView!
    //Realmインスタンスを取得する
    let realm = try! Realm()
    //検索バーのインスタンスを取得する
    let searchBar: UISearchBar = UISearchBar()

    
    //DB内のタスクが格納されるリスト。
    //日付の近い順でソート：昇順
    //以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date",ascending:true)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self

        
        searchBar.placeholder = "検索するカテゴリを入力してください"
        searchBar.layer.shadowOpacity = 0.2
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self

    }
    
    //検索バーで文字編集中（文字をクリアしたときも実行される）
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)  {
        if searchText != "" {
            let predicate = NSPredicate(format:"category == %@",searchText)
            taskArray = realm.objects(Task.self).filter(predicate)
        } else{
            taskArray = realm.objects(Task.self)
        }

        tableView.reloadData()
    }
    
    //検索ボタンがタップされた時に実行される
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(searchBar.text!)
        let predicate = NSPredicate(format:"category == %@",searchBar.text!)
        taskArray = realm.objects(Task.self).filter(predicate)
        //キーボード閉じる
        searchBar.endEditing(true)
        
        //リロード
        tableView.reloadData()
        
    }
    //セルの高さを返すメソッド
    func tableView(_ table: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  60
    }

    
    //データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView , numberOfRowsInSection section:Int ) -> Int{
        return taskArray.count
    }
    
    //各セルの内容を返すメソッド
    func tableView(_ tableView : UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AnimatableTableViewCell
        //Cell に値を設定する
        let task = taskArray[indexPath.row]
        //cell.textLabel?.text = task.title
        cell.title.text = task.title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString: String = formatter.string(from: task.date)
        //cell.detailTextLabel?.text = dateString
        cell.subtitle.text = dateString
        cell.category.text = task.category
        return cell
    }
    
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath ){
        //InputViewControllerに画面遷移
        performSegue(withIdentifier:"cellSegue",sender:nil)
    }
    //セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView:UITableView,commit editingStyle:UITableViewCell.EditingStyle,forRowAt indexPath:IndexPath){
        if editingStyle == .delete {
            //削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除する
            try! realm.write{
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at:[indexPath],with:.fade)
            }
            
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests{
                (requests:[UNNotificationRequest]) in
                for request in requests {
                    print("/-------------------")
                    print(request)
                    print("-------------------/")
                }
            }
        }
    }
    
    
    //segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue,sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        if segue.identifier == "cellSegue"{
            //セルの選択で呼ばれる時
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]

        }else{
            //+ボタンで呼ばれる時
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty:"id")! + 1
            }
            inputViewController.task = task
        }
    }
    
    //入力画面から戻ってきた時にTalbViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

