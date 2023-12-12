
# Dockerfile 簡介

此 Dockerfile 主要用於建立一個基於 Ubuntu 22.04 的容器，預裝 Apache、PHP 8.2 及相關的工具和擴展。

## 主要內容

### 基底映像檔

-   基於 **Ubuntu 22.04** 的官方映像檔。

### 環境設定

-   設定時區為 `Asia/Taipei`。
-   設定語系為繁體中文 (`zh_TW.UTF-8`)。

### 安裝軟體

-   使用 **Ondřej Surý** 的 PPA 倉庫安裝最新的 **Apache** 和 **PHP 8.2**。
-   安裝了多個 **PHP 8.2** 擴展，如 `php8.2-mysql`, `php8.2-gd`, `php8.2-curl` 等。
-   除此之外，也安裝了多種工具，例如 `curl`, `wget`, `git`, `vim` 等。

### 開放埠口

-   開放 **80** 號埠口以供 Apache 使用。

### 預設工作目錄

-   將工作目錄設定為 `/var/www/html`，這是 Apache 的預設網頁根目錄。

### 入口點 (ENTRYPOINT)

-   設定入口點為 `/script/run.sh`，在容器啟動時將執行這個腳本。

## 使用方法

要使用這個 Dockerfile 建立映像檔，您只需將 Dockerfile 存於本地目錄，然後在該目錄運行 Docker 建構指令。例如：
```
docker build -t apache2-php82 .
```
這將建立一個標籤為 `apache2-php82` 的 Docker 映像檔。

若要運行該映像檔並啟動容器，您可以使用以下命令：
```
docker run -d -p 80:80 apache2-php82
``` 
這將啟動一個容器並將主機的 80 埠映射到容器的 80 埠。您的 PHP 應用現應該可在瀏覽器透過 `http://localhost` 存取。

