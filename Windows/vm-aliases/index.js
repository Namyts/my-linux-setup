const fs = require('fs')
const chokidar = require('chokidar')

const hostsFilePath = 'C:/Windows/System32/drivers/etc/hosts'

const configPath = './config/'
const aliasesListFilePath = `${configPath}/aliases`
const VM_IP_PATH = `${configPath}/ip`

const updateHostsFile = () => {
	const hostsFile = fs.readFileSync(hostsFilePath).toString()
	const aliasesFile = fs.readFileSync(aliasesListFilePath).toString()
	const VM_IP_FILE = fs.readFileSync(VM_IP_PATH).toString()

	const hostsFileLines = hostsFile.split('\n')
	const aliases = aliasesFile.split(' ')
	const VM_IP = VM_IP_FILE.trim()

	//remove old aliases
	let newHostsFileLines = hostsFileLines.filter(l=>{
		const vmalias = /.* #VM-Alias/gi
		return !l.match(vmalias)
	})

	//add new aliases
	aliases.forEach(a=>{
		let newLine = `${VM_IP}	${a}`
		newLine += ' #VM-Alias'
		newHostsFileLines.push(newLine)
	})


	const newHostsFile = newHostsFileLines.join('\n')

	fs.writeFileSync(hostsFilePath,newHostsFile)
	console.log('hosts file has been updated!')
	console.log(`new ip ${VM_IP}`)
	console.log('\n')
}


chokidar.watch(configPath,{persistent:true}).on('all',(e) => {
	switch(e){
		case 'change': {
			console.log('ip has been changed?')
			updateHostsFile()
			break;
		}
		default: break;
	}
}).on('ready', ()=>console.log('watching ip file for changes'))

