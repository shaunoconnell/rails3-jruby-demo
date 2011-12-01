#--
# Copyright (c) 2010-2011 Engine Yard, Inc.
# Copyright (c) 2007-2009 Sun Microsystems, Inc.
# This source code is available under the MIT license.
# See the file LICENSE.txt for details.
#++

require 'rubygems'
require 'drb'
require 'warbler'

class Warbler::Config
  include DRb::DRbUndumped
end

class Warbler::Jar
  include DRb::DRbUndumped
end

class WarblerDrbServer
  def config(extra_config_proc = nil)
    @config ||= Warbler::Config.new {|c| extra_config_proc.call(c) if extra_config_proc }
  end

  def alive?
    true
  end

  def jar
    @jar ||= Warbler::Jar.new
  end

  def stop
    DRb.stop_service
  end
end

server = WarblerDrbServer.new
service = DRb.start_service 'druby://127.0.0.1:7890', server
service.thread.join

