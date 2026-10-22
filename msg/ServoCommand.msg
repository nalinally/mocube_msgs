# KRS サーボへの指令 1 つ分。device_manager が検査して "KRS,..." パケットにする

uint8 FREE=0          # 脱力
uint8 POSITION=1      # 位置指令
int32 ALL_SERVOS=-1   # servo にこれを入れると全サーボ (FREE のときだけ)

int32 module_id       # 送り先モジュールの Module.id
int32 servo           # ICS ID 0..5、または ALL_SERVOS
uint8 mode            # FREE / POSITION
int32 position        # POSITION のときの目標 (3500..11500, 中央 7500)。FREE では無視
