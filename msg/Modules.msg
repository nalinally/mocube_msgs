# /modules トピック。device_manager が把握している全モジュールの状態
# (オフラインのものも含む。台帳 devices.json に載っている全台)

float64 t            # publish した時刻 (UNIX time [s])
Module[] modules     # 登録順
