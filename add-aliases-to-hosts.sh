cat /etc/hosts | grep -v \#WSL2Alias | sudo tee /etc/hosts &> /dev/null

aliasString=`cat /home/namyts/my-wsl-setup/wsl2aliases/aliases`

#echo $aliasString

read -a arr <<< $aliasString
for a in "${arr[@]}"; do
	echo -e "127.0.0.1	$a #WSL2Alias" | sudo tee -a /etc/hosts &> /dev/null
done