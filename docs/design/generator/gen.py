"""Generator for the Findar redesign canvas (Claude Design artboards).

Canvas: https://claude.ai/artifact/NXLyPR63DLLKiY4ezRvt4D  (slug ae4c8883-4a74-402f-aa01-6bfe85b6530e)
Usage:  python gen.py <out_root>   -> writes <out_root>/project/canvas.json + one .dc.html per screen,
        then publish them to the canvas with publish_files (mode "patch").
This file is the source of truth for every visual detail (exact sizes, colours, copy) of each screen;
read the matching s_<screen>() function when implementing that screen in Flutter.
Functions defined lower in the file (the "v3 overrides" block) replace earlier ones with the same name.
P1/P2/P3 are photos uploaded to the canvas (copies of findar_app/assets/find-dar-test{1,2,3}.jpg).
"""
import json, os, sys, datetime

ROOT = sys.argv[1]
PROJ = os.path.join(ROOT, "project")
os.makedirs(PROJ, exist_ok=True)

P1 = "/_blob/6a6daaf211e4d6803728ac26799d6131"   # white villa
P2 = "/_blob/487d45a6bf391df649576dbe69c0276e"   # family house
P3 = "/_blob/2031810d97b8792006fb1f1e877eaab2"   # interior

LIGHT = dict(bg="#FFFFFF", surf="#F3F4F6", surf2="#FFFFFF", line="#E4E6EA", ink="#111317", muted="#5B6170",
             accent="#0A5FC2", accentT="#E7EFFA", btn="#111317", btnText="#FFFFFF", scrim="rgba(17,19,23,0.5)",
             amber="#F5B341", green="#11734A", greenT="#E3F3EA", red="#B42318", redT="#FDECEA", tab="#FFFFFF")
DARK = dict(bg="#0E1014", surf="#1B1E24", surf2="#16191E", line="#2B2F37", ink="#F2F3F5", muted="#A3A9B5",
            accent="#6AA6F0", accentT="#16263B", btn="#F2F3F5", btnText="#111317", scrim="rgba(0,0,0,0.6)",
            amber="#F5B341", green="#5CC78F", greenT="#14281E", red="#F28B82", redT="#3A1A18", tab="#121418")
T = LIGHT
FONT = "Manrope, system-ui, sans-serif"
AR_FONT = "'IBM Plex Sans Arabic', Manrope, system-ui, sans-serif"

ICONS = {
 "home": '<path d="M3 10.5 12 3l9 7.5"></path><path d="M5 9.5V21h14V9.5"></path><path d="M10 21v-6h4v6"></path>',
 "bookmark": '<path d="M6 3.5h12v17l-6-4-6 4z"></path>',
 "listings": '<rect x="4" y="3" width="16" height="18" rx="2.5"></rect><path d="M8 8h8M8 12h8M8 16h5"></path>',
 "user": '<circle cx="12" cy="8" r="4"></circle><path d="M4 21c1.5-4 4.5-6 8-6s6.5 2 8 6"></path>',
 "search": '<circle cx="11" cy="11" r="7"></circle><path d="m20 20-3.5-3.5"></path>',
 "sliders": '<path d="M4 7h9M17 7h3M4 17h3M11 17h9"></path><circle cx="15" cy="7" r="2"></circle><circle cx="9" cy="17" r="2"></circle>',
 "bed": '<path d="M3 18V6M3 14h18v4M21 14v-2a3 3 0 0 0-3-3h-7v5"></path><circle cx="7" cy="11" r="2"></circle>',
 "bath": '<path d="M4 12h16v3a5 5 0 0 1-5 5H9a5 5 0 0 1-5-5z"></path><path d="M6 12V6a2 2 0 0 1 4 0"></path><path d="M7 20l-1 2M17 20l1 2"></path>',
 "area": '<path d="M4 9V4h5M20 9V4h-5M4 15v5h5M20 15v5h-5"></path>',
 "pin": '<path d="M12 21s-7-6.2-7-11.5a7 7 0 0 1 14 0C19 14.8 12 21 12 21z"></path><circle cx="12" cy="9.5" r="2.5"></circle>',
 "phone": '<path d="M5 4h4l2 5-2.5 1.5a11 11 0 0 0 5 5L15 13l5 2v4a2 2 0 0 1-2 2A16 16 0 0 1 3 6a2 2 0 0 1 2-2z"></path>',
 "message": '<path d="M21 12a8 8 0 0 1-11.6 7.1L4 20l1-4.6A8 8 0 1 1 21 12z"></path>',
 "back": '<path d="M15 5l-7 7 7 7"></path>',
 "chev": '<path d="m9 6 6 6-6 6"></path>',
 "chevdown": '<path d="m6 9 6 6 6-6"></path>',
 "flag": '<path d="M5 21V4M5 4h11l-2 4 2 4H5"></path>',
 "plus": '<path d="M12 5v14M5 12h14"></path>',
 "minus": '<path d="M5 12h14"></path>',
 "camera": '<path d="M4 8h3l2-3h6l2 3h3v11H4z"></path><circle cx="12" cy="13" r="3.5"></circle>',
 "image": '<rect x="3" y="4" width="18" height="16" rx="2"></rect><circle cx="9" cy="10" r="2"></circle><path d="m21 16-5-5-9 9"></path>',
 "check": '<path d="m5 12 5 5 9-10"></path>',
 "more": '<circle cx="12" cy="5" r="1.3"></circle><circle cx="12" cy="12" r="1.3"></circle><circle cx="12" cy="19" r="1.3"></circle>',
 "bolt": '<path d="M13 3 5 14h6l-1 7 8-11h-6z"></path>',
 "eyeoff": '<path d="M3 3l18 18"></path><path d="M10.6 6.1A9.8 9.8 0 0 1 12 6c5 0 9 6 9 6a16 16 0 0 1-3 3.4M6.6 6.6C4.3 8.1 3 12 3 12s4 6 9 6a9 9 0 0 0 4.4-1.1"></path>',
 "eye": '<path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z"></path><circle cx="12" cy="12" r="3"></circle>',
 "edit": '<path d="M4 20h4L19 9l-4-4L4 16z"></path><path d="m14 6 4 4"></path>',
 "trash": '<path d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3"></path>',
 "globe": '<circle cx="12" cy="12" r="9"></circle><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"></path>',
 "moon": '<path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z"></path>',
 "mail": '<rect x="3" y="5" width="18" height="14" rx="2"></rect><path d="m3 7 9 6 9-6"></path>',
 "lock": '<rect x="5" y="11" width="14" height="10" rx="2"></rect><path d="M8 11V7a4 4 0 0 1 8 0v4"></path>',
 "x": '<path d="M6 6l12 12M18 6 6 18"></path>',
 "settings": '<circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"></path>',
 "wifioff": '<path d="M3 3l18 18M8.5 16.5a5 5 0 0 1 7 0M5 13a10 10 0 0 1 5-2.7M14 10.3A10 10 0 0 1 19 13M2 9.5a15 15 0 0 1 4.5-2.8M11 5a15 15 0 0 1 11 4.5"></path><circle cx="12" cy="20" r="0.8"></circle>',
 "building": '<rect x="5" y="3" width="14" height="18" rx="1"></rect><path d="M9 7h2M13 7h2M9 11h2M13 11h2M9 15h2M13 15h2"></path>',
 "villa": '<path d="M2 21h20M4 21V11l8-6 8 6v10"></path><path d="M9 21v-5h6v5M7 11h2M15 11h2"></path>',
 "apartment": '<rect x="4" y="3" width="10" height="18" rx="1"></rect><path d="M14 9h6v12h-6M7 7h1M10 7h1M7 11h1M10 11h1M7 15h1M10 15h1"></path>',
 "studio": '<rect x="3" y="5" width="18" height="15" rx="2"></rect><path d="M3 10h18M9 10v10"></path>',
 "sort": '<path d="M7 4v16M4 17l3 3 3-3M17 20V4M14 7l3-3 3 3"></path>',
 "card": '<rect x="3" y="5" width="18" height="14" rx="2"></rect><path d="M3 10h18M7 15h4"></path>',
 "clock": '<circle cx="12" cy="12" r="9"></circle><path d="M12 7v5l3 2"></path>',
 "logout": '<path d="M15 4h4v16h-4M10 8l-4 4 4 4M6 12h10"></path>',
 "sun": '<circle cx="12" cy="12" r="4"></circle><path d="M12 2v2M12 20v2M2 12h2M20 12h2M5 5l1.4 1.4M17.6 17.6 19 19M5 19l1.4-1.4M17.6 6.4 19 5"></path>',
 "refresh": '<path d="M20 11a8 8 0 1 0-2.3 5.7M20 4v7h-7"></path>',
 "shield": '<path d="M12 3 5 6v6c0 4.5 3 7.7 7 9 4-1.3 7-4.5 7-9V6z"></path><path d="m9 12 2 2 4-4"></path>',
}

def ic(name, size=20, color=None, sw=1.8, fill="none"):
    color = color or "currentColor"
    return (f'<svg width="{size}" height="{size}" viewBox="0 0 24 24" fill="{fill}" stroke="{color}" stroke-width="{sw}" '
            f'stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="flex: none">{ICONS[name]}</svg>')

GOOGLE = ('<svg width="20" height="20" viewBox="0 0 48 48" aria-hidden="true" style="flex: none">'
 '<path fill="#FFC107" d="M43.6 20.5H42V20H24v8h11.3C33.7 32.7 29.2 36 24 36c-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.8 1.2 7.9 3.1l5.7-5.7C34 6.1 29.3 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20 20-8.9 20-20c0-1.3-.1-2.4-.4-3.5z"></path>'
 '<path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.7 15.1 19 12 24 12c3.1 0 5.8 1.2 7.9 3.1l5.7-5.7C34 6.1 29.3 4 24 4 16.3 4 9.7 8.3 6.3 14.7z"></path>'
 '<path fill="#4CAF50" d="M24 44c5.2 0 9.9-2 13.4-5.2l-6.2-5.2C29.2 35.1 26.7 36 24 36c-5.2 0-9.6-3.3-11.3-7.9l-6.5 5C9.5 39.6 16.2 44 24 44z"></path>'
 '<path fill="#1976D2" d="M43.6 20.5H42V20H24v8h11.3c-.8 2.2-2.2 4.2-4.1 5.6l6.2 5.2C37 39.2 44 34 44 24c0-1.3-.1-2.4-.4-3.5z"></path></svg>')

def logo(size, color, label="Findar"):
    # New mark: house outline with a nested "f" (from reference/logo), redrawn as vector.
    h = round(size * 80 / 104)
    return (f'<svg width="{size}" height="{h}" viewBox="0 0 104 80" fill="none" stroke="{color}" stroke-width="17" stroke-linejoin="round" '
            f'role="img" aria-label="{label}" style="flex: none">'
            '<path d="M11 80V34L52 10L93 34"></path><path d="M43 80V53L55 45.5L74 56.5"></path></svg>')

def wordmark(size, color):
    return f'<span style="font-size: {size}px; font-weight: 800; letter-spacing: -0.045em; color: {color}; line-height: 1">findar</span>'

def lockup(size, color):
    return (f'<div style="display: flex; align-items: center; gap: {round(size*0.32)}px">{logo(round(size*1.25), color, "")}'
            f'{wordmark(size, color)}</div>').replace('aria-label=""', 'aria-hidden="true"')

def zellige(pid, color, opacity=0.12, height=260, fade=True, top=0):
    """Faint 8-point-star tile pattern (zellige-inspired) for header areas."""
    mask = ("-webkit-mask-image: linear-gradient(180deg, #000 0%, rgba(0,0,0,0.6) 45%, transparent 100%); "
            "mask-image: linear-gradient(180deg, #000 0%, rgba(0,0,0,0.6) 45%, transparent 100%); ") if fade else ""
    return (f'<svg aria-hidden="true" width="100%" height="{height}" style="position: absolute; left: 0; top: {top}px; opacity: {opacity}; {mask}pointer-events: none">'
            f'<defs><pattern id="{pid}" width="44" height="44" patternUnits="userSpaceOnUse">'
            f'<g fill="none" stroke="{color}" stroke-width="1.2">'
            '<path d="M14 14H30V30H14Z"></path><path d="M22 10.7 33.3 22 22 33.3 10.7 22Z"></path>'
            '<path d="M0 0 6 6M44 0 38 6M0 44 6 38M44 44 38 38"></path></g></pattern></defs>'
            f'<rect width="100%" height="100%" fill="url(#{pid})"></rect></svg>')

SKY = ('<path d="M0 119H390"></path>'
       '<path d="M8 119V60H58V119"></path><path d="M18 82v-8a5 5 0 0 1 10 0v8M38 82v-8a5 5 0 0 1 10 0v8M18 104v-8a5 5 0 0 1 10 0v8M38 104v-8a5 5 0 0 1 10 0v8"></path>'
       '<path d="M66 119V72H116V119"></path><path d="M71 72a20 20 0 0 1 40 0"></path><path d="M91 52V44"></path><path d="M84 119V102a7 7 0 0 1 14 0V119"></path>'
       '<path d="M124 119V34H166V119"></path><path d="M134 46h6M150 46h6M134 60h6M150 60h6M134 74h6M150 74h6M134 88h6M150 88h6M134 102h6M150 102h6"></path>'
       '<path d="M176 119V80L206 58L236 80V119"></path><path d="M200 119V101H212V119"></path><path d="M192 84h8M212 84h8"></path>'
       '<path d="M244 119V86H316V119"></path><path d="M252 119V102a8 8 0 0 1 16 0V119M272 119V102a8 8 0 0 1 16 0V119M292 119V102a8 8 0 0 1 16 0V119"></path>'
       '<path d="M324 119V52H372V119"></path><path d="M330 70H366M330 90H366M340 52V44H356V52"></path>'
       '<path d="M381 119V98"></path><circle cx="381" cy="90" r="8"></circle>')

def skyline(color, bottom=0, opacity=1.0, height=120, extra=""):
    """Line drawing of an Algiers-style street: arched windows, a dome, flats, a pitched-roof house, an arcade."""
    return (f'<svg aria-hidden="true" width="390" height="{height}" viewBox="0 0 390 120" fill="none" stroke="{color}" stroke-width="1.4" '
            f'stroke-linecap="round" stroke-linejoin="round" style="position: absolute; left: 0; bottom: {bottom}px; opacity: {opacity}; pointer-events: none; {extra}">{SKY}</svg>')

def spot(icon_svg, size=120):
    """Empty-state / success illustration: tinted disc, faint rings, mark or icon in the middle."""
    return (f'<div aria-hidden="true" style="position: relative; width: {size}px; height: {size}px; flex: none">'
            f'<svg width="{size}" height="{size}" viewBox="0 0 120 120" fill="none" style="position: absolute; inset: 0">'
            f'<circle cx="60" cy="60" r="59" stroke="{T["accent"]}" stroke-opacity="0.18" stroke-dasharray="3 5"></circle>'
            f'<circle cx="60" cy="60" r="46" fill="{T["accentT"]}"></circle>'
            f'<circle cx="104" cy="30" r="4" fill="{T["amber"]}"></circle><circle cx="16" cy="84" r="3" fill="{T["accent"]}" fill-opacity="0.5"></circle></svg>'
            f'<div style="position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; color: {T["accent"]}">{icon_svg}</div></div>')

def skyc():
    return "#CBD1DA" if T is LIGHT else "#353B45"

def deco(pid, sky_bottom=None, pat=True, h=260):
    out = zellige(pid, T["accent"], 0.13 if T is LIGHT else 0.22, h) if pat else ""
    if sky_bottom is not None:
        out += skyline(skyc(), sky_bottom)
    return out

def fmt(n):
    s = f"{int(n):,}".replace(",", " ")
    return s

# ---------- data ----------
L = [
 dict(id="villa", title="Villa with garden", loc="Hydra, Algiers", price=52000000, kind="sale", type="Villa", bd=5, ba=3, m2=320, img=P1, boosted=True),
 dict(id="flat", title="Apartment F4", loc="Bab Ezzouar, Algiers", price=65000, kind="rent", type="Apartment", bd=3, ba=1, m2=90, img=P3, boosted=True),
 dict(id="house", title="Family house", loc="Blida", price=18000000, kind="sale", type="House", bd=4, ba=2, m2=210, img=P2, boosted=False),
 dict(id="studio", title="Furnished studio", loc="Oran", price=30000, kind="rent", type="Studio", bd=1, ba=1, m2=35, img=P3, boosted=False),
 dict(id="office", title="Office space", loc="Didouche Mourad, Algiers", price=120000, kind="rent", type="Office", bd=0, ba=2, m2=140, img=None, boosted=False),
 dict(id="kouba", title="Apartment F3", loc="Kouba, Algiers", price=45000, kind="rent", type="Apartment", bd=2, ba=1, m2=70, img=P1, boosted=False),
]

