#!/usr/bin/env python3
"""Generate Capidock's API catalogue from a pinned upstream Coolify OpenAPI JSON.

Usage: python3 tool/generate_coolify_catalog.py /path/to/openapi.json COMMIT_SHA
Fetch the document from https://raw.githubusercontent.com/coollabsio/coolify/<SHA>/openapi.json.
"""
import json
import sys
from pathlib import Path


def generate(spec, commit):
    def resolve(value, seen=()):
        if isinstance(value, list):
            return [resolve(v, seen) for v in value]
        if not isinstance(value, dict):
            return value
        if '$ref' in value:
            ref = value['$ref']
            if ref in seen:
                return {'type': 'object'}
            node = spec
            for part in ref.removeprefix('#/').split('/'):
                node = node[part]
            return resolve(node, (*seen, ref))
        return {k: resolve(v, seen) for k, v in value.items()}
    operations = []
    for path, methods in spec['paths'].items():
        for method, source in methods.items():
            if method not in ('get', 'post', 'put', 'patch', 'delete'):
                continue
            body = source.get('requestBody', {})
            content = body.get('content', {}).get('application/json', {})
            operations.append({
                'id': source['operationId'], 'method': method.upper(), 'path': path,
                'group': source.get('tags', ['Settings'])[0],
                'title': source.get('summary', source['operationId']),
                'description': source.get('description', ''),
                'parameters': resolve(methods.get('parameters', []) + source.get('parameters', [])),
                'body': resolve(content.get('schema', {})),
                'bodyRequired': body.get('required', False),
                'upload': path.endswith('/imports/uploads'),
            })
    # Upstream annotations omit the multipart contract. Verified in
    # app/Http/Controllers/Api/Concerns/HandlesDatabaseImportsApi.php at this SHA.
    for op in operations:
        if op['upload']:
            op['body'] = {'type': 'object', 'required': ['upload_id'], 'properties': {
                'upload_id': {'type': 'string', 'format': 'uuid', 'description': 'UUID for this upload. Use it as upload_id when importing.'},
            }}
            op['bodyRequired'] = True
    return {'source': f'https://github.com/coollabsio/coolify/blob/{commit}/openapi.json',
            'commit': commit, 'operations': operations}


if __name__ == '__main__':
    output = generate(json.loads(Path(sys.argv[1]).read_text()), sys.argv[2])
    Path('assets/coolify/operations.json').write_text(json.dumps(output, ensure_ascii=False, indent=2)+'\n')
    print(f"Generated {len(output['operations'])} operations")
