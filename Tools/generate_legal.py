#!/usr/bin/env python3
"""
Single source of truth for Pitchsong's legal / info text.

Run from the project root:   python3 Tools/generate_legal.py

It writes:
  Pitchsong/Models/LegalContent.swift   (used by the in-app screens)
  Website/privacy.html, terms.html, about.html, support.html   (upload these to your website)

Edit the text below, run the script again, and both the app and the web pages stay identical.
"""
import html
import json
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

UPDATED = "November 22, 2026"
COMPANY = "Blunt Entertainment"
EMAIL = "bluntentertainment1@gmail.com"
WHATSAPP = "+234 708 793 4907"
INSTAGRAM = "@bluntt_kidd"

CONTACT_LINES = [
    f"Company: {COMPANY}, Nigeria",
    f"Email: {EMAIL}",
    f"WhatsApp: {WHATSAPP}",
    f"Instagram: {INSTAGRAM}",
]

# Each section: (heading, [paragraphs], [bullets])
PRIVACY = [
    ("Who we are",
     [f"Pitchsong is a music promotion app operated by {COMPANY} (“we”, “us”). This policy explains what the app does with your information. If you have questions, email {EMAIL}."],
     []),
    ("The short version",
     [],
     ["No account, no sign-in and no ads.",
      "No analytics, no tracking and no third-party SDKs in the app.",
      "We run no server for this app. The details you type into the order form stay on your device unless you choose to send them to us.",
      "We never sell your personal information."]),
    ("Information you enter in the app",
     ["In the order form you can enter your artist name, a song title, a link to your song and a genre. The app saves these in your device’s local storage so they appear in My Requests. They are not uploaded to us automatically. You can delete any request inside the app, and deleting the app removes everything it stored."],
     []),
    ("Information you send us",
     ["If you tap Send on WhatsApp, the app opens WhatsApp with a message that contains the details above and the package you chose. Nothing is sent until you press send in WhatsApp. WhatsApp is run by Meta and handles messages under its own terms and privacy policy. If you email us, your email provider handles the message in the same way."] ,
     []),
    ("Content loaded from the internet",
     ["The Home screen shows an example screenshot hosted on an image service (postimg.cc). Like any web image, loading it lets that host see your IP address and basic device details. The app does not send any other data."],
     []),
    ("Payments",
     ["The app does not take payments and never asks for card or bank details. Prices and payment are agreed directly with us on WhatsApp, outside the app."],
     []),
    ("How we use information you send us",
     ["We use the information you choose to send us to:"],
     ["reply to you and agree prices and details;",
      "deliver the promotion you ordered, which includes sharing your song link and basic details with playlist curators, creators, music blogs and platforms;",
      "give support, keep business records and meet legal duties."]),
    ("Sharing",
     ["We share your song details only as needed to carry out the campaign you ordered, and with service providers such as WhatsApp and email as described above. We do not sell your personal information or share it for advertising."],
     []),
    ("How long we keep it",
     ["Messages and form submissions are kept for as long as needed to run your campaign, answer questions and keep business records, then deleted or anonymised. Information saved in the app stays on your device until you delete it."],
     []),
    ("Your choices and rights",
     [f"You can ask us to access, correct or delete the information you sent us by emailing {EMAIL}. Depending on where you live (for example under the Nigeria Data Protection Act 2023, the GDPR or California law) you may have extra rights, and we will respond as the law requires."],
     []),
    ("Children",
     ["Pitchsong is made for artists and is not directed at children under 13. We do not knowingly collect information from children. If you believe a child has sent us information, email us and we will delete it."],
     []),
    ("Security",
     ["We take reasonable steps to protect the information we receive. No method of storage or transmission is completely secure."],
     []),
    ("Changes to this policy",
     ["We may update this policy. The date at the top shows the latest version."],
     []),
    ("Contact us", ["Questions or requests about privacy:"], CONTACT_LINES),
]