# ---------- primitives ----------
def page(title, body, w=390, h=844, lang="en", dirn="ltr", arabic=False):
    fonts = "family=Manrope:wght@400;500;600;700;800"
    if arabic:
        fonts += "&amp;family=IBM+Plex+Sans+Arabic:wght@400;500;600;700"
    return f'''<!doctype html>
<html lang="{lang}" dir="{dirn}">
<head>
<meta charset="utf-8">
<title>{title}</title>
<script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?{fonts}&amp;display=swap">
<style>
body{{margin:0}}
a{{color:#0A5FC2}}a:hover{{color:#084A97}}
input::placeholder,textarea::placeholder{{color:#6B7280}}
</style>
</helmet>
{body}
</x-dc>
<script type="text/x-dc" data-dc-script data-props='{{"$preview":{{"width":{w},"height":{h}}}}}'>
class Component extends DCLogic {{
renderVals() {{
return {{}};
}}
}}
</script>
</body>
</html>
'''

def phone(inner, h=844, font=FONT, dirn=None):
    d = f' dir="{dirn}"' if dirn else ""
    return (f'<div{d} style="width: 390px; height: {h}px; position: relative; overflow: hidden; box-sizing: border-box; '
            f'background: {T["bg"]}; color: {T["ink"]}; font-family: {font}; -webkit-font-smoothing: antialiased">{inner}</div>')

def iconbtn(name, label, bg=None, color=None, size=44, border=True, isz=20):
    bg = bg or T["bg"]; color = color or T["ink"]
    b = f"1px solid {T['line']}" if border else "none"
    return (f'<button aria-label="{label}" style="width: {size}px; height: {size}px; border-radius: 999px; background: {bg}; color: {color}; '
            f'border: {b}; display: flex; align-items: center; justify-content: center; padding: 0; flex: none">{ic(name, isz)}</button>')

def topbar(title, left=("back", "Back"), right=None):
    l = iconbtn(*left) if left else '<div style="width: 44px"></div>'
    r = right if right is not None else '<div style="width: 44px"></div>'
    return (f'<div style="position: relative; height: 56px; margin-top: 44px; padding: 0 16px; display: flex; align-items: center; justify-content: space-between; gap: 12px">'
            f'{l}<h1 style="margin: 0; font-size: 17px; font-weight: 700; letter-spacing: -0.01em">{title}</h1>{r}</div>')

def btn(text, kind="primary", icon=None, w="100%", h=52, extra=""):
    if kind == "primary":
        st = f"background: {T['btn']}; color: {T['btnText']}; border: none"
    elif kind == "accent":
        st = f"background: {T['accent']}; color: #FFFFFF; border: none"
    elif kind == "danger":
        st = f"background: {T['bg']}; color: {T['red']}; border: 1px solid {T['line']}"
    else:
        st = f"background: {T['bg']}; color: {T['ink']}; border: 1px solid {T['line']}"
    i = GOOGLE if icon == "google" else (ic(icon, 20) if icon else "")
    return (f'<button style="width: {w}; height: {h}px; border-radius: 999px; {st}; font-family: inherit; font-size: 16px; font-weight: 700; '
            f'display: flex; align-items: center; justify-content: center; gap: 10px; flex: none; {extra}">{i}<span>{text}</span></button>')

def chip(text, active=False, icon=None, h=38, small=False):
    if active:
        st = f"background: {T['btn']}; color: {T['btnText']}; border: 1px solid {T['btn']}"
    else:
        st = f"background: {T['bg']}; color: {T['ink']}; border: 1px solid {T['line']}"
    i = ic(icon, 16) if icon else ""
    fs = 13 if small else 14
    return (f'<button style="height: {h}px; padding: 0 16px; border-radius: 999px; {st}; font-family: inherit; font-size: {fs}px; font-weight: 600; '
            f'display: flex; align-items: center; gap: 6px; white-space: nowrap; flex: none">{i}{text}</button>')

def segmented(items, active, h=44):
    out = ""
    for it in items:
        if it == active:
            st = f"background: {T['bg']}; color: {T['ink']}; box-shadow: 0 1px 3px rgba(0,0,0,0.12)"
        else:
            st = f"background: transparent; color: {T['muted']}"
        out += (f'<button style="flex: 1; height: {h-8}px; border: none; border-radius: 999px; {st}; font-family: inherit; font-size: 14px; '
                f'font-weight: 700">{it}</button>')
    return f'<div style="display: flex; gap: 4px; padding: 4px; border-radius: 999px; background: {T["surf"]}">{out}</div>'

def field(label, value="", placeholder="", icon=None, trailing="", ftype="text", textarea=False, fid=None, h=52, focused=False):
    fid = fid or label.lower().replace(" ", "-").replace("(", "").replace(")", "").replace("²", "2")
    i = f'<span style="color: {T["muted"]}; display: flex">{ic(icon, 20)}</span>' if icon else ""
    border = f"1.5px solid {T['accent']}" if focused else f"1px solid {T['surf']}"
    common = f'style="flex: 1; min-width: 0; border: none; outline: none; background: transparent; font-family: inherit; font-size: 15px; font-weight: 500; color: {T["ink"]}'
    if textarea:
        ctl = f'<textarea id="{fid}" rows="4" placeholder="{placeholder}" {common}; resize: none; line-height: 1.5; padding: 14px 0">{value}</textarea>'
        box = f'<div style="display: flex; gap: 10px; padding: 0 16px; border-radius: 16px; background: {T["surf"]}; border: {border}">{ctl}</div>'
    else:
        ctl = f'<input id="{fid}" type="{ftype}" value="{value}" placeholder="{placeholder}" {common}">'
        box = (f'<div style="height: {h}px; display: flex; align-items: center; gap: 10px; padding: 0 16px; border-radius: 16px; '
               f'background: {T["surf"]}; border: {border}; box-sizing: border-box">{i}{ctl}{trailing}</div>')
    return (f'<div style="display: flex; flex-direction: column; gap: 8px">'
            f'<label for="{fid}" style="font-size: 13px; font-weight: 700; color: {T["ink"]}">{label}</label>{box}</div>')

def tabbar(active, labels=("Home", "Saved", "My listings", "Profile"), font=FONT):
    names = ["home", "bookmark", "listings", "user"]
    out = ""
    for n, lab in zip(names, labels):
        on = lab == active or n == active
        c = T["ink"] if on else T["muted"]
        fill = T["ink"] if (on and n in ("home", "bookmark")) else "none"
        dot = f'<span style="width: 4px; height: 4px; border-radius: 9px; background: {T["accent"]}"></span>' if on else '<span style="width: 4px; height: 4px"></span>'
        out += (f'<a href="#" style="flex: 1; display: flex; flex-direction: column; align-items: center; gap: 4px; color: {c}; text-decoration: none; '
                f'font-size: 11px; font-weight: {800 if on else 600}; padding-top: 10px">{ic(n, 24, fill=fill if n!="home" else "none")}<span>{lab}</span>{dot}</a>')
    return (f'<nav aria-label="Main" style="position: absolute; left: 0; right: 0; bottom: 0; height: 86px; background: {T["tab"]}; '
            f'border-top: 1px solid {T["line"]}; display: flex; box-sizing: border-box; padding: 0 8px; font-family: {font}">{out}</nav>')

def price(l, size=20, rent_word="/ month", cur="DA"):
    s = f'<span style="font-size: {size}px; font-weight: 800; letter-spacing: -0.02em">{fmt(l["price"])} {cur}</span>'
    if l["kind"] == "rent":
        s += f'<span style="font-size: {max(12, size-7)}px; font-weight: 600; color: {T["muted"]}"> {rent_word}</span>'
    return f'<div style="display: flex; align-items: baseline; gap: 2px; white-space: nowrap">{s}</div>'

def stats(l, size=13, labels=None):
    parts = []
    if l["bd"]:
        parts.append(("bed", f'{l["bd"]} bd' if not labels else f'{l["bd"]} {labels[0]}'))
    parts.append(("bath", f'{l["ba"]} ba' if not labels else f'{l["ba"]} {labels[1]}'))
    parts.append(("area", f'{l["m2"]} m²'))
    out = "".join(f'<span style="display: flex; align-items: center; gap: 5px">{ic(i, 16)}{t}</span>' for i, t in parts)
    return f'<div style="display: flex; gap: 14px; font-size: {size}px; font-weight: 600; color: {T["muted"]}">{out}</div>'

def photo(l, w, h, r=20, extra=""):
    if l["img"]:
        return f'<img src="{l["img"]}" alt="{l["title"]}, {l["loc"]}" style="width: {w}; height: {h}px; object-fit: cover; border-radius: {r}px; display: block; {extra}">'
    return (f'<div role="img" aria-label="No photo" style="width: {w}; height: {h}px; border-radius: {r}px; background: {T["surf"]}; color: {T["muted"]}; '
            f'display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 6px; font-size: 12px; font-weight: 600; {extra}">'
            f'{ic("building", 28)}<span>No photo</span></div>')

def boosted_badge(text="Boosted"):
    return (f'<span style="display: inline-flex; align-items: center; gap: 4px; height: 26px; padding: 0 10px; border-radius: 999px; '
            f'background: {T["amber"]}; color: #111317; font-size: 12px; font-weight: 800">{ic("bolt", 14, fill="#111317", sw=1.2)}{text}</span>')

def save_btn(saved=False, size=40):
    fill = "#111317" if saved else "none"
    return (f'<button aria-label="{"Remove from saved" if saved else "Save"}" style="width: {size}px; height: {size}px; border-radius: 999px; border: none; '
            f'background: rgba(255,255,255,0.94); color: #111317; display: flex; align-items: center; justify-content: center; padding: 0">{ic("bookmark", 20, fill=fill)}</button>')

def feature_card(l, w=296, saved=False, rent_word="/ month", labels=None, badge="Boosted", cur="DA"):
    return (f'<article style="width: {w}px; flex: none; display: flex; flex-direction: column; gap: 10px">'
            f'<div style="position: relative">{photo(l, f"{w}px", 196)}'
            f'<div style="position: absolute; top: 12px; inset-inline-start: 12px">{boosted_badge(badge) if l["boosted"] else ""}</div>'
            f'<div style="position: absolute; top: 10px; inset-inline-end: 10px">{save_btn(saved)}</div></div>'
            f'<div style="display: flex; flex-direction: column; gap: 4px; padding: 0 2px">{price(l, 20, rent_word, cur)}'
            f'<div style="font-size: 15px; font-weight: 700">{l["title"]}</div>'
            f'<div style="display: flex; align-items: center; gap: 4px; font-size: 13px; color: {T["muted"]}; font-weight: 500">{ic("pin", 15)}{l["loc"]}</div>'
            f'<div style="margin-top: 4px">{stats(l, 13, labels)}</div></div></article>')

def row_card(l, saved=False, rent_word="/ month", labels=None, cur="DA", tail=None):
    t = tail if tail is not None else save_btn(saved, 36).replace("rgba(255,255,255,0.94)", T["surf"]).replace("color: #111317", f"color: {T['ink']}").replace('fill="#111317"', f'fill="{T["ink"]}"')
    return (f'<article style="display: flex; gap: 14px; align-items: stretch">{photo(l, "104px", 104, 16, "flex: none")}'
            f'<div style="flex: 1; min-width: 0; display: flex; flex-direction: column; justify-content: center; gap: 4px">'
            f'<div style="font-size: 15px; font-weight: 700; white-space: nowrap; overflow: hidden; text-overflow: ellipsis">{l["title"]}</div>'
            f'<div style="display: flex; align-items: center; gap: 4px; font-size: 13px; color: {T["muted"]}; font-weight: 500">{ic("pin", 14)}{l["loc"]}</div>'
            f'{price(l, 16, rent_word, cur)}{stats(l, 12, labels)}</div>'
            f'<div style="align-self: flex-start">{t}</div></article>')

def section_head(title, action="View all"):
    a = f'<a href="#" style="font-size: 14px; font-weight: 700; color: {T["accent"]}; text-decoration: none">{action}</a>' if action else ""
    return (f'<div style="display: flex; align-items: center; justify-content: space-between">'
            f'<h2 style="margin: 0; font-size: 19px; font-weight: 800; letter-spacing: -0.02em">{title}</h2>{a}</div>')

def avatar(initials, size=48, bg=None, color=None, fs=None):
    bg = bg or T["accentT"]; color = color or T["accent"]; fs = fs or round(size * 0.36)
    return (f'<div aria-hidden="true" style="width: {size}px; height: {size}px; border-radius: 999px; background: {bg}; color: {color}; flex: none; '
            f'display: flex; align-items: center; justify-content: center; font-size: {fs}px; font-weight: 800">{initials}</div>')

def toggle(on=True):
    bg = T["accent"] if on else T["line"]
    pos = "flex-end" if on else "flex-start"
    return (f'<span aria-hidden="true" style="width: 50px; height: 30px; border-radius: 999px; background: {bg}; display: flex; justify-content: {pos}; '
            f'align-items: center; padding: 3px; box-sizing: border-box; flex: none"><span style="width: 24px; height: 24px; border-radius: 99px; background: #FFFFFF; box-shadow: 0 1px 2px rgba(0,0,0,0.2)"></span></span>')

def bottom_bar(inner, h=104):
    return (f'<div style="position: absolute; left: 0; right: 0; bottom: 0; min-height: {h}px; box-sizing: border-box; padding: 14px 20px 34px; '
            f'background: {T["bg"]}; border-top: 1px solid {T["line"]}; display: flex; align-items: center; gap: 12px">{inner}</div>')

def content(inner, top=0, pad=20, gap=24, bottom=0):
    return f'<div style="position: relative; padding: {top}px {pad}px {bottom}px; display: flex; flex-direction: column; gap: {gap}px">{inner}</div>'

def number_pills(active, opts=("Any", "1", "2", "3", "4+")):
    return '<div style="display: flex; gap: 8px">' + "".join(
        f'<button style="min-width: 48px; height: 44px; padding: 0 12px; border-radius: 999px; font-family: inherit; font-size: 14px; font-weight: 700; '
        + (f'background: {T["btn"]}; color: {T["btnText"]}; border: 1px solid {T["btn"]}' if o == active else f'background: {T["bg"]}; color: {T["ink"]}; border: 1px solid {T["line"]}')
        + f'">{o}</button>' for o in opts) + '</div>'

def label(t):
    return f'<div style="font-size: 15px; font-weight: 800">{t}</div>'

def divider():
    return f'<div style="height: 1px; background: {T["line"]}"></div>'

def stepper(name, val):
    b = lambda i, lab: (f'<button aria-label="{lab}" style="width: 40px; height: 40px; border-radius: 999px; border: 1px solid {T["line"]}; background: {T["bg"]}; '
                        f'color: {T["ink"]}; display: flex; align-items: center; justify-content: center; padding: 0">{ic(i, 18)}</button>')
    return (f'<div style="flex: 1; display: flex; flex-direction: column; gap: 8px"><div style="font-size: 13px; font-weight: 700">{name}</div>'
            f'<div style="height: 52px; border-radius: 16px; background: {T["surf"]}; display: flex; align-items: center; justify-content: space-between; padding: 0 6px">'
            f'{b("minus", "Decrease " + name)}<span style="font-size: 17px; font-weight: 800">{val}</span>{b("plus", "Increase " + name)}</div></div>')

def menu_row(icon, text, trailing=None, color=None, sub=None):
    c = color or T["ink"]
    tr = trailing if trailing is not None else f'<span style="color: {T["muted"]}; display: flex">{ic("chev", 18)}</span>'
    s = f'<div style="font-size: 13px; color: {T["muted"]}; font-weight: 500">{sub}</div>' if sub else ""
    return (f'<a href="#" style="min-height: 56px; display: flex; align-items: center; gap: 14px; text-decoration: none; color: {c}">'
            f'<span style="width: 40px; height: 40px; border-radius: 12px; background: {T["surf"]}; display: flex; align-items: center; justify-content: center; flex: none">{ic(icon, 20)}</span>'
            f'<div style="flex: 1"><div style="font-size: 15px; font-weight: 700">{text}</div>{s}</div>{tr}</a>')

def card(inner, pad=16, gap=0, extra=""):
    return f'<div style="border: 1px solid {T["line"]}; border-radius: 20px; padding: {pad}px; display: flex; flex-direction: column; gap: {gap}px; {extra}">{inner}</div>'

# ---------- screens ----------
B = {}

