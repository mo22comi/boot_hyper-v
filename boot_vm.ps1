function VirtualMachineName {
    # iniファイルの最終行から、仮想マシン名を読み込み
    $line = Get-Content ./boot_vm.ini -Tail 1;
    $my_name = $line.Split("=")[1];
    return $my_name;
}

function Main {
    # ウィンドウ非表示
    PowerShell -WindowStyle Hidden -Command Exit
    $machine_name = VirtualMachineName;

    # .NET Frameworkのダイアログ関連オブジェクト
    Add-Type -AssemblyName System.Windows.Forms;
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
        [parameter(mandatory=$true)][string]$machine_name
    )
    switch ($status) {
        "not_exists" {
            $contents = @{
                "text" = "「{0}」という仮想マシンは存在しません。" -f $machine_name;
                "caption" = "エラー";
                "buttons_type" = "OK";
                "icon_type" = "Warning";
            }
        }
        "off" {
            $contents = @{
                "text" = "{0}を起動しますか？" -f $machine_name;
                "caption" = "起動確認";
                "buttons_type" = "OKCancel";
                "icon_type" = "Question";
            }
        }
        "success" {
            $contents = @{
                "text" = "{0}の起動に成功しました。" -f $machine_name;
                "caption" = "成功";
                "buttons_type" = "OK";
                "icon_type" = "Information";
            }
        }
        "running" {
            $contents = @{
                "text" = "{0}はすでに起動しています。" -f $machine_name;
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
