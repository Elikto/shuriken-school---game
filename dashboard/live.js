'use strict';
/* SHURIKEN LIVE VIEW — public, read-only. No secret/token/local-agent access.
   Real game images = static Pages manifest built from verified GitHub Actions artifacts.
   Terminal = CI step timestamps + public commit diff lines, NOT raw remote stdout. */
(() => {
  const ROOT='https://github.com/Elikto/shuriken-school---game';
  const state={captures:[],current:0,codeSha:'',diffs:[],lastManifest:null,fetching:false};
  const byId=id=>document.getElementById(id);
  const paris=s=>{
    if(!s)return 'heure inconnue';
    const d=new Date(s);
    if(!Number.isFinite(d.getTime()))return 'heure inconnue';
    return new Intl.DateTimeFormat('fr-FR',{
      timeZone:'Europe/Paris',day:'2-digit',month:'2-digit',
      year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit'
    }).format(d);
  };
  const safelyLinked=(url)=>typeof url==='string'&&/^https:\/\/github\.com\/Elikto\/shuriken-school---game\/(actions\/runs\/[0-9]+|commit\/[0-9a-f]{40})$/.test(url)?url:ROOT+'/actions';
  const safeCapture=c=>c&&Number.isSafeInteger(c.run_id)&&/^live\/captures\/[0-9]+\.png$/.test(c.image||'')&&typeof c.run_url==='string';
  function visibleImage(entry){return entry&&entry.image?entry.image:null;}
  function pictureStatus(message){
    byId('preview-empty').hidden=false;
    byId('preview-empty').textContent=message;
    byId('preview-stage').hidden=true;
    byId('preview-gallery').replaceChildren();
  }
  function updateSelected(){
    const current=state.captures[state.current];
    if(!current){pictureStatus('Pas de capture Godot vérifiée disponible.');return;}
    const previous=state.captures[Math.min(state.current+1,state.captures.length-1)];
    byId('preview-empty').hidden=true;
    byId('preview-stage').hidden=false;
    byId('visual-new').src=visibleImage(current);
    byId('visual-old').src=visibleImage(previous);
    byId('visual-new').alt='Capture réelle Godot — exécution '+current.run_id;
    byId('visual-old').alt='Capture réelle précédente Godot — exécution '+previous.run_id;
    byId('visual-meta').textContent='Capture créée le '+paris(current.captured_at)+' · Godot réel · commit '+String(current.sha||'').slice(0,7);
    byId('visual-before-label').textContent=previous.run_id===current.run_id?'Aucun avant disponible':'Avant · #'+previous.run_id;
    byId('visual-after-label').textContent='Après · #'+current.run_id;
    byId('visual-source').href=safelyLinked(current.run_url);
    byId('visual-source').textContent='Vérifier la capture Godot et le build #'+current.run_id+' ↗';
    const range=byId('compare-range');
    range.disabled=previous.run_id===current.run_id;
    range.value='60';
    updateSlider();
    const buttons=state.captures.map((item,i)=>{
      const btn=document.createElement('button');
      btn.type='button';btn.className='preview-thumb'+(i===state.current?' selected':'');
      btn.setAttribute('aria-label','Afficher la capture du '+paris(item.captured_at));
      btn.setAttribute('aria-pressed',i===state.current?'true':'false');
      const img=document.createElement('img');
      img.src=item.image; img.loading='lazy';img.alt='Vignette de capture Godot #'+item.run_id;
      const note=document.createElement('span');note.textContent='#'+item.run_id+' · '+paris(item.captured_at);
      btn.append(img,note);btn.addEventListener('click',()=>{state.current=i;updateSelected();});
      return btn;
    });
    byId('preview-gallery').replaceChildren(...buttons);
  }
  function updateSlider(){
    const pct=Number(byId('compare-range').value)||0;
    byId('visual-new').style.clipPath='inset(0 '+(100-pct)+'% 0 0)';
    byId('visual-cut').style.left=pct+'%';
    byId('compare-range').setAttribute('aria-valuetext',pct+' % de la capture récente');
  }
  async function loadVisual(){
    if(state.fetching)return;
    state.fetching=true;
    try{
      const response=await fetch('live/manifest.json',{cache:'no-store'});
      if(!response.ok)throw Error('manifest absent');
      const manifest=await response.json();
      const good=(Array.isArray(manifest.captures)?manifest.captures:[]).filter(safeCapture).slice(0,5);
      if(!good.length){pictureStatus('Aucune capture réelle disponible pour le moment. Voir les compilations Godot.');return;}
      const oldRun=state.captures[state.current]?.run_id;
      const newKey=good.map(x=>x.run_id).join(',');
      state.captures=good;
      if(state.lastManifest!==newKey){
        state.current=Math.max(0,good.findIndex(x=>x.run_id===oldRun));
        state.lastManifest=newKey;
        updateSelected();
      }
      byId('preview-count').textContent=good.length+' capture(s) vérifiée(s)';
    }catch(e){
      if(!state.captures.length)pictureStatus('Les captures ne sont pas encore publiées. Le journal ne substitue jamais une illustration au rendu réel.');
      byId('preview-count').textContent='Publication des images en attente';
    }finally{state.fetching=false;}
  }
  const commands={
    'Vérifier la version':'godot --version',
    'Importer les scripts et scènes':'godot --headless --path game --editor --import --quit',
    'Tester le gameplay (vagues, héros, fumée, coffre)':'godot --headless --path game --script res://tests/smoke.gd',
    'Lancer brièvement la scène principale':'godot --headless --path game --quit-after 5',
    'Exporter le jeu Windows':'godot --headless --path game --export-release "Windows Desktop" ../dist/ShurikenSchool3D.exe',
    'Générer un screenshot depuis la scène réelle':'xvfb-run ... godot --script res://tests/capture.gd',
    'Vérifier la syntaxe Python':'python3 -m py_compile tools/blender/generate_heroes.py',
    'Générer Eizan, Okuni et Jimmy (maquettes originales)':'blender --background --python tools/blender/generate_heroes.py -- --output-dir dist/models',
    'Valider GLB, squelette et animation':'python3 (contrôle GLB : skins, bones, animations)',
    'Import Godot et test de rig 3D':'godot --headless --path game --script res://tests/glb_smoke.gd'
  };
  function securePatchLine(s){
    // Only public code changes, never action workflows/configuration, env or secrets.
    if(/(token|api[_-]?key|password|private[_-]?key|secret|bearer\s|gh_token|passphrase)/i.test(s))return '[ligne masquée : donnée potentiellement sensible]';
    return s.length>200?s.slice(0,200)+' …':s;
  }
  async function loadCodeChanges(){
    const recent=(model.commits||[]).slice(0,3);
    const head=recent.map(x=>x.sha).join(',');
    if(!head||head===state.codeSha)return;
    try{
      const results=await Promise.all(recent.map(async c=>{
        // Public GitHub commits expose the patch. No private APIs or local paths.
        const data=await fetchJson('/commits/'+encodeURIComponent(c.sha));
        return {sha:c.sha,when:c.commit?.author?.date||c.commit?.committer?.date,
          files:(data.files||[]).filter(f=>/^(game\/(scripts|tests)\/|tools\/blender\/|dashboard\/)[A-Za-z0-9_./-]+\.(gd|py|html|js|css)$/.test(f.filename||''))};
      }));
      const diffs=[];
      for(const commit of results){
        let budget=22;
        for(const file of commit.files){
          if(budget<=0)break;
          for(const line of String(file.patch||'').split('\n')){
            if(budget<=0)break;
            if(!/^[+-][^+-]/.test(line))continue;
            diffs.push({time:commit.when,type:'code',message:securePatchLine(line),file:file.filename,
              url:ROOT+'/commit/'+commit.sha});
            budget--;
          }
        }
      }
      state.diffs=diffs;
      state.codeSha=head;
    }catch(e){
      // Public API rate limiting must not remove existing verified data.
      console.warn('Shuriken diff read unavailable:',e.message);
    }
  }
  function toTerminalLine(e){
    const line=document.createElement('div');line.className='trace-line '+e.type;
    const dateNode=document.createElement('time');
    dateNode.dateTime=e.time||'';
    dateNode.textContent='['+paris(e.time)+']';
    const type=document.createElement('span');type.className='trace-type';type.textContent=e.type==='code'?'CODE':e.type==='command'?'CMD':'CI';
    const txt=document.createElement('span');txt.className='trace-msg';txt.textContent=e.message;
    line.append(dateNode,type,txt);
    if(e.url){
      const source=document.createElement('a');source.href=safelyLinked(e.url);source.target='_blank';
      source.rel='noopener noreferrer';source.textContent='↗';source.title=e.file||'Preuve GitHub';
      line.append(source);
    }
    return line;
  }
  function terminalEvents(){
    const events=[];
    for(const {run,jobs} of (model.activityGroups||[])){
      const url=safelyLinked(run.html_url);
      for(const job of jobs||[]){
        for(const step of job.steps||[]){
          if(!step.started_at)continue;
          const status=step.conclusion||step.status||'inconnu';
          events.push({time:step.started_at,type:'ci',url,
            message:job.name+' / '+step.name+' — '+status});
          // This is the exact approved workflow command, NOT a live stdout line.
          if(commands[step.name]){
            events.push({time:step.started_at,type:'command',url,
              message:'$ '+commands[step.name]+'  [commande déclarée dans le workflow]'});
          }
        }
      }
    }
    for(const diff of state.diffs){
      events.push({...diff, message:diff.file+'  '+diff.message+'  [horodatage du commit]'});
    }
    return events.filter(e=>e.time&&Number.isFinite(Date.parse(e.time)))
      .sort((a,b)=>new Date(b.time)-new Date(a.time)).slice(0,95);
  }
  function renderTerminal(){
    const list=terminalEvents();
    const target=byId('trace-lines');
    if(!target)return;
    target.replaceChildren(...list.map(toTerminalLine));
    if(!list.length){
      const msg=document.createElement('p');msg.textContent='En attente de nouvelles étapes GitHub et de modifications de code vérifiées.';
      msg.className='note';target.appendChild(msg);
    }
    byId('trace-status').textContent=list.length+' lignes vérifiées · synchro '+paris(new Date().toISOString());
  }
  async function tick(){
    await loadVisual();
    if((model.commits||[]).length)await loadCodeChanges();
    renderTerminal();
  }
  byId('compare-range').addEventListener('input',updateSlider);
  // Refresh the gallery independently of the public GitHub API quota.
  tick();
  setInterval(()=>{loadVisual();renderTerminal();},75000);
  setInterval(()=>{loadCodeChanges().finally(renderTerminal);},300000);
  document.addEventListener('visibilitychange',()=>{if(!document.hidden)tick();});
})();