def s_splash(dark=False):
    global T
    T = DARK if dark else LIGHT
    tile = (f'<div style="width: 116px; height: 116px; border-radius: 32px; background: #0A5FC2; display: flex; align-items: center; justify-content: center; '
            f'box-shadow: 0 18px 40px rgba(10,95,194,{0.45 if dark else 0.28})">{logo(68, "#FFFFFF")}</div>')
    inner = (zellige("spl" + ("d" if dark else ""), T["accent"], 0.22 if dark else 0.14, 460)
             + '<div style="position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 22px; padding-bottom: 60px">'
             + tile + wordmark(40, T["ink"])
             + f'<div style="font-size: 15px; color: {T["muted"]}; font-weight: 600; margin-top: -8px">Your property marketplace</div></div>'
             + f'<div aria-hidden="true" style="position: absolute; left: 50%; bottom: 168px; transform: translateX(-50%); width: 120px; height: 4px; border-radius: 9px; background: {T["surf"]}; overflow: hidden">'
             + f'<div style="width: 44px; height: 4px; border-radius: 9px; background: {T["accent"]}"></div></div>'
             + skyline(skyc(), 0, 1, 120))
    out = page("Splash" + (", dark" if dark else ""), phone(inner))
    T = LIGHT
    return out

def s_splash_dark():
    return s_splash(True)

def s_welcome():
    inner = (f'<div style="position: absolute; inset: 0 0 auto 0; height: 520px">'
             f'<img src="{P1}" alt="White villa with a tiled roof" style="width: 100%; height: 100%; object-fit: cover; display: block">'
             f'<div style="position: absolute; inset: 0; background: linear-gradient(180deg, rgba(0,0,0,0.35) 0%, rgba(0,0,0,0) 30%, rgba(0,0,0,0) 55%, rgba(0,0,0,0.55) 100%)"></div>'
             f'<div style="position: absolute; top: 60px; left: 24px">{lockup(24, "#FFFFFF")}</div>'
             f'<h1 style="position: absolute; left: 24px; right: 24px; bottom: 54px; margin: 0; color: #FFFFFF; font-size: 36px; line-height: 1.08; font-weight: 800; letter-spacing: -0.03em">Find a place<br>to call home.</h1></div>'
             f'<div style="position: absolute; left: 0; right: 0; bottom: 0; top: 488px; background: {T["bg"]}; border-radius: 28px 28px 0 0; padding: 14px 24px 34px; box-sizing: border-box; display: flex; flex-direction: column; gap: 14px">'
             f'<div style="width: 40px; height: 4px; border-radius: 9px; background: {T["line"]}; align-self: center"></div>'
             f'<p style="margin: 4px 0 6px; font-size: 15px; line-height: 1.5; color: {T["muted"]}; font-weight: 500">Houses, apartments, villas, studios and offices for sale or rent across Algeria.</p>'
             f'<div style="display: flex; gap: 10px">{btn("Log in", w="50%")}{btn("Create account", "secondary", w="50%")}</div>'
             f'<div style="display: flex; align-items: center; gap: 12px; color: {T["muted"]}; font-size: 13px; font-weight: 600"><span style="flex: 1; height: 1px; background: {T["line"]}"></span>or<span style="flex: 1; height: 1px; background: {T["line"]}"></span></div>'
             f'{btn("Continue with Google", "secondary", icon="google")}</div>')
    return page("Welcome", phone(inner))

def s_login():
    eye = f'<button aria-label="Show password" style="border: none; background: none; color: {T["muted"]}; padding: 0; display: flex">{ic("eye", 20)}</button>'
    inner = (deco("lg", 70) + topbar("") +
             content(f'<div style="display: flex; flex-direction: column; gap: 8px"><h1 style="margin: 0; font-size: 30px; font-weight: 800; letter-spacing: -0.03em">Welcome back</h1>'
                     f'<p style="margin: 0; color: {T["muted"]}; font-size: 15px; font-weight: 500">Log in to save listings and contact owners.</p></div>'
                     + field("Email address", "sara.meziane@gmail.com", icon="mail", ftype="email")
                     + field("Password", "••••••••••", icon="lock", ftype="password", trailing=eye, focused=True)
                     + f'<a href="#" style="align-self: flex-end; font-size: 14px; font-weight: 700; text-decoration: none; margin-top: -10px">Forgot password?</a>'
                     + btn("Log in")
                     + f'<div style="display: flex; align-items: center; gap: 12px; color: {T["muted"]}; font-size: 13px; font-weight: 600"><span style="flex: 1; height: 1px; background: {T["line"]}"></span>or<span style="flex: 1; height: 1px; background: {T["line"]}"></span></div>'
                     + btn("Continue with Google", "secondary", icon="google"), top=8, gap=20)
             + f'<p style="position: absolute; bottom: 40px; left: 0; right: 0; text-align: center; margin: 0; font-size: 14px; color: {T["muted"]}; font-weight: 500">Don\'t have an account? <a href="#" style="font-weight: 800; text-decoration: none">Register</a></p>')
    return page("Log in", phone(inner))

def s_register():
    rule = lambda t, ok: (f'<span style="display: flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 700; color: {T["green"] if ok else T["muted"]}">'
                          f'{ic("check" if ok else "minus", 14)}{t}</span>')
    acct = lambda t, sub, on: (f'<button style="flex: 1; text-align: start; padding: 14px; border-radius: 16px; font-family: inherit; background: {T["accentT"] if on else T["bg"]}; '
                               f'border: {"2px solid " + T["accent"] if on else "1px solid " + T["line"]}; color: {T["ink"]}; display: flex; flex-direction: column; gap: 4px">'
                               f'<span style="font-size: 15px; font-weight: 800">{t}</span><span style="font-size: 12px; color: {T["muted"]}; font-weight: 500">{sub}</span></button>')
    inner = (deco("rg", h=200) + topbar("Create account") +
             content(f'<div style="display: flex; flex-direction: column; gap: 8px"><div style="font-size: 13px; font-weight: 700">Account type</div>'
                     f'<div style="display: flex; gap: 10px">{acct("Individual", "Buying, renting or selling my own place", True)}{acct("Agency", "Listing properties for clients", False)}</div></div>'
                     + field("Full name", "Sara Meziane", icon="user")
                     + field("Email address", "sara.meziane@gmail.com", icon="mail", ftype="email")
                     + field("Phone number", "0555 12 34 56", icon="phone", ftype="tel")
                     + field("Password", "••••••••", icon="lock", ftype="password", focused=True)
                     + f'<div style="display: flex; flex-wrap: wrap; gap: 8px 14px; margin-top: -8px">{rule("8+ characters", True)}{rule("Uppercase", True)}{rule("Lowercase", True)}{rule("Number", False)}</div>',
                     top=4, gap=16)
             + bottom_bar(btn("Complete registration")))
    return page("Register", phone(inner))

def s_photo_setup():
    inner = (deco("ps", 0) + topbar("", right=f'<a href="#" style="font-size: 15px; font-weight: 700; text-decoration: none; padding: 10px 4px">Skip</a>') +
             content(f'<div style="display: flex; flex-direction: column; gap: 8px; text-align: center; align-items: center; margin-top: 24px">'
                     f'<h1 style="margin: 0; font-size: 28px; font-weight: 800; letter-spacing: -0.03em">Add a profile photo</h1>'
                     f'<p style="margin: 0; color: {T["muted"]}; font-size: 15px; font-weight: 500; max-width: 280px; line-height: 1.5">Buyers and owners are more likely to reply when they can see who they\'re talking to.</p></div>'
                     f'<div style="align-self: center; position: relative; margin: 20px 0">'
                     f'<div style="width: 168px; height: 168px; border-radius: 999px; border: 2px dashed {T["line"]}; background: {T["surf"]}; display: flex; align-items: center; justify-content: center; color: {T["muted"]}">{ic("user", 64, sw=1.4)}</div>'
                     f'<span style="position: absolute; right: 6px; bottom: 6px; width: 44px; height: 44px; border-radius: 999px; background: {T["accent"]}; color: #FFFFFF; display: flex; align-items: center; justify-content: center; border: 3px solid {T["bg"]}">{ic("camera", 20)}</span></div>'
                     + btn("Choose from gallery", icon="image") + btn("Take a photo", "secondary", icon="camera"), top=8, gap=14))
    return page("Profile photo", phone(inner))

def s_forgot():
    inner = (deco("fp", 0) + topbar("") +
             content(f'<div style="display: flex; flex-direction: column; gap: 8px"><h1 style="margin: 0; font-size: 30px; font-weight: 800; letter-spacing: -0.03em">Reset password</h1>'
                     f'<p style="margin: 0; color: {T["muted"]}; font-size: 15px; font-weight: 500; line-height: 1.5">We\'ll email you a verification code.</p></div>'
                     + field("Email address", "sara.meziane@gmail.com", icon="mail", ftype="email")
                     + f'<div style="display: flex; gap: 10px; align-items: center; padding: 12px 14px; border-radius: 14px; background: {T["greenT"]}; color: {T["green"]}; font-size: 14px; font-weight: 700">{ic("check", 18)}Code sent. Check your inbox.</div>'
                     + field("Verification code", "", "Enter the code", icon="shield", fid="code", focused=True)
                     + btn("Verify code")
                     + f'<p style="margin: 0; text-align: center; font-size: 14px; color: {T["muted"]}; font-weight: 500">Didn\'t get it? <a href="#" style="font-weight: 800; text-decoration: none">Resend code</a></p>',
                     top=8, gap=20))
    return page("Forgot password", phone(inner))

def s_reset():
    rule = lambda t, ok: (f'<span style="display: flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 700; color: {T["green"] if ok else T["muted"]}">{ic("check" if ok else "minus", 14)}{t}</span>')
    inner = (deco("rp", 104) + topbar("") +
             content(f'<div style="display: flex; flex-direction: column; gap: 8px"><h1 style="margin: 0; font-size: 30px; font-weight: 800; letter-spacing: -0.03em">New password</h1>'
                     f'<p style="margin: 0; color: {T["muted"]}; font-size: 15px; font-weight: 500">Choose a password you haven\'t used before.</p></div>'
                     + field("New password", "••••••••••", icon="lock", ftype="password")
                     + f'<div style="display: flex; flex-wrap: wrap; gap: 8px 14px; margin-top: -8px">{rule("8+ characters", True)}{rule("Uppercase", True)}{rule("Lowercase", True)}{rule("Number", True)}</div>'
                     + field("Confirm password", "••••••••••", icon="lock", ftype="password", fid="confirm", focused=True),
                     top=8, gap=20)
             + bottom_bar(btn("Update password")))
    return page("Reset password", phone(inner))

HOME_EN = dict(hello="Hello, Sara", headline="Find your next place", search="Search city or district", chips=("All", "For sale", "For rent"),
               sponsored="Sponsored", recent="Recent listings", viewall="View all", month="/ month", labels=None, tabs=("Home", "Saved", "My listings", "Profile"),
               badge="Boosted", cur="DA", settings="Settings", filters="Filters")
HOME_AR = dict(hello="مرحبًا، سارة", headline="اعثر على منزلك القادم", search="ابحث عن مدينة أو حي", chips=("الكل", "للبيع", "للإيجار"),
               sponsored="عقارات مميزة", recent="أحدث الإعلانات", viewall="عرض الكل", month="/ شهر", labels=("غرف", "حمّام"), tabs=("الرئيسية", "المحفوظات", "إعلاناتي", "حسابي"),
               badge="مُروَّج", cur="دج", settings="الإعدادات", filters="الفلاتر")
AR_LIST = {
 "villa": dict(title="فيلا مع حديقة", loc="حيدرة، الجزائر"),
 "flat": dict(title="شقة F4", loc="باب الزوار، الجزائر"),
 "house": dict(title="منزل عائلي", loc="البليدة"),
 "studio": dict(title="استوديو مفروش", loc="وهران"),
}

def home_body(s, lst, font=FONT):
    head = (f'<div style="display: flex; align-items: center; justify-content: space-between; gap: 12px">'
            f'<div style="display: flex; flex-direction: column; gap: 2px"><span style="font-size: 14px; color: {T["muted"]}; font-weight: 600">{s["hello"]}</span>'
            f'<h1 style="margin: 0; font-size: 26px; font-weight: 800; letter-spacing: -0.03em">{s["headline"]}</h1></div>'
            f'{iconbtn("settings", s["settings"], bg=T["surf"], border=False)}</div>')
    search = (f'<div style="display: flex; gap: 10px"><label style="flex: 1; height: 52px; border-radius: 999px; background: {T["surf"]}; display: flex; align-items: center; gap: 10px; padding: 0 18px; color: {T["muted"]}">'
              f'{ic("search", 20)}<input aria-label="{s["search"]}" placeholder="{s["search"]}" style="flex: 1; min-width: 0; border: none; outline: none; background: transparent; font-family: inherit; font-size: 15px; font-weight: 500; color: {T["ink"]}"></label>'
              f'{iconbtn("sliders", s["filters"], bg=T["btn"], color=T["btnText"], size=52, border=False, isz=22)}</div>')
    chips = '<div style="display: flex; gap: 8px">' + "".join(chip(c, i == 0) for i, c in enumerate(s["chips"])) + "</div>"
    carousel = (f'<div style="display: flex; gap: 14px; margin: 0 -20px; padding: 0 20px; overflow: hidden">'
                + feature_card(lst[0], saved=True, rent_word=s["month"], labels=s["labels"], badge=s["badge"], cur=s["cur"])
                + feature_card(lst[1], rent_word=s["month"], labels=s["labels"], badge=s["badge"], cur=s["cur"]) + '</div>')
    recent = "".join(row_card(l, rent_word=s["month"], labels=s["labels"], cur=s["cur"]) for l in lst[2:4])
    inner = deco("hm" + ("d" if T is DARK else "") + ("a" if s["cur"] != "DA" else ""), h=230) + content(head + search + chips
                    + f'<div style="display: flex; flex-direction: column; gap: 14px">{section_head(s["sponsored"], s["viewall"])}{carousel}</div>'
                    + f'<div style="display: flex; flex-direction: column; gap: 14px">{section_head(s["recent"], None)}{recent}</div>',
                    top=56, gap=20)
    return inner + tabbar(s["tabs"][0], s["tabs"], font)

def s_home():
    return page("Home", phone(home_body(HOME_EN, L)))

def s_home_dark():
    global T
    T = DARK
    out = page("Home, dark", phone(home_body(HOME_EN, L)))
    T = LIGHT
    return out

def s_home_ar():
    lst = []
    for l in L[:4]:
        d = dict(l); d.update(AR_LIST[l["id"]]); lst.append(d)
    return page("الرئيسية", phone(home_body(HOME_AR, lst, AR_FONT), font=AR_FONT, dirn="rtl"), lang="ar", dirn="rtl", arabic=True)

def s_filters():
    reset = f'<button style="border: none; background: none; font-family: inherit; font-size: 15px; font-weight: 700; color: {T["accent"]}; padding: 10px 4px">Reset</button>'
    types = '<div style="display: flex; flex-wrap: wrap; gap: 8px">' + "".join(
        chip(t, t == "Apartment", icon=i) for t, i in [("Any", None), ("House", "home"), ("Apartment", "apartment"), ("Villa", "villa"), ("Studio", "studio"), ("Office", "building")]) + "</div>"
    slider = (f'<div style="position: relative; height: 28px; margin: 4px 12px 0">'
              f'<div style="position: absolute; left: 0; right: 0; top: 12px; height: 4px; border-radius: 9px; background: {T["line"]}"></div>'
              f'<div style="position: absolute; left: 12%; right: 38%; top: 12px; height: 4px; border-radius: 9px; background: {T["accent"]}"></div>'
              f'<span style="position: absolute; left: calc(12% - 14px); top: 0; width: 28px; height: 28px; border-radius: 99px; background: #FFFFFF; border: 2px solid {T["accent"]}; box-sizing: border-box"></span>'
              f'<span style="position: absolute; right: calc(38% - 14px); top: 0; width: 28px; height: 28px; border-radius: 99px; background: #FFFFFF; border: 2px solid {T["accent"]}; box-sizing: border-box"></span></div>')
    minmax = (f'<div style="display: flex; gap: 10px">'
              + field("Min", "30 000", trailing=f'<span style="color: {T["muted"]}; font-weight: 700; font-size: 14px">DA</span>', fid="pmin")
              + field("Max", "90 000", trailing=f'<span style="color: {T["muted"]}; font-weight: 700; font-size: 14px">DA</span>', fid="pmax") + '</div>').replace('display: flex; flex-direction: column; gap: 8px"', 'display: flex; flex-direction: column; gap: 8px; flex: 1"')
    inner = (topbar("Advanced search", left=("x", "Close"), right=reset)
             + content(segmented(["Any", "For sale", "For rent"], "For rent")
                       + field("Location", "Algiers", icon="pin")
                       + f'<div style="display: flex; flex-direction: column; gap: 12px">{label("Property type")}{types}</div>' + divider()
                       + f'<div style="display: flex; flex-direction: column; gap: 12px"><div style="display: flex; justify-content: space-between; align-items: baseline">{label("Price per month")}<span style="font-size: 13px; color: {T["muted"]}; font-weight: 600">DA</span></div>{slider}{minmax}</div>' + divider()
                       + f'<div style="display: flex; flex-direction: column; gap: 12px">{label("Bedrooms")}{number_pills("2")}</div>'
                       + f'<div style="display: flex; flex-direction: column; gap: 12px">{label("Bathrooms")}{number_pills("Any")}</div>' + divider()
                       + field("Minimum area", "60", trailing=f'<span style="color: {T["muted"]}; font-weight: 700; font-size: 14px">m²</span>', fid="area")
                       + f'<div style="display: flex; flex-direction: column; gap: 12px">{label("Listed by")}{segmented(["Anyone", "Owner", "Agency"], "Anyone")}</div>',
                       top=4, gap=20, bottom=130)
             + bottom_bar(btn("Show results")))
    return page("Advanced search", phone(inner, h=1240)), 1240

