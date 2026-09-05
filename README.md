## 公開

`main` に push して `src/**` に変更があると、[`devcontainers/action`](https://github.com/devcontainers/action) が `src/` 配下の各 Feature を GHCR に公開します。Actions の `workflow_dispatch` から手動実行することもできます。

公開先は `ghcr.io/<owner>/<repo>/<feature-id>` です。

- Feature を更新したら `devcontainer-feature.json` の `version` を上げてください。同じバージョンは再公開されません。
- 初回公開後、GHCR のパッケージを **public** に変更しないと外部から参照できません（GitHub のパッケージ設定 → Change visibility）。


## 新しい Feature を追加する

1. `src/<feature-id>/` を作成する
2. `devcontainer-feature.json` に `id` / `version` / `name` / `options` を定義する
3. `install.sh` を追加する（`root` 権限で実行されます）
4. 上記の「Features 一覧」に行を追加する
