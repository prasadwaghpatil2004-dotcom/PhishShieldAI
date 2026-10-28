from pathlib import Path
p=Path('work/engine.js');s=p.read_text(encoding='utf-8-sig').replace("host.split('.').concat(original.toLowerCase().split('.'))", "host.split(/[.-]/).concat(original.toLowerCase().split(/[.-]/))")
s=s.replace("if(phoneLike&&digits.length===10&&authorityPattern.test(sender+' '+body))", "if(phoneLike&&digits.length===10&&(authorityPattern.test(sender+' '+body)||/\\b(?:enterprise|corporate|company|finance|payroll|hr|ceo|customer\\s+service)\\b/i.test(sender+' '+body)))")
p.write_text(s,encoding='utf-8')
p=Path('work/critical-engine-checks.cjs');s=p.read_text(encoding='utf-8-sig').replace("'porta1.example'", "'porta1.example','secure-rnicrosoft.example','login-paypa1.example'")
s=s.replace("check('Work-chat display names", "check('SMS corporate role claims are caught',()=>{for(const role of ['CEO','Finance','HR','Corporate','Payroll'])assert.equal(scan(role+' message','9876543210','SMS').contributions.domain,25)});\ncheck('Work-chat display names")
p.write_text(s,encoding='utf-8')
