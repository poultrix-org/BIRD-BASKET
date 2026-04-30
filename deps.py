import re

with open('pubspec.yaml', 'r') as f:
    text = f.read()

if 'http:' not in text:
    text = text.replace('dependencies:\n', 'dependencies:\n  http: ^1.2.0\n')
    with open('pubspec.yaml', 'w') as f:
        f.write(text)

