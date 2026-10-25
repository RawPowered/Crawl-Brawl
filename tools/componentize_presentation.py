from pathlib import Path
import re
import os
from pygments import lex
from pygments.lexers import get_lexer_by_name
from pygments.token import Token

OUTROOT = Path(__file__).resolve().parents[1]
SRC = Path(os.environ.get('CRAWL_BRAWL_PHASE0_SOURCE', '/mnt/data/phase0_run.gd'))
HOST_OUT = OUTROOT / 'scripts' / 'phase0_run.gd'
GEN_OUT = OUTROOT / 'tools' / 'componentize_presentation.py'

GROUPS = [
    ('world_presentation', 13922, 15576, 'RunWorldPresentationScript', 'run_world_presentation.gd'),
    ('actor_presentation', 15576, 16794, 'RunActorPresentationScript', 'run_actor_presentation.gd'),
    ('hud_presentation', 16794, 17434, 'RunHudPresentationScript', 'run_hud_presentation.gd'),
]

text = SRC.read_text(encoding='utf-8')
lines = text.splitlines(keepends=True)
lexer = get_lexer_by_name('gdscript')

func_starts=[]
for idx,line in enumerate(lines):
    m=re.match(r'^func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(',line)
    if m: func_starts.append((idx,m.group(1)))
func_blocks=[]
for n,(start,name) in enumerate(func_starts):
    end=func_starts[n+1][0] if n+1<len(func_starts) else len(lines)
    func_blocks.append({'start':start,'end':end,'name':name})
all_func_names={b['name'] for b in func_blocks}
first_func=func_blocks[0]['start']

top_vars=[]
for line in lines[:first_func]:
    m=re.match(r'^var\s+([A-Za-z_][A-Za-z0-9_]*)',line)
    if m: top_vars.append(m.group(1))

def bracket_delta(line:str)->int:
    d=0;q=None;esc=False
    for ch in line:
        if q:
            if esc: esc=False
            elif ch=='\\': esc=True
            elif ch==q: q=None
            continue
        if ch in ('"',"'"): q=ch; continue
        if ch=='#': break
        if ch in '([{': d+=1
        elif ch in ')]}': d-=1
    return d

def collect_const_blocks():
    blocks=[];i=0
    while i<first_func:
        m=re.match(r'^const\s+([A-Za-z_][A-Za-z0-9_]*)',lines[i])
        if not m: i+=1; continue
        name=m.group(1); st=i; bal=bracket_delta(lines[i]); i+=1
        while i<first_func and bal>0:
            bal+=bracket_delta(lines[i]); i+=1
        blocks.append((name,''.join(lines[st:i]).rstrip()+'\n'))
    return blocks
const_blocks=collect_const_blocks()
const_by_name=dict(const_blocks)
const_order=[n for n,_ in const_blocks]

custom_types={'Spider','Bullet','FirePatch','Structure','Spark','CombatImpact','XpHighlight','Pickup','BroodNest'}

def strip_custom_types(src:str)->str:
    names='|'.join(sorted(map(re.escape,custom_types),key=len,reverse=True))
    src=re.sub(r':\s*Array\[(?:'+names+r')\]','',src)
    src=re.sub(r':\s*(?:'+names+r')(?=\s*(?:=|,|\)|\bin\b))','',src)
    src=re.sub(r'\s*->\s*(?:'+names+r')(?=\s*:)','',src)
    return src

def stabilize_dynamic_proxy_inference(src: str) -> str:
    """Compatibility fallback for future Phase-1 regeneration.

    Phase-1 proxies intentionally expose run-owned state dynamically. Godot 4.7.1
    cannot use `:=` when an expression resolves to Variant. Regenerated extracted
    functions therefore keep local declarations dynamic. This changes typing only,
    not the assigned expression.
    """
    out=[]
    for line in src.splitlines(keepends=True):
        if re.match(r'^\s+var\b', line) and ':=' in line:
            line=line.replace(':=', '=', 1)
        out.append(line)
    return ''.join(out)

def rewrite_external_calls(src:str, local_func_names:set[str])->str:
    toks=list(lex(src,lexer)); out=[]; prev_sig=''
    for tok,val in toks:
        if tok in Token.Name and val in all_func_names and val not in local_func_names and prev_sig!='.':
            out.append('host.'+val)
        else:
            out.append(val)
        if tok not in Token.Text.Whitespace and tok not in Token.Comment:
            prev_sig=val
    return ''.join(out)

def signature_text(block):
    sig=[];paren=0;seen=False
    for i in range(block['start'],block['end']):
        ln=lines[i]; sig.append(ln)
        q=None;esc=False
        for ch in ln:
            if q:
                if esc:esc=False
                elif ch=='\\':esc=True
                elif ch==q:q=None
                continue
            if ch in ('"',"'"):q=ch;continue
            if ch=='(':paren+=1;seen=True
            elif ch==')':paren-=1
        if seen and paren==0 and ln.rstrip().endswith(':'): break
    return ''.join(sig)

def split_params(s):
    parts=[];cur=[];depth=0;q=None;esc=False
    for ch in s:
        if q:
            cur.append(ch)
            if esc:esc=False
            elif ch=='\\':esc=True
            elif ch==q:q=None
            continue
        if ch in ('"',"'"):q=ch;cur.append(ch);continue
        if ch in '([{':depth+=1
        elif ch in ')]}':depth-=1
        if ch==',' and depth==0:
            parts.append(''.join(cur));cur=[]
        else:cur.append(ch)
    if ''.join(cur).strip():parts.append(''.join(cur))
    return parts

