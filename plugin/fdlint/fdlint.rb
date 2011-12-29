unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.expand_path(path.to_s, File.dirname(caller[0]))
    end
  end
end

module VIM_FDLint

  require_relative 'core/lib/runner'

  @checker = XRay::Runner.new

  class << self

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
    
    public
    def list(results)
      vim_cmd "cexpr ''"
      results.each do |r|
        hl_line(r.row)
        vim_cmd "caddexpr '#{r.row},0,#{r.message}'"
      end
      #vim_cmd "cwindow"
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
      err = error_of_line line
      if err
        @last_line = line
        VIM::message err.message
      else
        clear_err_msg
      end
    end
    
    private
    def vim_call(fun, *args)
      vim_cmd "call #{fun}(#{args.map(&:inspect).join(",")})"
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
