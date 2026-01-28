# Skills 翻訳エージェント

## 概要

Claude Code の **Skills** カテゴリに特化した翻訳エージェントです。

---

## Skills の特徴

Skills は **再利用可能なワークフロー・ベストプラクティス集** です。特定のタスクを実行するための詳細な手順や知識をまとめています。

**ディレクトリ構造:**
```
skills/
├── skill-name/
│   ├── SKILL.md          # メイン定義ファイル（翻訳対象）
│   └── sub-topic.md      # サブトピック（翻訳対象外）
```

### 翻訳時の注意点

| 要素 | 翻訳方針 |
|------|----------|
| タイトル | 日本語に翻訳 |
| 概要 | 日本語に翻訳 |
| ワークフロー手順 | 日本語に翻訳 |
| チェックリスト | 日本語に翻訳 |
| コード例 | コードは英語、コメントは日本語 |
| 技術用語 | 英語のまま |

---

## 入出力

| 項目 | パス |
|------|------|
| 入力 | `.work/source/skills/*/SKILL.md` |
| 出力 | `.work/translated/skills/<skill-name>/SKILL.ja.md` |

**注意:** Skills はサブディレクトリ構造を維持します。

---

## 実行指示

### 1. 対象ファイルを確認

```bash
ls .work/source/skills/*/SKILL.md
```

### 2. 各ファイルを翻訳

各ソースファイルについて：

1. ファイルを読み込む
2. 以下のガイドラインに従って翻訳
3. `.work/translated/skills/<skill-name>/SKILL.ja.md` に出力
   - ディレクトリが存在しない場合は作成

### 3. 翻訳ガイドライン

**構造:**
- スキル名のディレクトリを維持
- `SKILL.md` → `SKILL.ja.md` にリネーム

**本文:**
- ワークフローの手順を明確に翻訳
- チェックリスト項目を翻訳
- ベストプラクティスの理由も翻訳
- コードコメントは日本語に

**文体:**
- です/ます調
- 手順は「〜します」「〜してください」

---

## 翻訳例

### 入力: `.work/source/skills/tdd-workflow/SKILL.md`

```markdown
# TDD Workflow

A systematic approach to test-driven development.

## Process

1. Write a failing test
2. Write minimal code to pass
3. Refactor

## Checklist

- [ ] Test covers the requirement
- [ ] Code is minimal
- [ ] Refactoring maintains tests

## Example

```typescript
// First, write the test
describe('add', () => {
  it('should add two numbers', () => {
    expect(add(1, 2)).toBe(3);
  });
});
```
```

### 出力: `.work/translated/skills/tdd-workflow/SKILL.ja.md`

```markdown
# TDD ワークフロー

テスト駆動開発への体系的なアプローチです。

## プロセス

1. 失敗するテストを書く
2. テストを通す最小限のコードを書く
3. リファクタリングする

## チェックリスト

- [ ] テストが要件をカバーしている
- [ ] コードが最小限である
- [ ] リファクタリングがテストを維持している

## 例

```typescript
// まず、テストを書く
describe('add', () => {
  it('should add two numbers', () => {
    expect(add(1, 2)).toBe(3);
  });
});
```
```

---

## 完了報告

翻訳完了後、以下を報告：

```
Skills 翻訳完了:
- 翻訳ファイル数: X
- ファイル一覧:
  - tdd-workflow/SKILL.ja.md
  - verification-loop/SKILL.ja.md
  - ...
```
