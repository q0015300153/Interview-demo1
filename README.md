# 使用一個 Dockerfile 建立 LNMP 的 Laravel 開發測試環境

* .env 為設定檔
* run.bat 為建立與啟動 Dockerfile
* run.bat [stop|s] 為停止與移除 image
* run.bat [exec|e] 可於容器內執行 linux 命令
* run.bat [mysql]  可執行 mysql 命令

* run.bat [add-laravel|add|a|dev-laravel|dev|d] 可新增或 git clone laravel 專案，然後開啟 npm watch 以供開發測試
* run.bat [laravel|l] 可執行 laravel 專案底下命令 Ex. php artsion 或 composer 或 webpack
* run.bat [php]       可執行 laravel 專案底下 php      命令
* run.bat [artisan]   可執行 laravel 專案底下 artisan  命令
* run.bat [composer]  可執行 laravel 專案底下 composer 命令
* run.bat [npm]       可執行 laravel 專案底下 npm      命令

目前適用於 windows bat 腳本

未來待開發 linux shell 腳本

* push2GCP.bat 可將編譯好的 docker 容器 push 到 GCP - container registry (使用 json.key)
* 然後透過 Cloud Run 執行網站

## 執行新增 laravel 專案後，可以做以下動作 ##
```php
// 手動修改 App\Http\Kernel 增加
protected $middlewareGroups = [
	'web' => [
	    // ...
	    \App\Http\Middleware\HandleInertiaRequests::class,
	],
	// ...
];
```

```js
// 手動修改 webpack.mix.js
const mix     = require('laravel-mix');
const webpack = require("webpack");

// mix
mix.version();
mix.disableNotifications();

// js
mix.js('resources/js/app.js', 'public/js')
    .extract(['vue'])
    .vue({
        extractStyles: true,
        globalStyles: false
    });

// css
mix.postCss('resources/css/app.css', 'public/css', [
        require('tailwindcss'),
    ]);
    
// webpack
mix.webpackConfig({
    plugins: [
        new webpack.DefinePlugin({
            __VUE_OPTIONS_API__: true,
            __VUE_PROD_DEVTOOLS__: true,
        }),
    ],
});
```

```js
// 手動修改 resources/js/app.js
require('./bootstrap');

import {createApp} from "vue";

const app = createApp({

});

app.mount("#app");
```

```js
// 手動修改 tailwind.config.js
// ...
  purge: [
    './storage/framework/views/*.php',
    './resources/**/*.blade.php',
    './resources/**/*.js',
    './resources/**/*.vue',
  ],
// ...
```

```css
/* 手動修改 resources/css/app.css */
@tailwind base;
@tailwind components;
@tailwind utilities;
```