Set-Location $PSScriptRoot

$Output = @()

$fichierliste = Get-content "liste_srv.txt"

$header = 'node', 'Date_Fin_Maintenance', 'VM', 'Groupe', 'var5', 'var6', 'var10'

$fichierexport = Import-Csv -Path "export.csv" -Delimiter ";" -Header $header

$continue = $true

Write-Host "===================================================="
Write-Host "          _                _              _ "       
Write-Host "         /\ \            /\ \            / /\ "     
Write-Host "        /  \ \          /  \ \          / /  \ "    
Write-Host "       / /\ \ \        / /\ \ \        / / /\ \__ " 
Write-Host "      / / /\ \_\      / / /\ \ \      / / /\ \___\ "
Write-Host "     / /_/_ \/_/     / / /  \ \_\     \ \ \ \/___/ "
Write-Host "    / /____/\       / / /    \/_/      \ \ \       "
Write-Host "   / /\____\/      / / /           _    \ \ \      "
Write-Host "  / / /______     / / /________   /_/\__/ / /      "
Write-Host " / / /_______\   / / /_________\  \ \/___/ /       "
Write-Host " \/__________/   \/____________/   \_____\/        "
Write-Host "                                                  "
Write-Host "===================================================="
Write-Host "===============Easy Check Server==================="
Write-Host "                                                  "
Write-Host "Consigne :                                          "
Write-Host "1 - Crée un fichier texte nommé : liste_srv.txt, contenant les noms des serveurs a check."
Write-Host "2 - Exporter la base PIC en format CSV et renommée le fichier : export.csv"
Write-Host "3 - Placer les deux documents dans le même dossier que le script"
Write-Host "4 - Exécuter le script !"
Write-Host "                                                  "


while ($continue) {
	
	Write-Host "--Voulez-vous tester si les machines réponde au ping ?--"
	Write-Host "1. oui"
	Write-Host "2. non"
	Write-Host "--------------------------------------------------------"

	$choix = read-host "faire un choix"

	switch ($choix) {
		1 {
			foreach ($serveur in $fichierliste){
				if (Test-Connection -ComputerName $serveur -Count 1 -ErrorAction SilentlyContinue) {
					#ping réussi et présent dans pic
					if ($serveur -in $fichierexport.node) {
                        Write-Host "$serveur est up et présent dans la base PIC" -ForegroundColor Green
                        $selectline = $fichierexport | Where-Object {$_.'node' -eq $serveur} 
						$Output += "up;$selectline"
                        
					}
                    #ping réussi mais non présent dans pic
					else {
						Write-Host "$serveur est up, mais non présente dans la base PIC" -ForegroundColor DarkGreen
						$Output += "up;$serveur;introuvable dans la base PIC"
					}
				}
                #ping échoué mais présent dans pic					
				elseif ($serveur -in $fichierexport.node) {
						Write-Host "$serveur est down mais présent dans la base PIC" -ForegroundColor Yellow
                        $selectline = $fichierexport | Where-Object {$_.'node' -eq $serveur}  
					    $Output += "down;$selectline"
				}		
                        #ping échoué et non présent dans pic
						else {
							Write-Host "$serveur est down et introuvable dans la base PIC" -ForegroundColor Red
							$Output += "down;$serveur;introuvable dans la base PIC"
						}              
			}
            $Output | Add-Content -path "result_check.csv"
            $continue = $false 
		}
		
		2 {
			foreach ($serveur in $fichierliste) {
				if ($serveur -in $fichierexport.node) {
                    Write-Host "$serveur est présent dans la base PIC" -ForegroundColor Green
                    $selectline = $fichierexport | Where-Object {$_.'node' -eq $serveur} 
					$Output += "$selectline"
				}
                else {
                    Write-Host "$serveur est introuvable dans la base PIC" -ForegroundColor Red
                    $Output += "$serveur;introuvable dans la base PIC"
                }
			}
			$Output | Add-Content -path "result_check.csv"
            $continue = $false
		}
	}
}
Write-Host "--------------------------------------------------------"
Write-Host "        Fichier (result_check.csv) généré"
Write-Host "       Cette fenêtre se fermera dans 10 sec."
Write-Host "--------------------------------------------------------"
Start-Sleep -s 10