#!/usr/bin/env ruby
require 'fileutils'

class Deployer

  class << self

    include FileUtils

    def deploy
      rp = runtime_path
      if rp.nil?
        warn 'Please provide a writable vim runtime path!'
        return
      end
      plg_path = File.join(rp, 'plugin/fdlint')
      rm_rf plg_path
      begin
        cp_r 'plugin/fdlint', plg_path
        puts "Successfully deployed into #{plg_path} ."
      rescue => e
        warn "Deploy into #{plg_path} failed!"
        raise e
      end
    end

    def runtime_path
      [ARGV[0], '~/.vim', '~/.vimruntime', '~/.vim_runtime'].each do |path|
        if path
          rp = File.expand_path path
          return rp if File.exist?(rp) and File.writable?(rp)
        end
      end
      return nil
    end

  end

end

Deployer.deploy
