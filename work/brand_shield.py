from pathlib import Path
import re,hashlib,json
out=Path('outputs/index.html');before=out.read_text(encoding='utf-8-sig')
scripts=lambda h:re.findall(r'<script\b[^>]*>[\s\S]*?</script>',h)
original=scripts(before)
Path('work/branding-script-hashes.json').write_text(json.dumps([hashlib.sha256(x.encode()).hexdigest() for x in original],indent=2))
p=Path('work/scanner.html');h=p.read_text(encoding='utf-8-sig')
h=h.replace('PhishRadar: private, on-device heuristic analysis','PhishShield AI: private, on-device heuristic analysis')
h=h.replace('<title>PhishRadar — Universal Message Forensics</title>','<title>PhishShield AI — Real-Time Threat Forensics &amp; Social Engineering Defense</title>')
logo='''<div class="brandmark" aria-hidden="true"><svg class="shield-logo" viewBox="0 0 72 72" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="shield-tone" x1="14" y1="14" x2="59" y2="59" gradientUnits="userSpaceOnUse"><stop stop-color="#4f46e5"/><stop offset=".48" stop-color="#5368e9"/><stop offset="1" stop-color="#06b6d4"/></linearGradient><linearGradient id="shield-rim" x1="10" y1="8" x2="64" y2="65" gradientUnits="userSpaceOnUse"><stop stop-color="#d3d6ff"/><stop offset="1" stop-color="#a5e8f4"/></linearGradient><radialGradient id="radar-glint"><stop stop-color="#cffafe" stop-opacity=".85"/><stop offset="1" stop-color="#67e8f9" stop-opacity="0"/></radialGradient></defs><rect x="3" y="3" width="66" height="66" rx="20" fill="#f0f4ff" stroke="url(#shield-rim)"/><path d="M36 12 56 20v17c0 12-20 24-20 24S16 49 16 37V20Z" fill="url(#shield-tone)"/><path d="M36 12 56 20v17c0 12-20 24-20 24Z" fill="#22d3ee" opacity=".15"/><path d="M36 17 51 23v14c0 9-15 19-15 19S21 46 21 37V23Z" fill="none" stroke="#fff" stroke-opacity=".3" stroke-width="1"/><circle cx="36" cy="34" r="11" fill="none" stroke="#e0f2fe" stroke-opacity=".7" stroke-width="1.3"/><circle cx="36" cy="34" r="6" fill="none" stroke="#e0f2fe" stroke-opacity=".35"/><path d="M36 34V23a11 11 0 0 1 11 11Z" fill="#a5f3fc" opacity=".25"/><path d="m36 34 8-8" stroke="#e0faff" stroke-width="1.4" stroke-linecap="round"/><circle cx="44" cy="26" r="8" fill="url(#radar-glint)"/><circle cx="44" cy="26" r="3.7" fill="none" stroke="#67e8f9" stroke-opacity=".6"/><circle cx="44" cy="26" r="1.9" fill="#ecfeff"/><circle cx="36" cy="34" r="1.8" fill="#a5f3fc"/></svg></div>'''
old='<div class="brandmark"><svg class="icon"><use href="#i-radar"/></svg></div>'
assert old in h
h=h.replace(old,logo,1).replace('<div class="brandname">PhishRadar</div><small>Universal Message Forensics</small>','<div class="brandname">PhishShield <span class="ai-word">AI</span></div><small>Real-Time Threat Forensics &amp; Social Engineering Defense</small>',1)
h=h.replace('</div></header><div class="mobile-privacy">','</div><div class="header-accent bg-gradient-to-r from-indigo-500 via-cyan-400 to-emerald-400 h-0.5" aria-hidden="true"></div></header><div class="mobile-privacy">',1)
p.write_text(h,encoding='utf-8')
css=Path('work/scanner.css');s=css.read_text(encoding='utf-8-sig');assert 'PhishShield AI: distinct light surfaces' not in s
css.write_text(s+'\n'+Path('work/shield-brand.css').read_text(encoding='utf-8-sig'),encoding='utf-8')
exec(Path('work/bundle.py').read_text(encoding='utf-8-sig'))
after=out.read_text(encoding='utf-8')
assert scripts(after)==original,'Original JavaScript changed'
assert re.findall(r'\bid="([^"]+)"',before)==[x for x in re.findall(r'\bid="([^"]+)"',after) if x not in ['shield-tone','shield-rim','radar-glint']], 'Existing DOM IDs changed'
print('Verified: all original script tags and JavaScript are byte-for-byte identical; original DOM IDs preserved.')
