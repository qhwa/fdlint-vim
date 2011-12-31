unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.expand_path(path.to_s, File.dirname(caller[0]))
    end
  end
end

def insp(o)
  case o
    when String, Symbol
      "'#{o.to_s.gsub(/(['"])/, "\\\1")}'"
    when Hash
      parts = []
      o.each { |name, value| parts << "#{insp name}:#{insp value}" }
      "{" << parts.join(",") << "}"
    else
      o.inspect
  end
end


module VIM_FDLint

  require 'find'
  require_relative 'core/lib/runner'

  @checker = XRay::Runner.new

  class << self

    def check_file( file )

      results = []
      if File.directory? file
        Find.find(file) do |f|
          results.concat check_file(f) unless File.directory? f
        end
      elsif @checker.valid_file? file
        f = file.to_s
        results.concat @checker.check_file( f )
      end

      unless results.empty?
        results.each do |r|
          item = {
            :filename     => file.to_s,
            :lnum         => r.row,
            :col          => r.column,
            :type         => r.level,
            :text         => r.message
          }
          VIM::evaluate "setqflist([#{insp item}], 'a')"
        end
      end

      results

    end

    def check
      
      filename = VIM::evaluate "bufname('%')"
      source = buffer_content

      clear_hls()
      vim_cmd "highlight link FDLintError SpellBad"

      @results = @checker.send("check".intern, source, filename)

      unless @results.empty?
        list @results 
        show_err_msg
      end

    end

    private
    def buffer_content
      VIM::evaluate "join(getline(1,'$'), '\n')"
    end

    def log(info)
      VIM::message info
    end
    
    public
    def list(results)
      results.each do |r|
        hl_line(r.row)
      end
    end
    
    def clear_hls
      vim_call "clearmatches"
    end
    
    def hl_line(n)
      vim_call "matchadd", 'FDLintError', "\\v%#{n}l\\S.*(\\S|$)"
    end

    def show_err_msg
      line = $curbuf.line_number
      return if line == @last_line
      @last_line = line
      err = error_of_line line
      if err
        VIM::message err.message
      else
        clear_err_msg
      end
    end
    
    private
    def vim_call(fun, *args)
      cmd =  "call #{fun}(#{args.map(&:inspect).join(",")})"
      vim_cmd cmd
    end
    
    def vim_cmd(str)
      VIM::command str
    end

    def clear_err_msg
      VIM::message ""
    end

    def error_of_line(ln)
      if @results
        @results.any? do |r|
          return r if r.row == ln
        end
      end
    end

  end

end
