const fs = require('fs')
const exec = require('child_process').exec
const chokidar = require('chokidar')

const hostsFilePath = 'C:/Windows/System32/drivers/etc/hosts'
const aliasesListFilePath = './aliases'
const WSL2IPFilePath = './ip'

const updateHostsFile = () => {
	const hostsFile = fs.readFileSync(hostsFilePath).toString()
	const aliasesFile = fs.readFileSync(aliasesListFilePath).toString()
	const WSL2IPFile = fs.readFileSync(WSL2IPFilePath).toString()

	const hostsFileLines = hostsFile.split('\n')
	const aliases = aliasesFile.split(' ')
	const WSL2IP = WSL2IPFile.trim()

	//remove old aliases
	let newHostsFileLines = hostsFileLines.filter(l=>{
		const wsl2Alias = /.* #WSL2Alias/gi
		return !l.match(wsl2Alias)
	})

	//add new aliases
	aliases.forEach(a=>{
		let newLine = `${WSL2IP}	${a}`
		newLine += ' #WSL2Alias'
		newHostsFileLines.push(newLine)
	})


	const newHostsFile = newHostsFileLines.join('\n')

	fs.writeFileSync(hostsFilePath,newHostsFile)
	console.log('hosts file has been updated!')
	console.log(`new ip ${WSL2IP}`)
	console.log('\n')
}


chokidar.watch(WSL2IPFilePath,{persistent:true}).on('all',(e) => {
	switch(e){
		case 'change': {
			console.log('ip has been changed?')
			updateHostsFile()
			break;
		}
		default: break;
	}
}).on('ready', ()=>console.log('watching ip file for changes'))

