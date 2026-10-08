#!/usr/bin/env python3
"""Export bundled legal documents to static HTML without external dependencies."""
import argparse
import html
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, default=ROOT / 'build/legal-site')
args = parser.parse_args()
args.output.mkdir(parents=True, exist_ok=True)
links = []
for source in sorted((ROOT / 'assets/legal').glob('*.json')):
    data = json.loads(source.read_text())
    locale = data['locale']
    translations = {
        'en': ('Terms of Use', 'Privacy Policy', 'Updated'),
        'pt': ('Termos de Uso', 'Política de Privacidade', 'Atualizado'),
        'es': ('Términos de Uso', 'Política de Privacidad', 'Actualizado'),
    }[locale.split('-')[0]]
    for kind, title in zip(('terms', 'privacy'), translations[:2]):
        filename = f'{kind}-{locale}.html'
        sections = ''.join(
            f"<section><h2>{html.escape(section['title'])}</h2><p>{html.escape(section['body'])}</p></section>"
            for section in data[kind]['sections']
        )
        page = f'''<!doctype html>
<html lang="{html.escape(locale)}"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Capidock — {html.escape(title)}</title>
<style>body{{margin:0;background:#100f16;color:#efecf7;font:1rem/1.7 system-ui,sans-serif}}main{{max-width:760px;margin:auto;padding:32px 24px}}h1,h2{{line-height:1.3}}h2{{font-size:1.25rem;margin-top:32px}}a{{color:#c3a5ff}}small{{color:#b7adc7}}p{{overflow-wrap:anywhere}}</style>
</head><body><main><nav><a href="index.html">Capidock</a></nav>
<h1>{html.escape(title)}</h1><small>{translations[2]}: {html.escape(data['date'])} · {html.escape(data['revision'])}</small>
{sections}</main></body></html>'''
        (args.output / filename).write_text(page)
        links.append(f'<li><a href="{filename}">{html.escape(locale)} — {html.escape(title)}</a></li>')
index = '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Capidock — Legal documents</title></head><body><h1>Capidock — Legal documents</h1><ul>' + ''.join(links) + '</ul></body></html>'
(args.output / 'index.html').write_text(index)
print(f'Exported 10 legal documents and an index to {args.output}')
