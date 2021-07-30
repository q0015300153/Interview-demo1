# 使用一個 Dockerfile 建立 LNMP 的 Laravel 開發測試環境

## 命令說明 ##
設定檔
* **.env**

建立與啟動 Dockerfile
* **run.bat**

停止與移除 image
* **run.bat stop**  
* **run.bat s**

於容器內執行 linux 命令
* **run.bat exec**  
* **run.bat e**

執行 mysql 命令
* **run.bat mysql**

新增或 git clone laravel 專案，然後開啟 npm watch 以供開發測試
* **run.bat add-laravel**  
* **run.bat add**  
* **run.bat a**  
* **run.bat dev-laravel**  
* **run.bat dev**  
* **run.bat d**

執行 laravel 專案底下命令 Ex. php artsion 或 composer 或 webpack
* **run.bat laravel**  
* **run.bat l**

執行 laravel 專案底下 php 命令
* **run.bat php**

執行 laravel 專案底下 artisan 命令
* **run.bat artisan**

執行 laravel 專案底下 composer 命令
* **run.bat composer**

執行 laravel 專案底下 npm 命令
* **run.bat npm**

> 目前適用於 windows bat 腳本  
> 未來待開發 linux shell 腳本

> **push2GCP.bat** 可將編譯好的 docker 容器 push 到 GCP - container registry (使用 json.key)  
> 然後透過 Cloud Run 執行網站

## 執行新增 laravel 專案後，可以做以下動作 ##
> 目前新專案會額外安裝 
> 1. Vue  
> 1. Inertia  
> #### 待安裝清單 ####
> 1. babel/plugin-syntax-dynamic-import  
> 2. Jetstream  

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
mix.sourceMaps();

// js
mix.js('resources/js/app.js', 'public/js')
    .vue({
        extractStyles: true,
        globalStyles: false
    })
    .extract([
        '@vue',
        '@inertiajs/inertia-vue3',
        '@inertiajs/progress',
    ]);

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

import {createApp, h} from 'vue';
import {createInertiaApp} from '@inertiajs/inertia-vue3';
import {InertiaProgress} from '@inertiajs/progress';

InertiaProgress.init({
  delay: 250,
  color: '#29d',
  includeCSS: true,
  showSpinner: false,
});

createInertiaApp({
  	resolve: name => import(`./Pages/${name}`),
  	setup({el, App, props, plugin}) {
    	createApp({render:() => h(App, props)})
      		.use(plugin)
      		.mount(el)
  	},
});
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

```html
<!-- 新增 resources/view/app.blade.php 增加 -->
<html>
<head>
	<meta charset="utf-8">
	<title></title>
	...
	<link href="{{mix('/css/app.css')}}" rel="stylesheet">
	...
</head>
<body>
	...
	@inertia
	...
	<script src="{{mix('/js/manifest.js')}}"></script>
	<script src="{{mix('/js/vendor.js')}}"></script>
	<script src="{{mix('/js/app.js')}}"></script>
</body>
</html>
```