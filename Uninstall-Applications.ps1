#Requires -RunAs

cls
do {
    $scriptOptions = [System.Management.Automation.Host.ChoiceDescription[]]@("&Yes", "&No")
    $scriptResults = $host.UI.PromptForChoice("Main Application", "Do you want to uninstall a program?", $scriptOptions, 0) #"Do you want to continue with the main application for uninstalling programs?"

    Switch ($scriptResults) {
        0 {    
            $app = Read-Host "Type in the name of program. Partly entered name is accepted. Do not use quotes"
    
            Write-Host "`nSearching for '$app'" -ForegroundColor Cyan
            
            $Scriptblock = { @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall') | % {
                            Get-ItemProperty $_\* | ? { $_.DisplayName -like "*$app*" }}}
    
            if ([bool](& $Scriptblock)) {
                Write-Host "`nFound program(s) with the name '$app'`n" -ForegroundColor Green 
                        }
            else { 
                Write-Host "`nNo program(s) with the name '$app`n' is/are installed" -ForegroundColor Red
                break; 
                    }

            $find = & $Scriptblock | Select DisplayName, UninstallString 

            $find = $find | ? {$_.DisplayName -ne $null }

            $find.DisplayName

            $options = [System.Management.Automation.Host.ChoiceDescription[]]@("&Yes", "&No")
            $results = $host.UI.PromptForChoice("Program(s) Found", "Do you want to uninstall this program or one of these programs? Selecting 'No' will bring you back to the main option.", $options, 0)

            if ($find.DisplayName.Count -gt 1 -and $results -eq 0) {    
                Write-Host "`nHere are the programs:`n" -ForegroundColor Green
    
                $find = For ($i =0; $i -lt $find.count; $i++) {
                        [pscustomobject]@{
                            Name = $find[$i].DisplayName
                            UninstallString = $find[$i].UninstallString
                            Index = $i
                            }           
                        }

                $find | ft Name, Index -AutoSize
                Start-Sleep -Seconds 1
                    }

            Elseif ($find.DisplayName.Count -eq 1 -and $results -eq 0) {    
                Write-Host "`nHere is the program:`n" -ForegroundColor Green

                $find = [pscustomobject]@{
                            Name = $find.DisplayName
                            UninstallString = $find.UninstallString
                            Index = 0
                                }
    
                $find | ft Name, Index -AutoSize
                Start-Sleep -Seconds 1
                }
        
        Switch ($results) {
            0 {
                do {
                    Write-Host "`nPlease enter the index number of the program you want to uninstall. If a mistake was made and you would like to continue without selecting a program, just press enter.`n" -ForegroundColor Yellow
                    $Index = (Read-Host "Enter Index Number") 
                    $Index = if ($Index.Length -eq 0) { break; } elseif ($index.Length -eq 1) { $Index }

                    $Index = $Index -as [int]
                    $uninst = $find[$Index].UninstallString

                    $Index = [string]::Empty

                    Write-Host "`nNote that some programs will require uninstall in a separate window. Please follow those steps and once finished, return to PowerShell console.`n" -ForegroundColor Yellow

                    if ($uninst -match "MsiExec.exe") {             
                        $uninst = $uninst -replace 'MsiExec.exe /I', 'MsiExec.exe /X'
                        #$uninst; Start-Sleep -Seconds 3 # Testing
                        & cmd /c $uninst /quiet /norestart
                            }

                    elseif ($uninst -like "*C:\*") {
                        $uninst = $uninst.Replace('"','')
                        #$uninst; Start-Sleep -Seconds 3 # Testing
                        & cmd /c $uninst /quiet /norestart
                            }                   

                  } #End of Do Statement
          
              until ($Index -eq [String]::Empty)

              }
            1 { break;}
                          
                } #End of Inner Switch
            }

        1 {}

    } #End of Main Switch

} 

until ($scriptResults -eq 1)