def s_results():
    active = '<div style="display: flex; gap: 8px; flex-wrap: wrap">' + "".join(
        f'<span style="height: 34px; padding: 0 8px 0 14px; border-radius: 999px; background: {T["accentT"]}; color: {T["accent"]}; display: inline-flex; align-items: center; gap: 4px; font-size: 13px; font-weight: 700">{t}'
        f'<button aria-label="Remove {t}" style="border: none; background: none; color: inherit; padding: 4px; display: flex">{ic("x", 14, sw=2.2)}</button></span>'
        for t in ["For rent", "Apartment", "2+ bd", "30k–90k DA"]) + "</div>"
    sortrow = (f'<div style="display: flex; justify-content: space-between; align-items: center"><span style="font-size: 14px; font-weight: 700; color: {T["muted"]}">3 results</span>'
               f'<button style="height: 36px; padding: 0 12px; border-radius: 999px; border: 1px solid {T["line"]}; background: {T["bg"]}; color: {T["ink"]}; font-family: inherit; font-size: 13px; font-weight: 700; display: flex; align-items: center; gap: 6px">{ic("sort", 16)}Newest{ic("chevdown", 16)}</button></div>')
    def big(l, saved=False):
        return (f'<article style="display: flex; flex-direction: column; gap: 10px"><div style="position: relative">{photo(l, "100%", 200)}'
                f'<div style="position: absolute; top: 12px; left: 12px">{boosted_badge() if l["boosted"] else ""}</div><div style="position: absolute; top: 10px; right: 10px">{save_btn(saved)}</div></div>'
                f'<div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 12px"><div style="display: flex; flex-direction: column; gap: 4px">'
                f'<div style="font-size: 16px; font-weight: 800">{l["title"]}</div><div style="display: flex; align-items: center; gap: 4px; font-size: 13px; color: {T["muted"]}; font-weight: 500">{ic("pin", 15)}{l["loc"]}</div></div>{price(l, 17)}</div>'
                f'{stats(l)}</article>')
    search = (f'<div style="display: flex; gap: 10px; align-items: center">{iconbtn("back", "Back")}<label style="flex: 1; height: 48px; border-radius: 999px; background: {T["surf"]}; display: flex; align-items: center; gap: 10px; padding: 0 16px; color: {T["muted"]}">'
              f'{ic("search", 20)}<input aria-label="Search" value="Algiers" style="flex: 1; min-width: 0; border: none; outline: none; background: transparent; font-family: inherit; font-size: 15px; font-weight: 600; color: {T["ink"]}"></label>'
              f'<div style="position: relative">{iconbtn("sliders", "Filters, 4 active", bg=T["btn"], color=T["btnText"], size=48, border=False)}<span style="position: absolute; top: -2px; right: -2px; min-width: 20px; height: 20px; border-radius: 99px; background: {T["accent"]}; color: #FFFFFF; font-size: 11px; font-weight: 800; display: flex; align-items: center; justify-content: center; border: 2px solid {T["bg"]}">4</span></div></div>')
    inner = content(search + active + sortrow + big(L[1]) + big(L[5], True), top=52, gap=16)
    return page("Search results", phone(inner))

def details_top(l, h=380):
    return (f'<div style="position: relative; height: {h}px">{photo(l, "100%", h, 0)}'
            f'<div style="position: absolute; top: 52px; left: 16px; right: 16px; display: flex; justify-content: space-between">'
            f'{iconbtn("back", "Back", bg="rgba(255,255,255,0.94)", color="#111317", border=False)}{save_btn(True, 44)}</div>'
            f'<span style="position: absolute; right: 16px; bottom: 44px; height: 28px; padding: 0 12px; border-radius: 999px; background: rgba(17,19,23,0.72); color: #FFFFFF; font-size: 12px; font-weight: 700; display: flex; align-items: center">1 / 6</span></div>')

def s_details():
    l = L[0]
    tile = lambda i, v, t: (f'<div style="flex: 1; border: 1px solid {T["line"]}; border-radius: 16px; padding: 12px; display: flex; flex-direction: column; gap: 6px">'
                            f'<span style="color: {T["accent"]}; display: flex">{ic(i, 22)}</span><span style="font-size: 17px; font-weight: 800">{v}</span><span style="font-size: 12px; color: {T["muted"]}; font-weight: 600">{t}</span></div>')
    pill = lambda t: f'<span style="height: 28px; padding: 0 12px; border-radius: 999px; background: {T["surf"]}; font-size: 12px; font-weight: 800; display: inline-flex; align-items: center">{t}</span>'
    owner = (f'<div style="display: flex; align-items: center; gap: 12px; padding: 14px; border-radius: 20px; background: {T["surf"]}">{avatar("DB", 48)}'
             f'<div style="flex: 1; min-width: 0"><div style="font-size: 15px; font-weight: 800">Dar El Bahia Immobilier</div><div style="font-size: 13px; color: {T["muted"]}; font-weight: 600">Agency · View profile</div></div>'
             f'{iconbtn("message", "Send SMS", bg=T["bg"], border=False)}</div>')
    sheet = (f'<div style="position: relative; margin-top: -28px; background: {T["bg"]}; border-radius: 28px 28px 0 0; padding: 22px 20px 130px; display: flex; flex-direction: column; gap: 20px">'
             f'<div style="display: flex; gap: 8px">{boosted_badge()}{pill("For sale")}{pill("Villa")}</div>'
             f'<div style="display: flex; flex-direction: column; gap: 6px"><h1 style="margin: 0; font-size: 24px; font-weight: 800; letter-spacing: -0.02em">{l["title"]}</h1>'
             f'<div style="display: flex; align-items: center; gap: 4px; font-size: 14px; color: {T["muted"]}; font-weight: 600">{ic("pin", 16)}{l["loc"]}<span> · Listed 3 days ago</span></div></div>'
             f'<div style="display: flex; gap: 10px">{tile("bed", "5", "Bedrooms")}{tile("bath", "3", "Bathrooms")}{tile("area", "320 m²", "Area")}</div>'
             f'<div style="display: flex; flex-direction: column; gap: 8px"><h2 style="margin: 0; font-size: 17px; font-weight: 800">About this property</h2>'
             f'<p style="margin: 0; font-size: 15px; line-height: 1.6; color: {T["muted"]}; font-weight: 500">[Owner\'s description goes here. Clamped to 4 lines with a Read more toggle; full text expands in place.]</p>'
             f'<a href="#" style="font-size: 14px; font-weight: 800; text-decoration: none">Read more</a></div>'
             f'<div style="display: flex; flex-direction: column; gap: 10px"><h2 style="margin: 0; font-size: 17px; font-weight: 800">Listed by</h2>{owner}</div>'
             f'<a href="#" style="display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; color: {T["muted"]}; text-decoration: none">{ic("flag", 18)}Report this listing</a></div>')
    bar = bottom_bar(f'<div style="flex: 1; display: flex; flex-direction: column; gap: 2px"><span style="font-size: 12px; font-weight: 700; color: {T["muted"]}">Price</span>{price(l, 21)}</div>'
                     + btn("Call", icon="phone", w="auto", extra="padding: 0 26px"))
    return page("Property details", phone(details_top(l) + sheet + bar, h=1120)), 1120

def s_report():
    reason = lambda t, on: (f'<label style="min-height: 52px; display: flex; align-items: center; gap: 12px; padding: 0 14px; border-radius: 14px; '
                            f'border: {"2px solid " + T["accent"] if on else "1px solid " + T["line"]}; background: {T["accentT"] if on else T["bg"]}; font-size: 15px; font-weight: 700">'
                            f'<input type="radio" name="reason" {"checked" if on else ""} style="width: 20px; height: 20px; accent-color: {T["accent"]}; margin: 0">{t}</label>')
    sheet = (f'<div role="dialog" aria-label="Report this listing" style="position: absolute; left: 0; right: 0; bottom: 0; background: {T["bg"]}; border-radius: 28px 28px 0 0; padding: 12px 20px 34px; display: flex; flex-direction: column; gap: 14px">'
             f'<div style="width: 40px; height: 4px; border-radius: 9px; background: {T["line"]}; align-self: center"></div>'
             f'<div style="display: flex; justify-content: space-between; align-items: center"><h2 style="margin: 0; font-size: 20px; font-weight: 800">Report this listing</h2>{iconbtn("x", "Close", bg=T["surf"], border=False, size=40)}</div>'
             f'<p style="margin: -6px 0 0; font-size: 14px; color: {T["muted"]}; font-weight: 500; line-height: 1.5">Reports are private. They help us keep listings accurate and safe.</p>'
             + reason("Fraudulent listing", False) + reason("Inaccurate information", True) + reason("Inappropriate content", False) + reason("No longer available", False)
             + field("Details (optional)", "", "Tell us what's wrong", textarea=True, fid="details")
             + btn("Send report") + '</div>')
    inner = details_top(L[0]) + f'<div style="position: absolute; inset: 0; background: {T["scrim"]}"></div>' + sheet
    return page("Report listing", phone(inner))

def s_saved():
    def tile(l):
        return (f'<article style="display: flex; flex-direction: column; gap: 8px"><div style="position: relative">{photo(l, "100%", 150, 18)}'
                f'<div style="position: absolute; top: 8px; right: 8px">{save_btn(True, 36)}</div></div>'
                f'<div style="display: flex; flex-direction: column; gap: 2px">{price(l, 15)}<div style="font-size: 14px; font-weight: 700">{l["title"]}</div>'
                f'<div style="font-size: 12px; color: {T["muted"]}; font-weight: 600">{l["loc"]}</div></div></article>')
    grid = '<div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 20px 14px">' + "".join(tile(l) for l in [L[0], L[2], L[5], L[4]]) + "</div>"
    inner = deco("sv", h=200) + content(f'<div style="display: flex; flex-direction: column; gap: 4px"><h1 style="margin: 0; font-size: 30px; font-weight: 800; letter-spacing: -0.03em">Saved</h1>'
                    f'<span style="font-size: 14px; color: {T["muted"]}; font-weight: 600">4 properties</span></div>' + grid, top=60, gap=20) + tabbar("Saved")
    return page("Saved", phone(inner))

def s_mylistings():
    status = lambda on: (f'<span style="display: inline-flex; align-items: center; gap: 6px; height: 24px; padding: 0 10px; border-radius: 999px; font-size: 12px; font-weight: 800; '
                         f'background: {T["greenT"] if on else T["surf"]}; color: {T["green"] if on else T["muted"]}"><span style="width: 6px; height: 6px; border-radius: 9px; background: currentColor"></span>{"Online" if on else "Offline"}</span>')
    more = lambda lab: iconbtn("more", lab, bg=T["bg"], border=False, size=40)
    def item(l, extra=""):
        badges = status(True) + (" " + boosted_badge() if l["boosted"] else "")
        return (f'<article style="display: flex; gap: 14px; padding: 12px; border: 1px solid {T["line"]}; border-radius: 20px; {extra}">{photo(l, "92px", 92, 14, "flex: none")}'
                f'<div style="flex: 1; min-width: 0; display: flex; flex-direction: column; gap: 6px"><div style="display: flex; gap: 6px; flex-wrap: wrap">{badges}</div>'
                f'<div style="font-size: 15px; font-weight: 800">{l["title"]}</div>{price(l, 15)}</div><div>{more("Actions for " + l["title"])}</div></article>')
    menu = (f'<div role="menu" style="position: absolute; right: 30px; top: 392px; width: 220px; background: {T["bg"]}; border-radius: 18px; box-shadow: 0 12px 32px rgba(17,19,23,0.18), 0 0 0 1px {T["line"]}; padding: 6px; display: flex; flex-direction: column">'
            + "".join(f'<button role="menuitem" style="height: 48px; border: none; background: {"" + T["surf"] if i == 1 else "transparent"}; border-radius: 12px; display: flex; align-items: center; gap: 12px; padding: 0 12px; font-family: inherit; font-size: 15px; font-weight: 700; color: {c}">{ic(n, 20)}{t}</button>'
                      for i, (n, t, c) in enumerate([("edit", "Edit", T["ink"]), ("bolt", "Boost", T["ink"]), ("eyeoff", "Make offline", T["ink"]), ("trash", "Delete", T["red"])])) + "</div>")
    head = (f'<div style="display: flex; justify-content: space-between; align-items: center"><h1 style="margin: 0; font-size: 30px; font-weight: 800; letter-spacing: -0.03em">My listings</h1>'
            f'{iconbtn("plus", "New listing", bg=T["btn"], color=T["btnText"], border=False, size=48, isz=22)}</div>')
    inner = deco("ml", h=200) + content(head + segmented(["Online · 3", "Offline · 1"], "Online · 3") + item(L[0]) + item(L[2]) + item(L[1]), top=60, gap=16) + menu + tabbar("My listings")
    return page("My listings", phone(inner))

def s_create():
    thumb = lambda src, cover=False: (f'<div style="position: relative; flex: none"><img src="{src}" alt="Listing photo" style="width: 96px; height: 96px; border-radius: 16px; object-fit: cover; display: block">'
                                      + (f'<span style="position: absolute; left: 6px; bottom: 6px; height: 22px; padding: 0 8px; border-radius: 99px; background: rgba(17,19,23,0.75); color: #FFFFFF; font-size: 11px; font-weight: 800; display: flex; align-items: center">Cover</span>' if cover else "")
                                      + f'<button aria-label="Remove photo" style="position: absolute; top: -6px; right: -6px; width: 26px; height: 26px; border-radius: 99px; border: 2px solid {T["bg"]}; background: {T["btn"]}; color: {T["btnText"]}; display: flex; align-items: center; justify-content: center; padding: 0">{ic("x", 14, sw=2.4)}</button></div>')
    photos = (f'<div style="display: flex; flex-direction: column; gap: 10px">{label("Photos")}<div style="display: flex; gap: 12px; padding-top: 6px">'
              f'<button style="width: 96px; height: 96px; flex: none; border-radius: 16px; border: 1.5px dashed {T["muted"]}; background: {T["surf"]}; color: {T["ink"]}; font-family: inherit; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 6px; font-size: 12px; font-weight: 700">{ic("camera", 22)}Add</button>'
              + thumb(P1, True) + thumb(P3) + f'</div><span style="font-size: 12px; color: {T["muted"]}; font-weight: 600">The first photo is the cover. Drag to reorder.</span></div>')
    types = '<div style="display: flex; flex-wrap: wrap; gap: 8px">' + "".join(chip(t, t == "Villa", icon=i) for t, i in [("House", "home"), ("Apartment", "apartment"), ("Villa", "villa"), ("Studio", "studio"), ("Office", "building")]) + "</div>"
    sugg = (f'<div style="margin-top: -12px; border: 1px solid {T["line"]}; border-radius: 16px; padding: 6px; display: flex; flex-direction: column; box-shadow: 0 8px 24px rgba(17,19,23,0.08)">'
            + "".join(f'<button style="min-height: 52px; border: none; background: {T["surf"] if i == 0 else "transparent"}; border-radius: 12px; text-align: start; padding: 8px 12px; font-family: inherit; color: {T["ink"]}; display: flex; gap: 10px; align-items: center">{ic("pin", 18)}<span style="display: flex; flex-direction: column"><span style="font-size: 14px; font-weight: 700">{a}</span><span style="font-size: 12px; color: {T["muted"]}; font-weight: 500">{b}</span></span></button>'
                      for i, (a, b) in enumerate([("Hydra", "Algiers, Algeria"), ("Hydra, Ben Aknoun", "Algiers, Algeria")])) + "</div>")
    vis = (f'<div style="display: flex; align-items: center; gap: 14px; padding: 14px 16px; border-radius: 16px; background: {T["surf"]}">'
           f'<div style="flex: 1"><div style="font-size: 15px; font-weight: 800">Visible to buyers</div><div style="font-size: 13px; color: {T["muted"]}; font-weight: 500">Turn off to save as offline</div></div>{toggle(True)}</div>')
    da = f'<span style="color: {T["muted"]}; font-weight: 800; font-size: 14px">DA</span>'
    inner = (topbar("New listing", left=("x", "Close")) +
             content(photos + field("Title", "Villa with garden", fid="title")
                     + field("Description", "", "Describe the property, the neighbourhood, what's included…", textarea=True, fid="desc")
                     + f'<div style="display: flex; flex-direction: column; gap: 8px"><div style="font-size: 13px; font-weight: 700">Listing type</div>{segmented(["For sale", "For rent"], "For sale")}</div>'
                     + f'<div style="display: flex; flex-direction: column; gap: 8px"><div style="font-size: 13px; font-weight: 700">Property type</div>{types}</div>'
                     + field("Price", "52 000 000", trailing=da, fid="price")
                     + f'<div style="display: flex; gap: 12px">{stepper("Bedrooms", 5)}{stepper("Bathrooms", 3)}</div>'
                     + field("Area", "320", trailing=f'<span style="color: {T["muted"]}; font-weight: 800; font-size: 14px">m²</span>', fid="area")
                     + field("Location", "Hydra", "Search an address", icon="pin", fid="loc", focused=True) + sugg + vis,
                     top=4, gap=20, bottom=130)
             + bottom_bar(btn("Publish listing")))
    return page("New listing", phone(inner, h=1720)), 1720