def arg_names(sig):
    p0=sig.find('(');depth=0;q=None;esc=False;p1=-1
    for i,ch in enumerate(sig[p0:],p0):
        if q:
            if esc:esc=False
            elif ch=='\\':esc=True
            elif ch==q:q=None
            continue
        if ch in ('"',"'"):q=ch;continue
        if ch=='(':depth+=1
        elif ch==')':
            depth-=1
            if depth==0:p1=i;break
    out=[]
    for part in split_params(sig[p0+1:p1]):
        m=re.match(r'\s*([A-Za-z_][A-Za-z0-9_]*)',part)
        if m:out.append(m.group(1))
    return out

def return_is_void(sig):
    m=re.search(r'->\s*([^:\n]+)\s*:',sig.replace('\n',' '))
    return bool(m and m.group(1).strip()=='void')

# Build group metadata and component files.
owner={}
component_stats=[]
for gid,start,end,script_const,filename in GROUPS:
    blocks=[b for b in func_blocks if start<=b['start']<end]
    names={b['name'] for b in blocks}
    for n in names:
        assert n not in owner
        owner[n]=gid
    selected_text=''.join(''.join(lines[b['start']:b['end']]) for b in blocks)
    used_vars={val for tok,val in lex(selected_text,lexer) if tok in Token.Name and val in top_vars}
    used_consts={val for tok,val in lex(selected_text,lexer) if tok in Token.Name and val in const_by_name}
    changed=True
    while changed:
        changed=False
        for cn in list(used_consts):
            for tok,val in lex(const_by_name[cn],lexer):
                if tok in Token.Name and val in const_by_name and val not in used_consts:
                    used_consts.add(val);changed=True
    needed_consts=[const_by_name[n] for n in const_order if n in used_consts]
    header=(f'## Crawl Brawl {gid.replace("_"," ")} component - Phase 1 monolith extraction\n'
            f'## Authoritative gameplay/save state remains on CrawlBrawlRun and is proxied here during migration.\n'
            'extends RefCounted\n\nvar host\n\nfunc _init(run_host) -> void:\n\thost = run_host\n\n')
    const_sec='## Dependency-closed compile-time constant mirror from CrawlBrawlRun.\n'+'\n'.join(needed_consts)+'\n'
    prox=['## Mutable run-state proxies. Ownership remains on CrawlBrawlRun in Phase 1.']
    for n in sorted(used_vars):
        prox += [f'var {n}:','\tget:',f'\t\treturn host.{n}','\tset(value):',f'\t\thost.{n} = value','']
    funcs=[]
    for b in blocks:
        raw=''.join(lines[b['start']:b['end']])
        raw=strip_custom_types(raw)
        raw=rewrite_external_calls(raw,names)
        raw=stabilize_dynamic_proxy_inference(raw)
        funcs.append(raw.rstrip()+'\n\n')
    comp_text=header+const_sec+'\n'.join(prox)+'\n'+''.join(funcs)
    out=OUTROOT/'systems'/'run_components'/filename
    out.parent.mkdir(parents=True,exist_ok=True)
    out.write_text(comp_text,encoding='utf-8')
    component_stats.append((gid,len(blocks),len(used_vars),len(used_consts),len(comp_text.splitlines()),out))

assert len(owner)==172

# Host wrappers.
replacement={}
gid_to_field={gid:'_'+gid for gid,_,_,_,_ in GROUPS}
for b in func_blocks:
    if b['name'] not in owner: continue
    sig=signature_text(b); args=arg_names(sig); gid=owner[b['name']]; field=gid_to_field[gid]
    call=f'{field}.{b["name"]}('+', '.join(args)+')'
    body='\t'+(call if return_is_void(sig) else 'return '+call)+'\n\n'
    replacement[b['start']]=(b['end'],sig+body)
out=[];i=0
while i<len(lines):
    if i in replacement:
        e,r=replacement[i];out.append(r);i=e
    else:out.append(lines[i]);i+=1
host=''.join(out)

needle='const GameplayTelemetryScript := preload("res://systems/gameplay_telemetry.gd")\n'
preloads=(needle+
          'const RunWorldPresentationScript := preload("res://systems/run_components/run_world_presentation.gd")\n'
          'const RunActorPresentationScript := preload("res://systems/run_components/run_actor_presentation.gd")\n'
          'const RunHudPresentationScript := preload("res://systems/run_components/run_hud_presentation.gd")\n')
assert needle in host
host=host.replace(needle,preloads,1)
needle2='var ui_textures: Dictionary = {}\n\n\nfunc set_difficulty'
fields=('var ui_textures: Dictionary = {}\n'
        'var _world_presentation: RefCounted\n'
        'var _actor_presentation: RefCounted\n'
        'var _hud_presentation: RefCounted\n\n\nfunc set_difficulty')
assert needle2 in host
host=host.replace(needle2,fields,1)
needle3='func _ready() -> void:\n'
init=(needle3+
      '\t_world_presentation = RunWorldPresentationScript.new(self)\n'
      '\t_actor_presentation = RunActorPresentationScript.new(self)\n'
      '\t_hud_presentation = RunHudPresentationScript.new(self)\n')
assert needle3 in host
host=host.replace(needle3,init,1)

HOST_OUT.parent.mkdir(parents=True,exist_ok=True)
HOST_OUT.write_text(host,encoding='utf-8')
GEN_OUT.parent.mkdir(parents=True,exist_ok=True)
GEN_OUT.write_text(Path(__file__).read_text(encoding='utf-8'),encoding='utf-8')

print('extracted_total',len(owner),'host_lines',len(host.splitlines()))
for stat in component_stats: print(*stat[:-1],stat[-1])
