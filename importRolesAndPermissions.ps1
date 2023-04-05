#Script to export roles and there permissions from a current VC and import into a new VC

#Remember to connect and then disconnect from each VC
connect-viserver nameofVC.domain.lab -Username sw\username -Password "Password"

#export from current VC
Get-VIRole |
Select @{N='vCenter';E={$_.Uid.Split('@:')[1]}},
  Name,
  @{N='PrivilegeList';E={[string]::Join([char]10,$_.PrivilegeList)}} |
Export-Csv -Path .\roles.csv -NoTypeInformation -UseCulture

#disconnect VC
disconnect-viserver * -Force -Confirm:$false

#Import to new VC

connect-viserver swvcweblab01.sw.sherwin.com -Username -Username sw\username -Password "Password"
Import-Csv -Path '\Users\username\roles.csv' -PipelineVariable row |
ForEach-Object -Process {
  $Role = @{
    Name = $row.Name
    Privilege = $row.PrivilegeList.Split("`n") | ForEach-Object { Get-VIPrivilege -Id $_ }
    Server = $row.vCenter
    Confirm = $false
    WhatIf = $false
  }
  New-VIRole @role
}