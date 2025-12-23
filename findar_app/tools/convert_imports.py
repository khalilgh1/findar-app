import os
import re
import sys

workspace_root = os.path.dirname(os.path.dirname(__file__))
lib_dir = os.path.join(workspace_root, 'lib')
pubspec = os.path.join(workspace_root, 'pubspec.yaml')

if not os.path.exists(pubspec):
    print('pubspec.yaml not found', file=sys.stderr)
    sys.exit(1)

pkg_name = None
with open(pubspec, 'r', encoding='utf-8') as f:
    for line in f:
        m = re.match(r'^name:\s*(\S+)', line)
        if m:
            pkg_name = m.group(1).strip()
            break

if not pkg_name:
    print('Package name not found in pubspec.yaml', file=sys.stderr)
    sys.exit(1)

print('Package name:', pkg_name)

dart_files = []
for root, dirs, files in os.walk(lib_dir):
    for fn in files:
        if fn.endswith('.dart'):
            dart_files.append(os.path.join(root, fn))

import_re = re.compile(r"^(\s*import\s+)(['\"])([^'\"]+)(['\"];.*)$")

changed_files = []

for path in dart_files:
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    dirpath = os.path.dirname(path)
    new_lines = []
    changed = False

    for ln in lines:
        m = import_re.match(ln)
        if not m:
            new_lines.append(ln)
            continue
        prefix, q1, imp, q2 = m.group(1), m.group(2), m.group(3), m.group(4)
        imp_stripped = imp.strip()
        # Skip package: and dart: imports
        if imp_stripped.startswith('package:') or imp_stripped.startswith('dart:'):
            new_lines.append(ln)
            continue
        # Skip imports that are clearly comments (already commented out)
        if prefix.lstrip().startswith('//'):
            new_lines.append(ln)
            continue

        # Resolve import target path
        resolved = None
        # If absolute windows path or absolute unix path
        if os.path.isabs(imp_stripped):
            candidate = os.path.normpath(imp_stripped)
            if os.path.exists(candidate):
                resolved = candidate
        else:
            candidate = os.path.normpath(os.path.join(dirpath, imp_stripped))
            if os.path.exists(candidate):
                resolved = candidate
            else:
                # Sometimes import may omit ./ and be relative to lib dir
                candidate2 = os.path.normpath(os.path.join(lib_dir, imp_stripped))
                if os.path.exists(candidate2):
                    resolved = candidate2

        if not resolved:
            # Could not resolve file on disk; leave as-is
            new_lines.append(ln)
            continue

        # Confirm resolved is inside lib dir
        lib_dir_norm = os.path.normpath(lib_dir)
        if os.path.commonpath([lib_dir_norm, resolved]) != lib_dir_norm:
            new_lines.append(ln)
            continue

        rel = os.path.relpath(resolved, lib_dir_norm)
        rel = rel.replace('\\', '/')
        new_import = f"{prefix}{q1}package:{pkg_name}/{rel}{q2}\n"
        if new_import != ln:
            new_lines.append(new_import)
            changed = True
        else:
            new_lines.append(ln)

    if changed:
        backup = path + '.bak'
        os.replace(path, backup)
        with open(path, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
        changed_files.append(path)

if changed_files:
    print('Modified files:')
    for p in changed_files:
        print('-', os.path.relpath(p, workspace_root))
else:
    print('No files changed.')
