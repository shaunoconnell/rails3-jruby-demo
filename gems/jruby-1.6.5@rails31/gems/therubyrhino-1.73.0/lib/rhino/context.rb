require 'stringio'

module Rhino

# ==Overview
#  All Javascript must be executed in a context which represents the execution environment in
#  which scripts will run. The environment consists of the standard javascript objects
#  and functions like Object, String, Array, etc... as well as any objects or functions which
#  have been defined in it. e.g.
#
#   Context.open do |cxt|
#     cxt['num'] = 5
#     cxt.eval('num + 5') #=> 10
#   end
#
# == Multiple Contexts.
# The same object may appear in any number of contexts, but only one context may be executing javascript code
# in any given thread. If a new context is opened in a thread in which a context is already opened, the second
# context will "mask" the old context e.g.
#
#   six = 6
#   Context.open do |cxt|
#     cxt['num'] = 5
#     cxt.eval('num') # => 5
#     Context.open do |cxt|
#       cxt['num'] = 10
#       cxt.eval('num') # => 10
#       cxt.eval('++num') # => 11
#     end
#     cxt.eval('num') # => 5
#   end
#
# == Notes
# While there are many similarities between Rhino::Context and Java::org.mozilla.javascript.Context, they are not
# the same thing and should not be confused.

  class Context
    attr_reader :scope

    class << self

      # initalize a new context with a fresh set of standard objects. All operations on the context
      # should be performed in the block that is passed.
      def open(options = {}, &block)
        new(options).open(&block)
      end

      def eval(javascript)
        new.eval(javascript)
      end

    end

    # Create a new javascript environment for executing javascript and ruby code.
    # * <tt>:sealed</tt> - if this is true, then the standard objects such as Object, Function, Array will not be able to be modified
    # * <tt>:with</tt> - use this ruby object as the root scope for all javascript that is evaluated
    # * <tt>:java</tt> - if true, java packages will be accessible from within javascript
    def initialize(options = {}) #:nodoc:
      ContextFactory.new.call do |native|
        @native = native
        @global = NativeObject.new(@native.initStandardObjects(nil, options[:sealed] == true))
        if with = options[:with]
          @scope = To.javascript(with)
          @scope.setParentScope(@global.j)
        else
          @scope = @global
        end
        unless options[:java]
          for package in ["Packages", "java", "javax", "org", "com", "edu", "net"]
            @global.j.delete(package)
          end
        end
      end
    end

    # Read a value from the global scope of this context
    def [](k)
      @scope[k]
    end

    # Set a value in the global scope of this context. This value will be visible to all the
    # javascript that is executed in this context.
    def []=(k, v)
      @scope[k] = v
    end

    # Evaluate a string of javascript in this context:
    # * <tt>source</tt> - the javascript source code to evaluate. This can be either a string or an IO object.
    # * <tt>source_name</tt> - associated name for this source code. Mainly useful for backtraces.
    # * <tt>line_number</tt> - associate this number with the first line of executing source. Mainly useful for backtraces
    def eval(source, source_name = "<eval>", line_number = 1)
      self.open do
        begin
          scope = To.javascript(@scope)
          if IO === source || StringIO === source
            result = @native.evaluateReader(scope, IOReader.new(source), source_name, line_number, nil)
          else
            result = @native.evaluateString(scope, source.to_s, source_name, line_number, nil)
          end
          To.ruby result
        rescue J::RhinoException => e
          raise Rhino::JavascriptError, e
        end
      end
    end

    def evaluate(*args) # :nodoc:
      self.eval(*args)
    end

    # Read the contents of <tt>filename</tt> and evaluate it as javascript. Returns the result of evaluating the
    # javascript. e.g.
    #
    # Context.open do |cxt|
    #   cxt.load("path/to/some/lib.js")
    # end
    #
    def load(filename)
      File.open(filename) do |file|
        evaluate file, filename, 1
      end
    end

    # Set the maximum number of instructions that this context will execute.
    # If this instruction limit is exceeded, then a Rhino::RunawayScriptError
    # will be raised
    def instruction_limit=(limit)
      @native.setInstructionObserverThreshold(limit);
      @native.factory.instruction_limit = limit
    end

    # Set the optimization level that this context will use. This is sometimes necessary
    # in Rhino, if the bytecode size of the compiled javascript exceeds the 64KB limit.
    # By using the -1 optimization level, you tell Rhino to run in interpretative mode,
    # taking a hit to performance but escaping the Java bytecode limit.
    def optimization_level=(level)
      @native.setOptimizationLevel(level)
    end

    # Enter this context for operations. Some methods such as eval() will
    # fail unless this context is open
    def open
      begin
        @native.factory.enterContext(@native)
        yield self
      ensure
        J::Context.exit()
      end if block_given?
    end

  end

  class IOReader < java.io.Reader #:nodoc:

    def initialize(io)
      @io = io
    end

    def read(charbuffer, offset, length)
      begin
        str = @io.read(length)
        if str.nil?
          return -1
        else
          jstring = java.lang.String.new(str)
          for i in 0 .. jstring.length - 1
            charbuffer[i + offset] = jstring.charAt(i)
          end
          return jstring.length
        end
      rescue StandardError => e
        raise java.io.IOException.new, "Failed reading from ruby IO object"
      end
    end
  end

  class ContextFactory < J::ContextFactory # :nodoc:

    def observeInstructionCount(cxt, count)
      raise RunawayScriptError, "script exceeded allowable instruction count" if count > @limit
    end

    def instruction_limit=(count)
      @limit = count
    end
  end

  class ContextError < StandardError # :nodoc:

  end

  class JavascriptError < StandardError # :nodoc:
    def initialize(native)
      @native = native
    end

    def message
      @native.cause.details
    end

    def javascript_backtrace
      @native.getScriptStackTrace()
    end
  end

  JSError = JavascriptError

  class RunawayScriptError < StandardError # :nodoc:
  end
end
