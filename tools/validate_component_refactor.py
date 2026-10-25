from pathlib import Path
import re
import json
from pygments import lex
from pygments.lexers import get_lexer_by_name
from pygments.token import Token

ORIG=Path('/mnt/data/phase0_run.gd')
ROOT=Path(__file__).resolve().parents[1]
HOST=ROOT/'scripts/phase0_run.gd'
COMPS=sorted((ROOT/'systems/run_components').glob('*.gd'))
lexer=get_lexer_by_name('gdscript')

def signatures(src):
    lines=src.splitlines(keepends=True)
    out={}
    i=0
    while i<len(lines):
        m=re.match(r'^func\s+([A-Za-z_]\w*)\s*\(',lines[i])
        if not m:
            i+=1;continue
        name=m.group(1);sig=[];depth=0;seen=False
        while i<len(lines):
            line=lines[i];sig.append(line)
            q=None;esc=False
            for ch in line:
                if q:
                    if esc:esc=False
                    elif ch=='\\':esc=True
                    elif ch==q:q=None
                    continue
                if ch in ('"',"'"):q=ch;continue
                if ch=='(':depth+=1;seen=True
                elif ch==')':depth-=1
            i+=1
            if seen and depth==0 and line.rstrip().endswith(':'):break
        out[name]=''.join(sig)
    return out

def delim_balance(s):
    bal={'(':0,'[':0,'{':0};close={')':'(',']':'[','}':'{'};minimum=0
    for t,v in lex(s,lexer):
        if t in Token.Punctuation:
            for ch in v:
                if ch in bal:bal[ch]+=1
                elif ch in close:
                    bal[close[ch]]-=1;minimum=min(minimum,bal[close[ch]])
    return bal,minimum

orig=ORIG.read_text(); host=HOST.read_text()
orig_sigs=signatures(orig); host_sigs=signatures(host)
print('original_functions',len(orig_sigs))
print('host_functions',len(host_sigs))
print('signature_key_match',set(orig_sigs)==set(host_sigs))
print('signature_exact_match',all(orig_sigs[k]==host_sigs[k] for k in orig_sigs))
print('save_version_original',re.search(r'^const SAVE_VERSION := (.+)$',orig,re.M).group(1))
print('save_version_refactor',re.search(r'^const SAVE_VERSION := (.+)$',host,re.M).group(1))

owned=set(); total_impl=0
all_funcs=set(orig_sigs)
for p in COMPS:
    s=p.read_text(); sf=set(re.findall(r'^func\s+([A-Za-z_]\w*)\s*\(',s,re.M)); sf.discard('_init')
    overlap=owned & sf
    owned |= sf; total_impl += len(sf)
    errors=[v for t,v in lex(s,lexer) if t is Token.Error]
    remaining=[];prev=''
    for t,v in lex(s,lexer):
        if t in Token.Name and v in all_funcs-sf and prev!='.':remaining.append(v)
        if t not in Token.Text.Whitespace and t not in Token.Comment:prev=v
    custom=re.findall(r'\b(?:Spider|Bullet|FirePatch|Structure|Spark|CombatImpact|XpHighlight|Pickup|BroodNest)\b',s)
    bal,minb=delim_balance(s)
    print(p.name,'impl_functions',len(sf),'overlap',len(overlap),'lex_errors',len(errors),'bare_external_calls',len(remaining),'monolith_local_types',len(custom),'balance',bal,'min_balance',minb)

print('extracted_implementation_functions',total_impl)
print('unique_extracted_functions',len(owned))
print('host_delegate_calls',sum(host.count(f'_{g}.') for g in ['world_presentation','actor_presentation','hud_presentation']))
print('host_lex_errors',sum(1 for t,v in lex(host,lexer) if t is Token.Error))
print('host_balance',delim_balance(host))
print('godot_runtime_validation','PENDING (Godot executable and full project not present in this environment)')

fix_records=json.loads((ROOT/'GODOT_4_7_1_INFERENCE_FIXES.json').read_text(encoding='utf-8'))
assert len(fix_records)==106
# Line numbers in the catalog are historical evidence, not validation anchors.
# Refactors insert/remove lines frequently; validate the known forbidden inference
# expressions against the whole current file so a shifted regression cannot pass.
fix_sources={}
for rec in fix_records:
    rel_path=rec['file']
    if rel_path not in fix_sources:
        fix_sources[rel_path]=(ROOT/rel_path).read_text(encoding='utf-8')
    source=fix_sources[rel_path]
    assert rec['before'] not in source, (
        f"unfixed Godot 4.7.1 inference pattern: {rel_path} variable={rec['variable']} "
        f"(catalog line {rec['line']})"
    )
print('godot_4_7_1_reported_inference_patterns_fixed',len(fix_records))
