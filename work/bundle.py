from pathlib import Path
h=Path('work/scanner.html').read_text(encoding='utf-8-sig')
h=h.replace('/* STYLES */',Path('work/scanner.css').read_text(encoding='utf-8-sig')).replace('/* LOGIC */',Path('work/engine.js').read_text(encoding='utf-8-sig')+'\n'+Path('work/files-engine.js').read_text(encoding='utf-8-sig')+'\n'+Path('work/scanner-ui.js').read_text(encoding='utf-8-sig'))
Path('outputs/index.html').write_text(h,encoding='utf-8')
print('Bundled scanner into outputs/index.html')
