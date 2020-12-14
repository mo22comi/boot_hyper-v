# boot_hyper-v
Hyper-Vの仮想マシンを起動するスクリプトです。

起動させたいマシンを、boot_vm.iniに記載します。  
~~boot_vm.batを実行することで起動します。~~  
~~boot_vm.batとboot_vm.ps1は、同じファイル名にする必要があります。~~

ショートカットを作成して、「リンク先」に  
`powershell -ExecutionPolicy RemoteSigned -File `  
を追記すれば、powershellを実行できる。  
batファイルはいちおう残しておく。

![shortcut](https://user-images.githubusercontent.com/47170845/102078019-93eb3000-3e4d-11eb-832c-284e549c4618.png)


##### 起動時
![boot](https://user-images.githubusercontent.com/47170845/66702889-7604d580-ed47-11e9-97c5-dbb76a962e3a.png)
##### 起動確認時
![success](https://user-images.githubusercontent.com/47170845/66702894-7d2be380-ed47-11e9-81ae-06cc1dfb1e5e.png)
##### すでに起動しているとき
![running](https://user-images.githubusercontent.com/47170845/66702896-7ef5a700-ed47-11e9-88e4-ffcc4c484dd2.png)
