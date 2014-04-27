BRAHMA-DAEMON 守护进程模板
======================

## 启动
    Brahma::Daemon.new(PID_NAME, PID_PATH).start do
        #TODO
    end

## 停止
    Brahma::Daemon.new(PID_NAME, PID_PATH).stop

## 状态
    Brahma::Daemon.new(PID_NAME, PID_PATH).start?
    Brahma::Daemon.new(PID_NAME, PID_PATH).stop?

