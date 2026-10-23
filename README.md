# mocube_msgs

mocube の UDP ブリッジ ([mocube_bridge](https://github.com/nalinally/mocube_bridge)) が使うメッセージ定義です。
`device_manager` ノードが `/modules` に `Modules` を publish し、`/servo_commands` の `ServoCommands` を購読します。

## 構造

```
Modules
├── float64 t                 publish 時刻 (UNIX time [s])
└── Module[] modules          台帳に載っている全モジュール (offline も含む, 登録順)
    ├── int32 id              PC が払い出した ID (0 始まり)
    ├── string mac            Wi-Fi MAC (大文字)
    ├── string addr           最後にパケットを受けた送信元 IP
    ├── float64 last_seen     最後の HEARTBEAT 時刻 (UNIX time [s])
    ├── bool online           last_seen から timeout (既定 3 秒) 以内
    └── IrReceiver[] receivers  常に 3 要素, 順番は u, r, f
        ├── string face       "u" / "r" / "f"
        ├── int32 address     その面で最後に見えた隣のモジュールの ID
        └── float64 t         その受信時刻 (UNIX time [s])
```

```
ServoCommands                 /servo_commands (device_manager が購読)
└── ServoCommand[] commands   先頭から順にモジュールへ送られる
    ├── int32 module_id       送り先の Module.id
    ├── int32 servo           ICS ID 0..5、または ALL_SERVOS (-1)
    ├── uint8 mode            FREE (0) / POSITION (1)
    └── float64 angle         POSITION のときの角度 [deg] -135..135 (0 が中央)。FREE では無視
                              回転モードのサーボでは速さと向き (0 で停止)
```

`ServoCommand` 1 つが UDP パケット `KRS,...` 1 つになります。`ALL_SERVOS` は `FREE` のときだけ使えます。
範囲外の指令は device_manager が warning を出して捨てます (モジュールには送られません)。

```
ModuleStates                  /module_states (mocube_estimator が publish)
├── float64 t                 publish 時刻 (UNIX time [s])
└── ModuleState[] modules     ID 順
    ├── int32 id              Module.id
    ├── bool localized        位置が決まっているか。false なら以下は無意味
    ├── geometry_msgs/Point position  連続位置 [m] (サーボ指令から積算し、赤外線で補正)
    ├── int32 grid_x/y/z      最後に赤外線か手動設定で確定した格子座標
    └── float64 grid_t        その確定時刻 (UNIX time [s])

srv/SetGridPositions          /set_grid_positions (mocube_estimator のサービス)
├── GridPosition[] positions  指定したモジュールを格子座標に置き直す (id, x, y, z)
└── --- bool success, string message
```

座標の軸は全モジュール共通で、r 面 = +x, f 面 = +y, u 面 = +z、ID0 が原点です
(詳しくは [mocube_estimator](https://github.com/nalinally/mocube_estimator) の README)。

`Vector2` は定義だけで現在は未使用です。

## 値の読み方

- `IrReceiver.face` とファームの受信チャンネルの対応: `u` = ch0 (G8), `r` = ch1 (G38), `f` = ch2 (G39)
- `IrReceiver.address`
  - `-1`: 起動してから一度も受信していない (このとき `t` = 0)
  - `255`: 隣のモジュールがまだ ID を取得していない (ファームの ID -1 が uint8 で送られたもの)
  - それ以外: 隣のモジュールの `Module.id`
- 隣接情報は上書きされるだけで消えません。「今も隣にいるか」は `t` が十分新しいか (ビーコンは 100 ms 周期) で判断してください
- 時刻はすべて PC の `time.time()` (ROS の `Time` 型ではなく float 秒)。sim time とは無関係です

## フィールドを追加するとき

1. `msg/*.msg` を編集 (新しいファイルなら `CMakeLists.txt` の `rosidl_generate_interfaces` にも追加)
2. `mocube_bridge` の `device_registry.Device` に状態を足し、`device_manager.to_modules_msg()` で詰める
3. `colcon build` (msg パッケージ → ブリッジの順に再ビルドされる)

メッセージ定義を変えたら、`/modules` を購読している側も再ビルドが必要です。
