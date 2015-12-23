# Delphi Application

* 内存泄漏检查 -> 播放列表UserData/数据传输过程中Json对象/网络请求Stream对象
    1. TVideoTransferProcessor.onGet -> Line 39 to 41 -> objJson
    2. TPlayerListProcessor.onGet -> Line 44 to 54 -> New Object
    3. ??? -> TPasLibVlcMedia
* 播放列表完善
* 播放列表与Web对接
* 播放状态中网络异常造成本地转换组建挂起，进而影响vlc播放列表挂起
* 长视频可能靠后的分段出现405或请求失败现象（需要重新计算播放地址）
* 分段视频（6分钟），播放错序。应修改为每段视频单独解析，与上一条一起调整

# Web Pages

* 播放列表与Application对接
* 播放列表标题显示异常
* 电视直播地址添加（计划）
