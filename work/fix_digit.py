from pathlib import Path
p=Path('work/engine.js');s=p.read_text(encoding='utf-8-sig').replace('(skeleton(l)===b.token)','(skeleton(l)===b.token||skeleton(l.replace(/1/g,\'i\'))===b.token)');p.write_text(s,encoding='utf-8')
