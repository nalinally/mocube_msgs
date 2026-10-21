# atom_krs_ros_udp_bridge_msg

mocube の UDP ブリッジ ([atom_krs_ros_udp_bridge](https://github.com/nalinally/atom_krs_ros_udp_bridge)) が使うメッセージ定義です。
`device_manager` ノードが `/modules` に `Modules` を publish します。

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
2. `atom_krs_ros_udp_bridge` の `device_registry.Device` に状態を足し、`device_manager.to_modules_msg()` で詰める
3. `colcon build` (msg パッケージ → ブリッジの順に再ビルドされる)

メッセージ定義を変えたら、`/modules` を購読している側も再ビルドが必要です。
