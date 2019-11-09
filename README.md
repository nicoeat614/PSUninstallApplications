# PSUninstallApplications
PowerShell script that prompts the user for options to uninstall applications that are located in the registry.

### Features included:
* Searches by string entry in both 32-bit and 64-bit registry for installed programs as opposed to searching through WMI/CIM, which doesn't captured all of the programs. 
* You select the program that you want to uninstall by index number. This is good for more than one programs that were found by the search.
* The script will run in a loop until you select "No" in the main choice options or you decide to break out of it with __CTRL+C__. 

### Screenshot:
![alt-text](https://raw.githubusercontent.com/nicoeat614/PSUninstallApplications/master/MainImage.JPG)

