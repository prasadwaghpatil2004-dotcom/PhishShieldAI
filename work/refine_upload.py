from pathlib import Path
p=Path('work/scanner-ui.js');s=p.read_text(encoding='utf-8-sig')
s=s.replace("async function handleFiles(files){", "function rejectUpload(message){uploadToken++;$('#upload-status').textContent=message;$('#upload-status').className='upload-status error';$('#file-input').value='';$('#analyze-button').disabled=false;$('#upload-drop').setAttribute('aria-busy','false')}\nasync function handleFiles(files){")
s=s.replace("$('#upload-status').textContent='Choose one file at a time.';$('#upload-status').className='upload-status error';", "rejectUpload('Choose one file at a time.');")
s=s.replace("$('#upload-status').textContent='Supported files: .eml, .txt, .png, .jpg, .jpeg.';$('#upload-status').className='upload-status error';$('#file-input').value='';", "rejectUpload('Supported files: .eml, .txt, .png, .jpg, .jpeg.');")
s=s.replace("$('#upload-status').textContent=file.size===0?'This file is empty.':isText?'Email/text files must be 2 MB or smaller.':'Screenshots must be 10 MB or smaller.';$('#upload-status').className='upload-status error';$('#file-input').value='';", "rejectUpload(file.size===0?'This file is empty.':isText?'Email/text files must be 2 MB or smaller.':'Screenshots must be 10 MB or smaller.');")
p.write_text(s,encoding='utf-8')
p=Path('work/files-engine.js');s=p.read_text(encoding='utf-8-sig').replace("chunk=line.trimEnd().endsWith('--')?null:[]", "chunk=line.trimEnd()==='--'+boundary+'--'?null:[]");p.write_text(s,encoding='utf-8')
p=Path('work/scanner.html');s=p.read_text(encoding='utf-8-sig').replace('On-device analysis · No message uploads','On-device analysis · No server uploads');p.write_text(s,encoding='utf-8')