PLANS = [("Basic", ["Featured placement on Home"], False), ("Premium", ["Featured placement on Home", "Priority in search results", "Boosted badge"], True),
         ("Agency", ["Top priority in search", "Boosted badge", "Dedicated support"], False)]

def s_plans():
    l = L[2]
    mini = (f'<div style="display: flex; gap: 12px; align-items: center; padding: 10px; border-radius: 18px; background: {T["surf"]}">{photo(l, "64px", 64, 12, "flex: none")}'
            f'<div><div style="font-size: 15px; font-weight: 800">{l["title"]}</div><div style="font-size: 13px; color: {T["muted"]}; font-weight: 600">{l["loc"]} · {fmt(l["price"])} DA</div></div></div>')
    def plan(name, feats, sel):
        radio = (f'<span style="width: 24px; height: 24px; border-radius: 99px; flex: none; display: flex; align-items: center; justify-content: center; '
                 + (f'background: {T["accent"]}; color: #FFFFFF">{ic("check", 14, sw=3)}' if sel else f'border: 2px solid {T["line"]}">') + '</span>')
        fl = "".join(f'<li style="display: flex; gap: 8px; align-items: center; font-size: 14px; font-weight: 600; color: {T["muted"]}"><span style="color: {T["green"]}; display: flex">{ic("check", 16, sw=2.4)}</span>{f}</li>' for f in feats)
        tag = f'<span style="height: 24px; padding: 0 10px; border-radius: 99px; background: {T["amber"]}; color: #111317; font-size: 11px; font-weight: 800; display: inline-flex; align-items: center">Most chosen</span>' if sel else ""
        return (f'<label style="display: flex; flex-direction: column; gap: 12px; padding: 18px; border-radius: 22px; border: {"2px solid " + T["accent"] if sel else "1px solid " + T["line"]}; background: {T["accentT"] if sel else T["bg"]}">'
                f'<div style="display: flex; align-items: center; gap: 12px">{radio}<div style="flex: 1; display: flex; align-items: center; gap: 8px"><span style="font-size: 17px; font-weight: 800">{name}</span>{tag}</div>'
                f'<div style="text-align: end"><div style="font-size: 17px; font-weight: 800">[PRICE] DA</div><div style="font-size: 12px; color: {T["muted"]}; font-weight: 700">[N] days</div></div></div>'
                f'<ul style="margin: 0; padding: 0 0 0 36px; list-style: none; display: flex; flex-direction: column; gap: 6px">{fl}</ul></label>')
    inner = (topbar("Boost listing") +
             content(f'<p style="margin: 0; font-size: 15px; color: {T["muted"]}; font-weight: 500; line-height: 1.5">Boosted listings appear in Sponsored on the Home screen and higher in search.</p>'
                     + mini + "".join(plan(*p) for p in PLANS), top=4, gap=16, bottom=130)
             + bottom_bar(btn("Continue to payment")))
    return page("Boost plans", phone(inner, h=980)), 980

def s_payment():
    l = L[2]
    row = lambda a, b, bold=False: f'<div style="display: flex; justify-content: space-between; font-size: {16 if bold else 14}px; font-weight: {800 if bold else 600}; color: {T["ink"] if bold else T["muted"]}"><span>{a}</span><span style="color: {T["ink"]}">{b}</span></div>'
    summary = card(f'<div style="display: flex; gap: 12px; align-items: center">{photo(l, "56px", 56, 12, "flex: none")}<div><div style="font-size: 15px; font-weight: 800">{l["title"]}</div><div style="font-size: 13px; color: {T["muted"]}; font-weight: 600">{l["loc"]}</div></div></div>'
                   + divider() + row("Plan", "Premium") + row("Duration", "[N] days") + divider() + row("Total", "[PRICE] DA", True), gap=12)
    method = lambda t, sub, on: (f'<label style="min-height: 64px; display: flex; align-items: center; gap: 14px; padding: 0 16px; border-radius: 16px; border: {"2px solid " + T["accent"] if on else "1px solid " + T["line"]}; background: {T["accentT"] if on else T["bg"]}">'
                                 f'<input type="radio" name="method" {"checked" if on else ""} style="width: 20px; height: 20px; accent-color: {T["accent"]}; margin: 0">'
                                 f'<span style="width: 40px; height: 40px; border-radius: 10px; background: {T["surf"]}; display: flex; align-items: center; justify-content: center">{ic("card", 20)}</span>'
                                 f'<span style="display: flex; flex-direction: column"><span style="font-size: 15px; font-weight: 800">{t}</span><span style="font-size: 12px; color: {T["muted"]}; font-weight: 600">{sub}</span></span></label>')
    inner = (topbar("Checkout") +
             content(f'<div style="display: flex; flex-direction: column; gap: 10px">{label("Order summary")}{summary}</div>'
                     + f'<div style="display: flex; flex-direction: column; gap: 10px">{label("Pay with")}{method("Edahabia", "Algérie Poste card", True)}{method("CIB", "Interbank card", False)}</div>'
                     + f'<div style="display: flex; gap: 10px; align-items: flex-start; font-size: 13px; color: {T["muted"]}; font-weight: 600; line-height: 1.5"><span style="color: {T["green"]}; display: flex">{ic("shield", 18)}</span>You\'ll finish on Chargily\'s secure payment page. Findar never sees your card details.</div>',
                     top=4, gap=24)
             + bottom_bar(btn("Pay [PRICE] DA", icon="lock")))
    return page("Checkout", phone(inner))

def s_paid():
    inner = (deco("bd", 104, h=420) + f'<div style="position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 18px; padding: 0 32px 80px; text-align: center">'
             f'{spot(ic("bolt", 46, color="#111317", fill=T["amber"], sw=1.4), 150)}'
             f'<h1 style="margin: 0; font-size: 28px; font-weight: 800; letter-spacing: -0.03em">Your listing is boosted</h1>'
             f'<p style="margin: 0; font-size: 15px; color: {T["muted"]}; font-weight: 500; line-height: 1.5">Family house, Blida now appears in Sponsored until [END DATE].</p></div>'
             + bottom_bar(btn("View listing", "secondary", w="50%") + btn("Done", w="50%")).replace(f"border-top: 1px solid {T['line']}", "border-top: none"))
    return page("Boost confirmed", phone(inner))

def s_profile():
    contact = card(menu_row("phone", "0555 12 34 56", "", sub="Phone") + divider() + menu_row("mail", "sara.meziane@gmail.com", "", sub="Email"), pad=12, gap=4)
    mini = lambda l: (f'<article style="display: flex; flex-direction: column; gap: 6px">{photo(l, "100%", 110, 14)}{price(l, 14)}'
                      f'<div style="font-size: 13px; font-weight: 700">{l["title"]}</div></article>')
    inner = deco("pf", h=280) + content(
        f'<div style="display: flex; justify-content: flex-end">{iconbtn("settings", "Settings", bg=T["surf"], border=False)}</div>'
        f'<div style="display: flex; flex-direction: column; align-items: center; gap: 10px; margin-top: -24px"><div style="position: relative">{avatar("SM", 96)}'
        f'<span style="position: absolute; right: -2px; bottom: -2px; width: 34px; height: 34px; border-radius: 99px; background: {T["btn"]}; color: {T["btnText"]}; border: 3px solid {T["bg"]}; display: flex; align-items: center; justify-content: center">{ic("camera", 16)}</span></div>'
        f'<h1 style="margin: 4px 0 0; font-size: 24px; font-weight: 800; letter-spacing: -0.02em">Sara Meziane</h1>'
        f'<span style="font-size: 13px; color: {T["muted"]}; font-weight: 700">Individual account · 4 listings</span></div>'
        f'<div style="display: flex; gap: 10px">{btn("Edit profile", "secondary", icon="edit", w="50%", h=48)}{btn("New listing", icon="plus", w="50%", h=48)}</div>'
        + contact
        + f'<div style="display: flex; flex-direction: column; gap: 12px">{section_head("My listings", "See all")}'
          f'<div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px">{mini(L[0])}{mini(L[2])}</div></div>',
        top=52, gap=18) + tabbar("Profile")
    return page("Profile", phone(inner))

def s_edit_profile():
    inner = (topbar("Edit profile") +
             content(f'<div style="display: flex; flex-direction: column; align-items: center; gap: 12px">{avatar("SM", 96)}'
                     f'<button style="height: 40px; padding: 0 16px; border-radius: 999px; border: 1px solid {T["line"]}; background: {T["bg"]}; color: {T["ink"]}; font-family: inherit; font-size: 14px; font-weight: 700; display: flex; align-items: center; gap: 8px">{ic("camera", 18)}Change photo</button></div>'
                     + field("Full name", "Sara Meziane", icon="user")
                     + field("Email address", "sara.meziane@gmail.com", icon="mail", ftype="email")
                     + field("Phone number", "0555 12 34 56", icon="phone", ftype="tel", focused=True), top=8, gap=20)
             + bottom_bar(btn("Save changes")))
    return page("Edit profile", phone(inner))

def s_user_profile():
    grid = '<div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 18px 14px">' + "".join(
        f'<article style="display: flex; flex-direction: column; gap: 6px"><div style="position: relative">{photo(l, "100%", 130, 16)}<div style="position: absolute; top: 8px; right: 8px">{save_btn(False, 34)}</div></div>'
        f'{price(l, 14)}<div style="font-size: 13px; font-weight: 700">{l["title"]}</div><div style="font-size: 12px; color: {T["muted"]}; font-weight: 600">{l["loc"]}</div></article>'
        for l in [L[0], L[1], L[4], L[5]]) + "</div>"
    inner = (topbar("") +
             content(f'<div style="display: flex; gap: 16px; align-items: center">{avatar("DB", 72)}<div style="display: flex; flex-direction: column; gap: 4px">'
                     f'<h1 style="margin: 0; font-size: 22px; font-weight: 800; letter-spacing: -0.02em">Dar El Bahia Immobilier</h1>'
                     f'<span style="align-self: flex-start; height: 24px; padding: 0 10px; border-radius: 99px; background: {T["accentT"]}; color: {T["accent"]}; font-size: 12px; font-weight: 800; display: inline-flex; align-items: center; gap: 4px">{ic("building", 14)}Agency</span></div></div>'
                     f'<div style="display: flex; gap: 10px">{btn("Message", "secondary", icon="message", w="50%", h=48)}{btn("Call", icon="phone", w="50%", h=48)}</div>'
                     + f'<div style="display: flex; flex-direction: column; gap: 14px">{section_head("Listings · 4", None)}{grid}</div>', top=0, gap=20))
    return page("Owner profile", phone(inner))

def s_settings():
    lang = lambda t, sub, on: (f'<label style="min-height: 56px; display: flex; align-items: center; gap: 14px"><div style="flex: 1"><div style="font-size: 15px; font-weight: 700">{t}</div><div style="font-size: 13px; color: {T["muted"]}; font-weight: 500">{sub}</div></div>'
                               f'<input type="radio" name="lang" {"checked" if on else ""} style="width: 22px; height: 22px; accent-color: {T["accent"]}; margin: 0"></label>')
    group = lambda title, inner: (f'<div style="display: flex; flex-direction: column; gap: 8px"><div style="font-size: 12px; font-weight: 800; color: {T["muted"]}; letter-spacing: 0.06em; text-transform: uppercase">{title}</div>'
                                  + card(inner, pad=12, gap=0) + '</div>')
    inner = (deco("st", 0, pat=False) + topbar("Settings") +
             content(group("Appearance", menu_row("moon", "Dark mode", toggle(False), sub="Follows the system until you change it"))
                     + group("Language", lang("English", "English", True) + divider() + lang("العربية", "Arabic", False) + divider() + lang("Français", "French", False))
                     + group("Contact us", menu_row("phone", "Call support", sub="[SUPPORT PHONE]") + divider() + menu_row("mail", "Email support", sub="[SUPPORT EMAIL]"))
                     + group("Account", menu_row("logout", "Log out", "", color=T["red"])),
                     top=8, gap=22))
    return page("Settings", phone(inner))

def s_states():
    blk = lambda title, inner: (f'<div style="display: flex; flex-direction: column; gap: 10px"><div style="font-size: 12px; font-weight: 800; color: {T["muted"]}; letter-spacing: 0.06em; text-transform: uppercase">{title}</div>{inner}</div>')
    skel = lambda w, h, r=10: f'<div style="width: {w}; height: {h}px; border-radius: {r}px; background: {T["surf"]}"></div>'
    skeleton = (f'<div style="display: flex; gap: 14px">{skel("104px", 104, 16)}<div style="flex: 1; display: flex; flex-direction: column; gap: 10px; justify-content: center">{skel("70%", 14)}{skel("50%", 12)}{skel("40%", 16)}</div></div>')
    offline = (f'<div style="display: flex; gap: 12px; align-items: center; padding: 14px; border-radius: 16px; background: {T["surf"]}"><span style="display: flex">{ic("wifioff", 22)}</span>'
               f'<div style="flex: 1"><div style="font-size: 14px; font-weight: 800">You\'re offline</div><div style="font-size: 13px; color: {T["muted"]}; font-weight: 500">Showing saved results from your last visit.</div></div>'
               f'<button style="height: 36px; padding: 0 14px; border-radius: 99px; border: none; background: {T["btn"]}; color: {T["btnText"]}; font-family: inherit; font-size: 13px; font-weight: 800">Retry</button></div>')
    empty = (f'<div style="display: flex; flex-direction: column; align-items: center; gap: 10px; text-align: center; padding: 20px; border: 1px dashed {T["line"]}; border-radius: 20px">'
             f'{spot(ic("bookmark", 34), 110)}'
             f'<div style="font-size: 16px; font-weight: 800">No saved properties yet</div><div style="font-size: 14px; color: {T["muted"]}; font-weight: 500">Tap the bookmark on any listing to keep it here.</div>'
             + btn("Browse listings", "secondary", w="auto", h=44, extra="padding: 0 20px") + '</div>')
    error = (f'<div style="display: flex; flex-direction: column; align-items: center; gap: 10px; text-align: center; padding: 20px; border: 1px solid {T["line"]}; border-radius: 20px">'
             f'{spot(ic("wifioff", 34), 110)}<div style="font-size: 16px; font-weight: 800">Couldn\'t load listings</div><div style="font-size: 14px; color: {T["muted"]}; font-weight: 500">The server didn\'t respond. Try again in a moment.</div>'
             + btn("Try again", icon="refresh", w="auto", h=44, extra="padding: 0 20px") + '</div>')
    snack = (f'<div role="status" style="display: flex; align-items: center; gap: 12px; padding: 14px 16px; border-radius: 16px; background: #111317; color: #FFFFFF; font-size: 14px; font-weight: 700">'
             f'<span style="flex: 1">Saved to your list</span><a href="#" style="color: #8EBBF5; text-decoration: none; font-weight: 800">Undo</a></div>')
    inner = content(f'<h1 style="margin: 0; font-size: 22px; font-weight: 800">Shared states</h1>'
                    + blk("Loading", skeleton + skeleton) + blk("Offline banner", offline) + blk("Empty", empty) + blk("Error", error) + blk("Snackbar", snack), top=32, gap=22)
    return page("States", phone(inner, h=1100)), 1100

