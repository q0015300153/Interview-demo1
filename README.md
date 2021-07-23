# 使用一個 Dockerfile 建立 LNMP 的 Laravel 開發測試環境

* .env 為設定檔
* run.bat 為建立與啟動
* stop.bat 為停止與移除
* exec.bat 可於容器內執行 linux 命令

目前適用於 windows bat 腳本
未來待開發 linux shell 腳本

* push2GCP.bat 可將編譯好的 docker 容器 push 到 GCP - container registry (使用 json.key)
* 然後透過 Cloud Run 執行網站