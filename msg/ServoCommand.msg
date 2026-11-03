# KRS サーボへの指令 1 つ分。device_manager が検査して "KRS,..." パケットにする

uint8 FREE=0          # 脱力
uint8 POSITION=1      # 角度指令 (回転モードのサーボでは回転の速さと向き)
int32 ALL_SERVOS=-1   # servo にこれを入れると全サーボ (FREE のときだけ)

int32 module_id       # 送り先モジュールの Module.id
int32 servo           # ICS ID 0..5、または ALL_SERVOS
uint8 mode            # FREE / POSITION
bool watchdog         # POSITION のとき、約 1 秒更新が無ければファームが 0 にする。送り続ける側が使う
float64 angle         # POSITION のときの角度 [deg] -135..135 (0 が中央)。FREE では無視
                      # 回転モードのサーボでは 0 で停止、0 から離れるほど速く回る (符号が向き)
