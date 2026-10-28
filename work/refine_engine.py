from pathlib import Path
p=Path('work/engine.js');s=p.read_text(encoding='utf-8-sig')
s=s.replace("function normalize(raw){let x=", "function normalize(raw){if(/^[/?#]/.test(raw))return null;let x=")
s=s.replace("const labels=host.split('.');", "const labels=[...new Set(host.split('.').concat(original.toLowerCase().split('.')))];")
s=s.replace("(l.length>=4&&b.token.length>=4&&(skeleton(l)===b.token||distance(l,b.token)===1))", "(skeleton(l)===b.token)||(l.length>=4&&b.token.length>=4&&distance(l,b.token)===1)")
s=s.replace("{name:'Amazon',token:'amazon',domains:['amazon.com','amazon.in','amazon.co.uk','amazonaws.com']}","{name:'Amazon',token:'amazon',domains:['amazon.com','amazon.in','amazon.co.uk','amazonaws.com']},{name:'Walmart',token:'walmart',domains:['walmart.com']}")
p.write_text(s,encoding='utf-8')
