#!/usr/bin/env python3
"""Apply/remove only the Minimal block, preserving unrelated user CSS."""
import argparse
from pathlib import Path
import os
import re
import shutil
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument('theme')
parser.add_argument('--config-root', type=Path, default=Path.home() / '.config')
args = parser.parse_args()
block = re.compile(r'\n/\* BEGIN OMARCHY MINIMAL \*/\n.*?/\* END OMARCHY MINIMAL \*/\n', re.S)

for version in ('gtk-3.0', 'gtk-4.0'):
    css = args.config_root / version / 'gtk.css'
    before = css.read_bytes().decode('utf-8') if css.exists() else ''
    after = block.sub('', before)
    if args.theme == 'minimal':
        palette = args.config_root / 'omarchy/themes/minimal/gtk' / f'{version}.css'
        after += '\n/* BEGIN OMARCHY MINIMAL */\n' + palette.read_text() + '/* END OMARCHY MINIMAL */\n'
    if after == before:
        continue
    backup = css.with_name('gtk.css.minimal.bak')
    if css.exists() and not block.search(before) and not backup.exists():
        shutil.copy2(css, backup)
    if not after and not backup.exists():
        css.unlink(missing_ok=True)
        continue
    css.parent.mkdir(parents=True, exist_ok=True)
    target = css.resolve()
    fd, name = tempfile.mkstemp(prefix='.minimal-', dir=target.parent)
    try:
        with os.fdopen(fd, 'wb') as output:
            output.write(after.encode('utf-8'))
        if target.exists():
            shutil.copymode(target, name)
        else:
            os.chmod(name, 0o644)
        os.replace(name, target)
    finally:
        Path(name).unlink(missing_ok=True)