def s_icon():
    def sq(size, r, bg, fg, lab, ring=False):
        sh = "0 10px 30px rgba(17,19,23,0.12)" + (", inset 0 0 0 1px #E4E6EA" if ring else "")
        return (f'<div style="display: flex; flex-direction: column; align-items: center; gap: 12px">'
                f'<div style="width: {size}px; height: {size}px; border-radius: {r}px; background: {bg}; display: flex; align-items: center; justify-content: center; box-shadow: {sh}">{logo(round(size*0.56), fg)}</div>'
                f'<span style="font-size: 13px; font-weight: 700; color: #5B6170">{lab}</span></div>')
    plate = lambda bg, fg, ring: (f'<div style="flex: 1; height: 120px; border-radius: 24px; background: {bg}; display: flex; align-items: center; justify-content: center'
                                  + ('; box-shadow: inset 0 0 0 1px #E4E6EA' if ring else '') + f'">{lockup(40, fg)}</div>')
    body = (f'<div style="position: relative; width: 980px; height: 640px; box-sizing: border-box; padding: 56px; background: #F3F4F6; font-family: {FONT}; color: #111317; display: flex; flex-direction: column; gap: 40px; overflow: hidden">'
            + zellige("ic", "#0A5FC2", 0.10, 640)
            + '<div style="position: relative; display: flex; flex-direction: column; gap: 6px"><h1 style="margin: 0; font-size: 28px; font-weight: 800; letter-spacing: -0.02em">App icon and logo</h1>'
            + '<p style="margin: 0; font-size: 15px; color: #5B6170; font-weight: 500; max-width: 640px">House outline with a nested “f”, redrawn as a vector from reference/logo. One weight, rounded joins, no detail, so it holds up at 29 px. The mark sits inside the Android adaptive-icon safe zone (inner 66%).</p></div>'
            + '<div style="position: relative; display: flex; gap: 44px; align-items: flex-end">'
            + sq(180, 42, "#0A5FC2", "#FFFFFF", "Primary") + sq(120, 28, "#FFFFFF", "#0A5FC2", "Light", True) + sq(120, 28, "#111317", "#FFFFFF", "Dark / themed")
            + sq(64, 15, "#0A5FC2", "#FFFFFF", "64 px") + sq(40, 10, "#0A5FC2", "#FFFFFF", "40 px") + sq(29, 7, "#0A5FC2", "#FFFFFF", "29 px") + '</div>'
            + '<div style="position: relative; display: flex; gap: 20px">'
            + plate("#FFFFFF", "#111317", True) + plate("#111317", "#FFFFFF", False) + plate("#0A5FC2", "#FFFFFF", False) + '</div></div>')
    return page("App icon and logo", body, 980, 640)

def s_tokens():
    sw = lambda c, n, h: (f'<div style="display: flex; flex-direction: column; gap: 6px"><div style="height: 56px; border-radius: 14px; background: {c}; border: 1px solid #E4E6EA"></div>'
                          f'<div style="font-size: 13px; font-weight: 800">{n}</div><div style="font-size: 12px; color: #5B6170; font-weight: 600">{h}</div></div>')
    colors = ('<div style="display: grid; grid-template-columns: repeat(6, minmax(0, 1fr)); gap: 14px">'
              + sw("#111317", "Ink", "#111317 · text, primary button") + sw("#5B6170", "Muted", "#5B6170 · secondary text") + sw("#F3F4F6", "Surface", "#F3F4F6 · fields, chips")
              + sw("#E4E6EA", "Line", "#E4E6EA · borders") + sw("#0A5FC2", "Findar blue", "#0A5FC2 · links, selection") + sw("#F5B341", "Boost", "#F5B341 · boosted only")
              + sw("#0E1014", "Dark bg", "#0E1014") + sw("#1B1E24", "Dark surface", "#1B1E24") + sw("#6AA6F0", "Dark blue", "#6AA6F0")
              + sw("#11734A", "Success", "#11734A · online, paid") + sw("#B42318", "Danger", "#B42318 · delete, logout") + sw("#E7EFFA", "Blue tint", "#E7EFFA · selected card") + '</div>')
    ty = lambda s, w, t, spec: f'<div style="display: flex; align-items: baseline; gap: 20px"><span style="width: 160px; font-size: 12px; color: #5B6170; font-weight: 700">{spec}</span><span style="font-size: {s}px; font-weight: {w}; letter-spacing: {"-0.03em" if s > 22 else "0"}">{t}</span></div>'
    type_ = (ty(30, 800, "Screen title", "Manrope 30 / 800") + ty(24, 800, "Listing title", "Manrope 24 / 800") + ty(19, 800, "Section header", "Manrope 19 / 800")
             + ty(20, 800, "52 000 000 DA", "Manrope 20 / 800 · price") + ty(15, 600, "Body and card titles", "Manrope 15 / 600") + ty(13, 600, "Meta, captions", "Manrope 13 / 600")
             + ty(16, 600, "حيدرة، الجزائر", "IBM Plex Sans Arabic (ar)"))
    rule = lambda a, b: f'<div style="display: flex; gap: 12px; font-size: 14px; line-height: 1.5"><span style="width: 140px; flex: none; font-weight: 800">{a}</span><span style="color: #5B6170; font-weight: 500">{b}</span></div>'
    rules = (rule("Radius", "Pills 999 · cards & photos 20 · fields 16 · thumbnails 14") + rule("Spacing", "4-pt grid; screen padding 20; section gap 20–24")
             + rule("Touch targets", "≥ 44 px (icon buttons 44, buttons 52, tab items full height)") + rule("Prices", "Grouped with a thin space + “DA” everywhere; rent adds “/ month”")
             + rule("Buttons", "One ink primary per screen; secondary is outlined; blue is for links and selection, never a second primary")
             + rule("Icons", "Outline 1.8 stroke, 20/24 px; filled only for the active tab and a saved bookmark"))
    body = (f'<div style="width: 1240px; height: 900px; box-sizing: border-box; padding: 56px; background: #FFFFFF; font-family: {FONT}; color: #111317; display: flex; flex-direction: column; gap: 32px">'
            f'<h1 style="margin: 0; font-size: 28px; font-weight: 800; letter-spacing: -0.02em">Foundations</h1>{colors}'
            f'<div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 48px"><div style="display: flex; flex-direction: column; gap: 14px">{type_}</div><div style="display: flex; flex-direction: column; gap: 14px">{rules}</div></div></div>')
    link = '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&amp;family=IBM+Plex+Sans+Arabic:wght@600&amp;display=swap">'
    return page("Foundations", body, 1240, 900, arabic=True)

# ===== v3 overrides: soft "glass" decoration style (replaces zellige + skyline) =====
ICONS["star"] = '<path d="m12 3 2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1-4.4-4.3 6.1-.9z"></path>'
ICONS["key"] = '<circle cx="8" cy="15" r="4"></circle><path d="m11 12 9-9M17 6l3 3M14 9l2 2"></path>'

def zellige(*a, **k):
    return ""

def skyline(*a, **k):
    return ""

GRAD = "linear-gradient(140deg, #1C74DB 0%, #0A5FC2 40%, #0B3A80 100%)"

def sparkle(pos, size=14, color=None, op=0.4):
    color = color or T["accent"]
    return (f'<svg aria-hidden="true" width="{size}" height="{size}" viewBox="0 0 24 24" style="position: absolute; {pos}; opacity: {op}">'
            f'<path d="M12 1 14.2 9.8 23 12 14.2 14.2 12 23 9.8 14.2 1 12 9.8 9.8Z" fill="{color}"></path></svg>')

def circle(pos, d, bg, extra=""):
    return f'<span aria-hidden="true" style="position: absolute; {pos}; width: {d}px; height: {d}px; border-radius: 999px; background: {bg}; {extra}"></span>'

def rings(pos, radii, color, ops, size=None):
    size = size or (max(radii) * 2 + 4)
    c = size / 2
    cs = "".join(f'<circle cx="{c}" cy="{c}" r="{r}" stroke="{color}" stroke-opacity="{o}" stroke-width="1.2"></circle>' for r, o in zip(radii, ops))
    return f'<svg aria-hidden="true" width="{size}" height="{size}" viewBox="0 0 {size} {size}" fill="none" style="position: absolute; {pos}; pointer-events: none">{cs}</svg>'

def glass_tile(icon, size, pos, rot=0, light=False, icolor=None):
    if light:   # on a light background: white tile, blue icon
        bg = f"linear-gradient(145deg, {T['bg']}, {T['surf']})"; bd = f"1px solid {T['line']}"; sh = "0 10px 24px rgba(17,19,23,0.10)"; col = icolor or T["accent"]
    else:       # on the blue gradient: frosted tile, white icon
        bg = "linear-gradient(145deg, rgba(255,255,255,0.40), rgba(255,255,255,0.10))"; bd = "1px solid rgba(255,255,255,0.45)"; sh = "0 12px 26px rgba(4,30,70,0.30)"; col = icolor or "#FFFFFF"
    return (f'<span aria-hidden="true" style="position: absolute; {pos}; width: {size}px; height: {size}px; border-radius: {round(size*0.3)}px; background: {bg}; border: {bd}; '
            f'box-shadow: {sh}; backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); transform: rotate({rot}deg); display: flex; align-items: center; justify-content: center; color: {col}">'
            f'{ic(icon, round(size*0.48), sw=2)}</span>')

def bubble(pos, d, op=0.35):
    return circle(pos, d, f"rgba(255,255,255,{op})", "box-shadow: inset 0 0 0 1px rgba(255,255,255,0.55)")

def glass_tag(txt, pos, rot=0):
    return (f'<a href="#" style="position: absolute; {pos}; transform: rotate({rot}deg); height: 34px; padding: 0 14px; border-radius: 999px; background: rgba(255,255,255,0.15); '
            f'border: 1px solid rgba(255,255,255,0.35); backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px); color: #FFFFFF; font-size: 13px; font-weight: 700; text-decoration: none; '
            f'display: flex; align-items: center; box-shadow: 0 6px 16px rgba(4,30,70,0.18); white-space: nowrap">{txt}</a>')

def blue_card_bg():
    return (circle("left: -90px; top: -110px", 260, "rgba(255,255,255,0.08)") + circle("right: -70px; bottom: -100px", 240, "rgba(255,255,255,0.07)")
            + rings("right: -60px; top: -60px", [60, 90], "#FFFFFF", [0.18, 0.10]))

def art_card(h, tiles, bubbles=()):
    return (f'<div aria-hidden="true" style="position: relative; height: {h}px; border-radius: 28px; overflow: hidden; background: {GRAD}; box-shadow: 0 16px 36px rgba(10,95,194,0.25)">'
            + blue_card_bg() + "".join(bubble(*b) for b in bubbles) + "".join(glass_tile(*t) for t in tiles) + '</div>')

def soft_top(h=280):
    tint = T["accentT"]
    return (f'<div aria-hidden="true" style="position: absolute; left: 0; right: 0; top: 0; height: {h}px; background: linear-gradient(180deg, {tint} 0%, {T["bg"]} 100%); pointer-events: none"></div>'
            + rings("right: -110px; top: -120px", [80, 120, 160], T["accent"], [0.14, 0.10, 0.06])
            + circle(f"left: -70px; top: {round(h*0.45)}px", 150, T["accent"], "opacity: 0.05"))

def deco(pid, sky_bottom=None, pat=True, h=260):
    out = soft_top(h) if pat else ""
    if sky_bottom is not None:
        out += rings(f"left: -120px; bottom: {sky_bottom - 120}px", [90, 130], T["accent"], [0.10, 0.06]) + circle(f"right: -60px; bottom: {sky_bottom + 40}px", 120, T["accent"], "opacity: 0.05")
    return out

def spot(icon_svg, size=120, minis=("home", "pin")):
    s = size
    return (f'<div aria-hidden="true" style="position: relative; width: {s}px; height: {s}px; flex: none">'
            + rings(f"left: {-s*0.25}px; top: {-s*0.25}px", [s*0.62, s*0.75], T["accent"], [0.16, 0.08], s*1.5)
            + circle(f"left: {s*0.1}px; top: {s*0.1}px", round(s*0.8), f"linear-gradient(145deg, {T['accentT']}, {T['bg']})", f"box-shadow: inset 0 0 0 1px {T['line']}")
            + glass_tile(minis[0], round(s*0.3), f"right: {-s*0.12}px; top: {s*0.02}px", 10, light=True)
            + glass_tile(minis[1], round(s*0.25), f"left: {-s*0.08}px; bottom: {s*0.06}px", -12, light=True)
            + sparkle(f"left: {s*0.12}px; top: {-s*0.02}px", 12)
            + f'<div style="position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; color: {T["accent"]}">{icon_svg}</div></div>')

def tabbar(active, labels=("Home", "Saved", "My listings", "Profile"), font=FONT, post="Post"):
    names = ["home", "bookmark", "listings", "user"]
    def item(n, lab):
        on = lab == active or n == active
        c = T["accent"] if on else T["muted"]
        fill = T["accent"] if (on and n == "bookmark") else "none"
        cur = 'aria-current="page" ' if on else ""
        return (f'<a href="#" {cur}style="flex: 1; display: flex; flex-direction: column; align-items: center; gap: 3px; color: {c}; text-decoration: none; '
                f'font-size: 11px; font-weight: {800 if on else 600}">{ic(n, 23, fill=fill, sw=2 if on else 1.8)}<span style="white-space: nowrap">{lab}</span></a>')
    center = (f'<a href="#" aria-label="{post}" style="flex: none; width: 74px; display: flex; flex-direction: column; align-items: center; gap: 4px; margin-top: -34px; '
              f'text-decoration: none; color: {T["muted"]}; font-size: 11px; font-weight: 700">'
              f'<span style="width: 60px; height: 60px; border-radius: 999px; background: linear-gradient(145deg, #2F86E8, #0A5FC2); color: #FFFFFF; display: flex; align-items: center; justify-content: center; '
              f'box-shadow: 0 10px 22px rgba(10,95,194,0.45), 0 0 0 5px {T["bg"]}">{ic("plus", 28, sw=2.4)}</span>{post}</a>')
    glass = "rgba(255,255,255,0.94)" if T is LIGHT else "rgba(27,30,36,0.94)"
    fade = (f'<div aria-hidden="true" style="position: absolute; left: 0; right: 0; bottom: 0; height: 130px; background: linear-gradient(180deg, rgba(255,255,255,0) 0%, {T["bg"]} 70%); pointer-events: none"></div>'
            if T is LIGHT else f'<div aria-hidden="true" style="position: absolute; left: 0; right: 0; bottom: 0; height: 130px; background: linear-gradient(180deg, rgba(14,16,20,0) 0%, {T["bg"]} 70%); pointer-events: none"></div>')
    return (fade + f'<nav aria-label="Main" style="position: absolute; left: 14px; right: 14px; bottom: 18px; height: 70px; border-radius: 35px; background: {glass}; '
            f'backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px); border: 1px solid {T["line"]}; box-shadow: 0 14px 34px rgba(17,19,23,0.14); '
            f'display: flex; align-items: center; padding: 0 6px; font-family: {font}">'
            + item(names[0], labels[0]) + item(names[1], labels[1]) + center + item(names[2], labels[2]) + item(names[3], labels[3]) + '</nav>')

# ---------- home ----------
HOME_EN.update(hero="Find your next place", tags=[("#Hydra", "left: 22px; top: 24px", -6), ("#ForRent", "right: 24px; top: 30px", 5),
               ("#Villa", "left: 26px; top: 234px", 4), ("#Oran", "left: 124px; top: 240px", -4), ("#F3", "right: 30px; top: 232px", -6)],
               post_t="List your property", post_s="Sell or rent it out on Findar", bytype="Browse by type",
               types=[("House", "home"), ("Apartment", "apartment"), ("Villa", "villa"), ("Studio", "studio"), ("Office", "building")], post="Post")
HOME_AR.update(hero="اعثر على منزلك القادم", tags=[("#حيدرة", "right: 22px; top: 24px", 6), ("#للإيجار", "left: 24px; top: 30px", -5),
               ("#فيلا", "right: 26px; top: 234px", -4), ("#وهران", "right: 120px; top: 240px", 4), ("#F3", "left: 30px; top: 232px", 6)],
               post_t="انشر عقارك", post_s="للبيع أو للإيجار على Findar", bytype="تصفح حسب النوع",
               types=[("منزل", "home"), ("شقة", "apartment"), ("فيلا", "villa"), ("استوديو", "studio"), ("مكتب", "building")], post="انشر")

def hero_search(s):
    tags = "".join(glass_tag(t, p, r) for t, p, r in s["tags"])
    return (f'<section style="position: relative; height: 290px; border-radius: 28px; overflow: hidden; background: {GRAD}; box-shadow: 0 18px 40px rgba(10,95,194,0.28); color: #FFFFFF">'
            + blue_card_bg() + tags + sparkle("left: 46%; top: 22px", 14, "#FFFFFF", 0.6)
            + f'<h1 style="position: absolute; left: 24px; right: 24px; top: 78px; margin: 0; text-align: center; font-size: 29px; line-height: 1.12; font-weight: 800; letter-spacing: -0.03em">{s["hero"]}</h1>'
            + f'<a href="#" style="position: absolute; left: 18px; right: 18px; top: 164px; height: 56px; border-radius: 999px; background: rgba(255,255,255,0.16); border: 1px solid rgba(255,255,255,0.38); '
              f'backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); display: flex; align-items: center; gap: 10px; padding: 0 6px 0 18px; color: #FFFFFF; text-decoration: none; font-size: 15px; font-weight: 600">'
              f'{ic("search", 20)}<span style="flex: 1; opacity: 0.92">{s["search"]}</span>'
              f'<span aria-label="{s["filters"]}" style="width: 44px; height: 44px; border-radius: 999px; background: #FFFFFF; color: #0A5FC2; display: flex; align-items: center; justify-content: center">{ic("sliders", 20)}</span></a>'
            + '</section>')

