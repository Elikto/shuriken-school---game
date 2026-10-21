'use strict';
// Shuriken School · mission jouable de fan-game. Graphismes originaux temporaires.
// Aucune ressource officielle, aucun service de matchmaking ou multijoueur simulé.
(() => {
const $ = id => document.getElementById(id);
const canvas = $('game');
const ctx = canvas.getContext('2d', {alpha: false});
if (!ctx) { $('startButton').disabled = true; return; }
const W = 2460, H = 1160;
const palette = { ground:'#a8c99d',path:'#eed8a8',orange:'#cf705b',night:'#1e3453',dark:'#324354',light:'#fff9e9',blue:'#9ccbe7',gold:'#f8cf71',purple:'#826c9a',green:'#4c785f'};
const heroes = [
  {name:'Eizan', color:'#f4c074',accent:'#6ba464',speed:245,skill:'Rush ninja'},
  {name:'Okuni', color:'#f8b5cb',accent:'#cc5684',speed:220,skill:'Instinct de détective'},
  {name:'Jimmy', color:'#a5caed',accent:'#4892c8',speed:260,skill:'Skate diversion'}
];
const walls = [
 {x:290,y:145,w:300,h:215,type:'academy'}, {x:330,y:855,w:320,h:230,type:'house'},
 {x:740,y:115,w:310,h:210,type:'house'}, {x:775,y:875,w:325,h:230,type:'house'},
 {x:1130,y:185,w:270,h:215,type:'house'}, {x:1150,y:905,w:320,h:190,type:'house'},
 {x:1480,y:120,w:245,h:205,type:'house'}, {x:1500,y:905,w:255,h:215,type:'house'},
 {x:1940,y:150,w:260,h:250,type:'katana'}, {x:1990,y:870,w:270,h:235,type:'katana'}
];
const props = {
 notes:[{x:480,y:650,t:'Un ruban violet',found:false},{x:1080,y:745,t:'Une lettre signée K',found:false},{x:1495,y:520,t:'Une empreinte de sandale',found:false}],
 cipher:{x:1570,y:790}, gate:{x:1760,y:445,w:33,h:200}, chest:{x:2260,y:525}
};
const lanterns = [{x:200,y:435},{x:650,y:435},{x:945,y:445},{x:1410,y:445},{x:1900,y:450},{x:2140,y:715},{x:1730,y:760}];
const sakuras = [{x:120,y:245,r:100},{x:525,y:115,r:85},{x:900,y:1040,r:94},{x:1290,y:99,r:95},{x:1680,y:1090,r:82},{x:2060,y:80,r:96},{x:2310,y:1020,r:75}];
const bushes=[{x:595,y:550,r:54},{x:915,y:685,r:48},{x:1300,y:670,r:44},{x:2025,y:660,r:52},{x:2175,y:730,r:55}];
const guardDefs=[
 {x:900,y:555,path:[{x:785,y:555},{x:1060,y:565}],rate:75},
 {x:1305,y:700,path:[{x:1200,y:690},{x:1550,y:690}],rate:86},
 {x:1900,y:550,path:[{x:1830,y:550},{x:2060,y:550}],rate:92},
 {x:2170,y:610,path:[{x:2090,y:610},{x:2350,y:610}],rate:89}
];
const state={mode:'start',time:0,score:0,notes:0,stage:0,deciphered:false,health:3,maxHealth:3,seen:0,hero:0,
 player:{x:170,y:590,dx:1,dy:0},guards:[],effects:[],projectiles:[],camera:{x:0,y:0},lastHurt:0,skillUntil:0,skillReady:0,throwReady:0,
 decoy:null,flashUntil:0, hintUntil:0,toastUntil:0,toast:'',checkpoint:{x:170,y:590}, ticks:0, sound:true};
const keys=new Set(),touch={up:false,left:false,right:false,down:false};
let vw=1280,vh=720,lastTime=0,started=false;
const clamp=(a,b,c)=>Math.min(c,Math.max(b,a));
const distance=(a,b)=>Math.hypot(a.x-b.x,a.y-b.y);
const dist=(x,y,a,b)=>Math.hypot(x-a,y-b);
function showToast(msg,t=3){state.toast=msg;state.toastUntil=state.time+t;$('tip').textContent=msg;$('tip').classList.add('show');}
function reset(){
 state.mode='playing';state.time=0;state.score=0;state.notes=0;state.stage=0;state.deciphered=false;state.health=3;state.seen=0;state.hero=0;
 state.player={x:170,y:590,dx:1,dy:0};state.guards=guardDefs.map((g,i)=>({...g,x:g.x,y:g.y,waypoint:i%2,stunned:0,look:0,alert:0}));
 state.effects=[];state.projectiles=[];state.lastHurt=-100;state.skillUntil=0;state.skillReady=0;state.throwReady=0;state.decoy=null;
 state.camera={x:0,y:0};state.checkpoint={x:170,y:590};state.ticks=0;state.hintUntil=0;state.flashUntil=0;
 props.notes.forEach(n=>n.found=false); Object.keys(touch).forEach(k=>touch[k]=false);keys.clear();
 $('endModal').classList.remove('visible');$('pauseModal').classList.remove('visible');$('startModal').classList.remove('visible');
 updateHud();showToast('Retrouve les trois indices dans la cour et la ville !',4);canvas.focus();
}
function updateHud(){
 let text=state.notes<3?`Indices du vol : ${state.notes}/3`:(!state.deciphered?'Okuni doit décrypter le message':'Récupère les tongs chez Katana School');
 $('objectiveText').textContent=text;
 $('progressPips').innerHTML=[0,1,2,3,4].map(i=>`<span class="pip ${i<state.notes+(state.deciphered?1:0)+(state.stage===2?1:0)?'done':''}"></span>`).join('');
 $('hearts').textContent=Array.from({length:3},(_,i)=>i<state.health?'♥':'♡').join(' ');
 $('zoneLabel').textContent=state.player.x<710?'École Shuriken':state.player.x<1760?'Tokirohama':'École Katana';
 $('footerStatus').textContent=state.mode==='playing'?'EN MISSION':state.mode==='paused'?'EN PAUSE':state.mode==='won'?'VICTOIRE':state.mode==='lost'?'MISSION ÉCHOUÉE':'PRÊT À JOUER';
 document.querySelectorAll('.hero-choice').forEach(b=>b.classList.toggle('active',+b.dataset.hero===state.hero));
}
function setHero(i){if(state.mode!=='playing')return;state.hero=i;updateHud();showToast(heroes[i].name+' · '+heroes[i].skill,1.4);playTone(360+i*95,.08);}
function collide(x,y,r=20){
 if(x<28||y<35||x>W-28||y>H-28)return true;
 for(const b of walls){const cx=clamp(x,b.x,b.x+b.w),cy=clamp(y,b.y,b.y+b.h);if(dist(x,y,cx,cy)<r)return true;}
 // Cloison continue, ouverture contrôlée par la grille centrale.
 if(x+r>1744 && x-r<1788 && !state.deciphered){return true;}
 if(x+r>1744 && x-r<1788 && (y<430 || y>660))return true;
 return false;
}
function moveActor(p,dx,dy,r=20){
 if(!collide(p.x+dx,p.y,r))p.x+=dx;
 if(!collide(p.x,p.y+dy,r))p.y+=dy;
}
function nearestInteractable(){
 const p=state.player,candidates=[];
 if(state.notes<3)props.notes.filter(n=>!n.found).forEach(n=>candidates.push({kind:'note',object:n,d:distance(p,n)}));
 if(state.notes===3&&!state.deciphered)candidates.push({kind:'cipher',object:props.cipher,d:distance(p,props.cipher)});
 if(state.deciphered)candidates.push({kind:'chest',object:props.chest,d:distance(p,props.chest)});
 candidates.sort((a,b)=>a.d-b.d);return candidates[0]?.d<94?candidates[0]:null;
}
function action(){
 if(state.mode!=='playing')return;
 const n=nearestInteractable();if(!n){showToast('Approche-toi d’un indice pour interagir.',1.7);return;}
 if(n.kind==='note'){n.object.found=true;state.notes++;state.score+=100;
  showToast('Indice '+state.notes+'/3 · '+n.object.t+' !',2.8);playTone(600,.11);}
 if(n.kind==='cipher'){
  if(state.hero!==1){showToast('Seule Okuni peut déchiffrer le message. Touche 2 !',3);return;}
  state.deciphered=true;state.score+=300;state.checkpoint={x:1590,y:600};
  showToast('Okuni a décrypté le message ! Passage vers Katana ouvert.',4);playTone(690,.3);
 }
 if(n.kind==='chest'){
  state.stage=2;state.score+=700;finish(true);return;
 }
 updateHud();
}
function skill(){
 if(state.mode!=='playing')return;
 if(state.time<state.skillReady){showToast('Technique en recharge…',1);return;}
 state.skillReady=state.time+8;
 const p=state.player;
 if(state.hero===0){state.skillUntil=state.time+2.4;showToast('Eizan · course ninja accélérée !',1.7);}
 else if(state.hero===1){state.flashUntil=state.time+3.6;state.effects.push({x:p.x,y:p.y,at:state.time,color:'#d46da0'});showToast('Okuni révèle les indices autour d’elle !',2.4);}
 else{state.decoy={x:p.x+p.dx*130,y:p.y+p.dy*130,until:state.time+5};showToast('Jimmy a lancé une diversion !',2.2);}
 playTone(450+state.hero*110,.14);
}
function throwProjectile(){
 if(state.mode!=='playing'||state.time<state.throwReady)return;
 state.throwReady=state.time+.6;const p=state.player;
 state.projectiles.push({x:p.x+p.dx*26,y:p.y+p.dy*26,dx:p.dx,dy:p.dy,life:1.15});
 playTone(420,.04);
}
function finish(win){state.mode=win?'won':'lost';updateHud();$('endKicker').textContent=win?'MISSION 01 ACCOMPLIE':'MISSION INTERROMPUE';
 $('endTitle').textContent=win?'Les tongs sont retrouvées !':'L’école a besoin de toi !';
 $('endDesc').textContent=win?'Le trio a récupéré les tongs. L’enquête est terminée… jusqu’à la prochaine aventure !':'Les gardes ont eu raison de notre équipe. Recommence avec une nouvelle stratégie.';
 $('stats').textContent=`Score ${state.score} · ${Math.floor(state.time/60)} min ${Math.floor(state.time%60).toString().padStart(2,'0')} s · Alertes ${state.seen}`;
 $('endModal').classList.add('visible');if(win)playTone(830,.45);}
function playTone(f=440,length=.12){if(!state.sound)return;try{const Audio=window.AudioContext||window.webkitAudioContext;if(!Audio)return;
 if(!playTone.ac)playTone.ac=new Audio();const ac=playTone.ac,osc=ac.createOscillator(),gain=ac.createGain();osc.type='triangle';osc.frequency.setValueAtTime(f,ac.currentTime);gain.gain.setValueAtTime(.045,ac.currentTime);gain.gain.exponentialRampToValueAtTime(.001,ac.currentTime+length);osc.connect(gain);gain.connect(ac.destination);osc.start();osc.stop(ac.currentTime+length);}catch{}}
function hurt(){if(state.time-state.lastHurt<1.7)return;state.lastHurt=state.time;state.health--;state.seen++;state.effects.push({x:state.player.x,y:state.player.y,at:state.time,color:'#f45e67'});
 if(state.health<=0){finish(false);return;}showToast('Repéré ! Retour au dernier point sûr…',2);state.player.x=state.checkpoint.x;state.player.y=state.checkpoint.y;state.skillUntil=0;updateHud();playTone(160,.23);
}
function update(dt){
 if(state.mode!=='playing')return;
 state.time+=dt;state.ticks++;
 const p=state.player;
 let ix=Number(keys.has('ArrowRight')||keys.has('d')||touch.right)-Number(keys.has('ArrowLeft')||keys.has('a')||touch.left);
 let iy=Number(keys.has('ArrowDown')||keys.has('s')||touch.down)-Number(keys.has('ArrowUp')||keys.has('w')||touch.up);
 const norm=Math.hypot(ix,iy);if(norm){ix/=norm;iy/=norm;p.dx=ix;p.dy=iy;}
 const speed=heroes[state.hero].speed*(state.hero===0&&state.time<state.skillUntil?1.9:1);
 moveActor(p,ix*dt*speed,iy*dt*speed);
 if(p.x>1820&&state.deciphered&&state.checkpoint.x<1800){state.checkpoint={x:1840,y:545};showToast('Point de contrôle : école Katana',2);}
 for(const guard of state.guards){
  if(guard.stunned>state.time)continue;
  let target=guard.path[guard.waypoint];
  if(state.decoy&&state.decoy.until>state.time&&dist(guard.x,guard.y,state.decoy.x,state.decoy.y)<420){target=state.decoy;}
  else if(distance(guard,p)<210 && visibleToGuard(guard,p) && !inBush(p)){target=p;guard.alert=state.time+2;}
  else if(guard.alert>state.time){target=p;}
  const dx=target.x-guard.x,dy=target.y-guard.y,len=Math.hypot(dx,dy);
  if(len>2){const shift=guard.rate*(guard.alert>state.time?1.5:1)*dt;const nx=dx/len*shift,ny=dy/len*shift;moveActor(guard,nx,ny,18);guard.look=Math.atan2(dy,dx);}
  if(target===guard.path[guard.waypoint]&&len<12){guard.waypoint=(guard.waypoint+1)%guard.path.length;}
  if(distance(p,guard)<34){hurt();if(state.mode!=='playing')break;}
 }
 if(state.decoy&&state.decoy.until<state.time)state.decoy=null;
 const next=[];
 for(const bullet of state.projectiles){bullet.x+=bullet.dx*520*dt;bullet.y+=bullet.dy*520*dt;bullet.life-=dt;
  const impact=state.guards.find(g=>dist(g.x,g.y,bullet.x,bullet.y)<26);
  if(impact){impact.stunned=state.time+3.5;impact.alert=0;state.score+=25;state.effects.push({x:impact.x,y:impact.y,at:state.time,color:'#f9c96b'});continue;}
  if(bullet.life>0&&!collide(bullet.x,bullet.y,7))next.push(bullet);
 }
 state.projectiles=next;
 state.effects=state.effects.filter(f=>state.time-f.at<1.1);
 state.camera.x=clamp(p.x-vw/2,0,Math.max(0,W-vw));state.camera.y=clamp(p.y-vh/2,0,Math.max(0,H-vh));
 if(state.toastUntil<state.time)$('tip').classList.remove('show');
 if(state.ticks%6===0)updateHud();
}
function inBush(p){return bushes.some(b=>distance(p,b)<b.r-6);}
function visibleToGuard(g,p){let angle=Math.atan2(p.y-g.y,p.x-g.x),diff=Math.atan2(Math.sin(angle-g.look),Math.cos(angle-g.look));return Math.abs(diff)<.66;}
function ellipse(x,y,rx,ry,color,rot=0){ctx.fillStyle=color;ctx.beginPath();ctx.ellipse(x,y,rx,ry,rot,0,Math.PI*2);ctx.fill();}
function roundedRect(x,y,w,h,r,color,stroke=null){ctx.beginPath();ctx.roundRect(x,y,w,h,r);ctx.fillStyle=color;ctx.fill();if(stroke){ctx.lineWidth=2;ctx.strokeStyle=stroke;ctx.stroke();}}
function titleText(text,x,y,sz,color='#fff',align='center'){ctx.font=`900 ${sz}px 'Nunito',sans-serif`;ctx.fillStyle=color;ctx.textAlign=align;ctx.fillText(text,x,y);}
function drawWorld(){
 ctx.fillStyle=palette.ground;ctx.fillRect(0,0,W,H);
 // Lit paths and floor tiles
 roundedRect(0,408,W,370,26,'#dfc997');roundedRect(16,432,W-32,321,18,'#eddaa9');
 ctx.strokeStyle='#d2b98e';ctx.lineWidth=3;
 for(let x=0;x<W;x+=60){for(let y=445;y<750;y+=55){ctx.strokeRect(x+(Math.floor(y/55)%2)*30,y,60,55);}}
 for(let y=0;y<H;y+=75){for(let x=0;x<W;x+=80){if(y>350&&y<810)continue; ctx.fillStyle=(Math.floor(x/80+y/75)%2===0)?'#accd9f':'#a7c69a';ctx.fillRect(x,y,79,74);}}
 // Area zoning arch signs
 roundedRect(62,403,210,28,9,'#ba8c6f');titleText('SHURIKEN SCHOOL',167,422,13,'#fff2d5');
 roundedRect(885,403,260,28,9,'#ad8168');titleText('TOKIROHAMA',1015,422,13,'#fff2d5');
 roundedRect(1922,403,290,28,9,'#875961');titleText('KATANA SCHOOL',2065,422,13,'#fff2d5');
 // Fences and gate
 roundedRect(1743,0,44,433,6,'#684456');roundedRect(1743,659,44,501,6,'#684456');
 for(let y=0;y<1160;y+=31){if(y>430&&y<662)continue;roundedRect(1748,y,32,12,3,'#be7a76');}
 const gateColor=state.deciphered?'#7dcc8f':'#c04f5c';roundedRect(1744,440,43,221,8,gateColor,'#442d47');
 for(let y=455;y<643;y+=31){ctx.fillStyle='#ffeab099';ctx.fillRect(1756,y,18,4);}
 titleText(state.deciphered?'OUVERT':'SCELLÉ',1765,420,18,'#40344a');
 // Buildings
 for(const b of walls)drawBuilding(b);
 // Sakura trees (front of buildings)
 sakuras.forEach(s=>drawTree(s));
 lanterns.forEach(l=>drawLantern(l));
 bushes.forEach(b=>{ellipse(b.x,b.y+9,b.r+5,b.r*.6,'#426d5f');ellipse(b.x,b.y,b.r,b.r*.64,'#5f9673');ellipse(b.x-15,b.y-6,b.r*.52,b.r*.35,'#76b38b');});
 // Path markers
 for(let x=120;x<W;x+=230){ellipse(x,585,6,3,'#c7ab7e');ellipse(x+36,622,5,3,'#c7ab7e');}
 // Objective props
 for(const n of props.notes){if(!n.found)drawNote(n);}
 if(state.notes===3&&!state.deciphered)drawCipher();else drawStand(props.cipher.x,props.cipher.y);
 drawChest();
 if(state.decoy){const a=clamp((state.decoy.until-state.time)/5,0,1);ctx.globalAlpha=a;ellipse(state.decoy.x,state.decoy.y,31,14,'#f1c25f');titleText('♪',state.decoy.x,state.decoy.y-20,33,'#fff8a2');ctx.globalAlpha=1;}
 // Guards, field of view; canvas context manages clipping
 for(const g of state.guards){if(g.stunned<state.time){ctx.beginPath();ctx.moveTo(g.x,g.y);ctx.arc(g.x,g.y,178,g.look-.62,g.look+.62);ctx.closePath();ctx.fillStyle=g.alert>state.time?'#ee6a6460':'#e9b56942';ctx.fill();}}
 state.guards.forEach(drawGuard);
 state.projectiles.forEach(b=>{ctx.save();ctx.translate(b.x,b.y);ctx.rotate(state.time*13);ctx.strokeStyle='#fffdc7';ctx.lineWidth=3;for(let i=0;i<4;i++){ctx.rotate(Math.PI/2);ctx.beginPath();ctx.moveTo(0,0);ctx.lineTo(9,0);ctx.stroke();}ctx.restore();});
 drawPlayer();
 for(const effect of state.effects){const age=state.time-effect.at;ctx.beginPath();ctx.strokeStyle=effect.color;ctx.lineWidth=5*(1-age);ctx.arc(effect.x,effect.y,age*105,0,Math.PI*2);ctx.stroke();}
 if(state.flashUntil>state.time){ctx.lineWidth=3;ctx.strokeStyle='#ffebace6';ctx.setLineDash([12,18]);ctx.beginPath();ctx.arc(state.player.x,state.player.y,160,0,2*Math.PI);ctx.stroke();ctx.setLineDash([]);}
}
function drawBuilding(b){
 roundedRect(b.x+9,b.y+15,b.w,b.h,9,'#53646f');roundedRect(b.x,b.y,b.w,b.h,8,b.type==='katana'?'#c49a92':'#dfcfaf','#6b716c');
 roundedRect(b.x-13,b.y-13,b.w+26,38,5,b.type==='katana'?'#6d4355':'#bf645d');
 roundedRect(b.x-9,b.y+18,b.w+18,20,4,b.type==='katana'?'#794658':'#d27765');
 for(let x=b.x+16;x<b.x+b.w-20;x+=44){roundedRect(x,b.y+65,24,32,3,'#89aab0','#9b8678');ctx.fillStyle='#f1e5b7';ctx.fillRect(x+10,b.y+66,3,31);}
 roundedRect(b.x+b.w*.4,b.y+b.h-68,b.w*.2,68,5,'#93705e');roundedRect(b.x+b.w*.4+8,b.y+b.h-61,b.w*.2-16,61,5,'#54555d');
 roundedRect(b.x+b.w*.48,b.y+b.h-27,5,5,2,'#f3de9c');
}
function drawTree(s){
 ellipse(s.x,s.y+48,38,15,'#658d76');roundedRect(s.x-12,s.y,25,65,7,'#866659');
 for(let i=0;i<7;i++){const a=i*2.4;ellipse(s.x+Math.sin(a)*s.r*.52,s.y+Math.cos(a)*s.r*.36,s.r*.39,s.r*.35,i%2?'#df89ae':'#f0b3c9',a*.12);}
 ellipse(s.x,s.y,s.r*.5,s.r*.35,'#ffcfdb');
 for(let j=0;j<6;j++){ellipse(s.x+(j-3)*14,s.y+((j*19)%32)-12,4,2,'#fff1dc');}
}
function drawLantern(l){roundedRect(l.x-3,l.y,6,44,3,'#6b5a58');roundedRect(l.x-12,l.y-21,25,29,5,'#f9e6aa','#a27c6a');roundedRect(l.x-16,l.y-26,33,8,3,'#a55453');}
function drawNote(n){ellipse(n.x,n.y+16,30,10,'#4c695c88');ctx.save();ctx.translate(n.x,n.y);ctx.rotate(Math.sin(state.time*2+n.x)*.08);roundedRect(-18,-25,37,43,4,'#ffefc3','#ad8670');roundedRect(-8,-15,20,3,2,'#c78e86');roundedRect(-8,-7,15,3,2,'#c78e86');roundedRect(-8,1,20,3,2,'#c78e86');ctx.restore();drawPin(n.x,n.y-54,'!');}
function drawPin(x,y,label){const bob=Math.sin(state.time*3+x)*4;ellipse(x,y+bob,17,17,'#fff2c8');titleText(label,x,y+6+bob,22,'#ae4d65');}
function drawStand(x,y){ellipse(x,y+17,37,16,'#6d7569');roundedRect(x-31,y-26,62,40,8,'#94795d');roundedRect(x-20,y-19,40,25,4,'#d6b891');}
function drawCipher(){drawStand(props.cipher.x,props.cipher.y);drawPin(props.cipher.x,props.cipher.y-66,'?');}
function drawChest(){const p=props.chest;ellipse(p.x,p.y+27,56,19,'#55645f');roundedRect(p.x-42,p.y-28,84,64,9,'#ba7357','#694a4c');roundedRect(p.x-40,p.y-40,80,25,9,'#e4ac67','#705148');roundedRect(p.x-8,p.y-20,17,44,4,'#ffdd8a');if(state.deciphered)drawPin(p.x,p.y-80,'★');}
function drawPerson(x,y,hero,angle=0){const h=heroes[hero];ellipse(x,y+17,21,9,'#344e5580');ctx.save();ctx.translate(x,y);
 // torse, arms, face, haircut
 roundedRect(-13,-3,26,29,7,h.accent,'#35475c');ellipse(-14,2,7,12,h.color);ellipse(14,2,7,12,h.color);ellipse(0,-14,17,18,h.color);
 if(hero===0){ellipse(-3,-27,18,8,'#49364e');ellipse(10,-25,6,11,'#49364e');ctx.strokeStyle='#68be78';ctx.lineWidth=5;ctx.beginPath();ctx.moveTo(10,7);ctx.lineTo(26,-13);ctx.stroke();}
 if(hero===1){ellipse(0,-26,19,10,'#5b3556');ellipse(-18,-16,8,17,'#5b3556');ctx.strokeStyle='#ffe5b7';ctx.lineWidth=3;ctx.beginPath();ctx.arc(10,14,14,0,Math.PI*1.65);ctx.stroke();}
 if(hero===2){ellipse(0,-27,21,11,'#27435d');roundedRect(-20,-31,37,9,3,'#4d85a8');roundedRect(-20,25,43,7,4,'#4e4b54');}
 ellipse(-6,-14,2,3,'#403e4c');ellipse(6,-14,2,3,'#403e4c');ctx.restore();}
function drawPlayer(){const p=state.player;
 if(state.time-state.lastHurt<1&&Math.floor(state.time*12)%2)return;
 if(state.hero===0&&state.time<state.skillUntil){ctx.beginPath();ctx.arc(p.x,p.y,35,0,Math.PI*2);ctx.strokeStyle='#ffdc82';ctx.lineWidth=4;ctx.stroke();}
 drawPerson(p.x,p.y,state.hero);
 ctx.strokeStyle='#f6dfb3';ctx.lineWidth=3;ctx.beginPath();ctx.arc(p.x,p.y,32,-Math.PI*.8,Math.PI*.1);ctx.stroke();
 const n=nearestInteractable();if(n&&n.d<94){titleText('E / ✦',p.x,p.y-47,14,'#fff9da');}
}
function drawGuard(g){ellipse(g.x,g.y+19,21,7,'#59495777');ctx.save();ctx.translate(g.x,g.y);roundedRect(-15,-2,30,31,7,'#7e485d');ellipse(0,-15,17,17,'#c995a1');ellipse(0,-27,20,8,'#4c344a');ellipse(-7,-15,2,3,'#fff2e2');ellipse(7,-15,2,3,'#fff2e2');ctx.restore();
 if(g.stunned>state.time)titleText('✦ ✦',g.x,g.y-43,15,'#fff5a3');else if(g.alert>state.time)titleText('!',g.x,g.y-43,25,'#ff655b');}
function render(){
 const cssW=canvas.clientWidth,cssH=canvas.clientHeight;if(!cssW||!cssH)return;
 const ratio=cssW/cssH;
 if(ratio<1){vw=760;vh=Math.round(760/ratio);}else{vw=1280;vh=Math.round(1280/ratio);}
 const dpr=Math.min(window.devicePixelRatio||1,2),pxW=Math.round(cssW*dpr),pxH=Math.round(cssH*dpr);
 if(canvas.width!==pxW||canvas.height!==pxH){canvas.width=pxW;canvas.height=pxH;}
 ctx.setTransform(pxW/vw,0,0,pxH/vh,0,0);
 ctx.fillStyle='#8fbab4';ctx.fillRect(0,0,vw,vh);
 const cam=state.camera;
 ctx.save();ctx.translate(-cam.x,-cam.y);drawWorld();ctx.restore();
 if(state.mode==='start'){
  // The menu overlays this generated background.
 }
 if(state.mode==='playing'){
  const baseY=vh-13;ctx.textAlign='left';ctx.font='800 13px Nunito';ctx.fillStyle='#20374dcc';
  if(cssW>830){const recharge=Math.max(0,state.skillReady-state.time);ctx.fillText(`TECHNIQUE ${recharge>0?recharge.toFixed(1)+'s':'PRÊTE'} · LANCER : K`,14,baseY);}
 }
}
function tick(t){const dt=Math.min(.04,Math.max(0,(t-lastTime)/1000||0));lastTime=t;update(dt);render();requestAnimationFrame(tick);}
function togglePause(force){
 if(state.mode==='start'||state.mode==='won'||state.mode==='lost')return;
 const shouldPause=typeof force==='boolean'?force:state.mode==='playing';state.mode=shouldPause?'paused':'playing';$('pauseModal').classList.toggle('visible',shouldPause);updateHud();
}
// Keyboard input, with preventDefault for page scrolling.
window.addEventListener('keydown',e=>{
 const key=e.key.length===1?e.key.toLowerCase():e.key;
 if(['ArrowUp','ArrowDown','ArrowLeft','ArrowRight',' ','Escape'].includes(e.key)||['w','a','s','d'].includes(key))e.preventDefault();
 keys.add(key);
 if(e.repeat)return;
 if(key==='Escape'||key==='p')togglePause();
 if(state.mode!=='playing')return;
 if(key==='e'||key==='Enter')action();
 if(key==='1'||key==='2'||key==='3')setHero(Number(key)-1);
 if(key==='q')setHero((state.hero+1)%3);
 if(key===' '||key==='Shift')skill();
 if(key==='k'||key==='j'||key==='f')throwProjectile();
});
window.addEventListener('keyup',e=>keys.delete(e.key.length===1?e.key.toLowerCase():e.key));
window.addEventListener('blur',()=>{keys.clear();Object.keys(touch).forEach(k=>touch[k]=false);if(state.mode==='playing')togglePause(true);});
document.addEventListener('visibilitychange',()=>{if(document.hidden&&state.mode==='playing')togglePause(true);});
$('startButton').addEventListener('click',reset);
$('restartEnd').addEventListener('click',reset);
$('restartPause').addEventListener('click',reset);
$('pauseToggle').addEventListener('click',()=>togglePause());
$('resumeButton').addEventListener('click',()=>togglePause(false));
$('soundToggle').addEventListener('click',()=>{state.sound=!state.sound;$('soundToggle').textContent=state.sound?'♫ ON':'♫ OFF';});
$('actionButton').addEventListener('click',action);
$('skillButton').addEventListener('click',skill);
$('throwButton').addEventListener('click',throwProjectile);
document.querySelectorAll('.hero-choice').forEach(b=>b.addEventListener('click',()=>setHero(Number(b.dataset.hero))));
document.querySelectorAll('[data-press]').forEach(b=>{
 const dir=b.dataset.press;
 b.addEventListener('pointerdown',e=>{e.preventDefault();touch[dir]=true;b.setPointerCapture(e.pointerId);});
 b.addEventListener('pointerup',e=>{e.preventDefault();touch[dir]=false;});
 b.addEventListener('pointercancel',()=>{touch[dir]=false;});
 b.addEventListener('lostpointercapture',()=>{touch[dir]=false;});
});
// Optional developer smoke-test hooks: no network access and no hidden gameplay cheats from regular UI.
window.__shurikenDebug={snapshot:()=>({mode:state.mode,hero:state.hero,notes:state.notes,deciphered:state.deciphered,health:state.health,time:state.time,score:state.score}),start:reset};
updateHud();requestAnimationFrame(tick);
})();
