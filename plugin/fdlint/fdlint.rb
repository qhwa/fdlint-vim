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
      type = XRay::Runner.file_type filename
      source = buffer_content

      clear_hls()
      vim_cmd "highlight link FDLintError SpellBad"

      ok, @results = @checker.send("check_#{type}".intern, source)

      list @results
      show_err_msg

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
      err = error_of_line line
      if err
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
