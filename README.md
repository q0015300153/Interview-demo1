# 使用一個 Dockerfile 建立 LNMP 的 Laravel 開發測試環境

* .env 為設定檔
* run.bat 為建立與啟動
* run.bat stop 簡寫 s 為停止與移除
* run.bat exec 簡寫 e 可於容器內執行 linux 命令
* run.bat dev-laravel 簡寫 d 可新增或 git clone laravel 專案，然後開啟 npm watch 以供開發
* run.bat laravel 簡寫 l 可執行 laravel 專案底下命令 Ex. php artsion 或 composer 或 webpack

目前適用於 windows bat 腳本
未來待開發 linux shell 腳本

* push2GCP.bat 可將編譯好的 docker 容器 push 到 GCP - container registry (使用 json.key)
* 然後透過 Cloud Run 執行網站