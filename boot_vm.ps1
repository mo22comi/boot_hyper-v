function ReadIniFile {
    param (
        [parameter(mandatory=$true)][string]$file_name
    )
    $configure = @{};
    $lines = Get-Content $file_name;
    foreach($line in $lines){
        # コメントと空行を除外する
        if($line -match "^$"){ continue }
        if($line -match "^\s*;"){ continue }

        $param = $line.split("=", 2);
        $configure.Add($param[0], $param[1]);
      }
    return $configure;
}

function Main {
    $ini_file_name = "boot_vm.ini";
    # ウィンドウ非表示
    PowerShell -WindowStyle Hidden -Command Exit
    # .NET Frameworkのダイアログ関連オブジェクト
    Add-Type -AssemblyName System.Windows.Forms;

    # iniファイル存在チェック
    if(Test-Path $ini_file_name){
        $config = ReadIniFile $ini_file_name;
        $machine_name = $config["name"];

        # 仮想マシンの存在チェック
        if(ExistsVirtualMachine $machine_name){
            # 起動してなかったらダイアログ表示して起動、起動実行したら起動確認
            if(IsRunning $machine_name){
                $contents = DialogContents "running" $machine_name;
                $dialog = ShowDialog $contents;
            }Else{
                $contents = DialogContents "off" $machine_name;
                $dialog = ShowDialog $contents;
                if($dialog -eq "OK"){
                    BootVirtualMachine $machine_name $dialog
                }
            }
        }Else{
            $contents = DialogContents "not_exists" $machine_name;
            $dialog = ShowDialog $contents;
        }
    }else {
        $contents = DialogContents "no_ini_file" $ini_file_name;
        $dialog = ShowDialog $contents;
    }
}

function BootVirtualMachine {
    param (
        [parameter(mandatory=$true)][string]$machine_name,
        [parameter(mandatory=$true)][string]$dialog
    )
    $RETRY_COUNT = 3;
    Start-VM -Name $machine_name
    # 起動確認
    for($i = 0; $i -lt $RETRY_COUNT; $i++){
        Start-Sleep -s 5;
        if(IsRunning $machine_name){
            $contents = DialogContents "success" $machine_name;
            $dialog = ShowDialog $contents;
            break;
        }Else{
            continue;
        }
    }
}

function ExistsVirtualMachine {
    param (
        [parameter(mandatory=$true)][string]$machine_name
    )
    $machines = Get-VM | Where-Object {$_.Name -eq $machine_name};
    $exists = !($null -eq $machines);
    return $exists;
}

function IsRunning {
    param (
        [parameter(mandatory=$true)][string]$machine_name
    )
    # 仮想マシンのState取得
    $state = Get-VM $machine_name | Select-Object State;
    $is_running = $state -match "Running";
    return $is_running;
}

function ShowDialog {
    param (
        [hashtable]$contents
    )
    $dialog = [System.Windows.Forms.MessageBox]::Show($contents["text"], $contents["caption"], $contents["buttons_type"], $contents["icon_type"]);
    return $dialog;
}

function DialogContents {
    param (
        [parameter(mandatory=$true)][string]$status,
        [parameter(mandatory=$true)][string]$target
    )
    switch ($status) {
        "no_ini_file" {
            $contents = @{
                "text" = "「{0}」が見つかりません。`r`nアプリケーションを終了します。" -f $target;
                "caption" = "エラー";
                "buttons_type" = "OK";
                "icon_type" = "Warning";
            }
        }
        "not_exists" {
            $contents = @{
                "text" = "「{0}」という仮想マシンは存在しません。" -f $target;
                "caption" = "エラー";
                "buttons_type" = "OK";
                "icon_type" = "Warning";
            }
        }
        "off" {
            $contents = @{
                "text" = "{0}を起動しますか？" -f $target;
                "caption" = "起動確認";
                "buttons_type" = "OKCancel";
                "icon_type" = "Question";
            }
        }
        "success" {
            $contents = @{
                "text" = "{0}の起動に成功しました。" -f $target;
                "caption" = "成功";
                "buttons_type" = "OK";
                "icon_type" = "Information";
            }
        }
        "running" {
            $contents = @{
                "text" = "{0}はすでに起動しています。" -f $target;
                "caption" = "終了";
                "buttons_type" = "OK";
                "icon_type" = "Warning";
            }
        }
        Default {
            $contents = @{
                "text" = "デフォルトの表示です。";
                "caption" = "デフォルト";
                "buttons_type" = "OK";
                "icon_type" = "Warning";
            }
        }
    }
    return $contents;
}

Main;