def post_banner(s):
    return (f'<a href="#" style="position: relative; overflow: hidden; display: flex; align-items: center; gap: 16px; padding: 18px; border-radius: 24px; text-decoration: none; color: #FFFFFF; '
            f'background: linear-gradient(135deg, #222938 0%, #111317 100%); border: 1px solid rgba(255,255,255,0.06)">'
            + circle("inset-inline-end: -40px; top: -60px", 170, "radial-gradient(circle, rgba(47,134,232,0.55) 0%, rgba(47,134,232,0) 70%)")
            + sparkle("inset-inline-end: 70px; bottom: 16px", 12, "#FFFFFF", 0.5)
            + f'<span style="position: relative; width: 56px; height: 56px; border-radius: 999px; background: #FFFFFF; color: #0A5FC2; display: flex; align-items: center; justify-content: center; flex: none">'
              f'{ic("home", 26, sw=2)}<span style="position: absolute; right: -2px; bottom: -2px; width: 22px; height: 22px; border-radius: 99px; background: #F5B341; color: #111317; display: flex; align-items: center; justify-content: center; border: 2px solid #FFFFFF">{ic("plus", 12, sw=3)}</span></span>'
            + f'<span style="position: relative; flex: 1; display: flex; flex-direction: column; gap: 3px"><span style="font-size: 18px; font-weight: 800">{s["post_t"]}</span>'
              f'<span style="font-size: 13px; font-weight: 600; color: rgba(255,255,255,0.75)">{s["post_s"]}</span></span>'
            + f'<span style="position: relative; display: flex">{ic("chev", 22, sw=2.2)}</span></a>')

def type_card(lab, icon):
    return (f'<a href="#" style="position: relative; overflow: hidden; flex: none; width: 136px; height: 148px; box-sizing: border-box; border-radius: 22px; border: 1px solid {T["line"]}; '
            f'background: {T["bg"]}; padding: 14px; display: flex; flex-direction: column; justify-content: space-between; text-decoration: none; color: {T["ink"]}">'
            + circle("inset-inline-end: -46px; top: -46px", 116, T["accentT"])
            + circle("inset-inline-start: -14px; bottom: 34px", 34, T["accentT"], "opacity: 0.8")
            + sparkle("inset-inline-end: 22px; bottom: 46px", 12)
            + f'<span style="position: relative; width: 52px; height: 52px; border-radius: 999px; background: {T["accentT"]}; box-shadow: inset 0 0 0 1px {T["line"]}; color: {T["accent"]}; display: flex; align-items: center; justify-content: center">{ic(icon, 24, sw=2)}</span>'
            + f'<span style="position: absolute; top: 12px; inset-inline-end: 12px; width: 30px; height: 30px; border-radius: 99px; border: 1px solid {T["line"]}; background: {T["bg"]}; color: {T["accent"]}; display: flex; align-items: center; justify-content: center">{ic("chev", 15, sw=2.2)}</span>'
            + f'<span style="position: relative; font-size: 15px; font-weight: 800">{lab}</span></a>')

def home_body(s, lst, font=FONT):
    head = (f'<div style="display: flex; align-items: center; justify-content: space-between; gap: 12px">'
            f'<div style="display: flex; flex-direction: column; gap: 2px"><span style="font-size: 13px; color: {T["muted"]}; font-weight: 700">{s["hello"]}</span>'
            f'{lockup(22, T["ink"]).replace("#111317", T["ink"])}</div>'
            f'{iconbtn("settings", s["settings"], bg=T["bg"], border=True)}</div>')
    head = head.replace(f'stroke="{T["ink"]}" stroke-width="17"', f'stroke="{T["accent"]}" stroke-width="17"')
    types = (f'<div style="display: flex; gap: 12px; margin: 0 -20px; padding: 2px 20px; overflow: hidden">' + "".join(type_card(l, i) for l, i in s["types"]) + '</div>')
    carousel = (f'<div style="display: flex; gap: 14px; margin: 0 -20px; padding: 0 20px; overflow: hidden">'
                + feature_card(lst[0], saved=True, rent_word=s["month"], labels=s["labels"], badge=s["badge"], cur=s["cur"])
                + feature_card(lst[1], rent_word=s["month"], labels=s["labels"], badge=s["badge"], cur=s["cur"]) + '</div>')
    recent = "".join(row_card(l, rent_word=s["month"], labels=s["labels"], cur=s["cur"]) for l in lst[2:4])
    inner = (soft_top(300) + content(head + hero_search(s) + post_banner(s)
                    + f'<div style="display: flex; flex-direction: column; gap: 14px">{section_head(s["bytype"], None)}{types}</div>'
                    + f'<div style="display: flex; flex-direction: column; gap: 14px">{section_head(s["sponsored"], s["viewall"])}{carousel}</div>'
                    + f'<div style="display: flex; flex-direction: column; gap: 14px">{section_head(s["recent"], None)}{recent}</div>',
                    top=52, gap=22, bottom=120))
    return inner + tabbar(s["tabs"][0], s["tabs"], font, s["post"])

HOME_H = 1560

def s_home():
    return page("Home", phone(home_body(HOME_EN, L), h=HOME_H)), HOME_H

def s_home_dark():
    global T
    T = DARK
    out = page("Home, dark", phone(home_body(HOME_EN, L), h=HOME_H))
    T = LIGHT
    return out, HOME_H

def s_home_ar():
    lst = []
    for l in L[:4]:
        d = dict(l); d.update(AR_LIST[l["id"]]); lst.append(d)
    return page("الرئيسية", phone(home_body(HOME_AR, lst, AR_FONT), h=HOME_H, font=AR_FONT, dirn="rtl"), lang="ar", dirn="rtl", arabic=True), HOME_H

# ---------- splash ----------
def s_splash(dark=False):
    global T
    T = DARK if dark else LIGHT
    tile = (f'<div style="position: relative; width: 116px; height: 116px; border-radius: 32px; background: {GRAD}; display: flex; align-items: center; justify-content: center; '
            f'box-shadow: 0 18px 40px rgba(10,95,194,{0.5 if dark else 0.32}), inset 0 1px 0 rgba(255,255,255,0.25)">{logo(68, "#FFFFFF")}</div>')
    inner = (f'<div aria-hidden="true" style="position: absolute; inset: 0; background: linear-gradient(180deg, {T["accentT"]} 0%, {T["bg"]} 45%, {T["bg"]} 70%, {T["accentT"]} 100%)"></div>'
             + rings("left: -105px; top: 117px", [100, 145, 190, 240], T["accent"], [0.16, 0.11, 0.07, 0.04], 600)
             + circle("right: -80px; top: 60px", 180, T["accent"], "opacity: 0.05") + circle("left: -60px; bottom: 90px", 150, T["accent"], "opacity: 0.05")
             + glass_tile("pin", 46, "left: 52px; top: 250px", -12, light=True) + glass_tile("bookmark", 40, "right: 56px; top: 236px", 10, light=True)
             + glass_tile("key", 42, "right: 70px; top: 560px", -8, light=True) + glass_tile("home", 38, "left: 74px; top: 572px", 8, light=True)
             + sparkle("left: 120px; top: 200px", 14) + sparkle("right: 120px; top: 620px", 12)
             + '<div style="position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 22px; padding-bottom: 20px">'
             + tile + wordmark(40, T["ink"])
             + f'<div style="font-size: 15px; color: {T["muted"]}; font-weight: 600; margin-top: -8px">Your property marketplace</div></div>'
             + f'<div aria-hidden="true" style="position: absolute; left: 50%; bottom: 96px; transform: translateX(-50%); width: 120px; height: 4px; border-radius: 9px; background: {T["line"]}; overflow: hidden">'
             + f'<div style="width: 44px; height: 4px; border-radius: 9px; background: {T["accent"]}"></div></div>')
    out = page("Splash" + (", dark" if dark else ""), phone(inner))
    T = LIGHT
    return out

def s_splash_dark():
    return s_splash(True)

# ---------- auth ----------
def s_login():
    eye = f'<button aria-label="Show password" style="border: none; background: none; color: {T["muted"]}; padding: 0; display: flex">{ic("eye", 20)}</button>'
    art = art_card(150, [("home", 66, "left: 34px; top: 40px", -8), ("pin", 48, "left: 132px; top: 16px", 10), ("bookmark", 44, "left: 206px; top: 84px", -6),
                         ("message", 52, "right: 30px; top: 26px", 8), ("phone", 38, "left: 124px; top: 98px", -12)],
                   [("right: 112px; top: 30px", 14), ("left: 22px; top: 18px", 10), ("right: 54px; bottom: 18px", 18, 0.25)])
    inner = (deco("lg") + topbar("") +
             content(art + f'<div style="display: flex; flex-direction: column; gap: 8px"><h1 style="margin: 0; font-size: 30px; font-weight: 800; letter-spacing: -0.03em">Welcome back</h1>'
                     f'<p style="margin: 0; color: {T["muted"]}; font-size: 15px; font-weight: 500">Log in to save listings and contact owners.</p></div>'
                     + field("Email address", "sara.meziane@gmail.com", icon="mail", ftype="email")
                     + field("Password", "••••••••••", icon="lock", ftype="password", trailing=eye, focused=True)
                     + f'<a href="#" style="align-self: flex-end; font-size: 14px; font-weight: 700; text-decoration: none; margin-top: -10px">Forgot password?</a>'
                     + btn("Log in")
                     + f'<div style="display: flex; align-items: center; gap: 12px; color: {T["muted"]}; font-size: 13px; font-weight: 600"><span style="flex: 1; height: 1px; background: {T["line"]}"></span>or<span style="flex: 1; height: 1px; background: {T["line"]}"></span></div>'
                     + btn("Continue with Google", "secondary", icon="google")
                     + f'<p style="text-align: center; margin: 4px 0 0; font-size: 14px; color: {T["muted"]}; font-weight: 500">Don\'t have an account? <a href="#" style="font-weight: 800; text-decoration: none">Register</a></p>',
                     top=4, gap=18))
    return page("Log in", phone(inner, h=980)), 980

def s_forgot():
    art = art_card(130, [("mail", 64, "left: 40px; top: 34px", -8), ("lock", 46, "left: 140px; top: 18px", 10), ("shield", 50, "right: 40px; top: 40px", 8), ("key", 38, "left: 200px; top: 80px", -10)],
                   [("right: 120px; top: 24px", 12), ("left: 24px; bottom: 16px", 16, 0.25)])
    inner = (deco("fp") + topbar("") +
             content(art + f'<div style="display: flex; flex-direction: column; gap: 8px"><h1 style="margin: 0; font-size: 30px; font-weight: 800; letter-spacing: -0.03em">Reset password</h1>'
                     f'<p style="margin: 0; color: {T["muted"]}; font-size: 15px; font-weight: 500; line-height: 1.5">We\'ll email you a verification code.</p></div>'
                     + field("Email address", "sara.meziane@gmail.com", icon="mail", ftype="email")
                     + f'<div style="display: flex; gap: 10px; align-items: center; padding: 12px 14px; border-radius: 14px; background: {T["greenT"]}; color: {T["green"]}; font-size: 14px; font-weight: 700">{ic("check", 18)}Code sent. Check your inbox.</div>'
                     + field("Verification code", "", "Enter the code", icon="shield", fid="code", focused=True)
                     + btn("Verify code")
                     + f'<p style="margin: 0; text-align: center; font-size: 14px; color: {T["muted"]}; font-weight: 500">Didn\'t get it? <a href="#" style="font-weight: 800; text-decoration: none">Resend code</a></p>',
                     top=4, gap=18))
    return page("Forgot password", phone(inner, h=920)), 920

def s_reset():
    rule = lambda t, ok: (f'<span style="display: flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 700; color: {T["green"] if ok else T["muted"]}">{ic("check" if ok else "minus", 14)}{t}</span>')
    art = art_card(130, [("lock", 64, "left: 40px; top: 34px", -8), ("shield", 48, "left: 146px; top: 18px", 10), ("check", 44, "right: 44px; top: 44px", 8), ("key", 38, "left: 210px; top: 82px", -10)],
                   [("right: 120px; top: 22px", 12), ("left: 22px; bottom: 16px", 16, 0.25)])
    inner = (deco("rp") + topbar("") +
             content(art + f'<div style="display: flex; flex-direction: column; gap: 8px"><h1 style="margin: 0; font-size: 30px; font-weight: 800; letter-spacing: -0.03em">New password</h1>'
                     f'<p style="margin: 0; color: {T["muted"]}; font-size: 15px; font-weight: 500">Choose a password you haven\'t used before.</p></div>'
                     + field("New password", "••••••••••", icon="lock", ftype="password")
                     + f'<div style="display: flex; flex-wrap: wrap; gap: 8px 14px; margin-top: -8px">{rule("8+ characters", True)}{rule("Uppercase", True)}{rule("Lowercase", True)}{rule("Number", True)}</div>'
                     + field("Confirm password", "••••••••••", icon="lock", ftype="password", fid="confirm", focused=True),
                     top=4, gap=18)
             + bottom_bar(btn("Update password")))
    return page("Reset password", phone(inner))

def s_photo_setup():
    av = (f'<div style="align-self: center; position: relative; width: 168px; height: 168px; margin: 40px 0 30px">'
          + rings("left: -66px; top: -66px", [112, 140], T["accent"], [0.18, 0.09], 300)
          + glass_tile("image", 44, "left: -64px; top: 6px", -10, light=True) + glass_tile("camera", 40, "right: -60px; top: 104px", 10, light=True)
          + sparkle("right: -20px; top: -14px", 14) + sparkle("left: -10px; bottom: -20px", 10)
          + f'<div style="position: relative; width: 168px; height: 168px; border-radius: 999px; border: 2px dashed {T["accent"]}; background: linear-gradient(145deg, {T["accentT"]}, {T["bg"]}); display: flex; align-items: center; justify-content: center; color: {T["accent"]}; box-sizing: border-box">{ic("user", 64, sw=1.4)}</div>'
          + f'<span style="position: absolute; right: 6px; bottom: 6px; width: 44px; height: 44px; border-radius: 999px; background: {GRAD}; color: #FFFFFF; display: flex; align-items: center; justify-content: center; border: 3px solid {T["bg"]}">{ic("camera", 20)}</span></div>')
    inner = (deco("ps") + topbar("", right=f'<a href="#" style="font-size: 15px; font-weight: 700; text-decoration: none; padding: 10px 4px">Skip</a>') +
             content(f'<div style="display: flex; flex-direction: column; gap: 8px; text-align: center; align-items: center; margin-top: 16px">'
                     f'<h1 style="margin: 0; font-size: 28px; font-weight: 800; letter-spacing: -0.03em">Add a profile photo</h1>'
                     f'<p style="margin: 0; color: {T["muted"]}; font-size: 15px; font-weight: 500; max-width: 280px; line-height: 1.5">Buyers and owners are more likely to reply when they can see who they\'re talking to.</p></div>'
                     + av + btn("Choose from gallery", icon="image") + btn("Take a photo", "secondary", icon="camera"), top=8, gap=14))
    return page("Profile photo", phone(inner))

# ---------- profile ----------
def wave_header(h, inner):
    return (f'<div style="position: relative; height: {h}px; overflow: hidden; background: linear-gradient(180deg, {T["accentT"]} 0%, {T["bg"]} 100%)">'
            + rings("right: -150px; top: -150px", [90, 130, 170, 210], T["accent"], [0.14, 0.10, 0.07, 0.04], 440)
            + rings("left: -120px; top: 40px", [70, 100], T["accent"], [0.10, 0.06], 220)
            + f'<svg aria-hidden="true" width="390" height="150" viewBox="0 0 390 150" preserveAspectRatio="none" style="position: absolute; left: 0; bottom: 0">'
            f'<path d="M0 46C80 14 150 76 232 50C302 28 350 56 390 38V150H0Z" fill="{T["accent"]}" fill-opacity="0.14"></path>'
            f'<path d="M0 82C70 60 142 108 222 86C292 66 340 96 390 78V150H0Z" fill="{T["accent"]}" fill-opacity="0.28"></path>'
            f'<path d="M0 116C90 96 162 134 252 114C312 101 352 118 390 108V150H0Z" fill="#0A5FC2"></path></svg>'
            + inner + '</div>')

