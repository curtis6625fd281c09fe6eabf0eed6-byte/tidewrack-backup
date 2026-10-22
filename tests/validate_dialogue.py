#!/usr/bin/env python3
"""Validate authored dialogue schemas and a route to an ending from every entry.
This is content validation, not a replacement for the Godot runtime tests.
"""
from __future__ import annotations
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ENTRY_POINTS = {
    'keeper_intro.json': {'logbook', 'radio', 'door'},
    'lamp_room.json': {'start', 'wick', 'lens', 'not_ready', 'relight', 'already_lit'},
}


def validate_graph(graph, entries):
    errors, warnings = [], []
    if not isinstance(graph, dict) or not graph:
        return ['graph must be a nonempty object'], []
    edges = {key: set() for key in graph}
    terminals = set()
    for key, node in graph.items():
        if not isinstance(node, dict):
            errors.append(f'{key}: node must be an object')
            continue
        if not isinstance(node.get('text'), str):
            errors.append(f'{key}: text must be a string')
        if 'speaker' in node and not isinstance(node['speaker'], str):
            errors.append(f'{key}: speaker must be a string')
        has_next, has_choices = 'next' in node, 'choices' in node
        if has_next == has_choices:
            errors.append(f'{key}: supply exactly one of next or choices')
        records = [node]
        if has_choices:
            choices = node['choices']
            if not isinstance(choices, list) or not choices:
                errors.append(f'{key}: choices must be a nonempty array')
                choices = []
            for index, choice in enumerate(choices):
                if not isinstance(choice, dict):
                    errors.append(f'{key}: choice {index} must be an object')
                    continue
                if not isinstance(choice.get('text'), str) or 'next' not in choice:
                    errors.append(f'{key}: choice {index} requires text and next')
                records.append(choice)
        for record in records:
            flags = record.get('set_flag', {})
            if not isinstance(flags, dict) or any(not isinstance(k, str) or type(v) is not bool for k, v in flags.items()):
                errors.append(f'{key}: set_flag must map strings to booleans')
            if 'next' not in record:
                continue
            target = record['next']
            if target is None:
                terminals.add(key)
            elif not isinstance(target, str) or target not in graph:
                errors.append(f'{key}: invalid target {target!r}')
            else:
                edges[key].add(target)
    def reachable(start):
        seen, stack = set(), [start]
        while stack:
            key = stack.pop()
            if key in seen:
                continue
            seen.add(key)
            stack.extend(edges.get(key, ()))
        return seen
    seen = set()
    for entry in entries:
        if entry not in graph:
            errors.append(f'missing entry {entry}')
            continue
        visit = reachable(entry)
        seen |= visit
        if not visit & terminals:
            errors.append(f'{entry}: no reachable ending')
    # Also catch a selectable branch entering a loop with no exit.
    for key in sorted(seen):
        if not reachable(key) & terminals:
            errors.append(f'{key}: reachable dead-end loop')
    for key in sorted(set(graph) - seen):
        warnings.append(f'{key}: unreachable from declared entries')
    return errors, warnings


def validate_file(path):
    try:
        data = json.loads(path.read_text(encoding='utf-8'))
    except (OSError, json.JSONDecodeError) as exc:
        return [str(exc)], []
    entries = ENTRY_POINTS.get(path.name)
    if entries is None:
        return ['declare explicit entry points in ENTRY_POINTS'], []
    return validate_graph(data, entries)


def main():
    failures = 0
    files = sorted((ROOT / 'data/dialogue').glob('*.json'))
    if not files:
        print('No dialogue graphs found')
        return 1
    for path in files:
        errors, warnings = validate_file(path)
        failures += len(errors)
        print(f"{'FAIL' if errors else 'OK'} {path.name}")
        for message in errors:
            print(f'  ERROR: {message}')
        for message in warnings:
            print(f'  warning: {message}')
    return int(failures != 0)

if __name__ == '__main__':
    raise SystemExit(main())
