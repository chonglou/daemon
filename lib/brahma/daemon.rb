require 'fileutils'
require 'syslog/logger'

module Brahma
  class Daemon
    attr_reader :logger

    def initialize(name, home)
      @name = name
      unless Dir.exist?(home)
        FileUtils.mkdir_p home
      end
      @pid = File.expand_path "#{home}/#{@name}.pid"
      @stop = File.expand_path "#{home}/#{@name}.stop"
      @logger = ::Syslog::Logger.new "brahma-#{name}"
    end

    def run
      return unless block_given?

      if start?
        @logger.error "进程[#{@name}]已存在"
        return
      end
      Process.daemon
      pid = Process.pid
      @logger.info "启动[#{@name}, #{pid}]"
      File.open @pid, 'w', 0600 do |f|
        f.write pid
      end
      $0 = "brahma-#{@name}"
      yield
    end

    def kill
      if start?
        `kill -TERM #{@pid}`
      else
        @logger.error "进程[#{@name}]尚未启动"
      end
    end

    def start
      run do
        loop do
          if stop?
            break
          end
          yield
        end
      end
    end

    def stop?
      if File.exist?(@stop) && File.mtime(@stop) > File.mtime(@pid)
        File.delete @pid
        File.delete @stop
        true
      end
    end

    def start?
      if File.exist?(@pid)
        if Dir.exist?("/proc/#{File.read(@pid).to_i}")
          true
        else
          File.delete @pid
          File.delete @stop if File.exist?(@stop)
        end
      end
    end

    def stop
      unless start?
        @logger.error "进程[#{@name}]尚未启动"
        return
      end
      yield if block_given?
      @logger.info "停止[#{@name}]"
      FileUtils.touch @stop
    end
  end
end