TERMS = [
    ("About these terms",
     [f"These terms cover your use of the Pitchsong app by {COMPANY}. The app itself is licensed to you under Apple’s standard Licensed Application End User License Agreement. By using the app you agree to these terms."],
     []),
    ("What we do",
     ["We offer music promotion packages: pitching songs to playlist curators, working with creators on TikTok and Instagram, and arranging features on music blogs and websites. The app is a way to choose a package and contact us."],
     []),
    ("No guarantees",
     [],
     ["Playlist curators, creators and blogs decide for themselves whether to add or feature a song. We cannot and do not guarantee placements, streams, followers or any other result.",
      "Numbers marked as estimates (for example “est. 10,000 streams”) are estimates only.",
      "We do not buy placements, pay curators to add songs, or sell fake streams, followers or views, and we will not accept orders that ask for them."]),
    ("Ordering and payment",
     ["Choosing a package in the app does not create a paid order. Prices, payment methods, timelines and any refund terms are agreed with us in writing on WhatsApp. Payment is made outside the app, directly to " + COMPANY + ". Apple is not involved in those payments."],
     []),
    ("Your music and content",
     ["You confirm that you own or control the rights to the music you submit and that it does not infringe anyone else’s rights or break the law. You keep all rights to your music. You allow us to share your song link and basic details with curators, creators and websites as needed to deliver your campaign."],
     []),
    ("Acceptable use",
     ["You agree not to:"],
     ["submit unlawful, infringing, hateful or abusive content;",
      "ask us for fake streams, followers, views or paid placements;",
      "misuse the app or try to disrupt it."]),
    ("Other companies",
     ["Spotify, TikTok, Instagram, WhatsApp and Apple are separate companies. Pitchsong is not affiliated with, endorsed by or sponsored by them. Their names are used only to describe the services our promotion relates to."],
     []),
    ("Limits of liability",
     ["To the extent the law allows, the app and our services are provided “as is”. We are not liable for indirect or consequential losses or for decisions made by third parties such as curators, creators and blogs. Nothing here limits rights you have by law that cannot be limited."],
     []),
    ("Apple",
     ["These terms are between you and " + COMPANY + ", not Apple. Apple has no duty to provide support or maintenance for the app and is not responsible for claims about it."],
     []),
    ("Changes and governing law",
     ["We may update these terms. The date at the top shows the latest version. These terms are governed by the laws of the Federal Republic of Nigeria, without limiting any consumer rights you have where you live."],
     []),
    ("Contact us", ["Questions about these terms:"], CONTACT_LINES),
]

ABOUT = [
    ("Who we are",
     [f"Pitchsong is the app from {COMPANY}, a music promotion and artist marketing company based in Nigeria and expanding to Africa and Europe. We help independent artists put their music in front of new listeners."],
     []),
    ("What we offer",
     [],
     ["Spotify playlist promotion: pitching your song to playlist curators.",
      "TikTok music marketing: creators using your sound.",
      "Instagram music campaigns: Reels and posts that use your sound.",
      "Blog and press campaigns: features on music and entertainment websites.",
      "Full combo packages that bring these together."]),
    ("How we work",
     ["You choose a package and message us on WhatsApp. We confirm the price and details with you, then run your campaign. Setup typically takes 24 to 72 hours after confirmation."],
     []),
    ("Our approach",
     ["We keep it honest. Curators, creators and blogs always make their own choice. We do not buy placements, and we do not sell fake streams, followers or views."],
     []),
    ("Get in touch", [], CONTACT_LINES),
]

SUPPORT = [
    ("Talk to us",
     ["We are happy to help with orders, pricing and anything about the app."],
     CONTACT_LINES),
    ("Orders and pricing",
     ["Message us on WhatsApp for prices, payment details and campaign timelines. Payment is arranged there, never inside the app."],
     []),
    ("Support and privacy requests",
     [f"Email {EMAIL} for app problems, data requests or anything else. If it is about an order, please include your artist name and song title."],
     []),
]

DOCS = {
    "privacy": ("Privacy Policy", PRIVACY, True),
    "terms": ("Terms of Use", TERMS, True),
    "about": ("About Us", ABOUT, False),
    "support": ("Contact Us", SUPPORT, False),
}


# ------------------------------------------------------------------ Swift
def sw(s):
    return json.dumps(s, ensure_ascii=False)


def swift_sections(name, sections):
    out = [f"    static let {name}: [LegalSection] = ["]
    for h, paras, bullets in sections:
        out.append("        LegalSection(")
        out.append(f"            heading: {sw(h)},")
        out.append("            paragraphs: [" + ", ".join(sw(p) for p in paras) + "],")
        out.append("            bullets: [" + ", ".join(sw(b) for b in bullets) + "]")
        out.append("        ),")
    out.append("    ]")
    return "\n".join(out)