def s_profile():
    head_inner = (f'<div style="position: absolute; left: 20px; right: 20px; top: 52px; display: flex; justify-content: space-between; align-items: center">'
                  f'<h1 style="margin: 0; font-size: 30px; font-weight: 800; letter-spacing: -0.03em">Profile</h1>{iconbtn("settings", "Settings", bg=T["bg"])}</div>'
                  f'<div style="position: absolute; left: 0; right: 0; top: 104px; display: flex; flex-direction: column; align-items: center; gap: 6px">'
                  f'<div style="position: relative; padding: 4px; border-radius: 999px; background: {T["bg"]}; box-shadow: 0 10px 26px rgba(10,95,194,0.20)">{avatar("SM", 100)}'
                  f'<span style="position: absolute; right: 0; bottom: 0; width: 34px; height: 34px; border-radius: 99px; background: {T["btn"]}; color: {T["btnText"]}; border: 3px solid {T["bg"]}; display: flex; align-items: center; justify-content: center">{ic("camera", 16)}</span></div>'
                  f'<div style="margin-top: 6px; font-size: 24px; font-weight: 800; letter-spacing: -0.02em">Sara Meziane</div>'
                  f'<div style="font-size: 14px; color: {T["muted"]}; font-weight: 600">sara.meziane@gmail.com</div>'
                  f'<span style="margin-top: 4px; height: 30px; padding: 0 12px; border-radius: 999px; background: rgba(255,255,255,0.75); border: 1px solid {T["line"]}; backdrop-filter: blur(6px); color: #111317; font-size: 13px; font-weight: 700; display: inline-flex; align-items: center; gap: 6px">{ic("user", 15)}Individual account</span>'
                  f'<a href="#" style="margin-top: 8px; height: 44px; padding: 0 20px; border-radius: 999px; background: #FFFFFF; color: #0A5FC2; box-shadow: 0 8px 20px rgba(4,30,70,0.18); font-size: 15px; font-weight: 800; text-decoration: none; display: inline-flex; align-items: center; gap: 8px">{ic("edit", 17)}Edit profile</a></div>')
    stat = lambda i, v, t: (f'<div style="flex: 1; display: flex; flex-direction: column; align-items: center; gap: 4px"><span style="color: {T["accent"]}; display: flex">{ic(i, 22)}</span>'
                            f'<span style="font-size: 22px; font-weight: 800">{v}</span><span style="font-size: 11px; font-weight: 800; color: {T["muted"]}; letter-spacing: 0.08em; text-transform: uppercase">{t}</span></div>')
    vline = f'<span style="width: 1px; align-self: stretch; margin: 8px 0; background: {T["line"]}"></span>'
    stats_ = (f'<div style="display: flex; padding: 18px 8px; border-radius: 24px; background: {T["bg"]}; border: 1px solid {T["line"]}; box-shadow: 0 8px 24px rgba(17,19,23,0.05)">'
              + stat("listings", "4", "Listings") + vline + stat("eye", "3", "Online") + vline + stat("bookmark", "4", "Saved") + '</div>')
    boost = (f'<div style="position: relative; overflow: hidden; padding: 20px; border-radius: 24px; background: linear-gradient(135deg, #222938 0%, #111317 100%); color: #FFFFFF; display: flex; flex-direction: column; gap: 14px">'
             + circle("right: -50px; top: -70px", 190, "radial-gradient(circle, rgba(245,179,65,0.35) 0%, rgba(245,179,65,0) 70%)") + sparkle("right: 40px; bottom: 26px", 12, "#FFFFFF", 0.5)
             + f'<div style="position: relative; display: flex; gap: 14px; align-items: center"><span style="width: 44px; height: 44px; border-radius: 14px; background: rgba(255,255,255,0.10); border: 1px solid rgba(255,255,255,0.18); display: flex; align-items: center; justify-content: center">{ic("bolt", 22, color="#111317", fill="#F5B341", sw=1.2)}</span>'
               f'<div style="flex: 1"><div style="font-size: 17px; font-weight: 800">Boost a listing</div><div style="font-size: 13px; color: rgba(255,255,255,0.75); font-weight: 600">Show up in Sponsored and higher in search.</div></div></div>'
             + f'<a href="#" style="position: relative; align-self: flex-start; height: 40px; padding: 0 16px; border-radius: 999px; background: #FFFFFF; color: #111317; font-size: 14px; font-weight: 800; text-decoration: none; display: inline-flex; align-items: center; gap: 6px">See plans{ic("chev", 16, sw=2.2)}</a></div>')
    contact = card(menu_row("phone", "0555 12 34 56", "", sub="Phone") + divider() + menu_row("mail", "sara.meziane@gmail.com", "", sub="Email"), pad=12, gap=4)
    mini = lambda l: (f'<article style="display: flex; flex-direction: column; gap: 6px">{photo(l, "100%", 110, 14)}{price(l, 14)}<div style="font-size: 13px; font-weight: 700">{l["title"]}</div></article>')
    inner = (wave_header(400, head_inner)
             + content(stats_ + boost + contact
                       + f'<div style="display: flex; flex-direction: column; gap: 12px">{section_head("My listings", "See all")}'
                         f'<div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px">{mini(L[0])}{mini(L[2])}</div></div>',
                       top=0, gap=18, bottom=120).replace('position: relative; padding: 0px', 'position: relative; margin-top: -10px; padding: 0px')
             + tabbar("Profile"))
    return page("Profile", phone(inner, h=1300)), 1300

def s_user_profile():
    grid = '<div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 18px 14px">' + "".join(
        f'<article style="display: flex; flex-direction: column; gap: 6px"><div style="position: relative">{photo(l, "100%", 130, 16)}<div style="position: absolute; top: 8px; right: 8px">{save_btn(False, 34)}</div></div>'
        f'{price(l, 14)}<div style="font-size: 13px; font-weight: 700">{l["title"]}</div><div style="font-size: 12px; color: {T["muted"]}; font-weight: 600">{l["loc"]}</div></article>'
        for l in [L[0], L[1], L[4], L[5]]) + "</div>"
    head_inner = (f'<div style="position: absolute; left: 16px; top: 50px">{iconbtn("back", "Back")}</div>'
                  f'<div style="position: absolute; left: 0; right: 0; top: 70px; display: flex; flex-direction: column; align-items: center; gap: 8px">'
                  f'<div style="padding: 4px; border-radius: 999px; background: {T["bg"]}; box-shadow: 0 10px 26px rgba(10,95,194,0.20)">{avatar("DB", 88)}</div>'
                  f'<div style="font-size: 22px; font-weight: 800; letter-spacing: -0.02em">Dar El Bahia Immobilier</div>'
                  f'<span style="height: 30px; padding: 0 12px; border-radius: 999px; background: rgba(255,255,255,0.75); border: 1px solid {T["line"]}; color: #0A5FC2; font-size: 13px; font-weight: 800; display: inline-flex; align-items: center; gap: 6px">{ic("building", 15)}Agency</span></div>')
    inner = (wave_header(300, head_inner)
             + content(f'<div style="display: flex; gap: 10px">{btn("Message", "secondary", icon="message", w="50%", h=48)}{btn("Call", icon="phone", w="50%", h=48)}</div>'
                       + f'<div style="display: flex; flex-direction: column; gap: 14px">{section_head("Listings · 4", None)}{grid}</div>', top=16, gap=20))
    return page("Owner profile", phone(inner, h=1000)), 1000

# ---------- boost plans ----------
def s_plans():
    l = L[2]
    mini = (f'<div style="display: flex; gap: 12px; align-items: center; padding: 10px; border-radius: 18px; background: {T["surf"]}">{photo(l, "64px", 64, 12, "flex: none")}'
            f'<div><div style="font-size: 15px; font-weight: 800">{l["title"]}</div><div style="font-size: 13px; color: {T["muted"]}; font-weight: 600">{l["loc"]} · {fmt(l["price"])} DA</div></div></div>')
    icons = {"Basic": "bolt", "Premium": "star", "Agency": "building"}
    def plan(name, feats, sel):
        radio = (f'<span style="width: 24px; height: 24px; border-radius: 99px; flex: none; display: flex; align-items: center; justify-content: center; '
                 + (f'background: {T["accent"]}; color: #FFFFFF">{ic("check", 14, sw=3)}' if sel else f'border: 2px solid {T["line"]}; background: {T["bg"]}">') + '</span>')
        fl = "".join(f'<li style="display: flex; gap: 8px; align-items: center; font-size: 14px; font-weight: 600; color: {T["muted"]}"><span style="color: {T["green"]}; display: flex">{ic("check", 16, sw=2.4)}</span>{f}</li>' for f in feats)
        tag = f'<span style="height: 24px; padding: 0 10px; border-radius: 99px; background: {T["amber"]}; color: #111317; font-size: 11px; font-weight: 800; display: inline-flex; align-items: center">Most chosen</span>' if sel else ""
        tile = (f'<span style="width: 48px; height: 48px; border-radius: 16px; flex: none; display: flex; align-items: center; justify-content: center; '
                + (f'background: {GRAD}; color: #FFFFFF; box-shadow: 0 8px 18px rgba(10,95,194,0.3)' if sel else f'background: {T["accentT"]}; color: {T["accent"]}')
                + f'">{ic(icons[name], 22, sw=2)}</span>')
        return (f'<label style="position: relative; overflow: hidden; display: flex; flex-direction: column; gap: 14px; padding: 18px; border-radius: 24px; border: {"2px solid " + T["accent"] if sel else "1px solid " + T["line"]}; background: {T["accentT"] if sel else T["bg"]}">'
                + circle("right: -50px; top: -60px", 150, T["accent"] if sel else T["accentT"], "opacity: 0.10" if sel else "")
                + sparkle("right: 26px; bottom: 22px", 12)
                + f'<div style="position: relative; display: flex; align-items: center; gap: 12px">{tile}<div style="flex: 1; display: flex; flex-direction: column; gap: 4px"><div style="display: flex; align-items: center; gap: 8px"><span style="font-size: 17px; font-weight: 800">{name}</span>{tag}</div>'
                  f'<span style="font-size: 13px; color: {T["muted"]}; font-weight: 700">[PRICE] DA · [N] days</span></div>{radio}</div>'
                + f'<ul style="position: relative; margin: 0; padding: 0 0 0 60px; list-style: none; display: flex; flex-direction: column; gap: 6px">{fl}</ul></label>')
    inner = (deco("bp", h=220) + topbar("Boost listing") +
             content(f'<p style="margin: 0; font-size: 15px; color: {T["muted"]}; font-weight: 500; line-height: 1.5">Boosted listings appear in Sponsored on the Home screen and higher in search.</p>'
                     + mini + "".join(plan(*p) for p in PLANS), top=4, gap=16, bottom=130)
             + bottom_bar(btn("Continue to payment")))
    return page("Boost plans", phone(inner, h=1020)), 1020

# ---------- layout ----------
PAGES = [
 ("start", "Start & sign in", [("Splash.dc.html", "Splash", s_splash), ("Welcome.dc.html", "Welcome", s_welcome), ("Login.dc.html", "Log in", s_login),
                               ("Register.dc.html", "Register", s_register), ("PhotoSetup.dc.html", "Profile photo", s_photo_setup),
                               ("ForgotPassword.dc.html", "Forgot password", s_forgot), ("ResetPassword.dc.html", "Reset password", s_reset)]),
 ("browse", "Browse & contact", [("Main.dc.html", "Home", s_home), ("Filters.dc.html", "Advanced search", s_filters), ("Results.dc.html", "Search results", s_results),
                                 ("Details.dc.html", "Property details", s_details), ("Report.dc.html", "Report sheet", s_report), ("Saved.dc.html", "Saved", s_saved),
                                 ("OwnerProfile.dc.html", "Owner profile", s_user_profile)]),
 ("sell", "List & boost", [("MyListings.dc.html", "My listings", s_mylistings), ("CreateListing.dc.html", "New / edit listing", s_create),
                           ("BoostPlans.dc.html", "Boost plans", s_plans), ("Checkout.dc.html", "Checkout", s_payment), ("BoostDone.dc.html", "Boost confirmed", s_paid)]),
 ("account", "Account", [("Profile.dc.html", "Profile", s_profile), ("EditProfile.dc.html", "Edit profile", s_edit_profile), ("Settings.dc.html", "Settings", s_settings)]),
 ("system", "System: icon, themes, RTL, states", [("AppIcon.dc.html", "App icon and logo", s_icon), ("SplashDark.dc.html", "Splash, dark", s_splash_dark), ("Foundations.dc.html", "Foundations", s_tokens), ("HomeDark.dc.html", "Home, dark", s_home_dark),
                                                   ("HomeArabic.dc.html", "Home, Arabic (RTL)", s_home_ar), ("States.dc.html", "Shared states", s_states)]),
]

MOTION = {
 "start": [("Splash → Welcome", "The blue tile scales in (0.9 → 1, spring) and the house outline draws, then the inner f (stroke reveal, 450 ms each, 120 ms overlap). Rings ripple outward once; the four floating tiles drift in from 8 px away and then bob slowly (±3 px, 4 s loop). While the session check runs, the bar under the tagline slides back and forth. Then the tile flies into the header logo as a Hero."),
           ("Auth forms", "Field focus: border animates to blue 150 ms. Password rules tick green one by one as they pass (check scales 0.6 → 1, 180 ms). Submit button morphs to a 52 px circle with a progress ring while loading; errors shake the field 3× over 300 ms + haptic.")],
 "browse": [("Card → Details", "Photo is a shared Hero (300 ms, emphasized decelerate). The details sheet slides up 24 px and fades in, 80 ms after the photo lands. Back reverses it."),
            ("Home hero", "Hashtag chips float slowly (±4 px, 5–7 s loops, different phases) and pause while the user scrolls. Tapping one runs that quick search. The glass search pill expands into the search screen as a shared element. Type cards press to 0.97 scale; their chevron nudges 2 px."),
            ("Lists & bookmark", "First load: cards fade + rise 12 px, staggered 40 ms, max 6. Skeletons shimmer (1.2 s). Bookmark: scale 1 → 1.25 → 1 spring + fill + light haptic; snackbar with Undo."),
            ("Filters & sheets", "Segmented thumb slides 220 ms. Chips cross-fade fill 150 ms. Show results label counts up when the result number changes. Report sheet: spring from bottom, scrim fades 200 ms, drag-to-dismiss.")],
 "sell": [("Listing actions", "Overflow menu scales from the dots (0.9 → 1, origin top-right, 160 ms). Make offline: card dims to 60% and slides to the Offline tab counter (count bumps). Delete: card collapses height 220 ms after confirm."),
          ("Boost", "Plan cards: selection ring grows in 180 ms. Success screen: check circle scales in with spring, check stroke draws 400 ms, then a single soft haptic.")],
 "account": [("Tabs & settings", "Floating tab bar. The centre Post button lifts on press (scale 0.94 → 1.04 → 1, spring) and opens New listing as a sheet from the bottom. Tab switch: fade-through 200 ms; the active icon and label turn blue. Dark mode toggle: theme cross-fades 250 ms. Language change rebuilds RTL with a 200 ms fade, no slide (direction flips)."),
             ("Reduced motion", "When the OS asks for reduced motion (MediaQuery.disableAnimations), replace every slide, scale and Hero with a 150 ms cross-fade and drop shimmer.")],
 "system": [("What changes in code", "Theme rebuilt from these tokens in core/theme (light + dark), Manrope + IBM Plex Sans Arabic via google_fonts, one PriceText widget for the DA format, shared ListingCard / FeatureCard / PillButton / Field widgets, flutter_native_splash for the launch screen, flutter_launcher_icons for the icon.")],
}

GAP_X, ROW_TITLE = 80, 300
boards, order, notes, pages = {}, [], {}, []
y = 0
for pid, pname, items in PAGES:
    pages.append({"id": pid, "name": pname})
    x = 0; maxh = 0
    for fname, title, fn in items:
        res = fn()
        html, h = (res if isinstance(res, tuple) else (res, None))
        w = 390
        if fname == "AppIcon.dc.html": w, h = 980, 640
        elif fname == "Foundations.dc.html": w, h = 1240, 900
        h = h or 844
        with open(os.path.join(PROJ, fname), "w", encoding="utf-8") as f:
            f.write(html)
        boards[fname] = {"x": x, "y": 0, "w": w, "h": h, "title": title, "page": pid}
        order.append(fname)
        x += w + GAP_X; maxh = max(maxh, h)
    notes[f"t_{pid}"] = {"x": 0, "y": -300, "text": pname, "kind": "title1", "maxW": x - GAP_X, "page": pid}
    for i, (t, body) in enumerate(MOTION.get(pid, [])):
        notes[f"m_{pid}_{i}"] = {"x": i * 470, "y": maxh + 140, "text": f"Motion · {t}\n\n{body}", "w": 390, "fill": "blue", "page": pid}

order.remove("Main.dc.html"); order.insert(0, "Main.dc.html")
canvas = {"v": 3, "createdOnFiles": {"v": 1, "at": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")}, "title": "Findar app redesign",
          "launch": {"view": "canvas", "page": "browse"}, "pages": pages, "boards": boards, "order": order, "notes": notes, "designSystems": []}
with open(os.path.join(PROJ, "canvas.json"), "w", encoding="utf-8") as f:
    json.dump(canvas, f, ensure_ascii=False, indent=1)
print("\n".join(order))
