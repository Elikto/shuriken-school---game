"""Browser smoke and deterministic mission-path test against the local web game.
Run: python tests/smoke.py (requires Playwright + Chromium).
"""
from pathlib import Path
import re
from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parents[1] / 'web'

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True, executable_path='/usr/bin/chromium', args=['--no-sandbox'])
    page = browser.new_page(viewport={'width': 1440, 'height': 900}, device_scale_factor=1)
    errors=[]
    page.on('pageerror', lambda err: errors.append(str(err)))
    def load_game(target, test_hooks=False):
        html = (ROOT / 'index.html').read_text(encoding='utf-8')
        html = re.sub(r'<link rel="stylesheet" href="style.css"\s*/?>', '', html)
        html = html.replace('<script src="game.js"></script>', '')
        css = (ROOT/'style.css').read_text(encoding='utf-8')
        css = re.sub(r'@import[^;]*;', '', css)
        source = (ROOT/'game.js').read_text(encoding='utf-8')
        if test_hooks:
            find='window.__shurikenDebug={snapshot:'
            replace="window.__shurikenDebug={teleport:(x,y)=>{state.player.x=x;state.player.y=y;state.camera.x=clamp(x-vw/2,0,W-vw);state.camera.y=clamp(y-vh/2,0,H-vh);}, disableGuards:()=>{state.guards=[]}, snapshot:"
            assert find in source
            source = source.replace(find, replace)
        html=html.replace('</head>', f'<style>{css}</style></head>').replace('</body>', f'<script>{source}</script></body>')
        target.set_content(html, wait_until='load')
    load_game(page, test_hooks=True)
    assert page.locator('#startModal').is_visible()
    page.screenshot(path=str(ROOT.parent / 'capture-menu-pc.png'), full_page=True)
    page.locator('#startButton').click()
    page.wait_for_timeout(250)
    assert page.evaluate('window.__shurikenDebug.snapshot().mode') == 'playing'
    page.keyboard.press('2')
    assert page.evaluate('window.__shurikenDebug.snapshot().hero')==1
    page.keyboard.press('1')
    page.evaluate('window.__shurikenDebug.disableGuards()')
    for i, (x,y) in enumerate([(480,650),(1080,745),(1495,520)]):
        page.evaluate('([x,y])=>window.__shurikenDebug.teleport(x,y)', [x,y])
        page.keyboard.press('e')
        snap=page.evaluate('window.__shurikenDebug.snapshot()')
        assert snap['notes']==i+1, snap
    page.evaluate('window.__shurikenDebug.teleport(1570,790)')
    page.keyboard.press('e')
    assert page.evaluate('window.__shurikenDebug.snapshot().deciphered') is False
    page.keyboard.press('2')
    page.keyboard.press('e')
    assert page.evaluate('window.__shurikenDebug.snapshot().deciphered') is True
    page.screenshot(path=str(ROOT.parent / 'capture-jeu-pc.png'), full_page=True)
    page.evaluate('window.__shurikenDebug.teleport(2260,525)')
    page.keyboard.press('e')
    assert page.evaluate('window.__shurikenDebug.snapshot().mode') == 'won'
    assert page.locator('#endModal').is_visible()
    page.locator('#restartEnd').click()
    page.keyboard.press('Escape')
    assert page.locator('#pauseModal').is_visible()
    page.locator('#resumeButton').click()
    assert page.evaluate('window.__shurikenDebug.snapshot().mode')=='playing'
    assert not errors, errors
    print('PC PASS: title, start, character switch, 3 clues, Okuni-only cipher, victory, restart, pause', page.evaluate('window.__shurikenDebug.snapshot()'))

    mob = browser.new_page(viewport={'width': 390, 'height': 844}, device_scale_factor=1, is_mobile=True, has_touch=True)
    mob_errors=[]
    mob.on('pageerror', lambda err: mob_errors.append(str(err)))
    load_game(mob)
    mob.screenshot(path=str(ROOT.parent / 'capture-menu-mobile.png'), full_page=True)
    assert mob.locator('#startButton').is_visible()
    mob.locator('#startButton').click()
    assert mob.evaluate('window.__shurikenDebug.snapshot().mode') == 'playing'
    mob.locator('[data-hero="2"]').click()
    assert mob.evaluate('window.__shurikenDebug.snapshot().hero')==2
    mob.locator('#skillButton').tap()
    mob.screenshot(path=str(ROOT.parent / 'capture-jeu-mobile.png'), full_page=True)
    assert not mob_errors, mob_errors
    print('MOBILE PASS: responsive, touch hero selection and skill', mob.evaluate('window.__shurikenDebug.snapshot()'))
    browser.close()