def write_swift():
    parts = [
        "// GENERATED by Tools/generate_legal.py. Do not edit by hand; edit the script and run it again.",
        "import Foundation",
        "",
        "struct LegalSection {",
        "    let heading: String",
        "    let paragraphs: [String]",
        "    let bullets: [String]",
        "}",
        "",
        "enum LegalContent {",
        f"    static let updated = {sw(UPDATED)}",
        "",
        swift_sections("privacy", PRIVACY),
        "",
        swift_sections("terms", TERMS),
        "",
        swift_sections("about", ABOUT),
        "",
        swift_sections("support", SUPPORT),
        "}",
        "",
    ]
    path = os.path.join(ROOT, "Pitchsong", "Models", "LegalContent.swift")
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(parts))
    print("wrote", os.path.relpath(path, ROOT))


# ------------------------------------------------------------------- HTML
CSS = """
:root{--bg:#0c0713;--surface:#1a1029;--line:rgba(167,139,250,.25);--text:#f4eefc;--muted:#a89ac6;--magenta:#ff3d8a;--amber:#ffb224}
*{box-sizing:border-box}
body{margin:0;background:radial-gradient(900px 500px at 10% -10%,rgba(255,61,138,.22),transparent),radial-gradient(900px 600px at 100% 100%,rgba(139,92,246,.25),transparent),var(--bg);color:var(--text);font:16px/1.65 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;min-height:100vh}
main{max-width:760px;margin:0 auto;padding:32px 18px 64px}
nav{display:flex;flex-wrap:wrap;gap:8px 18px;margin-bottom:28px;font-size:14px}
nav a{color:var(--muted);text-decoration:none}nav a:hover,nav a.on{color:var(--text)}
.brand{font-weight:900;letter-spacing:.08em;margin-bottom:6px}.brand b{color:#ff7a3d}
h1{font-size:34px;line-height:1.15;margin:.2em 0 .1em}
.date{color:var(--muted);font-size:14px;margin-bottom:24px}
h2{font-size:19px;margin:30px 0 8px;color:var(--amber)}
p,li{color:#d9cfee}a{color:#7fd8ff}
ul{padding-left:20px}li{margin:6px 0}
footer{margin-top:44px;padding-top:18px;border-top:1px solid var(--line);color:var(--muted);font-size:13px}
"""


def linkify(escaped):
    escaped = re.sub(r"([\w.+-]+@[\w-]+\.[\w.]+)", r'<a href="mailto:\1">\1</a>', escaped)
    return escaped


def page(slug, title, sections, dated):
    nav = " ".join(
        f'<a class="{"on" if s == slug else ""}" href="{s}.html">{DOCS[s][0]}</a>' for s in DOCS
    )
    body = []
    for h, paras, bullets in sections:
        body.append(f"<h2>{html.escape(h)}</h2>")
        for p in paras:
            body.append(f"<p>{linkify(html.escape(p))}</p>")
        if bullets:
            body.append("<ul>" + "".join(f"<li>{linkify(html.escape(b))}</li>" for b in bullets) + "</ul>")
    date = f'<div class="date">Last updated: {UPDATED}</div>' if dated else ""
    return f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title} · Pitchsong by {COMPANY}</title>
<meta name="description" content="{title} for the Pitchsong app by {COMPANY}.">
<style>{CSS}</style></head>
<body><main>
<div class="brand">PITCH<b>SONG</b></div>
<nav>{nav}</nav>
<h1>{title}</h1>
{date}
{''.join(body)}
<footer>© 2026 {COMPANY}. Pitchsong is not affiliated with, endorsed by or sponsored by Spotify, TikTok, Instagram, WhatsApp or Apple.</footer>
</main></body></html>
"""


def write_html():
    outdir = os.path.join(ROOT, "Website")
    os.makedirs(outdir, exist_ok=True)
    for slug, (title, sections, dated) in DOCS.items():
        path = os.path.join(outdir, f"{slug}.html")
        with open(path, "w", encoding="utf-8") as f:
            f.write(page(slug, title, sections, dated))
        print("wrote", os.path.relpath(path, ROOT))


if __name__ == "__main__":
    write_swift()
    write_html()
