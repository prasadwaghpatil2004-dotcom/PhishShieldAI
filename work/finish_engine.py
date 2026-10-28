from pathlib import Path
p=Path('work/engine.js');s=p.read_text(encoding='utf-8-sig')
s=s.replace("raw=raw.replace(/[.,!?;:)\\]}]+$/,'');", "raw=raw.replace(/[.,!?;:]+$/,'');for(const [open,close] of [['(',')'],['[',']'],['{','}']])while(raw.endsWith(close)&&raw.split(close).length>raw.split(open).length)raw=raw.slice(0,-1);")
needle="const extracted=extractURLs(body),urls=[];"
s=s.replace(needle,"for(const m of body.matchAll(/\\b[a-z\\d.!#$%&'*+\\/=?^_`{|}~-]+@([^\\s<>,;]+)/gi)){const host=m[1].replace(/[.)]+$/,'');const start=m.index+m[0].lastIndexOf('@')+1;inspectHost(host,host,'body',start,start+host.length)}\n"+needle)
p.write_text(s,encoding='utf-8')
p=Path('work/scanner-checks.cjs');s=p.read_text(encoding='utf-8-sig');s=s.replace("check('Full bundled JavaScript parses'", "check('Raw email headers and email addresses in pasted text',()=>{const r=scan('From: Support <help@rnicrosoft.test>\\nSubject: Review\\n\\nHello');assert(r.senderInferred);assert(has(r,'lookalike-microsoft'));assert(has(scan('Contact security@rnicrosoft.test for help.'),'lookalike-microsoft'));assert(has(scan('https://[2001:db8::1]'),'ip-url'))});\ncheck('Full bundled JavaScript parses'")
p.write_text(s,encoding='utf-8')
