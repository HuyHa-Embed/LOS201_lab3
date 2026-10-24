import sys, markdown, weasyprint
src, dst = sys.argv[1:3]
html = markdown.markdown(open(src, encoding='utf-8').read(), extensions=['tables', 'fenced_code'])
css = '''@page{size:A4;margin:18mm 15mm}
body{font-family:"DejaVu Sans",sans-serif;font-size:9.5pt;line-height:1.45}
h1{font-size:17pt;border-bottom:2px solid #2E75B6;padding-bottom:4px}
h2{font-size:13pt;color:#1F4E79;margin-top:18px}
table{border-collapse:collapse;width:100%;margin:8px 0;font-size:8.5pt}
th,td{border:1px solid #999;padding:3px 5px;vertical-align:top}th{background:#DCE9F5}
code{font-family:"DejaVu Sans Mono",monospace;font-size:8pt;background:#f1f1f1;word-break:break-all}
pre{background:#f1f1f1;padding:6px;white-space:pre-wrap}pre code{background:none}
img{max-width:100%}'''
weasyprint.HTML(string=f'<html><head><meta charset="utf-8"><style>{css}</style></head><body>{html}</body></html>',
                base_url=src).write_pdf(dst)
