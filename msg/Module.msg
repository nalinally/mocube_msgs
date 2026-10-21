# 1 モジュール (AtomS3) 分の状態

int32 id             # device_manager が払い出した ID (0 始まり)
string mac           # Wi-Fi MAC アドレス (大文字, "DC:54:75:CB:BF:2C")
string addr          # 最後にパケットを受けた送信元 IP
float64 last_seen    # 最後に HEARTBEAT を受けた時刻 (UNIX time [s])
bool online          # last_seen から timeout 秒以内なら true
IrReceiver[] receivers  # 赤外線受信器ごとの隣接情報 (u, r, f の順)
