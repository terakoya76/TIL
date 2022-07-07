# npm publish

## User Package
tsconfig.json
```json
{
  "compilerOptions": {
    "target": "es6",
    "module": "commonjs",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "esModuleInterop": true,
    "noImplicitAny": true,
    "outDir": "./build",
    "rootDir": ".",
    "strict": true,
    "forceConsistentCasingInFileNames": true
  },
  "extends": "./node_modules/gts/tsconfig-google.json",
  "include": [
    "src/**/*.ts"
  ],
  "exclude": [
    ".git",
    "node_modules"
  ]
}
  ```

package.json
```json
(snip)
  "name": "hoge",
  "version": "0.0.1",
  "bin": {
    "ts-example": "./bin/index.js"
  },
(snip)
```

include `src/index.ts` build output from `bin/index.js` when binary.
```javascript
#!/usr/bin/env node
require('../build/src/index.js');
```

release from gh-action.
```yaml
name: release
on:
  push:
    branches:
      - main
    tags:
      - "v[0-9]+.[0-9]+.[0-9]+"

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: haya14busa/action-bumpr@v1
        id: bumpr
        if: "!startsWith(github.ref, 'refs/tags/')"

      # Get tag name.
      - uses: haya14busa/action-cond@v1
        id: tag
        with:
          cond: "${{ startsWith(github.ref, 'refs/tags/') }}"
          if_true: ${{ github.ref }}
          if_false: ${{ steps.bumpr.outputs.next_version }}

      - name: Create release
        id: create_release
        uses: actions/create-release@v1.0.0
        with:
          tag_name: ${{ steps.tag.outputs.value }}
          release_name: Release ${{ steps.tag.outputs.value }}
          draft: false
          prerelease: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - uses: actions/setup-node@v3
        if: "steps.tag.outputs.value != ''"
        with:
          node-version: "18.x"

      - name: download dependencies
        run: npm ci

      # access: public for organization puckage.
      - uses: JS-DevTools/npm-publish@v1
        with:
          token: ${{ secrets.NPM_TOKEN }}
```

## Organization Package

package.json
```json
(snip)
  "name": "my-org/hoge",
  "version": "0.0.1",
  "bin": {
    "ts-example": "./bin/index.js"
  },
(snip)
```

release from gh-action with access property.
```yaml
name: release
on:
  push:
    branches:
      - main
    tags:
      - "v[0-9]+.[0-9]+.[0-9]+"

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: haya14busa/action-bumpr@v1
        id: bumpr
        if: "!startsWith(github.ref, 'refs/tags/')"

      # Get tag name.
      - uses: haya14busa/action-cond@v1
        id: tag
        with:
          cond: "${{ startsWith(github.ref, 'refs/tags/') }}"
          if_true: ${{ github.ref }}
          if_false: ${{ steps.bumpr.outputs.next_version }}

      - name: Create release
        id: create_release
        uses: actions/create-release@v1.0.0
        with:
          tag_name: ${{ steps.tag.outputs.value }}
          release_name: Release ${{ steps.tag.outputs.value }}
          draft: false
          prerelease: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - uses: actions/setup-node@v3
        if: "steps.tag.outputs.value != ''"
        with:
          node-version: "18.x"

      - name: download dependencies
        run: npm ci

      # access: public for organization puckage.
      - uses: JS-DevTools/npm-publish@v1
        with:
          access: "public"
          token: ${{ secrets.NPM_TOKEN }}
```
