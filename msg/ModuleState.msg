# 1 モジュール分の推定位置 (mocube_estimator が出す)
# 軸は全モジュール共通: r 面 = +x, f 面 = +y, u 面 = +z。ID0 を原点に固定

int32 id                     # Module.id
bool localized               # 位置が決まっているか (赤外線か手動設定で一度でも置かれたら true)
                             # false のとき以下の値は意味を持たない
geometry_msgs/Point position # モジュール中心の連続位置 [m]。サーボ指令から積算し、赤外線で補正
int32 grid_x                 # 最後に赤外線 (または手動設定) で確定した格子座標
int32 grid_y
int32 grid_z
float64 grid_t               # grid_* を確定した時刻 (UNIX time [s])
